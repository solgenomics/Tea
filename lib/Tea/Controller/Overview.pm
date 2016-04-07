package Tea::Controller::Overview;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Tea::Controller::Overview - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut


sub index :Path('/overview/') :Args(0) {
    my ( $self, $c ) = @_;
    
    $c->stash(template => 'overview.mas');
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
