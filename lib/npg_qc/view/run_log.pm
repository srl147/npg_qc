#########
# Author:        ajb
# Maintainer:    $Author: jo3 $
# Created:       2008-09-25
# Last Modified: $Date: 2010-03-30 16:40:28 +0100 (Tue, 30 Mar 2010) $
# Id:            $Id: run_log.pm 8943 2010-03-30 15:40:28Z jo3 $
# $HeadURL: svn+ssh://intcvs1.internal.sanger.ac.uk/repos/svn/new-pipeline-dev/npg-qc/trunk/lib/npg_qc/view/run_log.pm $
#

package npg_qc::view::run_log;
use strict;
use warnings;
use base qw(npg_qc::view);
use English qw{-no_match_vars};
use Carp;
use npg_qc::model::run_log;
use Readonly;

our $VERSION = do { my ($r) = q$Revision: 8943 $ =~ /(\d+)/mxs; $r; };

1;
__END__
=head1 NAME

npg_qc::view::run_log

=head1 VERSION

$Revision: 8943 $

=head1 SYNOPSIS

  my $oRunLog = npg_qc::view::run_log->new({util => $util});

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 new - inherited from base class, sets up object, passing into it the arguments given, and determining user

=head2 authorised - inherited from base class, only showing analysis data, at this time all are authorised

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

strict
warnings
npg_qc::view
English
Carp
npg_qc::model::run_log
Readonly

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

Andy Brown, E<lt>ajb@sanger.ac.ukE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2010 GRL, by Andy Brown

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
