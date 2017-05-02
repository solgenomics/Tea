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


sub delete_project_data :Path('/delete_project/') :Args(0) {
  my ($self, $c) = @_;
  
  # to store erros as they may happen
  my @errors; 

  # get variables from catalyst object
  my $project_id = $c->req->param("project_id");
  
  my $dbname = $c->config->{dbname};
  my $host = $c->config->{dbhost};
  my $username = $c->config->{dbuser};
  my $password = $c->config->{dbpass};

  my $delete_enabled = $c->config->{delete_project};

  my $schema = Tea::Schema->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  my $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  
  my $project_rs = $schema->resultset('Project')->single({project_id => $project_id});
  my $figure_rs = $schema->resultset('Figure')->search({project_id => $project_id});
  
  if ($figure_rs) {
    
    my $condition_rs = $schema->resultset('Condition')->search({figure_id => $figure_rs->figure_id});
    my $figure_layer_rs = $schema->resultset('FigureLayer')->search({figure_id => $figure_rs->figure_id});
    my $layer_rs = $schema->resultset('Layer')->search({layer_id => $figure_layer_rs->layer_id});
  
    while(my $l = $layer_rs->next) {
      $l->delete_all(cascade_delete => 0);
    }
    while(my $l = $figure_layer_rs->next) {
      $l->delete_all(cascade_delete => 0);
    }
    
    if ($condition_rs) {
      while(my $l = $condition_rs->next) {
        $l->delete_all(cascade_delete => 0);
      }
    }
    
    while(my $l = $figure_rs->next) {
      $l->delete_all(cascade_delete => 0);
    }
    
  }
  
  $project_rs->delete_all(cascade_delete => 0);
  
  
  # $layer_rs->delete_all(cascade_delete => 0);
  # $figure_layer_rs->delete_all(cascade_delete => 0);
  # $condition_rs->delete_all(cascade_delete => 0);
  # $figure_rs->delete_all(cascade_delete => 0);
  
  my @project_ids;
  my %project_names;

  my $all_rs = $schema->resultset("Project");
  while(my $n = $all_rs->next) {
    push (@project_ids,$n->project_id);
    $project_names{$n->project_id} = $n->name;
  }
  
  $c->stash->{rest} = {
    project_ids => \@project_ids,
    project_names => \%project_names,
  };
  
}





1;
