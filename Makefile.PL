use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME               => 'App::Config',
    AUTHOR             => q{Binary.com <binary@cpan.org>},
    VERSION_FROM       => 'lib/App/Config.pm',
    ABSTRACT_FROM      => 'lib/App/Config.pm',
    LICENSE            => 'apache',
    PL_FILES           => {},
    MIN_PERL_VERSION   => 5.014,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More'              => 0,
        'Moose'                   => 0,
        'Data::Hash::DotNotation' => 0,
        'Data::Chronicle::Writer' => 0,
        'Data::Chronicle::Reader' => 0,
        'Data::Chronicle::Mock'   => 0,
        'YAML::XS'                => 0,
        'JSON::XS'                => 0,
        'Test::MockObject'        => 0,
        'Time::HiRes'             => 0,
    },
    PREREQ_PM => {
        'Moose'                   => 0,
        'Data::Hash::DotNotation' => 0,
        'Data::Chronicle::Writer' => 0,
        'Data::Chronicle::Reader' => 0,
        'YAML::XS'                => 0,
        'JSON::XS'                => 0,
        'Time::HiRes'             => 0,
    },
    dist => {
        COMPRESS => 'gzip -9f',
        SUFFIX   => 'gz',
    },
    clean => {FILES => 'App-Config-*'},
);
