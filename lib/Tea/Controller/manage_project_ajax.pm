package Tea::Controller::manage_project_ajax;

=head1 AUTHOR

Noe Fernandez

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use Moose;
use JSON;

use DBIx::Class;
use strict;
use warnings;
use Tea::Schema;
use DBI;


BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
    default => 'application/json',
    stash_key => 'rest',
    map => { 'application/json' => 'JSON', 'text/html' => 'JSON' },
   );

our %urlencode;


sub delete_project_data :Path('/expression_viewer/delete_project/') :Args(0) {
  my ($self, $c) = @_;
  
  # to store erros as they may happen
  my @errors; 

  # get variables from catalyst object
  my $project_id = $c->req->param("project_id");
  
  my $delete_enabled = $c->config->{delete_project};
  
  if (!$delete_enabled) {
    $c->stash->{rest} = {
      prj_html => 1
    };
    print STDERR "delete projects is disabled!\n";
  }
  
  my $dbname = $c->config->{dbname};
  my $host = $c->config->{dbhost};
  my $username = $c->config->{dbuser};
  my $password = $c->config->{dbpass};

  
  my $schema = Tea::Schema->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  my $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  
  my $project_rs = $schema->resultset('Project')->single({project_id => $project_id});
  my $figure_rs = $schema->resultset('Figure')->search({project_id => $project_id});
  
  my @fl_ids;
  
  
  if ($figure_rs) {
    
    while(my $fig = $figure_rs->next) {
    
      my $condition_rs = $schema->resultset('Condition')->search({figure_id => $fig->figure_id});
      
      if ($condition_rs) {
        $condition_rs->delete_all;
      }
      
      my $figure_layer_rs = $schema->resultset('FigureLayer')->search({figure_id => $fig->figure_id});
      
      
      # while(my $fl = $figure_layer_rs->next) {
      #   push (@fl_ids, $fl->layer_id);
      # }
      
      $figure_layer_rs->delete_all;
      
    }
    $figure_rs->delete_all;
  }
  
  $project_rs->delete;
  
  # foreach my $flid (@fl_ids) {
  #   my $layer_rs = $schema->resultset('Layer')->search({layer_id => $flid});
  #
  #   $layer_rs->delete;
  #
  # }
  
  

  $c->stash->{rest} = {
    prj_html => 1
  };
  
}





1;
