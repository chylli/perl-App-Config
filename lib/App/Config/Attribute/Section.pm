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

=head1 AUTHOR

Arun Murali, C<< <arun at regentmarkets.com> >>

=head1 COPYRIGHT

(c) 2013- RMG Tech (Malaysia) Sdn Bhd

=cut
