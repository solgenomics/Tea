package Tea::Controller::Expression_viewer_functions;

use Moose;
use strict;
use warnings;
use DBIx::Class;
use Tea::Schema;
use DBI;
use Data::Dumper;


=head2 get_sps_datasets

Get all data sets for selected species formatted in html for input page.

ARGV: sps_id.

Return: html radio select box for all available datasets after checking privacy
=cut

sub get_sps_datasets {
  my $self = shift;
  my $schema = shift;
  my $sps_id = shift;
  my $multiple_sps = shift;
  my $user_id = shift;

  my $projects_rs = $schema->resultset('Project');

  my @projects = ();
  my %project_name_hash;
  my %project_order_hash;
  my $project_ordinal;
  my %project_group_hash;

  while(my $proj_obj = $projects_rs->next) {

      my $project_name = $proj_obj->name;

      #--------------------------------------------------- Privacy code
      # check if data set is private
      my $is_private = $proj_obj->private;

      if ($is_private) {

        # get groups associated to each data set
        my $proj_group_rs = $schema->resultset('ProjectPrivateGroup')->search({project_id => $proj_obj->project_id});

        while(my $proj_group_obj = $proj_group_rs->next) {
          my $group_id = $proj_group_obj->private_group_id;

          my $group_rs = $schema->resultset('PrivateGroup')->single({private_group_id => $group_id});

          $project_group_hash{$group_rs->name} = 1;
        }

        foreach my $group (keys %project_group_hash) {
          print STDERR "\n\n\n ### $project_name: $group $is_private\n\n\n";
        }
        %project_group_hash = ();





        print STDERR "\n\n\n\n user id???: $user_id\n\n\n\n";


        # connect to user db an check user is verified and has the one of the groups of the dataset

        #check if it is private and check all groups from the user vs all groups from the dataset
        #check if it is private and check all groups from the user vs all groups from the dataset
        #check if it is private and check all groups from the user vs all groups from the dataset
      }


      if ($is_private) {
        next;
      }
      #---------------------------------------------------

      my $project_name = $proj_obj->name;
      my $project_id = $proj_obj->project_id;

      if ($proj_obj->ordinal) {
        $project_ordinal = $proj_obj->ordinal;
      }
      else {
        $project_ordinal = $project_id;
      }

      if ($multiple_sps) {

        if ($sps_id == $proj_obj->organism_id) {
          $project_name_hash{$project_id} = $project_name;
          $project_order_hash{$project_ordinal} = $project_id;
        }
      }
      else {
        $project_name_hash{$project_id} = $project_name;
        $project_order_hash{$project_ordinal} = $project_id;
      }

  }

  foreach my $key (sort {$a <=> $b} keys %project_order_hash) {
    my $project_id = $project_order_hash{$key};
    my $project_name = $project_name_hash{$project_id};
    push(@projects,"<div id=\"project_radio_div\" class=\"radio\">\n<label><input id=\"project_".$project_id."\" type='radio' class='organism_col' name=\"optradio\" value=\'".$project_id."\'> $project_name</label>\n</div>\n");
  }

  # save array info in text variable
  my $projects_html = join("\n", @projects);

  return ($projects_html);

}



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
      # print STDERR "Sps: $sps ".$n->$column_name."\n";

      if ($n->$column_name eq $sps) {
        $res_ids{$n->$column_id} = 1;
        # print STDERR "------------- Sps: $sps ".$n->$column_id."\n";

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

get all organ, stage and tissue names from input page, and return the figures available only for the selected items

ARGS: schema, all_figures_rs, organims_selected, stages_selected, tissues_selected
Returns: selected_figures_rs

=cut

sub get_layer_options {
  my $self = shift;
  my $schema = shift;
  my $fig_rs = shift;
  my $org_names = shift;
  my $stage_names = shift;
  my $tissue_names = shift;

  my %project_layer_ids;
  # save all layer ids from the selected project.
  while(my $fig_obj = $fig_rs->next) {
    my $fig_layer_rs = $schema->resultset('FigureLayer')->search({figure_id => $fig_obj->figure_id});

    while(my $fig_layer_obj = $fig_layer_rs->next) {
      $project_layer_ids{$fig_layer_obj->layer_id} = 1;
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

  # get the figure resultsets from the layers
  my @layer_ids = keys %layer_ids_found;
  my %fig_ids;
  my $fig_layer_rs = $schema->resultset('FigureLayer')->search({layer_id => \@layer_ids});

  while (my $fig_layer_obj = $fig_layer_rs->next) {
    $fig_ids{$fig_layer_obj->figure_id} = 1;
  }

  my @figure_ids = keys %fig_ids;
  my $filtered_fig_rs = $schema->resultset('Figure')->search({figure_id => \@figure_ids});

  return $filtered_fig_rs;
}


=head2 get_input_options

get figure_rs objs and save them in
organ, stage and tissue name arrays sorted by ordinal

ARGS: schema, figures_rs
Returns: organ, stage, tissue and treatment name arrays sorted by ordinal

=cut

sub get_input_options {
  my $self = shift;
  my $schema = shift;
  my $all_fig_rs = shift;

  my %organs;
  my %stages;
  my %tissues;
  my %conditions;

  my $stage_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "stage"})->single;
  my $tissue_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "tissue"})->single;

  while (my $n = $all_fig_rs->next) {

    my $fig_layer_rs = $schema->resultset('FigureLayer')->search({figure_id => $n->figure_id});
    my $condition_rs = $schema->resultset('Condition')->search({figure_id => $n->figure_id});

    while(my $m = $fig_layer_rs->next) {
      my $layer_rs = $schema->resultset('Layer')->search({layer_id => $m->layer_id})->single;
      my $layer_info_rs = $schema->resultset('LayerInfo')->search({layer_info_id => $layer_rs->layer_info_id})->single;

      $organs{$layer_info_rs->organ} = 1;

      if ($layer_rs->layer_type_id == $stage_layer_type_rs->layer_type_id){
        $stages{$layer_info_rs->name} = $layer_rs->cube_ordinal;
      }
      if ($layer_rs->layer_type_id == $tissue_layer_type_rs->layer_type_id){
        $tissues{$layer_info_rs->name} = $layer_rs->cube_ordinal;
      }
    }

    while (my $cond_rs = $condition_rs->next) {
      $conditions{$cond_rs->name} = 1;
    }
  }
  my @organs = sort keys %organs;
  my @stages = sort { $stages{$a} <=> $stages{$b} } keys %stages;
  my @tissues = sort { $tissues{$a} <=> $tissues{$b} } keys %tissues;
  my @conditions = sort keys %conditions;

  return (\@organs,\@stages,\@tissues,\@conditions);
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
    $e =~ s/_/ /g;

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
    $name =~ s/_/ /g;

    push(@res,"<option id=\"$option_id\" value=\"$option_id\">".$name."</option>");
  }

  return \@res;
}

