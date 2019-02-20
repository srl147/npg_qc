use strict;
use warnings;
use Test::More tests => 7;
use Test::Exception;
use File::Temp qw/ tempdir /;
use Archive::Extract;
use Perl6::Slurp;
use JSON qw/from_json to_json/;

use npg_tracking::glossary::composition::component::illumina;
use npg_tracking::glossary::composition::factory;

my $tempdir = tempdir( CLEANUP => 1);
my $archive = '17448_1_9';
my $ae = Archive::Extract->new(archive => "t/data/autoqc/bam_flagstats/${archive}.tar.gz");
$ae->extract(to => $tempdir) or die $ae->error;
$archive = join q[/], $tempdir, $archive;
my $file1 = join q[/], $archive, '17448_1#9_F0x900.stats';

use_ok ('npg_qc::autoqc::results::samtools_stats');

subtest 'selecting an object with correct filter' => sub {
  plan tests => 9;

  my $pkg = 'npg_qc::autoqc::results::samtools_stats';
  my @results = ();
  push @results, $pkg->load("$archive/qc/all_json/17448_1#9_F0x900.samtools_stats.json");
  
  my $result = $results[0]->result4visuals(\@results);
  ok (!$result, 'object not returned');

  push @results, $pkg->load("$archive/qc/all_json/17448_1#9_F0x900.samtools_stats.json");
  ok (!$result, 'object not returned');

  push @results, $pkg->load("$archive/qc/all_json/17448_1#9_F0xB00.samtools_stats.json");
  $result = $results[0]->result4visuals(\@results);
  ok ($result, 'object returned');
  is ($result->filter, 'F0xB00', 'object has correct filter value');

  push @results, $pkg->load("$archive/qc/all_json/17448_1#9_F0xB00.samtools_stats.json");
  throws_ok { $results[0]->result4visuals(\@results) }
    qr/Multiple results for filter F0xB00/,
    'error for two objects with the same filter';
 
  my $filter = 'F0x000';
  my $r = pop @results;
  # cannot assing the ro filter attribute directly,
  # doing it hard way
  my $h = from_json($r->freeze);
  $h->{filter} = $filter;
  $r = $pkg->thaw(to_json($h));
  is ($r->filter, $filter, 'filter value reassigned - test prereq.');

  push @results, $r;
  $result = $results[0]->result4visuals(\@results);
  ok ($result, 'object returned');
  is ($result->filter, $filter, 'object has correct filter value');
  push @results, $r;
  throws_ok { $results[0]->result4visuals(\@results) }
    qr/Multiple results for filter $filter/,
    'error for two objects with the same filter';  
};

subtest 'object with an empty composition' => sub {
  plan tests => 1;
  throws_ok { npg_qc::autoqc::results::samtools_stats->new() }
    qr/Can only build old style results/,
    'no-argument constructor - error';
};

subtest 'object with an one-component composition' => sub { 
  plan tests => 10;

  my $c = npg_tracking::glossary::composition::component::illumina->new(
    id_run => 17448, position => 1, tag_index => 9);
  my $f = npg_tracking::glossary::composition::factory->new();
  $f->add_component($c);
  my $r = npg_qc::autoqc::results::samtools_stats->new(
    stats_file    => $file1,
    composition   => $f->create_composition(),
    filename_root => '17448_1#9');
  isa_ok ($r, 'npg_qc::autoqc::results::samtools_stats');

  is ($r->num_components, 1, 'one component');
  is ($r->composition_digest(),
    'bfc10d33f4518996db01d1b70ebc17d986684d2e04e20ab072b8b9e51ae73dfa', 'digest');
  is ($r->filter, 'F0x900', 'filter');
  is ($r->composition_subset, undef, 'subset undefined');
  lives_ok { $r->execute() } 'execute() method runs successfully';
  is ($r->stats, slurp($file1), 'stats file content saved correctly');
  is ($r->filename_root, '17448_1#9_F0x900', 'filename root');
  is ($r->filter, 'F0x900', 'filter is set');
  is ($r->to_string(),
    'npg_qc::autoqc::results::samtools_stats {"components":[{"id_run":17448,"position":1,"tag_index":9}]}',
    'string representation');
};

subtest 'object with an one-component phix subset composition' => sub { 
  plan tests => 6;

  my $c = npg_tracking::glossary::composition::component::illumina->new(
    id_run => 17448, position => 1, tag_index => 9, subset => 'phix');
  my $f = npg_tracking::glossary::composition::factory->new();
  $f->add_component($c);
  my $file2 = join q[/], $archive, '17448_1#9_phix_F0xB00.stats';
  my $r = npg_qc::autoqc::results::samtools_stats->new(
    stats_file  => $file2,
    composition => $f->create_composition());
  my $digest = 'ca4c3f9e6f8247fed589e629098d4243244ecd71f588a5e230c3353f5477c5cb';
  is ($r->composition_digest(), $digest, 'digest');
  is ($r->filter, 'F0xB00', 'filter');
  is ($r->composition_subset, 'phix', 'phix subset');
  is ($r->stats, slurp($file2), 'stats file content saved correctly');
  is ($r->filename_root, $digest.'_F0xB00', 'filename root');
  is ($r->to_string(),
    'npg_qc::autoqc::results::samtools_stats {"components":[{"id_run":17448,"position":1,"subset":"phix","tag_index":9}]}',
    'string representation');
};

subtest 'serialization and instantiation' => sub { 
  plan tests => 12;

  my $c = npg_tracking::glossary::composition::component::illumina->new(
    id_run => 17448, position => 1, tag_index => 9);
  my $f = npg_tracking::glossary::composition::factory->new();
  $f->add_component($c);
  my $r = npg_qc::autoqc::results::samtools_stats->new(
    stats_file => $file1, composition => $f->create_composition());
  my $digest = $r->composition_digest;
  lives_ok { $r->execute() } 'execute() method runs successfully';
  is ($r->filter, 'F0x900', 'filter');
  is ($r->stats, slurp($file1), 'stats file content generated correctly');
  
  my $json;
  lives_ok { $json = $r->freeze(); } 'serialization ok';
  unlike ($json, qr/stats_file/, 'stats_file attribute is not serialized');
  my $r1;
  lives_ok {$r1 = npg_qc::autoqc::results::samtools_stats->thaw($json) }
    'object instantiated from JSON string';
  isa_ok ($r1, 'npg_qc::autoqc::results::samtools_stats');
  is ($r1->to_string, $r->to_string, 'the same string representation');
  is ($r1->composition_digest, $digest, 'the same composition digest');
  is ($r1->stats_file, undef, 'stats file value undefined');
  throws_ok { $r1->execute }
    qr/Samtools stats file path \(stats_file attribute\) should be set/,
    'no stats file - execute error';
  lives_ok { $r1->freeze(); } 'serialization ok';
};

subtest 'deserialization: version mismatch supressed' => sub {
   plan tests => 4;
 
  my $json_string = slurp $tempdir .
    '/17448_1_9/qc/all_json/17448_1#9_F0x900.samtools_stats.json';
  like ($json_string, qr/npg_qc::autoqc::results::samtools_stats-10.1/,
    'expected version');
  like ($json_string, qr/npg_tracking::glossary::composition-11.3/,
    'expected version');
  like ($json_string, qr/npg_tracking::glossary::composition::component::illumina-0.0.2/,
    'expected version');
  lives_ok { npg_qc::autoqc::results::samtools_stats->thaw($json_string) }
    'version mismatch does not cause an error';
};

1;