#########
# Author:        Marina Gourtovaia
# Maintainer:    $Author: mg8 $
# Created:       25 August 2010
# Last Modified: $Date: 2011-02-08 18:09:10 +0000 (Tue, 08 Feb 2011) $
# Id:            $Id: rpt_key.pm 12560 2011-02-08 18:09:10Z mg8 $
# $HeadURL: svn+ssh://intcvs1.internal.sanger.ac.uk/repos/svn/new-pipeline-dev/npg-qc/trunk/lib/npg_qc/autoqc/role/rpt_key.pm $
#

package npg_qc::autoqc::role::rpt_key;

use strict;
use warnings;
use Moose::Role;
use Carp;
use English qw(-no_match_vars);

use Readonly; Readonly::Scalar our $VERSION => do { my ($r) = q$Revision: 12560 $ =~ /(\d+)/smx; $r; };
## no critic (Documentation::RequirePodAtEnd)

Readonly::Scalar our $RPT_KEY_DELIM => q[:];
Readonly::Scalar our $RPT_KEY_MIN_LENGTH => 2;
Readonly::Scalar our $RPT_KEY_MAX_LENGTH => 3;

=head1 NAME

npg_qc::autoqc::role::rpt_key

=head1 VERSION

$Revision: 12560 $

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=cut


=head2 rpt_key

A string concatenating id_run, position and tag index (where present)

=cut
sub rpt_key {
    my ($obj, $other) = @_;

    my $key = join $RPT_KEY_DELIM, $obj->id_run, $obj->position;
    if ($obj->can('tag_index') && defined $obj->tag_index) {
        $key = join $RPT_KEY_DELIM, $key,  $obj->tag_index;
    }
    return $key;
}


=head2 inflate_rpt_key

Extract id_run, position and tag_index from rpt key and return as a hash ref

=cut
sub inflate_rpt_key {
    my ($self, $key) = @_;

    my @values = split /$RPT_KEY_DELIM/smx, $key;
    if (@values < $RPT_KEY_MIN_LENGTH || @values > $RPT_KEY_MAX_LENGTH) {
        croak qq[Invalid rpt key $key];
    }
    my $map = {};
    $map->{id_run} = $values[0];
    $map->{position} = $values[1];
    if (@values == $RPT_KEY_MAX_LENGTH) {
        $map->{tag_index} = $values[2];
    }
    return $map;
}


=head2 rpt_key_delim

A string used to concatenate rpt_key

=cut
sub rpt_key_delim {
    return $RPT_KEY_DELIM;
}


1;
__END__


=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item Moose::Role

=item Carp

=item English

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

Author: Marina Gourtovaia E<lt>mg8@sanger.ac.ukE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2010 GRL, by Marina Gourtovaia

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
