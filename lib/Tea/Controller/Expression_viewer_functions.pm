package Tea::Controller::Expression_viewer_functions;

use Moose;
use strict;
use warnings;
use DBIx::Class;
use Tea::Schema;
use DBI;
use Data::Dumper;

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

sub get_layer_options {
  my $self = shift;
  my $schema = shift;
  my $exp_rs = shift;
  my $org_names = shift;
  my $stage_names = shift;
  my $tissue_names = shift;
  
  my %project_layer_ids;
  # save all layer ids from the selected organism.
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
  
  return (\@organs,\@stages,\@tissues);
  # return (\%organs,\%stages,\%tissues);
  
}

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

sub get_image_hash {
  my $self = shift;
  my $schema = shift;
  my $experiment_ids = shift;
  
  my %res_hash;
  
  my $organ_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "organ"})->single;
  my $stage_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "stage"})->single;
  my $tissue_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "tissue"})->single;
  
  my $exp_layer_rs = $schema->resultset('ExperimentLayer')->search({experiment_id => $experiment_ids});
    
  while (my $exp_layer = $exp_layer_rs->next) {
      
    my $layer_rs = $schema->resultset('Layer')->search({layer_id => $exp_layer->layer_id})->single;
    
    # if layer is an organ
    if ($layer_rs->layer_type_id == $organ_layer_type_rs->layer_type_id) {
      my $layer_info_rs = $schema->resultset('LayerInfo')->search({layer_info_id => $layer_rs->layer_info_id})->single;
      $res_hash{"organ"}{"organ"}{"image_name"} = $layer_rs->image_file_name;
      $res_hash{"organ"}{"organ"}{"image_width"} = $layer_rs->image_width;
      $res_hash{"organ"}{"organ"}{"image_height"} = $layer_rs->image_height;
    }

    # if layer is a stage
    if ($layer_rs->layer_type_id == $stage_layer_type_rs->layer_type_id) {
      my $layer_info_rs = $schema->resultset('LayerInfo')->search({layer_info_id => $layer_rs->layer_info_id})->single;
      my $stage_name = $layer_info_rs->name;
      $stage_name =~ s/ /_/g;
    
      $res_hash{$stage_name}{"bg"}{"image_name"} = $layer_rs->image_file_name;
      $res_hash{$stage_name}{"bg"}{"image_width"} = $layer_rs->image_width;
      $res_hash{$stage_name}{"bg"}{"image_height"} = $layer_rs->image_height;
    }

    # if layer is a tissue
    if ($layer_rs->layer_type_id == $tissue_layer_type_rs->layer_type_id) {
  
      my $layer_info_rs = $schema->resultset('LayerInfo')->search({layer_info_id => $layer_rs->layer_info_id})->single;
      my $parent_layer_rs = $schema->resultset('Layer')->search({layer_id => $layer_rs->parent_id})->single;
      my $parent_layer_info_rs = $schema->resultset('LayerInfo')->search({layer_info_id => $parent_layer_rs->layer_info_id})->single;
      my $tissue_name = $layer_info_rs->name;
      $tissue_name =~ s/ /_/g;
    
      $res_hash{$parent_layer_info_rs->name}{$tissue_name}{"image_name"} = $layer_rs->image_file_name;
      $res_hash{$parent_layer_info_rs->name}{$tissue_name}{"image_width"} = $layer_rs->image_width;
      $res_hash{$parent_layer_info_rs->name}{$tissue_name}{"image_height"} = $layer_rs->image_height;
    }
  
  }
  
  return \%res_hash;
}



1;