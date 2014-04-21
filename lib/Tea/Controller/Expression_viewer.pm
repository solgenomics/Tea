package Tea::Controller::Expression_viewer;

use Moose;

# use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }


=head1 NAME

Tea::Controller::Expression_viewer - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path('/Expression_viewer/input/') :Args(0) {
    my ( $self, $c ) = @_;

    # $c->response->body('Matched Tea::Controller::Expression_viewer in Expression_viewer.');
 
    $c->stash(template => 'Expression_viewer/output.mas');
    # $c->stash(template => 'Expression_viewer/output.tt');
	
}


=encoding utf8

=head1 AUTHOR

noe,,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
