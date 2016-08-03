package App::Config;

use 5.006;
use strict;
use warnings;

=head1 NAME

App::Config - The great new App::Config!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    my $app_config = App::Config->new;

=head1 DESCRIPTION

This module parses configuration files and provides interface to access
configuration information.

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

use Moose;
use namespace::autoclean;
use YAML::XS qw(LoadFile);

use App::Config::Attribute::Section;
use App::Config::Attribute::Global;
use Data::Hash::DotNotation;

use Data::Chronicle::Reader;
use Data::Chronicle::Writer;

has definition_yml =>  (
                        is => 'ro',
                        isa => 'String',
                        required => 1,
                       );

has chronicle_reader => (
                         is  => 'ro',
                         isa => 'Data::Chronicle::Reader',
                        );

has chronicle_writer => (
                         is  => 'ro',
                         isa => 'Data::Chronicle::Writer',
                        );



sub check_for_update {
    my $self     = shift;
    my $data_set = $self->data_set;

    my $app_settings = self->chronicle_reader->get('app_settings', 'binary');

    if ($app_settings and $data_set) {
        my $db_version = $app_settings->{_rev};
        unless ($data_set->{version} and $db_version and $db_version eq $data_set->{version}) {
            $self->_add_app_setttings($data_set, $app_settings);
        }
    }

    return;
}

# definitions database
has _defdb => (
    is      => 'rw',
    lazy    => 1,
    default => sub { LoadFile(shift->definition_yml) },
);

has 'data_set' => (
    is         => 'ro',
    lazy_build => 1,
);

sub _build_class {
    my $self = shift;
    $self->_create_attributes($self->_defdb, $self);
    return;
}

sub _create_attributes {
    my $self               = shift;
    my $definitions        = shift;
    my $containing_section = shift;

    $containing_section->meta->make_mutable;
    foreach my $definition_key (keys %{$definitions}) {
        $self->_validate_key($definition_key, $containing_section);
        my $definition = $definitions->{$definition_key};
        if ($definition->{isa} eq 'section') {
            $self->_create_section($containing_section, $definition_key, $definition);
            $self->_create_attributes($definition->{contains}, $containing_section->$definition_key);
        } elsif ($definition->{global}) {
            $self->_create_global_attribute($containing_section, $definition_key, $definition);
        } else {
            $self->_create_generic_attribute($containing_section, $definition_key, $definition);
        }
    }
    $containing_section->meta->make_immutable;

    return;
}

sub _create_section {
    my $self       = shift;
    my $section    = shift;
    my $name       = shift;
    my $definition = shift;

    my $writer      = "_$name";
    my $path_config = {};
    if ($section->isa('App::Config::Attribute::Section')) {
        $path_config = {parent_path => $section->path};
    }

    my $new_section = Moose::Meta::Class->create_anon_class(superclasses => ['App::Config::Attribute::Section'])->new_object(
        name       => $name,
        definition => $definition,
        data_set   => {},
        %$path_config
    );

    $section->meta->add_attribute(
        $name,
        is            => 'ro',
        isa           => 'App::Config::Attribute::Section',
        writer        => $writer,
        documentation => $definition->{description},
    );
    $section->$writer($new_section);

    #Force Moose Validation
    $section->$name;

    return;
}

sub _create_global_attribute {
    my $self       = shift;
    my $section    = shift;
    my $name       = shift;
    my $definition = shift;

    my $attribute = $self->_add_attribute('App::Config::Attribute::Global', $section, $name, $definition);
    $self->_add_dynamic_setting_info($attribute->path, $definition);

    return;
}

sub _create_generic_attribute {
    my $self       = shift;
    my $section    = shift;
    my $name       = shift;
    my $definition = shift;

    $self->_add_attribute('App::Config::Attribute', $section, $name, $definition);

    return;
}

sub _add_attribute {
    my $self       = shift;
    my $attr_class = shift;
    my $section    = shift;
    my $name       = shift;
    my $definition = shift;

    my $fake_name = "a_$name";
    my $writer    = "_$fake_name";

    my $attribute = $attr_class->new(
        name        => $name,
        definition  => $definition,
        parent_path => $section->path,
        data_set    => $self->data_set,
    )->build;

    $section->meta->add_attribute(
        $fake_name,
        is      => 'ro',
        handles => {
            $name          => 'value',
            'has_' . $name => 'has_value',
        },
        documentation => $definition->{description},
        writer        => $writer,
    );

    $section->$writer($attribute);

    return $attribute;
}

sub _validate_key {
    my $self    = shift;
    my $key     = shift;
    my $section = shift;

    if (grep { $key eq $_ } qw(path parent_path name definition version data_set check_for_update save_dynamic)) {
        die "Variable with name $key found under "
            . $section->path
            . ".\n$key is an internally used variable and cannot be reused, please use a different name";
    }

    return;
}

sub save_dynamic {
    my $self = shift;
    my $settings = $self->chronicle_reader->get('app_settings', 'binary') || {};

    #Cleanup globals
    my $global = Data::Hash::DotNotation->new();
    foreach my $key (keys %{$self->dynamic_settings_info->{global}}) {
        if ($self->data_set->{global}->key_exists($key)) {
            $global->set($key, $self->data_set->{global}->get($key));
        }
    }

    $settings->{global} = $global->data;
    $settings->{_rev}   = time;
    $self->chronicle_writer->set('app_settings', 'binary', $settings);

    return 1;
}

sub current_revision {
    my $self = shift;
    my $settings = $self->chronicle_reader->get('app_settings', 'binary');
    return $settings->{_rev};
}

sub _build_data_set {
    my $self = shift;

    # relatively small yaml, so loading it shouldn't be expensive.
    my $data_set->{app_config} = Data::Hash::DotNotation->new(data => {});

    $self->_add_app_setttings($data_set, $self->chronicle_reader->get('app_settings', 'binary') || {});

    return $data_set;
}

sub _add_app_setttings {
    my $self         = shift;
    my $data_set     = shift;
    my $app_settings = shift;

    if ($app_settings) {
        $data_set->{global} = Data::Hash::DotNotation->new(data => $app_settings->{global});
        $data_set->{version} = $app_settings->{_rev};
    }

    return;
}

has dynamic_settings_info => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} },
);

sub _add_dynamic_setting_info {
    my $self       = shift;
    my $path       = shift;
    my $definition = shift;

    $self->dynamic_settings_info = {} unless ($self->dynamic_settings_info);
    $self->dynamic_settings_info->{global} = {} unless ($self->dynamic_settings_info->{global});

    $self->dynamic_settings_info->{global}->{$path} = {
        type        => $definition->{isa},
        default     => $definition->{default},
        description => $definition->{description}};

    return;
}

sub BUILD {
    my $self = shift;

    $self->_build_class;

    return;
}

__PACKAGE__->meta->make_immutable;

1;

=head1 AUTHOR

Binary.com, C<< <support at binary.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-app-config at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-Config>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::Config


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-Config>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-Config>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-Config>

=item * Search CPAN

L<http://search.cpan.org/dist/App-Config/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2016 Binary.com.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of App::Config
