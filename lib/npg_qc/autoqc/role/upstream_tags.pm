#########
# Author:        Kevin Lewis
# Maintainer:    $Author: kl2 $
# Created:       30 August 2013
# Last Modified: $Date: 2013-09-06 17:03:56 +0100 (Fri, 06 Sep 2013) $
# Id:            $Id: upstream_tags.pm 17453 2013-09-06 16:03:56Z kl2 $
# $HeadURL: svn+ssh://intcvs1.internal.sanger.ac.uk/repos/svn/new-pipeline-dev/npg-qc/trunk/lib/npg_qc/autoqc/role/upstream_tags.pm $
#

package npg_qc::autoqc::role::upstream_tags;

use strict;
use warnings;
use Moose::Role;
use Readonly;

with qw(npg_qc::autoqc::role::result);

our $VERSION = do { my ($r) = q$Revision: 17453 $ =~ /(\d+)/smx; $r; };

sub criterion {
	my $self = shift;

	return q[Currently no pass/fail levels set];
}

no Moose;

1;

__END__


=head1 NAME

    npg_qc::autoqc::role::upstream_tags

=head1 VERSION

    $Revision: 17453 $

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 criterion

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item Moose::Role

=item Readonly

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

Author: Kevin Lewis E<lt>kl2@sanger.ac.ukE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2013 GRL, by Kevin Lewis

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
