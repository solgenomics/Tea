
package Tea;
use Moose;
use namespace::autoclean;

use Catalyst  qw/
                    Session
                    Session::Store::FastMmap
                    Session::State::Cookie
                /;
extends 'Catalyst';
__PACKAGE__->setup;

package Tea::Controller::user_login_ajax;
use Moose;
use namespace::autoclean;
BEGIN { extends 'Catalyst::Controller::REST' };

__PACKAGE__->config(
    default => 'application/json',
    stash_key => 'rest',
    map => { 'application/json' => 'JSON', 'text/html' => 'JSON' },
   );


=head1 AUTHOR

Noe Fernandez

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use strict;
use warnings;


our %urlencode;

=head2 user_logged_in

get gene names from the selected project for autocompleting their names on input boxes

ARGS: project_id
Returns: gene anmes array

=cut

sub user_logged_in :Path('/expression_viewer/user_logged/') :Args(0) {
  my ($self, $c) = @_;

  my $user_id = $c->session->{is_logged_in};
  # print STDERR "\n\n\n\nHello 2 !!!  $user_id \n\n\n\n";

  my $msg = "out";
  if ($user_id && $user_id =~ /\d+/) {
    $msg = "in";
  }

  $c->stash->{rest} = {
      msg => $msg
  };

}


sub user_login :Path('/expression_viewer/user_login/') :Args(0) {
  my ($self, $c) = @_;

  my $user_id = $c->req->param("user_id");
  # print STDERR "\n\n\n\nFIRST LOGIN: $user_id\n\n\n\n";

  $c->session->{is_logged_in} = $user_id;

  $c->stash->{rest} = {
      msg => "in"
  };

}


1;
