#########
# Author:        John O'Brien
# Maintainer:    $Author: mg8 $
# Created:       14 April 2009
# Last Modified: $Date: 2013-03-25 13:55:06 +0000 (Mon, 25 Mar 2013) $
# Id:            $Id: gc_bias.pm 16882 2013-03-25 13:55:06Z mg8 $
# $HeadURL: svn+ssh://intcvs1.internal.sanger.ac.uk/repos/svn/new-pipeline-dev/npg-qc/trunk/lib/npg_qc/autoqc/results/gc_bias.pm $
#

package npg_qc::autoqc::results::gc_bias;

use strict;
use warnings;
use Moose;

extends qw(npg_qc::autoqc::results::result);
with qw(npg_qc::autoqc::role::gc_bias);


our $VERSION = do { my ($r) = q$Revision: 16882 $ =~ /(\d+)/smx; $r; };

has 'max_y'                => ( is  => 'rw',
                                isa => 'Num',
);

has 'window_size'          => ( is  => 'rw',
                                isa => 'Int',
);

has 'window_count'         => ( is  => 'rw',
                                isa => 'Int',
);

has 'bin_count'            => ( is  => 'rw',
                                isa => 'Int',
);

has 'actual_quantile_x'    => ( is  => 'rw',
                                isa => 'ArrayRef',
);

has 'actual_quantile_y'    => ( is  => 'rw',
                                isa => 'ArrayRef',
);

has 'gc_lines'             => ( is  => 'rw',
                                isa => 'ArrayRef',
);

has 'plot_x'               => ( is  => 'rw',
                                isa => 'ArrayRef',
);

has 'plot_y'               => ( is  => 'rw',
                                isa => 'ArrayRef',
);

has 'ideal_lower_quantile' => ( is  => 'rw',
                                isa => 'ArrayRef',
);

has 'ideal_upper_quantile' => ( is  => 'rw',
                                isa => 'ArrayRef',
);

has 'cached_plot'          => ( is  => 'rw',
                                isa => 'Str',
);

no Moose;

1;

__END__


=head1 NAME

    npg_qc::autoqc::results::gc_bias

=head1 VERSION

    $Revision: 16882 $

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

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


