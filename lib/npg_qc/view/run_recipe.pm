#########
# Author:        gq1
# Maintainer:    $Author: jo3 $
# Created:       2009-01-20
# Last Modified: $Date: 2010-03-30 16:40:28 +0100 (Tue, 30 Mar 2010) $
# Id:            $Id: run_recipe.pm 8943 2010-03-30 15:40:28Z jo3 $
# $HeadURL: svn+ssh://intcvs1.internal.sanger.ac.uk/repos/svn/new-pipeline-dev/npg-qc/trunk/lib/npg_qc/view/run_recipe.pm $
#

package npg_qc::view::run_recipe;
use strict;
use warnings;
use base qw(npg_qc::view);
use Readonly;
use Carp;
use English qw(-no_match_vars);

our $VERSION = do { my ($r) = q$Revision: 8943 $ =~ /(\d+)/mxs; $r; };

sub read_xml{
  my ($self) = @_;
  my $cgi   = $self->util->cgi();
  my $model = $self->model();
  my $id_run_recipe = $model->id_run_recipe();
  $model = npg_qc::model::run_recipe->new({util => $self->util(),id_run => $id_run_recipe});
  $self->model($model);

  return 1;
}

1;
__END__
=head1 NAME

npg_qc::view::run_recipe

=head1 VERSION

$Revision: 8943 $

=head1 SYNOPSIS

  my $o = npg_qc::view::offset->new({util => $util});

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 read_xml - convert the current primary key id_run_recipe to id_run and return the recipe xml

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

strict
warnings
npg_qc::view

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

Guoying Qi, E<lt>gq1@sanger.ac.ukE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2010 GRL, by Andy Brown

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
