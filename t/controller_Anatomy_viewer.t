use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Tea';
use Tea::Controller::Anatomy_viewer;

ok( request('/anatomy_viewer')->is_success, 'Request should succeed' );
done_testing();
