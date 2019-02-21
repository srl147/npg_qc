package npg_qc::autoqc::role::illumina_analysis;

use Moose::Role;
use Carp;

our $VERSION = '0';

## no critic (Documentation::RequirePodAtEnd)

=head1 NAME

npg_qc::autoqc::role::illumina_analysis

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 aligned_mean

aligned_mean

=cut
sub aligned_mean {
    my $self = shift;
    my $result = undef;
    my $lane_metrics = $self->lane_metrics();
    if (exists($lane_metrics->{'aligned_mean'})) {
        $result = $lane_metrics->{'aligned_mean'};
    }
    return $result;
}
    
=head2 aligned_stdev

aligned_stdev

=cut
sub aligned_stdev {
    my $self = shift;
    my $result = undef;
    my $lane_metrics = $self->lane_metrics();
    if (exists($lane_metrics->{'aligned_stdev'})) {
        $result = $lane_metrics->{'aligned_stdev'};
    }
    return $result;
}
    
=head2 cluster_count_mean

cluster_count_mean

=cut
sub cluster_count_mean {
    my $self = shift;
    my $result = undef;
    my $lane_metrics = $self->lane_metrics();
    if ( exists($lane_metrics->{'cluster_count_mean'})) {
        $result = $lane_metrics->{'cluster_count_mean'};
    }
    return $result;
}
    
=head2 cluster_count_pf_mean

cluster_count_pf_mean

=cut
sub cluster_count_pf_mean {
    my $self = shift;
    my $result = undef;
    my $lane_metrics = $self->lane_metrics();
    if ( exists($lane_metrics->{'cluster_count_pf_mean'})) {
        $result = $lane_metrics->{'cluster_count_pf_mean'};
    }
    return $result;
}
    
=head2 cluster_count_pf_stdev

cluster_count_pf_stdev

=cut
sub cluster_count_pf_stdev {
    my $self = shift;
    my $result = undef;
    my $lane_metrics = $self->lane_metrics();
    if ( exists($lane_metrics->{'cluster_count_pf_stdev'})) {
        $result = $lane_metrics->{'cluster_count_pf_stdev'};
    }
    return $result;
}
    
=head2 cluster_count_pf_total

cluster_count_pf_total

=cut
sub cluster_count_pf_total {
    my $self = shift;
    my $result = undef;
    my $lane_metrics = $self->lane_metrics();
    if ( exists($lane_metrics->{'cluster_count_pf_total'})) {
        $result = $lane_metrics->{'cluster_count_pf_total'};
    }
    return $result;
}
    
=head2 cluster_count_stdev

cluster_count_stdev

=cut
sub cluster_count_stdev {
    my $self = shift;
    my $result = undef;
    my $lane_metrics = $self->lane_metrics();
    if ( exists($lane_metrics->{'cluster_count_stdev'})) {
        $result = $lane_metrics->{'cluster_count_stdev'};
    }
    return $result;
}
    
=head2 cluster_count_total

cluster_count_total

=cut
sub cluster_count_total {
    my $self = shift;
    my $result = undef;
    my $lane_metrics = $self->lane_metrics();
    if ( exists($lane_metrics->{'cluster_count_total'})) {
        $result = $lane_metrics->{'cluster_count_total'};
    }
    return $result;
}
    
=head2 cluster_density_mean

cluster_density_mean

=cut
sub cluster_density_mean {
    my $self = shift;
    my $result = undef;
    my $lane_metrics = $self->lane_metrics();
    if ( exists($lane_metrics->{'cluster_density_mean'})) {
        $result = $lane_metrics->{'cluster_density_mean'};
    }
    return $result;
}
    
=head2 cluster_density_pf_mean

cluster_density_pf_mean

=cut
sub cluster_density_pf_mean {
    my $self = shift;
    my $result = undef;
    my $lane_metrics = $self->lane_metrics();
    if ( exists($lane_metrics->{'cluster_density_pf_mean'})) {
        $result = $lane_metrics->{'cluster_density_pf_mean'};
    }
    return $result;
}
    
=head2 cluster_density_pf_stdev

cluster_density_pf_stdev

=cut
sub cluster_density_pf_stdev {
    my $self = shift;
    my $result = undef;
    my $lane_metrics = $self->lane_metrics();
    if ( exists($lane_metrics->{'cluster_density_pf_stdev'})) {
        $result = $lane_metrics->{'cluster_density_pf_stdev'};
    }
    return $result;
}
    
=head2 cluster_density_stdev

cluster_density_stdev

=cut
sub cluster_density_stdev {
    my $self = shift;
    my $result = undef;
    my $lane_metrics = $self->lane_metrics();
    if ( exists($lane_metrics->{'cluster_density_stdev'})) {
        $result = $lane_metrics->{'cluster_density_stdev'};
    }
    return $result;
}
    
=head2 cluster_pf_mean

cluster_pf_mean

=cut
sub cluster_pf_mean {
    my $self = shift;
    my $result = undef;
    my $lane_metrics = $self->lane_metrics();
    if ( exists($lane_metrics->{'cluster_pf_mean'})) {
        $result = $lane_metrics->{'cluster_pf_mean'};
    }
    return $result;
}
    
=head2 cluster_pf_stdev

cluster_pf_stdev

=cut
sub cluster_pf_stdev {
    my $self = shift;
    my $result = undef;
    my $lane_metrics = $self->lane_metrics();
    if ( exists($lane_metrics->{'cluster_pf_stdev'})) {
        $result = $lane_metrics->{'cluster_pf_stdev'};
    }
    return $result;
}
    
=head2 occupied_mean

occupied_mean

=cut
sub occupied_mean {
    my $self = shift;
    my $result = undef;
    my $lane_metrics = $self->lane_metrics();
    if ( exists($lane_metrics->{'occupied_mean'})) {
        $result = $lane_metrics->{'occupied_mean'};
    }
    return $result;
}
    
=head2 occupied_stdev

occupied_stdev

=cut
sub occupied_stdev {
    my $self = shift;
    my $result = undef;
    my $lane_metrics = $self->lane_metrics();
    if ( exists($lane_metrics->{'occupied_stdev'})) {
        $result = $lane_metrics->{'occupied_stdev'};
    }
    return $result;
}
    
no Moose::Role;

1;
__END__

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item Moose::Role

=item Carp

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

Steven Leonard E<lt>srl@sanger.ac.ukE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2019 GRL

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
