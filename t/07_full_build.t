use Test::Most 0.22 (tests => 8);
use Test::Warn;
use Data::Chronicle::Mock;
use App::Config;
use FindBin qw($Bin);

my $app_config;
my ($chronicle_r, $chronicle_w) = Data::Chronicle::Mock::get_mocked_chronicle();
lives_ok {
    $app_config = App::Config->new(
        definition_yml   => "$Bin/test.yml",
        chronicle_reader => $chronicle_r,
        chronicle_writer => $chronicle_w,
    );
}
'We are living';

ok($app_config->system->isa('App::Config::Attribute::Section'), 'system is a Section');
is_deeply($app_config->system->admins, [], "admins is empty by default");
my $old_revision = $app_config->current_revision;
$app_config->system->email('test@abc.com');
$app_config->save_dynamic;
is_deeply($app_config->system->email, 'test@abc.com', "email is updated");
my $new_revision = $app_config->current_revision;
isnt($new_revision, $old_revision, "revision updated");
my $app_config2 = App::Config->new(
    definition_yml   => "$Bin/test.yml",
    chronicle_reader => $chronicle_r,
    chronicle_writer => $chronicle_w,
);
is($app_config2->current_revision, $new_revision,  "revision is correct even if we create a new instance");
is($app_config2->system->email,    'test@abc.com', "email is updated");
$app_config->system->email('test2@abc.com');
$app_config->save_dynamic;
$app_config2->check_for_update;
is($app_config2->system->email, 'test2@abc.com', "check_for_update worked");
