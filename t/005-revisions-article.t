use Test::More qw/no_plan/;
use strict;
use warnings;
use Sciangai;
BEGIN {chdir 't/'};
use Dancer::Test;

diag "Resetting caches for this test..";
$Sciangai::memd->delete_multi(
    'latest_10_pages',
    map { ("page-$_", "orevs-$_") }
    qw/Home/
);
$Sciangai::mongopage->remove();

response_content_like [ 'GET' => '/Home' ], qr/No such page/, 'OK no such page /Home yet on wiki';

my $response;

# Post with contents instead works
$response = dancer_response POST => '/Home', { params => { contents => 'DUMMY CONTENTS' } };
is $response->{status}, 302, "response for POST /Home is 302";
like $response->header('location'), qr{/Home}, "Correct redirect to /Home with DUMMY contents";
response_content_like [ 'GET' => '/Home' ], qr/DUMMY CONTENTS/, 'OK /Home has DUMMY contents';
response_content_like [ 'GET' => '/Home' ], qr/anonymous/, 'OK /Home has anonymous';
response_content_like [ 'GET' => '/Home' ], qr/Latest modified/, 'OK /Home has Latest modified';
response_content_like [ 'GET' => '/Home' ], qr/revision 1/i, 'OK /Home has revision 1';

# Post updated contents
$response = dancer_response POST => '/Home', { params => { contents => 'BLAH BLAH BLAH' } };
is $response->{status}, 302, "response for POST /Home is 302";
like $response->header('location'), qr{/Home}, "Correct redirect to /Home with DUMMY contents";
response_content_like [ 'GET' => '/Home' ], qr/BLAH BLAH BLAH/, 'OK /Home has DUMMY contents';
response_content_like [ 'GET' => '/Home' ], qr/anonymous/, 'OK /Home has anonymous';
response_content_like [ 'GET' => '/Home' ], qr/Latest modified/, 'OK /Home has Latest modified';
response_content_like [ 'GET' => '/Home' ], qr/revision 2/i, 'OK /Home has revision 2';

# Post updated contents
$response = dancer_response POST => '/Home', { params => { contents => 'MEH MEH' } };
is $response->{status}, 302, "response for POST /Home is 302";
like $response->header('location'), qr{/Home}, "Correct redirect to /Home with DUMMY contents";
response_content_like [ 'GET' => '/Home' ], qr/MEH MEH/, 'OK /Home has DUMMY contents';
response_content_like [ 'GET' => '/Home' ], qr/anonymous/, 'OK /Home has anonymous';
response_content_like [ 'GET' => '/Home' ], qr/Latest modified/, 'OK /Home has Latest modified';
response_content_like [ 'GET' => '/Home' ], qr/revision 3/i, 'OK /Home has revision 3';

# Delete page
$response = dancer_response POST => '/delete', { params => { name => 'Home' } };
is $response->{status}, 302, "response for POST /delete is 302";
like $response->header('location'), qr{/Home}, "Correct redirect to /Home after delete";
response_content_like [ 'GET' => '/Home' ], qr/No such page/, 'OK no such page /Home yet on wiki';

## TEST ENDS
$Sciangai::memd->delete_multi(
    'latest_10_pages',
    map { ("page-$_", "orevs-$_") }
    qw/Home/
);
$Sciangai::mongopage->remove();
