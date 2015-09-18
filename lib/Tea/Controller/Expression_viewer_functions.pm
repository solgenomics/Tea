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

1;