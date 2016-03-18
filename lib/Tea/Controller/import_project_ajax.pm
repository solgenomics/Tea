package Tea::Controller::Impot_project_ajax;

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

use Tea::Controller::Expression_viewer_functions;

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
    default => 'application/json',
    stash_key => 'rest',
    map => { 'application/json' => 'JSON', 'text/html' => 'JSON' },
   );

our %urlencode;


sub get_project_data :Path('/import_project/get_project_data/') :Args(0) {
  my ($self, $c) = @_;
  
  # to store erros as they may happen
  my @errors; 

  # get variables from catalyst object
  my $project_id = $c->req->param("project_id");

 
  # $c->stash->{rest} = {
  # };
  
}





1;
