#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::CheckManifest 0.9;

ok_manifest({exclude => [qw(/.travis.yml /.git)]});
