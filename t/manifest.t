#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

unless ($ENV{RELEASE_TESTING}) {
    plan(skip_all => "Author tests not required for installation");
}

my $min_tcm = 0.9;
eval "use Test::CheckManifest $min_tcm";

ok_manifest({exclude => [qw(/.travis.yml /.git)]});
