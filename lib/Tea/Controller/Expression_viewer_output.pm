package Tea::Controller::Expression_viewer_output;

use Moose;
use Lucy::Simple;
use JSON;

# use namespace::autoclean;


BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
    default => 'application/json',
    stash_key => 'rest',
    map => { 'application/json' => 'JSON', 'text/html' => 'JSON' },
   );

our %urlencode;


=head1 NAME

Tea::Controller::Expression_viewer - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut


sub get_expression :Path('/Expression_viewer/result/') :Args(0) {
    my ($self, $c) = @_;
 
}



=encoding utf8

=head1 AUTHOR

Noe Fernandez

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;