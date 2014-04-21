use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Tea';
use Tea::Controller::Overview;

ok( request('/overview')->is_success, 'Request should succeed' );
done_testing();
