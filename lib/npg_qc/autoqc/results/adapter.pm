#########
# Author:        John O'Brien and Marina Gourtovaia
# Maintainer:    $Author: mg8 $
# Created:       14 April 2009
# Last Modified: $Date: 2013-03-25 13:55:06 +0000 (Mon, 25 Mar 2013) $
# Id:            $Id: adapter.pm 16882 2013-03-25 13:55:06Z mg8 $
# $HeadURL: svn+ssh://intcvs1.internal.sanger.ac.uk/repos/svn/new-pipeline-dev/npg-qc/trunk/lib/npg_qc/autoqc/results/adapter.pm $
#

package npg_qc::autoqc::results::adapter;

use strict;
use warnings;
use Moose;

extends qw(npg_qc::autoqc::results::result);
with qw(npg_qc::autoqc::role::adapter);


our $VERSION = do { my ($r) = q$Revision: 16882 $ =~ /(\d+)/smx; $r; };


has forward_read_filename           => ( is  => 'rw',
                                         isa => 'Maybe[Str]', );


has reverse_read_filename           => ( is  => 'rw',
                                         isa => 'Maybe[Str]', );


has forward_fasta_read_count        => ( is  => 'rw',
                                         isa => 'Int', );


has forward_contaminated_read_count => ( is  => 'rw',
                                         isa => 'Int', );


has forward_blat_hash               => ( is  => 'rw',
                                         isa => 'HashRef', );


has reverse_fasta_read_count        => ( is  => 'rw',
                                         isa => 'Maybe[Int]', );


has reverse_contaminated_read_count => ( is  => 'rw',
                                         isa => 'Maybe[Int]', );


has reverse_blat_hash               => ( is  => 'rw',
                                         isa => 'Maybe[HashRef]', );

has forward_start_counts            => ( is  => 'rw',
                                         isa => 'Maybe[HashRef]', );
has reverse_start_counts            => ( is  => 'rw',
                                         isa => 'Maybe[HashRef]', );

no Moose;

1;

__END__


=head1 NAME

    npg_qc::autoqc::results::adapter

=head1 VERSION

    $Revision: 16882 $

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 forward_read_filename Filename for the first (forward) read 

=head2 reverse_read_filename Filename for the second (reverse) read

=head2 forward_fasta_read_count

=head2 forward_contaminated_read_count

=head2 forward_blat_hash

=head2 reverse_fasta_read_count

=head2 reverse_contaminated_read_count

=head2 reverse_blat_hash

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item Moose

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

Author: Marina Gourtovaia E<lt>mg8@sanger.ac.ukE<gt> and John O'Brien E<lt>jo3@sanger.ac.ukE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2010 GRL, by John O'Brien and Marina Gourtovaia

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
