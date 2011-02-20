use Test::More qw/no_plan/;
use strict;
use warnings;
use Sciangai;
use Dancer::Test;

diag "Deploying schema..";
unlink 'sciangai.db';
qx{../bin/deploy_schema ../environments/development.yml};
diag "Deployed schema..";
ok( -f 'sciangai.db' ) or BAIL_OUT("Need sciangai.db");
## TEST BEGINS

diag "Resetting caches for this test..";
$Sciangai::memd->delete('latest_10_pages');
$Sciangai::memd->delete('page-Home');
$Sciangai::memd->delete('orevs-Home');

route_exists [ 'GET' => '/' ],     'a route handler is defined for /';
route_exists [ 'GET' => '/Home' ], 'a route handler is defined for /Home';

response_status_is [ 'GET' => '/' ],     302, 'response status is 302 for /';
response_status_is [ 'GET' => '/Home' ], 200, 'response status is 200 for /Home';

response_content_like [ 'GET' => '/Home' ], qr/No such page/, 'OK no such page /Home yet on wiki';

## TEST ENDS
unlink 'sciangai.db';
