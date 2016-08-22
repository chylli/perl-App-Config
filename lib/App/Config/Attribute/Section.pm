package App::Config::Attribute::Section;

use Moose;
use namespace::autoclean;
extends 'App::Config::Node';

=head1 NAME

App::Config::Attribute::Section

=cut

__PACKAGE__->meta->make_immutable;
1;

=head1 NOTE

This class isn't intended for consumption outside of App::Config.

=cut
