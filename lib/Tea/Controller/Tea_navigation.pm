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


sub about :Path('/about/') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'about.mas');
}


sub links :Path('/links/') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'links.mas');
}


sub contact :Path('/contact/') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'contact.mas');
}

sub av_menu :Path('/anatomy_viewer/') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'anatomy_menu.mas');
}

sub microscopy :Path('/microscopy/') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'microscopy.mas');
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
