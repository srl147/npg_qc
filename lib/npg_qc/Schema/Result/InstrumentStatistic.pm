
package npg_qc::Schema::Result::InstrumentStatistic;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

##no critic(RequirePodAtEnd RequirePodLinksIncludeText ProhibitMagicNumbers ProhibitEmptyQuotes)

=head1 NAME

npg_qc::Schema::Result::InstrumentStatistic

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::InflateColumn::Serializer>

=back

=cut

__PACKAGE__->load_components('InflateColumn::DateTime', 'InflateColumn::Serializer');

=head1 TABLE: C<instrument_statistics>

=cut

__PACKAGE__->table('instrument_statistics');

=head1 ACCESSORS

=head2 id_instrument_statistics

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 id_run

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 end

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 id_run_actual

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 instrument

  data_type: 'tinytext'
  is_nullable: 0

=head2 num_tile_low_cluster

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 num_tile_high_cluster

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 num_tile_high_intensity

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 num_tile_low_intensity

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 num_tile_high_error

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 num_tile_movez_out

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  'id_instrument_statistics',
  {
    data_type => 'bigint',
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  'id_run',
  { data_type => 'bigint', extra => { unsigned => 1 }, is_nullable => 0 },
  'end',
  { data_type => 'tinyint', extra => { unsigned => 1 }, is_nullable => 0 },
  'id_run_actual',
  { data_type => 'bigint', extra => { unsigned => 1 }, is_nullable => 0 },
  'instrument',
  { data_type => 'tinytext', is_nullable => 0 },
  'num_tile_low_cluster',
  { data_type => 'smallint', extra => { unsigned => 1 }, is_nullable => 1 },
  'num_tile_high_cluster',
  { data_type => 'smallint', extra => { unsigned => 1 }, is_nullable => 1 },
  'num_tile_high_intensity',
  { data_type => 'smallint', extra => { unsigned => 1 }, is_nullable => 1 },
  'num_tile_low_intensity',
  { data_type => 'smallint', extra => { unsigned => 1 }, is_nullable => 1 },
  'num_tile_high_error',
  { data_type => 'smallint', extra => { unsigned => 1 }, is_nullable => 1 },
  'num_tile_movez_out',
  { data_type => 'smallint', extra => { unsigned => 1 }, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id_instrument_statistics>

=back

=cut

__PACKAGE__->set_primary_key('id_instrument_statistics');

=head1 UNIQUE CONSTRAINTS

=head2 C<idx_id_run_end>

=over 4

=item * L</id_run>

=item * L</end>

=back

=cut

__PACKAGE__->add_unique_constraint('idx_id_run_end', ['id_run', 'end']);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2014-02-23 17:42:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KQYC841TNC5Qok4lcgoVRw

our $VERSION   = do { my ($r) = q$Revision: 18173 $ =~ /(\d+)/mxs; $r; };

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 VERSION

$Revision: 18173 $

=head1 SYNOPSIS

=head1 DESCRIPTION

Result class definition in DBIx binding for npg-qc database.

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 SUBROUTINES/METHODS

=head1 DEPENDENCIES

=over

=item strict

=item warnings

=item Moose

=item MooseX::NonMoose

=item MooseX::MarkAsMethods

=item DBIx::Class::Core

=item DBIx::Class::InflateColumn::DateTime

=item DBIx::Class::InflateColumn::Serializer

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

Marina Gourtovaia E<lt>mg8@sanger.ac.ukE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2014 GRL, by Marina Gourtovaia

This file is part of NPG.

NPG is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut

