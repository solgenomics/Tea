
package Tea;
use Moose;
use namespace::autoclean;

Tea->config(
    'Plugin::Session' => {
        expires => 600,
        storage => '/tmp/session'
    },
);

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

  my $msg = "out";
  my $user_id = 0;

  # print STDERR "\n\nSession_expires: ".($c->session_expires-time())." secs\n\n";

  # my $cookie_time = $c->session->{expiration_time};

  # if ($epoc > $cookie_time) {
    # $c->delete_session;
    # print STDERR "\n\n\n\nexpired:  $epoc - $cookie_time = ".($epoc-$cookie_time)."\n\n\n\n";
  # }
  # else {
    # print STDERR "\n\n\n\ncookie_time:  $epoc - $cookie_time = ".($epoc-$cookie_time)."\n\n\n\n";
  # }

  if ($c->session->{is_logged_in}) {
    $user_id = $c->session->{is_logged_in};
    $msg = "in";
  } else {
    $c->delete_session;
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

  # my $cookie_time = $c->calculate_session_cookie_expires;
  # $c->session->{expiration_time} = $cookie_time;


  $c->stash->{rest} = {
      msg => "in"
  };

}


sub user_logout :Path('/expression_viewer/user_logout/') :Args(0) {
  my ($self, $c) = @_;

  $c->delete_session;

# print STDERR "\n\n\nSESSION ID: $sid\n\n\n";

  $c->stash->{rest} = {
      msg => "out"
  };

}

1;
