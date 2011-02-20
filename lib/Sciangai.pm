package Sciangai;
use Dancer ':syntax';

use Dancer::Plugin::DBIC;
use Cache::Memcached::Fast;
use Digest::SHA;
use Text::MultiMarkdown;

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

our $default_cache_for = config->{sciangai}->{cache_for} // 86400;

before sub {
    my $c = cookies;
    delete $c->{$_} for grep $_ ne 'dancer.session', keys %$c;
};

before_template sub {
    my $tokens = shift;
    $tokens->{latest_pages} = $memd->get('latest_10_pages');
    if ($tokens->{latest_pages}) {
        #debug("latest pages list was cached");
    } else {
        #debug("Gathering and caching last pages  list");
        my @latest_pages = schema->resultset('Page')->search(
            { is_live => 1, },
            {
                order_by => { -desc => 'last_modified' },
                rows     => 10,
            }
        )->all;
        $tokens->{latest_pages} = [ map { $_->as_hashref } @latest_pages ];
        $memd->set( 'latest_10_pages', $tokens->{latest_pages}, $default_cache_for );
    }
};

get '/' => sub {
    return redirect '/Home';
};

get qr,^/(?<page>.*)$, => sub {
    params->{page} = captures->{page};
    my $page = $memd->get("page-" . params->{page});
    $page ||= do {
        my ($_page) =
          schema->resultset('Page')->search( { is_live => 1, name => params->{page} }, )->all;
        my $_ph = $_page ? $_page->as_hashref : undef;
        $memd->set( "page-" . params->{page}, $_ph, $default_cache_for ) if $_ph;
        $_ph;
    };
    my $older_revisions = $memd->get("orevs-" . params->{page});
    $older_revisions ||= do {
        my @older_revisions =
          $page
          ? (
            map { $_->as_hashref }
              schema->resultset('Page')->search( { is_live => 0, name => params->{page} },
                { order_by => { -desc => 'id' } } )->all,
          )
          : ();
        $memd->set("orevs-" . params->{page}, \@older_revisions, $default_cache_for) if @older_revisions;
        \@older_revisions;
    };
    template 'page' =>
      { page => $page ? $page : undef, older_revisions => $older_revisions, };
};

post '/delete' => sub {
    my ($page) = schema->resultset('Page')->search(
        { is_live => 1, id => params->{id} },
    )->all;
    if ( $page ) {
        $page->is_live(0);
        $page->update;
        $memd->delete('latest_10_pages');
        $memd->delete('page-' . $page->name);
        $memd->delete('orevs-' . $page->name);
    }
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
    my ($page) = schema->resultset('Page')->search(
        { is_live => 1, name => params->{page} },
    )->all;
    if ( $page and $page->contents eq params->{contents} )
    {
        #debug("Redirecting to / as page is live and contents are the same");
        return redirect '/' . params->{page};
    }
    my $new_revision = $page ? $page->revision + 1 : 1;
    if ($page) {
        #debug("Setting older page to no longer live");
        $page->is_live(0);
        $page->update;
    }
    #debug("Creating new page...");
    my $new_page = schema->resultset('Page')->new(
        {
            is_live          => 1,
            name             => params->{page},
            contents         => params->{contents},
            revision         => $new_revision,
            last_modified_by => 1,                   # FIXME anonymous coward
        }
    );
    $new_page->insert;
    $memd->delete('latest_10_pages');
    $memd->delete('page-' . params->{page});
    $memd->delete('orevs-' . params->{page});
    #debug("Inserted new page and removed caches, redirecting to /" . params->{page});
    return redirect '/' . params->{page};
};

true;
