#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'App::Config' ) || print "Bail out!\n";
}

diag( "Testing App::Config $App::Config::VERSION, Perl $], $^X" );
