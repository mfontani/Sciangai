use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Sciangai',
    AUTHOR              => q{YOUR NAME <youremail@example.com>},
    VERSION_FROM        => 'lib/Sciangai.pm',
    ABSTRACT            => 'YOUR APPLICATION ABSTRACT',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'                   => 0,
        'YAML'                         => 0,
        'Dancer'                       => 1.3003,
        'MongoDB'                      => 0,
        'Text::MultiMarkdown'          => 0,
        'Dancer::Session::Cookie'      => 0,
        'Text::Xslate'                 => 0,
        'Dancer::Template::Xslate'     => 0,
        'Cache::Memcached::Fast'       => 0,
        'Plack::Middleware::Deflater'  => 0,
        'Plack::Middleware::Debug'     => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Sciangai-*' },
);
