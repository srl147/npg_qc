#########
# Author:        John O'Brien
# Maintainer:    $Author: mg8 $
# Created:       14 April 2009
# Last Modified: $Date: 2013-03-20 09:55:43 +0000 (Wed, 20 Mar 2013) $
# Id:            $Id: contamination.pm 16861 2013-03-20 09:55:43Z mg8 $
# $HeadURL: svn+ssh://intcvs1.internal.sanger.ac.uk/repos/svn/new-pipeline-dev/npg-qc/trunk/lib/npg_qc/autoqc/role/contamination.pm $
#

package npg_qc::autoqc::role::contamination;

use strict;
use warnings;
use Moose::Role;
use Readonly;

with qw(npg_qc::autoqc::role::result);

our $VERSION = do { my ($r) = q$Revision: 16861 $ =~ /(\d+)/smx; $r; };


Readonly::Scalar my $PERCENT => 100;

sub normalised_contamination {
    my ($self) = @_;

    if (!defined $self->contaminant_count || !defined $self->genome_factor) {
        return;
    }

    my %contaminant_count = %{ $self->contaminant_count() };
    my %genome_correction = %{ $self->genome_factor() };
    my $fastq_size        = $self->read_count();
    return if $fastq_size == 0;

    my %normalized_value;

    foreach my $organism ( keys %contaminant_count ) {
        my $raw_count = $contaminant_count{$organism};
        my $value =  ( $raw_count / $fastq_size )
                             * $genome_correction{$organism}
                             * $PERCENT;
        $normalized_value{$organism} = sprintf '%.1f', $value;
    }

    return \%normalized_value;
}


sub ranked_organisms {
    my ($self) = @_;

    my %normalized = %{ $self->normalised_contamination() || {} };

    my @ranked_organisms =
        reverse sort { $normalized{$a} <=> $normalized{$b} } keys %normalized;

    return \@ranked_organisms;
}


no Moose;

1;

__END__


=head1 NAME

    npg_qc::autoqc::role::contamination

=head1 VERSION

    $Revision: 16861 $

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 normalised_contamination

    Normalise the raw contaminant counts by dividing by the total number of
    reads and multiplying by a factor that accounts for how much of the
    organism's genome is represented in the reference sequence. Return a
    hashref with the organism names as keys.

=head2 ranked_organisms

    Sort the organisms represented in the reference sequence by descending
    order of their normalised contamination values. Return this list as an
    array reference.

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item Moose::Role

=item Readonly

=item strict

=item warnings

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

Author: John O'Brien E<lt>jo3@sanger.ac.ukE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2010 GRL, by John O'Brien

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
