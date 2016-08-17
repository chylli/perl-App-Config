#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

unless ($ENV{RELEASE_TESTING}) {
    plan(skip_all => "Author tests not required for installation");
}

# Ensure a recent version of Test::Pod::Coverage
my $min_tpc = 1.08;
eval "use Test::Pod::Coverage $min_tpc";

# Test::Pod::Coverage doesn't require a minimum Pod::Coverage version,
# but older versions don't recognize some common documentation styles
my $min_pc = 0.18;
eval "use Pod::Coverage $min_pc";

all_pod_coverage_ok();
