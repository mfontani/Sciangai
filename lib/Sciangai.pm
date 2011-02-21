package Sciangai;
use Dancer ':syntax';

use MongoDB;
use Cache::Memcached::Fast;
use Digest::SHA;
use Text::MultiMarkdown;
use Data::Dumper;

our $VERSION = '0.1';

our $memd = Cache::Memcached::Fast->new(
    {
        %{    config->{plugins}->{Memcached}
            ? config->{plugins}->{Memcached}
            : {
                servers   => ['127.0.0.1:11211'],
                namespace => 'sciangai:',
            }
          }
    }
);

our $mongo     = MongoDB::Connection->new;
our $mongodb   = $mongo->sciangai;
our $mongopage = $mongodb->page;

our $default_cache_for = config->{sciangai}->{cache_for} // 86400;

sub _markdown_to_html
{
    my $text = shift;
    eval "require Text::MultiMarkdown";
    return Text::MultiMarkdown::markdown($text);
}

before sub {
    my $c = cookies;
    delete $c->{$_} for grep $_ ne 'dancer.session', keys %$c;
};

before_template sub {
    my $tokens = shift;
    $tokens->{latest_pages} =
      [ reverse $mongopage->find( {}, { sort_by => { last_modified => 1 } } )
          ->limit(10)->all ];
};

get '/' => sub {
#my @everything = $mongopage->find->all;
#die Dumper(\@everything);
    return redirect '/Home';
};

get qr,^/(?<page>.*)$, => sub {
    params->{page} = captures->{page};

    my $page = $mongopage->find_one({ name => params->{page} });

    template 'page' => { page => exists $page->{_id} ? $page : undef };

};

post '/delete' => sub {

    if (!params->{id} and !params->{name})
    {
        debug("No page to delete");
        return redirect '/Home';
    }
    debug( "Fetching page by ID " . params->{id} )     if params->{id};
    debug( "Fetching page by NAME " . params->{name} ) if params->{name};
    my $page = params->{id}
      ? do {
        my $oid = MongoDB::OID->new( value => params->{id} );
        $mongopage->find_one( { _id => $oid } );
      }
      : $mongopage->find_one( { name => params->{name} } );
    debug("Got page: " . Dumper($page));

    if ( !exists $page->{_id} )
    {
        debug("Not deleting nonexisting page");
        return redirect '/Home';
    }

    my $rc = $mongopage->remove( { _id => $page->{_id} } );

    debug("Deleted page: " . Dumper($rc));

    return redirect '/Home';
};

post qr,^/(?<page>.*)$, => sub {
    params->{page} = captures->{page};
    if (!params->{page} or !length params->{page})
    {
        #debug("Redirecting to / as there is no param 'page'");
        return redirect '/Home';
    }
    if (!params->{contents}) {
        #debug("Redirecting to / as there are no contents");
        return redirect '/' . params->{page};
    }

    debug("Trying to fetch a name " . params->{page} . " from mongo");
    my $page = $mongopage->find_one({ name => params->{page} });
    debug("Fetched from mongo: " . Dumper($page));
    my $id = 0;
    if ( $page and exists $page->{_id} )
    {
        debug("HAVE page");
        $id = $page->{_id};
        debug("Got page: id $id") if $id;
        my $rc = $mongopage->update(
            { _id => $page->{_id} },
            {
                revision => $page->{revision} + 1,
                revisions => [ $page, ref $page->{revisions} ? @{$page->{revisions}} : () ],
                name => params->{page},
                contents => params->{contents},
                last_modified => scalar localtime time,
                contents_html => _markdown_to_html( params->{contents} ),
                last_modified_by => {
                    id => 0,
                    username => 'anonymous',
                    name => 'Anonymous Coward',
                    created => 0,
                    is_active => 1,
                },
            },
            { safe => 1 }
        );
        debug("UPDATE, rc: " . Dumper($rc));
    }
    else
    {
        debug("DO NOT HAVE page, inserting new");
        my $newpage = $mongopage->insert({
            name => params->{page},
            contents => params->{contents},
            revision => 1,
            revisions => [],
            last_modified => scalar localtime time,
            last_modified => scalar localtime time,
            contents_html => _markdown_to_html( params->{contents} ),
            last_modified_by => {
                id => 0,
                username => 'anonymous',
                name => 'Anonymous Coward',
                created => 0,
                is_active => 1,
            },
        }, { safe => 1, });
        debug("INSERTED, results: " . Dumper($newpage));
    }
    $mongopage->ensure_index({ name => 1, }, { unique => 1 });

    return redirect '/' . params->{page};
};

true;
