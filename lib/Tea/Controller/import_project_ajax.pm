package Tea::Controller::import_project_ajax;

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


sub get_project_data :Path('/get_project_data/') :Args(0) {
  my ($self, $c) = @_;
  
  # to store erros as they may happen
  my @errors; 

  # get variables from catalyst object
  my $project_id = $c->req->param("project_id");
  
  my $dbname = $c->config->{dbname};
  my $host = $c->config->{dbhost};
  my $username = $c->config->{dbuser};
  my $password = $c->config->{dbpass};

  my $schema = Tea::Schema->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  my $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  
  my $project_rs = $schema->resultset('Project')->single({project_id => $project_id});
  my $organism_rs = $schema->resultset('Organism')->single({organism_id => $project_rs->organism_id});
  
 
  $c->stash->{rest} = {
    project_id => $project_id,
    project_name => $project_rs->name,
    project_contact => $project_rs->contact,
    project_description => $project_rs->description,
    project_index => $project_rs->indexed_dir,
    organism_id => $project_rs->organism_id,
    organism_species => $organism_rs->species,
    organism_variety => $organism_rs->variety,
    organism_description => $organism_rs->description,
  };
  
}





1;
