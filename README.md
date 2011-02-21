# Sciangai

A very simple wiki written in Perl using the Dancer framework.

# Intended audience

There's an audience?! Whoah, you could've told me!

I use this as a personal wiki either on localhost or behind HTTP auth on the
local LAN.  It is not safe (yet) to be used in any other fashion, but it does
the small job I need it for really well and quickly!

A sample nginx config if found at the end of the page

# License

The code is released under the same terms as Perl 5 itself.

# Features

- Uses MongoDB, for WEB SCALE!!
- Uses Text::MultiMarkdown for the pages
- Keeps older pages revisions around
- Uses (not yet) memcached

# Bugs

Where?! Please use the "issues" tab on Github to report them.

# Known bugs

- The revisions interface is clunky
- Some routes are not fully implemented

# How to make it work for you

    $ git clone ... ; cd Sciangai
    $ cpanm Cache::Memcached::Fast
    # you may have to force the above one
    $ cpanm Dancer
    # you may have to force HTTP::Server::Simple and retry
    $ cpanm Test::More MongoDB      \
        Text::MultiMarkdown         \
        Text::Xslate                \
        Dancer::Template::Xslate    \
        Cache::Memcached::Fast      \
        Plack::Middleware::Deflater \
        Plack::Middleware::Debug
    # if you want to run using starman:
    $ cpanm Starman

    $ perl bin/app.pl
    # webserver (development) will be on port 3000.

    # Production
    $ starman -E production --port 12345

# nginx config

    server {
        listen 80;
        server_name wiki.example.com;
        access_log /opt/nginx/log/wiki.example.com.access.log;
        location / {
            auth_basic                 "My Wiki";
            auth_basic_user_file       /opt/nginx/htpasswd;
            proxy_pass                 http://127.0.0.1:12345/;
            proxy_redirect             off;
            proxy_set_header           Host             $host;
            proxy_set_header           X-Real-IP        $remote_addr;
            proxy_set_header           X-Forwarded-For  $proxy_add_x_forwarded_for;
            proxy_max_temp_file_size   0;
            client_max_body_size       1m;
            client_body_buffer_size    64k;
            proxy_connect_timeout      20;
            proxy_send_timeout         20;
            proxy_read_timeout         20;
            proxy_buffer_size          4k;
            proxy_buffers              4 32k;
            proxy_busy_buffers_size    64k;
            proxy_temp_file_write_size 64k;
        }
    }

# See also:

- Dancer         - the Perl web framework
- PSGI and Plack - the new black? See http://perlvogue.com/
- Starman        - to deploy the app in production

# About the name

The webapp is a wiki. The word "wiki" comes from the hawaiian "wikiwiki".
A leghornese band ([Ottavo Padiglione](http://it.wikipedia.org/wiki/Ottavo_Padiglione))
created a wonderful song, "_Hawaii_ da _Shangai_" recalling those days,
as kids, running around the Shangai neighborhood of Leghorn,
oblivious to the hardship of life and the neighborhood.

    And in those summer nights,
    at the end of the railway,
    amongst the workers' houses,
    we could see the Hawaii.

In leghornese, that neighborhood's name is usually spelled "Sciangai".
