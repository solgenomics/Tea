use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Tea';
use Tea::Controller::Expression_viewer;

ok( request('/expression_viewer')->is_success, 'Request should succeed' );
done_testing();
