#########
# Maintainer:    $Author: ejz $
# Last Modified: $Date: 2012-04-02 15:17:16 +0100 (Mon, 02 Apr 2012) $ $Author: mg8 $
# Id:            $Id: Makefile.PL 15422 2012-04-02 14:17:16Z mg8 $
# Source:        $Source: /cvsroot/Bio-DasLite/Bio-DasLite/Makefile.PL,v $
# Revision:      $Revision: $
# $HeadURL: svn+ssh://svn.internal.sanger.ac.uk/repos/svn/new-pipeline-dev/npg-qc/branches/prerelease-52.0/Build.PL $
#

use strict;
use warnings;
use Module::Build;


my $class = Module::Build->subclass(code => <<'EOF');

  my $blibr = q[blib/lib/R];

  sub ACTION_install {
    my $self = shift;
    if (!$ENV{'NPG_QC_WEB_INSTALL'}) {
      my $blibr = q[blib/lib/R];
      `mkdir -p $blibr`;
      `cp -vu lib/R/gc_bias_data.R $blibr`;
    }
    $self->SUPER::ACTION_install;
  }

  sub ACTION_webinstall {
    my $self = shift;
    if ($ENV{'NPG_QC_WEB_INSTALL'}) {
      $self->install_path('data' => join q{/}, $self->install_base(), 'data');
      $self->add_build_element('data');
      $self->install_path('htdocs' => join q{/}, $self->install_base(), 'htdocs');
      $self->add_build_element('htdocs');
      $self->install_path('cgi-bin' => join q{/}, $self->install_base(), 'cgi-bin');
      $self->add_build_element('cgi'); 
    } else {
      warn "WARNING: 'NPG_QC_WEB_INSTALL is not set, nothing to do for webinstall\n\n";
      return;
    }
    $self->SUPER::ACTION_install;
  }

  sub process_htdocs_files {
    `find htdocs -type f | grep -v .svn | cpio -pdv --quiet blib`;
    return;
  }

  sub process_cgi_files {
    my $self = shift;
    my $cgi_bin = 'blib/cgi-bin';
    my $script  = 'npg_qc';
    `mkdir -p $cgi_bin`;
    `cp cgi-bin/$script $cgi_bin`;
    $script = join q[/], $cgi_bin, $script; 
    $self->fix_shebang_line(($script));
    `chmod +x $script`;
    return;
  }

  sub process_data_files {
    `find data/npg_qc_web/templates -type f | grep -v .svn | cpio -pdv --quiet blib`;
    return;
  }
EOF

my $extended_build_requires = {
                'Pod::Usage'                      => 0,
                'npg_testing::db'                 => 0,
                'Test::Deep'                      => '0.103',
                'Test::Distribution'              => 0,
                'Test::Perl::Critic'              => 0,
                'Test::Warn'                      => '0.11',
                'DateTime::Format::SQLite'        => 0,
                'File::Copy'                      => 0,
                'File::Path'                      => 0,
                'npg_tracking::Schema'            => 0,
};

