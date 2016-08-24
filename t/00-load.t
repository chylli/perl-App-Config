#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok('App::Config::Chronicle') || print "Bail out!\n";
}

diag("Testing App::Config::Chronicle $App::Config::Chronicle::VERSION, Perl $], $^X");