=head2 get_image_hash

From an array of figure ids return an array of ids sorted by ordinal,
a HoH for stages and a HoHoA for tissues. The HoH has as first keys the layer ids and as a second key image_name, image_width, image_height and stage
or tissue name in the case of the HoHoA, that have as values the list of image names, width, height or tissue names

ARGS: schema, arrayref of figure ids
Returns: arraryref of stage ids sorted by ordinal, stage images hash and tissue images hash

=cut

sub get_image_hash {
  my $self = shift;
  my $schema = shift;
  my $layer_ids = shift;

  my %stage_hash;
  my %stage_ordinal_id;
  my @stage_ids;
  my %tissue_hash;

  my $parent_layer_rs;

  my $stage_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "stage"})->single;
  my $tissue_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "tissue"})->single;

  my $layer_rs = $schema->resultset('Layer')->search({layer_id => $layer_ids});

  # iterate each one of the layers
  while (my $one_layer = $layer_rs->next) {

    # if layer is a stage
    if ($one_layer->layer_type_id == $stage_layer_type_rs->layer_type_id) {

      my $figure_layer_rs = $schema->resultset('FigureLayer')->search({layer_id => $one_layer->layer_id})->single;
      # get all figure layer resultset for current figure
      my $figure_rs = $schema->resultset('Figure')->search({figure_id => $figure_layer_rs->figure_id})->single;

      my $layer_info_rs = $schema->resultset('LayerInfo')->search({layer_info_id => $one_layer->layer_info_id})->single;

      # my $stage_name = $figure_rs->cube_stage_name;
      my $stage_name = $layer_info_rs->name;
      my $stage_top_label = $figure_rs->figure_name;
      $stage_name =~ s/ /_/g;

      $stage_ordinal_id{$one_layer->layer_id} = $one_layer->img_ordinal;

      $stage_hash{$one_layer->layer_id}{"image_name"} = $one_layer->image_file_name;
      $stage_hash{$one_layer->layer_id}{"image_width"} = $one_layer->image_width;
      $stage_hash{$one_layer->layer_id}{"image_height"} = $one_layer->image_height;
      $stage_hash{$one_layer->layer_id}{"stage_top_label"} = $stage_top_label;
      $stage_hash{$one_layer->layer_id}{"stage_name"} = $stage_name;
      $stage_hash{$one_layer->layer_id}{"bg_color"} = $layer_info_rs->bg_color;
    }

    # if layer is a tissue
    if ($one_layer->layer_type_id == $tissue_layer_type_rs->layer_type_id) {






      # TO DO need to join tables to find all the parent stages from a tissue





      my $layer_info_rs = $schema->resultset('LayerInfo')->search({layer_info_id => $one_layer->layer_info_id})->single;

      # get figure layer resultset
      # my $figure_layer_rs = $schema->resultset('FigureLayer')->search({layer_id => $one_layer->layer_id})->single;
      my $figure_layer_rs = $schema->resultset('FigureLayer')->search({layer_id => $one_layer->layer_id});

      # get all figure layer resultset for current figure
      while (my $fig_layer1 = $figure_layer_rs->next) {
        my $parent_fig_layer_rs = $schema->resultset('FigureLayer')->search({figure_id => $fig_layer1->figure_id});

        while (my $fig_layer = $parent_fig_layer_rs->next) {

          my $layer_p = $schema->resultset('Layer')->search({layer_id => $fig_layer->layer_id})->single;

          if ($layer_p->layer_type_id == $stage_layer_type_rs->layer_type_id) {
            $parent_layer_rs = $layer_p;
          }
        }

        my $tissue_name = $layer_info_rs->name;
        $tissue_name =~ s/ /_/g;

        push(@{$tissue_hash{$parent_layer_rs->layer_id}{"image_name"}}, $one_layer->image_file_name);
        push(@{$tissue_hash{$parent_layer_rs->layer_id}{"image_width"}}, $one_layer->image_width);
        push(@{$tissue_hash{$parent_layer_rs->layer_id}{"image_height"}}, $one_layer->image_height);
        push(@{$tissue_hash{$parent_layer_rs->layer_id}{"tissue_name"}}, $tissue_name);
        $tissue_hash{$parent_layer_rs->layer_id}{"bg_color"}{$tissue_name} = $layer_info_rs->bg_color;

      }

    }

  }

  # save the layer_ids for the stages in an array sorted by the ordinal value in the table
  foreach my $id (sort {$stage_ordinal_id{$a} <=> $stage_ordinal_id{$b} } keys %stage_ordinal_id) {
    if ($tissue_hash{$id} && $stage_hash{$id}) {
      push(@stage_ids,$id);
    }
  }

  # print STDERR "stage ids:\n";
  # print Dumper @stage_ids;
  #
  # print STDERR "stage hash:\n";
  # print Dumper %stage_hash;
  #
  # print STDERR "tissue hash:\n";
  # print Dumper %tissue_hash;

  return (\@stage_ids,\%stage_hash,\%tissue_hash);
}



1;
