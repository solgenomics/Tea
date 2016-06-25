package Tea::Controller::Expression_viewer_functions;

use Moose;
use strict;
use warnings;
use DBIx::Class;
use Tea::Schema;
use DBI;
use Data::Dumper;


=head2 get_ids_from_query

Query postgres database to extract ids from a table using a rs obj 
for a given column name to match and a given column name (column id) to return

ARGS: schema, table name, query (rs obj), column name, column id
Returns: sorted array of ids matching for the query

=cut

sub get_ids_from_query {
  my $self = shift;
  my $schema = shift;
  my $table_name = shift;
  my $query = shift;
  my $column_name = shift;
  my $column_id = shift;
  
  my %res_ids;
  
  my $all_rs = $schema->resultset($table_name);
  while(my $n = $all_rs->next) {
  
    foreach my $sps (@{$query}) {
      $sps =~ s/_/ /g;
      # print STDERR "Sps: $sps\n";
      
      if ($n->$column_name eq $sps) {
        $res_ids{$n->$column_id} = 1;
        # print STDERR "------------- Sps: $sps\n";
        
      }
    }
  }
  my @res_ids;
  if ($column_id =~ /id/) {
    @res_ids = sort {$a <=> $b} keys %res_ids;
  } else {
    @res_ids = sort keys %res_ids;
  }
  
  return \@res_ids;
}

=head2 get_layer_options

get all organ, stage and tissue names from input page, get their experiment and layer ids
check all the parents and return selected feature together with their parents

ARGS: schema, all_experiments_rs, organims_selected, stages_selected, tissues_selected
Returns: selected_experiments_rs

=cut

sub get_layer_options {
  my $self = shift;
  my $schema = shift;
  my $exp_rs = shift;
  my $org_names = shift;
  my $stage_names = shift;
  my $tissue_names = shift;
  
  my %project_layer_ids;
  # save all layer ids from the selected project.
  while(my $exp_obj = $exp_rs->next) {
    my $exp_layer_rs = $schema->resultset('ExperimentLayer')->search({experiment_id => $exp_obj->experiment_id});

    while(my $exp_layer_obj = $exp_layer_rs->next) {
      $project_layer_ids{$exp_layer_obj->layer_id} = 1;
    }
  }
  
  # save all names together
  my @all_names;
  push(@all_names,@$org_names);
  push(@all_names,@$stage_names);
  push(@all_names,@$tissue_names);
  
  my %layer_ids_found;
  
  # get the parent layer_ids from the names
  foreach my $name (@all_names) {
    $name =~ s/_/ /g;
    my $layer_info_rs = $schema->resultset('LayerInfo')->search({name => $name});

    while (my $layer_info_obj = $layer_info_rs->next) {
      my $layer_rs = $schema->resultset('Layer')->search({layer_info_id => $layer_info_obj->layer_info_id});
    
      while (my $layer_obj = $layer_rs->next) {
        if ($project_layer_ids{$layer_obj->parent_id}) {
          $layer_ids_found{$layer_obj->parent_id} = 1;
        }
      }
    }
  }
  
  # get the experiment resultsets from the layers
  my @layer_ids = keys %layer_ids_found;
  my %exp_ids;
  my $exp_layer_rs = $schema->resultset('ExperimentLayer')->search({layer_id => \@layer_ids});

  while (my $exp_layer_obj = $exp_layer_rs->next) {
    $exp_ids{$exp_layer_obj->experiment_id} = 1;
    # print STDERR "exp id: ".$exp_layer_obj->experiment_id."\n";
  }
  
  my @experiment_ids = keys %exp_ids;
  my $filtered_exp_rs = $schema->resultset('Experiment')->search({experiment_id => \@experiment_ids});
  
  return $filtered_exp_rs;
}


=head2 get_input_options

get experiment_rs objs and save them in
organ, stage and tissue hashes with name as key and rs_obj as value

ARGS: schema, experiments_rs
Returns: organ, stage and tissue hashes

=cut

