use Test::More qw/no_plan/;
use strict;
use warnings;
use Sciangai;
BEGIN {chdir 't/'};
use Dancer::Test;

diag "Deploying schema..";
unlink 'sciangai.db';
qx{../bin/deploy_schema ../environments/development.yml};
diag "Deployed schema..";
ok( -f 'sciangai.db' ) or BAIL_OUT("Need sciangai.db");
# create anonymous coward user
my $anon = Sciangai::schema->resultset('User')->new({
    username => 'anonymous',
});
$anon->insert;
## TEST BEGINS

diag "Resetting caches for this test..";
$Sciangai::memd->delete_multi(
    'latest_10_pages',
    map { ("page-$_", "orevs-$_") }
    qw/Home slartibartfast slarti_bart_&_faster slarti+bart+fast /
);

response_content_like [ 'GET' => '/Home' ], qr/No such page/, 'OK no such page /Home yet on wiki';

my $response;

# Just POST doesn't do much
$response = dancer_response POST => '/';
is $response->{status}, 302, "response for POST / is 302";
like $response->header('location'), qr{/Home}, "Correct redirect to /Home";
response_content_like [ 'GET' => '/Home' ], qr/No such page/, 'OK still no such page /Home yet on wiki';

# Post with empty contents neither
$response = dancer_response POST => '/', { params => { contents => '' } };
is $response->{status}, 302, "response for POST / is 302";
like $response->header('location'), qr{/Home}, "Correct redirect to /Home with no contents";
response_content_like [ 'GET' => '/Home' ], qr/No such page/, 'OK still no such page /Home yet on wiki';

# Post with contents on / neither
$response = dancer_response POST => '/', { params => { contents => 'DUMMY contents' } };
is $response->{status}, 302, "response for POST / is 302";
like $response->header('location'), qr{/Home}, "Correct redirect to /Home with no contents";
response_content_like [ 'GET' => '/Home' ], qr/No such page/, 'OK still no such page /Home yet on wiki';

# Just POST to /Home doesn't do much
$response = dancer_response POST => '/Home';
is $response->{status}, 302, "response for POST /Home is 302";
like $response->header('location'), qr{/Home}, "Correct redirect to /Home";
response_content_like [ 'GET' => '/Home' ], qr/No such page/, 'OK still no such page /Home yet on wiki';

# Post with empty contents neither
$response = dancer_response POST => '/Home', { params => { contents => '' } };
is $response->{status}, 302, "response for POST /Home is 302";
like $response->header('location'), qr{/Home}, "Correct redirect to /Home with empty contents";
response_content_like [ 'GET' => '/Home' ], qr/No such page/, 'OK still no such page /Home yet on wiki after empty contents';

# Post with contents instead works
$response = dancer_response POST => '/Home', { params => { contents => 'DUMMY CONTENTS' } };
is $response->{status}, 302, "response for POST /Home is 302";
like $response->header('location'), qr{/Home}, "Correct redirect to /Home with DUMMY contents";
response_content_like [ 'GET' => '/Home' ], qr/DUMMY CONTENTS/, 'OK /Home has DUMMY contents';
response_content_like [ 'GET' => '/Home' ], qr/anonymous/, 'OK /Home has anonymous';
response_content_like [ 'GET' => '/Home' ], qr/Latest modified/, 'OK /Home has Latest modified';

# Post with contents on dummy page works too
$response = dancer_response POST => '/slartibartfast', { params => { contents => 'DUMMY CONTENTS' } };
is $response->{status}, 302, "response for POST /slartibartfast is 302";
like $response->header('location'), qr{/slartibartfast}, "Correct redirect to /slartibartfast with DUMMY contents";
response_content_like [ 'GET' => '/slartibartfast' ], qr/DUMMY CONTENTS/, 'OK /slartibartfast has DUMMY contents';
response_content_like [ 'GET' => '/slartibartfast' ], qr/anonymous/, 'OK /slartibartfast has anonymous';
response_content_like [ 'GET' => '/Home' ], qr/Latest modified/, 'OK /Home has Latest modified';
response_content_like [ 'GET' => '/Home' ], qr/slartibartfast/, 'OK /Home has slartibartfast';

# Post with contents on dummy page works too
$response = dancer_response POST => '/slarti_bart_&_faster', { params => { contents => 'DUMMY CONTENTS' } };
is $response->{status}, 302, "response for POST /slarti_bart_&_faster is 302";
like $response->header('location'), qr{/slarti_bart_&_faster}, "Correct redirect to /slarti_bart_&_faster with DUMMY contents";
response_content_like [ 'GET' => '/slarti_bart_&_faster' ], qr/DUMMY CONTENTS/, 'OK /slarti_bart_&_faster has DUMMY contents';
response_content_like [ 'GET' => '/slarti_bart_&_faster' ], qr/anonymous/, 'OK /slarti_bart_&_faster has anonymous';
response_content_like [ 'GET' => '/Home' ], qr/Latest modified/, 'OK /Home has Latest modified';
response_content_like [ 'GET' => '/Home' ], qr/slartibartfast/, 'OK /Home has slartibartfast';
response_content_like [ 'GET' => '/Home' ], qr/slarti_bart/, 'OK /Home has slarti_bart';

# Post with contents on dummy page works too
$response = dancer_response POST => '/slarti+bart+fast', { params => { contents => 'DUMMY CONTENTS' } };
is $response->{status}, 302, "response for POST /slarti+bart+fast is 302";
like $response->header('location'), qr{/slarti\+bart\+fast}, "Correct redirect to /slarti+bart+fast with DUMMY contents";
response_content_like [ 'GET' => '/slarti+bart+fast' ], qr/DUMMY CONTENTS/, 'OK /slarti+bart+fast has DUMMY contents';
response_content_like [ 'GET' => '/slarti+bart+fast' ], qr/anonymous/, 'OK /slarti+bart+fast has anonymous';
response_content_like [ 'GET' => '/Home' ], qr/Latest modified/, 'OK /Home has Latest modified';
response_content_like [ 'GET' => '/Home' ], qr/slartibartfast/, 'OK /Home has slartibartfast';
response_content_like [ 'GET' => '/Home' ], qr/slarti_bart/, 'OK /Home has slarti_bart';
response_content_like [ 'GET' => '/Home' ], qr/slarti\+bart/, 'OK /Home has slarti+bart';

## TEST ENDS
diag "Resetting caches for this test..";
$Sciangai::memd->delete_multi(
    'latest_10_pages',
    map { ("page-$_", "orevs-$_") }
    qw/Home slartibartfast slarti_bart_&_faster slarti+bart+fast /
);
unlink 'sciangai.db';
