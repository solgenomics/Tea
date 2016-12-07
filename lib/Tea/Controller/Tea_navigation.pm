package Tea::Controller::Tea_navigation;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Tea::Controller::Tea_navigation - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut


sub about :Path('/help/') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'help.mas');
}


sub links :Path('/help/input') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'input_help.mas');
}


sub contact :Path('/help/output') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'output_help.mas');
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