sub get_input_options {
  my $self = shift;
  my $schema = shift;
  my $all_exp_rs = shift;
  
  my %organs;
  my %stages;
  my %tissues;
  my $organ_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "organ"})->single;
  my $stage_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "stage"})->single;
  my $tissue_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "tissue"})->single;
  
  while (my $n = $all_exp_rs->next) {
    
    my $exp_layer_rs = $schema->resultset('ExperimentLayer')->search({experiment_id => $n->experiment_id});
    
    while(my $m = $exp_layer_rs->next) {
      my $layer_rs = $schema->resultset('Layer')->search({layer_id => $m->layer_id})->single;
      my $layer_info_rs = $schema->resultset('LayerInfo')->search({layer_info_id => $layer_rs->layer_info_id})->single;
      
      if ($layer_rs->layer_type_id == $organ_layer_type_rs->layer_type_id){
        $organs{$layer_info_rs->name} = 1;
      }
      if ($layer_rs->layer_type_id == $stage_layer_type_rs->layer_type_id){
        # $stages{$layer_info_rs->name} = 1;
        $stages{$layer_info_rs->name} = $layer_rs->ordinal
      }
      if ($layer_rs->layer_type_id == $tissue_layer_type_rs->layer_type_id){
        # $tissues{$layer_info_rs->name} = 1;
        $tissues{$layer_info_rs->name} = $layer_rs->ordinal
      }
    }
  }
  my @organs = sort keys %organs;
  my @stages = sort { $stages{$a} <=> $stages{$b} } keys %stages;
  my @tissues = sort { $tissues{$a} <=> $tissues{$b} } keys %tissues;
  
  # print STDERR Dumper(%stages);
  
  return (\@organs,\@stages,\@tissues);
  # return (\%organs,\%stages,\%tissues);
  
}

=head2 names_array_to_option

Format an arrayref with layer names in HTML format, as options for a form,
using the name as the part visible for the user and the name without spaces as the HTML id and value

ARGS: arrayref of layers
Returns: HTML option format

=cut

sub names_array_to_option {
  my $self = shift;
  my $layers_arrayref = shift;
  
  my @layer_options;
  # my @layers = sort keys %$layers_hashref;
  
  foreach my $e (@$layers_arrayref) {
    my $option_id = $e;
    $option_id =~ s/ /_/g;
    push(@layer_options,"<option id=\"$option_id\" value=\"$option_id\">".$e."</option>");
  }
  
  return (\@layer_options);
}

=head2 filter_layer_type

Find all the layers for the selected layer type. Return the selected column for each one of the layer_ids sent to the function.

ARGS: schema, arrayref of layer ids, layer type (stage, tissue, organ), column to return
Returns: sorted arrayref of selected column to return

=cut

sub filter_layer_type {
  my $self = shift;
  my $schema = shift;
  my $layer_ids = shift;
  my $layer_type = shift;
  my $returned_column = shift;
  
  my %res_ids;
  
  my $layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "$layer_type"})->single;
  
  my $all_rs = $schema->resultset("Layer");
  while(my $n = $all_rs->next) {
    if ($n->layer_type_id eq $layer_type_rs->layer_type_id) {
      foreach my $sps (@{$layer_ids}) {
        if ($n->layer_id eq $sps) {
            $res_ids{$n->$returned_column} = 1;
        }
      }
    }
  }
  my @res_ids = sort {$a <=> $b} keys %res_ids;

  return \@res_ids;
}

=head2 array_to_option

Format an arrayref with layer ids in HTML format as options for a form.
Using the ids extract the names for the result


ARGS: schema, arrayref of layer ids
Returns: arraryref of HTML option formatted layer names

=cut

