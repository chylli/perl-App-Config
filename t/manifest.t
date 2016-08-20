#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More => 1;
use Test::CheckManifest 0.9;

ok_manifest({exclude => [qw(/.travis.yml /.git)]});
