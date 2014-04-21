package Tea::View::Mason;

use strict;
use warnings;
use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

extends 'Catalyst::View::HTML::Mason';
with 'Catalyst::Component::ApplicationAttribute';

# use Catalyst qw/$c /;

__PACKAGE__->config(
    # globals => ['$c'],
    template_extension => '.mas',
    interp_args => {
        #data_dir => Tea->tempfiles_base->subdir('mason'),
        comp_root => [
            [ main => Tea->path_to('mason') ],
        ],
    },
);


=he


=head1 NAME

Expr::View::Mason - Mason View Component for Expr

=head1 DESCRIPTION

Mason View Component for Expr

=head1 SEE ALSO

L<Expr>, L<HTML::Mason>

=head1 AUTHOR

noe,,,,

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