sub array_to_option {
  my $self = shift;
  my $schema = shift;
  my $ids_arrayref = shift;
  
  my @res;
  my %res;
  
  my $layer_rs = $schema->resultset('Layer')->search({layer_id => $ids_arrayref});
  while (my $layer_obj = $layer_rs->next) {
    my $layer_rs = $schema->resultset('LayerInfo')->search({layer_info_id => $layer_obj->layer_info_id})->single;
    $res{$layer_rs->name} = $layer_rs->layer_id;
  }
  
  foreach my $name (sort(keys %res)) {
    
    my $option_id = $name;
    $option_id =~ s/ /_/g;
    
    push(@res,"<option id=\"$option_id\" value=\"$option_id\">".$name."</option>");
  }
  
  return \@res;
}

=head2 get_image_hash

From an array of experiment ids return an array of ids sorted by ordinal, 
a HoH for stages and a HoHoA for tissues. The HoH has as first keys the layer ids and as a second key image_name, image_width, image_height and stage 
or tissue name in the case of the HoHoA, that have as values the list of image names, width, height or tissue names

ARGS: schema, arrayref of experiment ids
Returns: arraryref of stage ids sorted by ordinal, stage images hash and tissue images hash

=cut

sub get_image_hash {
  my $self = shift;
  my $schema = shift;
  my $experiment_ids = shift;
  
  my %stage_hash;
  my %stage_ordinal_id;
  my @stage_ids;
  my %tissue_hash;

  my $stage_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "stage"})->single;
  my $tissue_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "tissue"})->single;
  
  my $exp_layer_rs = $schema->resultset('ExperimentLayer')->search({experiment_id => $experiment_ids});
    
  # print STDERR Dumper($experiment_ids);
  
  # iterate each one of the experiment layers table
  while (my $exp_layer = $exp_layer_rs->next) {
    
    # get one layer
    my $layer_rs = $schema->resultset('Layer')->search({layer_id => $exp_layer->layer_id})->single;
    
    # if layer is a stage
    if ($layer_rs->layer_type_id == $stage_layer_type_rs->layer_type_id) {
      my $layer_info_rs = $schema->resultset('LayerInfo')->search({layer_info_id => $layer_rs->layer_info_id})->single;
      my $stage_name = $layer_info_rs->name;
      $stage_name =~ s/ /_/g;
      
      $stage_ordinal_id{$layer_rs->layer_id} = $layer_rs->ordinal;
      
      $stage_hash{$layer_rs->layer_id}{"image_name"} = $layer_rs->image_file_name;
      $stage_hash{$layer_rs->layer_id}{"image_width"} = $layer_rs->image_width;
      $stage_hash{$layer_rs->layer_id}{"image_height"} = $layer_rs->image_height;
      $stage_hash{$layer_rs->layer_id}{"stage_name"} = $stage_name;
    }

    # if layer is a tissue
    if ($layer_rs->layer_type_id == $tissue_layer_type_rs->layer_type_id) {
  
      my $layer_info_rs = $schema->resultset('LayerInfo')->search({layer_info_id => $layer_rs->layer_info_id})->single;
      my $parent_layer_rs = $schema->resultset('Layer')->search({layer_id => $layer_rs->parent_id})->single;
      my $parent_layer_info_rs = $schema->resultset('LayerInfo')->search({layer_info_id => $parent_layer_rs->layer_info_id})->single;
      my $tissue_name = $layer_info_rs->name;
      $tissue_name =~ s/ /_/g;
    
      push(@{$tissue_hash{$parent_layer_rs->layer_id}{"image_name"}}, $layer_rs->image_file_name);
      push(@{$tissue_hash{$parent_layer_rs->layer_id}{"image_width"}}, $layer_rs->image_width);
      push(@{$tissue_hash{$parent_layer_rs->layer_id}{"image_height"}}, $layer_rs->image_height);
      push(@{$tissue_hash{$parent_layer_rs->layer_id}{"tissue_name"}}, $tissue_name);
    }
  
  }
  
  # save the layer_ids for the stages in an array sorted by the ordinal value in the table
  foreach my $id (sort {$stage_ordinal_id{$a} <=> $stage_ordinal_id{$b} } keys %stage_ordinal_id) {
    push(@stage_ids,$id);
  }
  
  return (\@stage_ids,\%stage_hash,\%tissue_hash);
}



1;