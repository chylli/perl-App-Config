use Test::Most 0.22 (tests => 3);
use Test::Warn;
use Data::Chronicle::Mock;
use App::Config;
use FindBin qw($Bin);

my $app_config;
my ($chronicle_r, $chronicle_w) = Data::Chronicle::Mock::get_mocked_chronicle();
lives_ok {
  $app_config = App::Config->new(definition_yml => "$Bin/test.yml",
                                 chronicle_reader => $chronicle_r,
                                 chronicle_writer => $chronicle_w,
                                );
}
'We are living';

ok($app_config->system->isa('App::Config::Attribute::Section'), 'system is a Section');
is_deeply($app_config->system->admins, [], "admins is empty by default");
