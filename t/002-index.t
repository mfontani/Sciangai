use Test::More qw/no_plan/;
use strict;
use warnings;
use Sciangai;
BEGIN {chdir 't/'};
use Dancer::Test;

diag "Resetting caches for this test..";
$Sciangai::memd->delete_multi('latest_10_pages', 'page-Home', 'orevs-Home');

$Sciangai::mongopage->remove();

route_exists [ 'GET' => '/' ],     'a route handler is defined for /';
route_exists [ 'GET' => '/Home' ], 'a route handler is defined for /Home';

response_status_is [ 'GET' => '/' ],     302, 'response status is 302 for /';
response_status_is [ 'GET' => '/Home' ], 200, 'response status is 200 for /Home';

response_content_like [ 'GET' => '/Home' ], qr/No such page/, 'OK no such page /Home yet on wiki';

## TEST ENDS
diag "Resetting caches for this test..";
$Sciangai::memd->delete_multi('latest_10_pages', 'page-Home', 'orevs-Home');
