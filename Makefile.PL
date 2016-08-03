use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'App::Config',
    AUTHOR           => q{Binary.com <support@binary.com>},
    VERSION_FROM     => 'lib/App/Config.pm',
    ABSTRACT_FROM    => 'lib/App/Config.pm',
    LICENSE          => 'apache',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
        'Moose'      => 0,
    },
    PREREQ_PM => {
        'Moose'      => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'App-Config-*' },
);