my $extended_requires = {
                'autodie'                         => '2.10',
                'Class::Std'                      => '0.0.8',
                'Compress::Zlib'                  => 0,
                'Cwd'                             => 0,
                'DBI'                             => '1.608',
                'DBIx::Class'                     => 0,
                'DBIx::Class::InflateColumn::Serializer' => 0,
                'Digest::MD5'                     => 0,
                'Exporter'                        => '5.63',
                'Fatal'                           => 0,
                'Fcntl'                           => 0,
                'File::Basename'                  => 0,
                'File::Glob'                      => 0,
                'File::Spec'                      => 0,
                'File::Spec::Functions'           => 0,
                'File::Slurp'                     => 0,
                'File::Temp'                      => 0,
                'FindBin'                         => '1.47',
                'Getopt::Long'                    => '2.37',
                'Getopt::Std'                     => 0,
                'HTTP::Request::Common'           => '5.822',
                'HTTP::Response'                  => 0,
                'IPC::SysV'                       => 0,
                'JSON'                            => '2.12',
                'lib'                             => '0.5565',
                'Lingua::EN::Inflect'             => 0,
                'List::MoreUtils'                 => '0.22',
                'List::Util'                      => '1.21',
                'LWP::UserAgent'                  => '5.823',
                'Math::Round'                     => '0.06',
                'MIME::Base64'                    => 0,
                'MIME::Base64::Perl'              => 0,
                'Module::Pluggable::Object'        => 0,
                'Moose'                           => '0.93',
                'Moose::Meta::Class'              => 0,
                'Moose::Role'                     => '0.93',
                'Moose::Util::TypeConstraints'    => 0,
                'MooseX::Aliases'                 => 0,
                'MooseX::AttributeCloner'         => 0,
                'MooseX::AttributeHelpers'        => 0,
                'MooseX::ClassAttribute'          => 0,
                'MooseX::NonMoose'                => '0',
                'MooseX::Storage'                 => 0,
                'MooseX::StrictConstructor'       => '0.08',
                'Parallel::ForkManager'           => 0,
                'PDL::Core'                       => 0,
                'PDL::Lite'                       => 0,
                'Perl6::Slurp'                    => '0.03',
                'Try::Tiny'                       => 0,

                'npg_common::Alignment'                    => 0,
                'npg_common::diagram::visio_histo_google'  => 0,
                'npg_common::extractor::fastq'             => 0,
                'npg_common::fastqcheck'                   => 0,
                'npg_common::roles::run::lane::file_names' => 0,
                'npg_common::roles::software_location'     => 0,
                'npg_common::sequence::reference::base_count' => 0,
                'npg_testing::db'                          => 0,
                'npg_tracking::data::reference::list'      => 0,
                'npg_tracking::glossary::tag'              => 0,
                'npg_tracking::illumina::run::folder'      => 0,
                'npg_tracking::illumina::run::short_info'  => 0,
                'npg_tracking::illumina::run::long_info'   => 0,
                'npg_tracking::util::types'                => 0,
                'st::api::lims'                            => 0,
};

my $build_requires = {
                'ExtUtils::CBuilder'              => 0,
                'Test::Exception'                 => '0.27',
                'Test::More'                      => '0.86',
                'HTML::PullParser'                => '3.57',
                'YAML'                            => '0.68',
                'IO::Scalar'                      => 0,
                'XML::Simple'                     => '2.18',
                'MIME::Parser'                    => '5.427',
                'MIME::Lite'                      => '3.024',
},

my $requires = {
                'base'                            => '2.12',
                'Carp'                            => '1.04',
                'ClearPress::model'               => '0',
                'ClearPress::view'                => '0',
                'ClearPress::view::error'         => '0',
                'Data::Dumper'                    => '2.121_08',
                'DateTime'                        => '0.5',
                'Digest::SHA1'                    => '0.0',
                'English'                         => '1.02',
                'MIME::Base64'                    => 0,
                'POSIX'                           => '1.09',
                'Readonly'                        => '1.03',
                'Readonly::XS'                    => 0,
                'Statistics::Lite'                => 0,
                'strict'                          => '1.03',
                'Template'                        => '2.19',
                'warnings'                        => '1.05',
                'XML::LibXML'                     => '1.70',
                'XML::SAX'                        => 0,

                'npg::util'                                => 0,
                'npg::controller'                          => 0,
                'npg::util::image::graph'                  => 0,
                'npg::util::image::heatmap'                => 0,
                'npg::util::image::image_map'              => 0,
                'npg::util::image::merge'                  => 0,
                'npg::util::image::scale'                  => 0,
                'npg::api::run'                            => 0,
                'npg::api::run_status'                     => 0,
};

if (!$ENV{'NPG_QC_WEB_INSTALL'}) {
  while (my ($key, $value) = each %{$extended_requires}) {
    $requires->{$key} = $value;
  }
  while (my ($key, $value) = each %{$extended_build_requires}) {
    $build_requires->{$key} = $value;
  } 
}

if ($^X =~ /^\/software\/perl-5\.8\.8/smx) {
  delete $requires->{'DBIx::Class::Schema::Loader'};
}

my $builder = $class->new(

                'module_name'         => 'npg-qc',
                'dist_author'         => q(wtsi-npg <npg@sanger.ac.uk>),
                'dist_version_from'   => 'lib/npg_qc/util.pm',
                'dist_abstract'       => 'Illumina and WTSI quality control for NGS data',
                'license'             => 'gpl',

          'configure_requires' => {
                'ExtUtils::CBuilder'              => 0,
                'Readonly'                        => 0,
                'Readonly::XS'                    => 0,
          },

          'build_requires' => $build_requires,
          'requires'      =>  $requires,
         
          'dist'          => { COMPRESS => 'gzip', SUFFIX => 'gz', },
         );

$builder->create_build_script();

1;
