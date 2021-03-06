#########
# Author:        dj3
# Maintainer:    $Author: dj3 $
# Created:       21 June 2009
# Last Modified: $Date: 2012-11-07 10:31:12 +0000 (Wed, 07 Nov 2012) $
# Id:            $Id: bam_flagstats.pm 16199 2012-11-07 10:31:12Z dj3 $
# $HeadURL: svn+ssh://svn.internal.sanger.ac.uk/repos/svn/new-pipeline-dev/npg-qc/branches/prerelease-51.0/lib/npg_qc/autoqc/results/bam_flagstats.pm $
#

package npg_qc::autoqc::results::spatial_filter;

use strict;
use warnings;
use Moose;
use Carp;
use Perl6::Slurp;

extends qw(npg_qc::autoqc::results::result);
with qw(npg_qc::autoqc::role::result);

use Readonly; Readonly::Scalar our $VERSION => do { my ($r) = q$Revision: 16199 $ =~ /(\d+)/mxs; $r; };

has '+path'               =>  (
                               required   => 0,
                                        );



has 'num_total_reads'              => (
                                       isa            => 'Maybe[Int]',
                                       is             => 'rw',
                                       required       => 0,
		                                );

has 'num_spatial_filter_fail_reads'=> (
                                       isa            => 'Maybe[Int]',
                                       is             => 'rw',
                                       required       => 0,
		                                );


sub parse_output{
  my ( $self, $stderr_output ) = @_;

#Processed 419675538 traces
#QC failed        0 traces

  my $log = slurp defined $stderr_output ? $stderr_output : \*STDIN;
  if($log=~/^Processed \s+ (\d+) \s+ traces$/smx) {$self->num_total_reads($1);}
  if($log=~/^(?:QC[ ]failed|Removed) \s+ (\d+) \s+ traces$/smx) {$self->num_spatial_filter_fail_reads($1);}

  return;
}


no Moose;

1;

__END__


=head1 NAME

    npg_qc::autoqc::results::spatial_filter

=head1 VERSION

    $Revision: 16199 $

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 SUBROUTINES/METHODS

=head2 parse_output - parse the spatial_filter stderr output and store relevant data in result object

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item Moose

=item npg_qc::autoqc::results::result

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

Author: David K. Jackson E<lt>david.jackson@sanger.ac.ukE<gt><gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2010 GRL, by David K. Jackson

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
