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


sub help :Path('/help/') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'help.mas');
}


sub help_input :Path('/help/input') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'help/input_help.mas');
}

sub help_params :Path('/help/input_params') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'help/input_params.mas');
}


sub help_output :Path('/help/output') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'help/output_help.mas');
}

sub find_genes :Path('/help/find_genes') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'help/find_gene.mas');
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
