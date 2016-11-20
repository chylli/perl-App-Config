requires 'perl', '5.014';

requires 'Data::Chronicle::Reader';
requires 'Data::Chronicle::Writer';
requires 'Data::Hash::DotNotation';
requires 'JSON::XS';
requires 'Moose';
requires 'Time::HiRes';
requires 'YAML::XS';
requires 'namespace::autoclean';

on test => sub {
    requires 'Test::MockObject';
    requires 'Test::More', '>= 0.98';
};
