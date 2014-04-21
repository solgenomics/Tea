use strict;
use warnings;

use Tea;

my $app = Tea->apply_default_middlewares(Tea->psgi_app);
$app;

