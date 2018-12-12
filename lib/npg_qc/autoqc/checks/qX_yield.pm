package npg_qc::autoqc::checks::qX_yield;

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;
use Readonly;
use Math::Round qw(round);
use Try::Tiny;

use npg_common::fastqcheck;

extends qw(npg_qc::autoqc::checks::check);

## no critic (Documentation::RequirePodAtEnd ProhibitParensWithBuiltins)
our $VERSION = '0';

=head1 NAME

npg_qc::autoqc::checks::qX_yield

=head1 SYNOPSIS

Inherits from npg_qc::autoqc::checks::check.
See description of attributes in the documentation for that module.

  my $check = npg_qc::autoqc::checks::qX_yield->new(id_run=>5, position=>1);

=head1 DESCRIPTION

A fast check capturing yield for a number of threshold qualities (20, 30, 40).

=head1 SUBROUTINES/METHODS

=cut

Readonly::Array  my @QUALITY_THRESHOLDS        => (20, 30, 40);
Readonly::Scalar my $EXT                       => 'fastqcheck';
Readonly::Scalar my $MIN_YIELD_THRESHOLD_KB_HS => 5_000_000;
Readonly::Scalar my $DEFAULT_READ_LENGTH_HS    => 75;
Readonly::Scalar my $THOUSAND                  => 1000;
Readonly::Scalar my $NA                        => -1;

has '+file_type'        => (default => $EXT,);

=head2 platform_is_hiseq

=cut

has 'platform_is_hiseq' => (isa => q[Bool], is  => q[ro],);

=head2 execute

=cut

override 'execute' => sub {
  my $self = shift;

  super();

  my @fnames = @{$self->input_files};
  my $short_fnames = $self->generate_filename_attr();

  $self->result->threshold_quality($QUALITY_THRESHOLDS[0]);
  my $count = 0;
  my @apass = ($NA, $NA);

  foreach my $filename (@fnames) {

      my $suffix = $count + 1;
      my $filename_method = "filename$suffix";
      $self->result->$filename_method($short_fnames->[$count]);

      my $fq = npg_common::fastqcheck->new(fastqcheck_path => $filename);
      my @values = map { round($_ / $THOUSAND) }
                   @{$fq->qx_yield(\@QUALITY_THRESHOLDS)};

      my $yield_method = "yield$suffix";
      $self->result->$yield_method($values[0]);
      my $yield_method_q = join q[_], $yield_method, q[q30];
      $self->result->$yield_method_q($values[1]);
      $yield_method_q = join q[_], $yield_method, q[q40];
      $self->result->$yield_method_q($values[2]);

      if (!defined $self->tag_index) {
          my $threshold = $self->_get_threshold($fq);
          if ($threshold != $NA) {
              my $threshold_yield_method = "threshold_yield$suffix";
              $self->result->$threshold_yield_method($threshold);
          } else {
              if ($self->result->$yield_method == 0 ) {
                  $threshold = 0;
              }
          }

          if ($threshold >= 0) {
              $apass[$count] = 0;
              if ($self->result->$yield_method > $threshold) {
                  $apass[$count] = 1;
              }
          }
      }
      $count++;
  }

  if ($self->num_components == 1 && !defined $self->composition->get_component(0)->tag_index) {
      my $pass = $self->overall_pass(\@apass, $count);
      if ($pass != $NA) {
          $self->result->pass($pass);
      }
  }

  return 1;
};


sub _get_threshold {
  my ($self, $fq) = @_;

  my $threshold = $NA;

  if ($self->num_components > 1) {
    return $threshold;
  }

  my $read_length = 0;
  try {
    $read_length = $fq->read_length();
  };
  if ($read_length <= 0) {
    return $threshold;
  }

  if($self->platform_is_hiseq()) {
    $threshold = $MIN_YIELD_THRESHOLD_KB_HS;
    if ($read_length != $DEFAULT_READ_LENGTH_HS) {
      $threshold = ($read_length * $threshold) / $DEFAULT_READ_LENGTH_HS;
    }
  }

  return round($threshold);
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item Moose

=item MooseX::StrictConstructor

=item namespace::autoclean

=item Readonly

=item Math::Round

=item Try::Tiny

=item npg_common::fastqcheck

=item npg_qc::autoqc::checks::check

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

Marina Gourtovaia E<lt>mg8@sanger.ac.ukE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2018 GRL

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
