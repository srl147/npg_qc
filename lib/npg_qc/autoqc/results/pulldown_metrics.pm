#########
# Author:        Marina Gourtovaia
# Maintainer:    $Author: kl2 $
# Created:       27 April 2012
# Last Modified: $Date: 2013-04-23 10:24:42 +0100 (Tue, 23 Apr 2013) $
# Id:            $Id: pulldown_metrics.pm 17067 2013-04-23 09:24:42Z kl2 $
# $HeadURL: svn+ssh://intcvs1.internal.sanger.ac.uk/repos/svn/new-pipeline-dev/npg-qc/trunk/lib/npg_qc/autoqc/results/pulldown_metrics.pm $
#

package npg_qc::autoqc::results::pulldown_metrics;

use Moose;

extends qw(npg_qc::autoqc::results::result);
with qw(npg_qc::autoqc::role::pulldown_metrics);

use Readonly; Readonly::Scalar our $VERSION => do { my ($r) = q$Revision: 17067 $ =~ /(\d+)/smx; $r; };
## no critic (Documentation::RequirePodAtEnd)

=head1 NAME

  npg_qc::autoqc::results::pulldown_metrics

=head1 VERSION

  $Revision: 17067 $

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 bait_path

An absolute path to the directory with intervals files.

=cut
has 'bait_path'    => (isa        => 'Maybe[Str]',
                       is         => 'rw',
                       required   => 0,
		      );

=head2 bait_territory

The number of bases which have one or more baits on top of them. BAIT_TERRITORY in Picard metrics.

=cut
has 'bait_territory' => (isa        => 'Maybe[Int]',
                         is         => 'rw',
                         required   => 0,
		        );

=head2 target_territory

The unique number of target bases in the experiment where target is usually exons etc. TARGET_TERRITORY in Picard metrics.

=cut
has 'target_territory' => (isa        => 'Maybe[Int]',
                           is         => 'rw',
                           required   => 0,
		          );


=head2 total_reads_num

The total number of reads in the input BAM file. TOTAL_READS and PF_READS in Picard metrics.

=cut
has 'total_reads_num' =>  (isa        => 'Maybe[Int]',
                           is         => 'rw',
                           required   => 0,
		          );

=head2 unique_reads_num

The number of reads that are not marked as duplicates. PF_UNIQUE_READS in Picard metrics.

=cut
has 'unique_reads_num' =>  (isa        => 'Maybe[Int]',
                            is         => 'rw',
                            required   => 0,
		           );

=head2 unique_reads_aligned_num

The number of PF unique reads that are aligned with mapping score > 0 to the reference genome. PF_UQ_READS_ALIGNED in Picard metrics.

=cut
has 'unique_reads_aligned_num' =>  (isa        => 'Maybe[Int]',
                                    is         => 'rw',
                                    required   => 0,
		                   );

=head2 unique_bases_aligned_num

 The number of PF unique reads that are aligned with mapping score > 0 to the reference genome. PF_UQ_BASES_ALIGNED in Picard metrics. 

=cut
has 'unique_bases_aligned_num' =>  (isa        => 'Maybe[Int]',
                                    is         => 'rw',
                                    required   => 0,
		                   );

=head2 on_bait_bases_num

 The number of PF aligned bases that mapped to a baited region of the genome. ON_BAIT_BASES in Picard metrics. 

=cut
has 'on_bait_bases_num' =>         (isa        => 'Maybe[Int]',
                                    is         => 'rw',
                                    required   => 0,
		                   );

=head2 near_bait_bases_num

 The number of PF aligned bases that mapped to within a fixed interval of a baited region, but not on a baited region. NEAR_BAIT_BASES in Picard metrics. 

=cut
has 'near_bait_bases_num' =>      (isa        => 'Maybe[Int]',
                                    is         => 'rw',
                                    required   => 0,
		                   );

=head2 off_bait_bases_num

 The number of PF aligned bases that mapped to neither on or near a bait. OFF_BAIT_BASES in Picard metrics. 

=cut
has 'off_bait_bases_num' =>        (isa        => 'Maybe[Int]',
                                    is         => 'rw',
                                    required   => 0,
		                   );

=head2 on_target_bases_num

 The number of PF aligned bases that mapped to a targetted region of the genome. ON_TARGET_BASES in Picard metrics. 

=cut
has 'on_target_bases_num' =>       (isa        => 'Maybe[Int]',
                                    is         => 'rw',
                                    required   => 0,
		                   );

=head2 mean_bait_coverage

 The mean coverage of all baits in the experiment. MEAN_BAIT_COVERAGE in Picard metrics. 

=cut
has 'mean_bait_coverage' =>        (isa        => 'Maybe[Num]',
                                    is         => 'rw',
                                    required   => 0,
		                   );

=head2 mean_target_coverage

 The mean coverage of targets that recieved at least coverage depth = 2 at one base. MEAN_TARGET_COVERAGE in Picard metrics. 

=cut
has 'mean_target_coverage' =>      (isa        => 'Maybe[Num]',
                                    is         => 'rw',
                                    required   => 0,
		                   );

=head2 fold_enrichment

 The fold by which the baited region has been amplified above genomic background. FOLD_ENRICHMENT in Picard metrics. 

=cut
has 'fold_enrichment' =>           (isa        => 'Maybe[Num]',
                                    is         => 'rw',
                                    required   => 0,
		                   );

=head2 zero_coverage_targets_fraction

 The fraction of targets that did not reach coverage=2 over any base. ZERO_CVG_TARGETS_PCT in Picard metrics. 

=cut
has 'zero_coverage_targets_fraction' =>      (isa        => 'Maybe[Num]',
                                              is         => 'rw',
                                              required   => 0,
		                             );

=head2 library_size

 The estimated number of unique molecules in the selected part of the library. HS_LIBRARY_SIZE in Picard metrics. 

=cut
has 'library_size' =>              (isa        => 'Maybe[Int]',
                                    is         => 'rw',
                                    required   => 0,
		                   );


=head2 other_metrics

 All remaining Picard HS metrics as a key-values pairs

=cut

has 'other_metrics'  =>             (isa        => 'HashRef',
                                     is         => 'rw',
                                     required   => 0,
		                    );

=head2 interval_files_identical

 Flag to indicate that the bait and target interval files are identical (so disregard "on-target" metrics)

=cut
has 'interval_files_identical' =>      (isa        => 'Maybe[Bool]',
                                              is         => 'rw',
                                              required   => 0,
		                             );

no Moose;

1;

__END__

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item Moose

=item Readonly

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

Author: Marina Gourtovaia<lt>mg8@sanger.ac.ukE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2012 GRL, by Marina Gourtovaia

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
