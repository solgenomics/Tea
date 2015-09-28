package Tea::Controller::Expression_viewer_functions;

use Moose;
use strict;
use warnings;
use DBIx::Class;
use Tea::Schema;
use DBI;


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
  
  foreach my $layer_id (@{$ids_arrayref}) {
    
    my $layer_info_ids = get_ids_from_query($self,$schema,"Layer",[$layer_id],"layer_id","layer_info_id");
    my $layer_names = get_ids_from_query($self,$schema,"LayerInfo",$layer_info_ids,"layer_info_id","name");
    
    $res{$layer_names->[0]} = $layer_id;
  }
  
  foreach my $name (sort(keys %res)) {
    my $option_id = $name;
    $option_id =~ s/ /_/g;
    
    push(@res,"<option id=\"$option_id\" value=\"$option_id\">".$name."</option>");
    # push(@res,"<option id=\"$res{$name}\" value=\"$res{$name}\">".$name."</option>");
  }
  
  return \@res;
}

sub get_image_hash {
  my $self = shift;
  my $schema = shift;
  my $experiment_ids = shift;
  
  my %res_hash;
  
  # my $layer_ids = $db_funct->get_ids_from_query($schema,"ExperimentLayer",$experiment_ids,"experiment_id","layer_id");
  my $organ_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "organ"})->single;
  my $stage_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "stage"})->single;
  my $tissue_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "tissue"})->single;
  
  foreach my $exp_id (@{$experiment_ids}) {
    
    my $layer_ids = get_ids_from_query($self,$schema,"ExperimentLayer",[$exp_id],"experiment_id","layer_id");
    
    foreach my $layer_id (@{$layer_ids}) {
      
      my $layer_rs = $schema->resultset('Layer')->search({layer_id => $layer_id})->single;
    
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
    
  }
  
  return \%res_hash;
}

1;