#########
# Author:        John O'Brien
# Maintainer:    $Author: mg8 $
# Created:       14 April 2009
# Last Modified: $Date: 2013-03-20 09:55:43 +0000 (Wed, 20 Mar 2013) $
# Id:            $Id: contamination.pm 16861 2013-03-20 09:55:43Z mg8 $
# $HeadURL: svn+ssh://intcvs1.internal.sanger.ac.uk/repos/svn/new-pipeline-dev/npg-qc/trunk/lib/npg_qc/autoqc/results/contamination.pm $
#

package npg_qc::autoqc::results::contamination;

use strict;
use warnings;
use Moose;

extends qw(npg_qc::autoqc::results::result);
with qw(npg_qc::autoqc::role::contamination);

our $VERSION = do { my ($r) = q$Revision: 16861 $ =~ /(\d+)/smx; $r; };


has reference_version => ( is  => 'rw',
                           isa => 'Str', );


has contaminant_count => ( is  => 'rw',
                           isa => 'HashRef', );


has aligner_version   => ( is  => 'rw',
                           isa => 'Str', );


has genome_factor     => ( is  => 'rw',
                           isa => 'HashRef', );


has read_count        => ( is   => 'rw',
                           isa  => 'Int', );

no Moose;

1;

__END__


=head1 NAME

    npg_qc::autoqc::results::contamination

=head1 VERSION

    $Revision: 16861 $

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 reference_version

=head2 aligner_version

=head2 genome_factor

=head2 read_count

=head2 contaminant_count

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item Moose

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
