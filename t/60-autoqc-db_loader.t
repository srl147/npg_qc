use strict;
use warnings;
use Test::More tests => 52;
use Test::Exception;
use Test::Warn;
use Moose::Meta::Class;
use Perl6::Slurp;
use JSON;
use npg_testing::db;

use_ok('npg_qc::autoqc::db_loader');
{
  my $db_loader = npg_qc::autoqc::db_loader->new();
  isa_ok($db_loader, 'npg_qc::autoqc::db_loader');

  $db_loader = npg_qc::autoqc::db_loader->new(
      path=>['t/data/autoqc/tag_decode_stats'],
      verbose => 0,
  );
  is(scalar @{$db_loader->json_file}, 1, 'one json file found');
  is($db_loader->json_file->[0], 't/data/autoqc/tag_decode_stats/6624_3_tag_decode_stats.json',
    'correct json file found');
  my $values = decode_json(slurp('t/data/autoqc/tag_decode_stats/6624_3_tag_decode_stats.json'));
  ok($db_loader->_pass_filter($values, 'tag_decode_stats'), 'filter test positive');

  $db_loader = npg_qc::autoqc::db_loader->new(id_run=>[3, 2, 6624]);
  ok($db_loader->_pass_filter($values, 'tag_decode_stats'), 'filter test positive');
  $db_loader = npg_qc::autoqc::db_loader->new(id_run=>[3, 2]);
  ok(!$db_loader->_pass_filter($values, 'tag_decode_stats'), 'filter test negative');
  $db_loader = npg_qc::autoqc::db_loader->new(lane=>[4,3]);
  ok($db_loader->_pass_filter($values, 'tag_decode_stats'), 'filter test positive');
  $db_loader = npg_qc::autoqc::db_loader->new(lane=>[4,5]);
  ok(!$db_loader->_pass_filter($values, 'tag_decode_stats'), 'filter test negative');
  $db_loader = npg_qc::autoqc::db_loader->new(check=>[]);
  ok($db_loader->_pass_filter($values, 'tag_decode_stats'), 'filter test positive');
  $db_loader = npg_qc::autoqc::db_loader->new(check=>['tag_decode_stats','other']);
  ok($db_loader->_pass_filter($values, 'tag_decode_stats'), 'filter test positive');
  $db_loader = npg_qc::autoqc::db_loader->new(check=>['insert_size','other']);
  ok(!$db_loader->_pass_filter($values, 'tag_decode_stats'), 'filter test negative');
}

my $schema = Moose::Meta::Class->create_anon_class(
          roles => [qw/npg_testing::db/])
          ->new_object({})->create_test_db(q[npg_qc::Schema]);
{
  my $is_rs = $schema->resultset('InsertSize');
  my $current_count = $is_rs->search({})->count;

  my $db_loader = npg_qc::autoqc::db_loader->new(
       schema => $schema,
       path   => ['t/data/autoqc/insert_size/6062_8#1.insert_size.json'],
  );
  my $count_loaded;
  warnings_exist {$count_loaded = $db_loader->load()}
   [qr/not a directory, skipping/, qr/0 json files have been loaded/],
   'non-directory path entry skipped';
  is($count_loaded, 0, 'nothing loaded');

  $db_loader = npg_qc::autoqc::db_loader->new(
       schema => $schema,
       path   => ['t/data/autoqc/dbix_loader/is'],
       verbose => 0,
  );
  lives_ok {$count_loaded = $db_loader->load()} 'file loaded';
  is($count_loaded, 1, 'reported one file loaded');
  $current_count++;
  is ($is_rs->search({})->count, $current_count, 'one record added to the table');
  lives_ok {$db_loader->load()} 'reload insert size result';
  my $rs = $is_rs->search({});
  is($rs->count, $current_count, 'no new records added');
  my $row = $rs->next;
  is(join(q[ ],@{$row->expected_size}), '50 200', 'insert size');
  is($row->num_well_aligned_reads, 50, 'number well-aligned reads');

  $db_loader = npg_qc::autoqc::db_loader->new(
       schema => $schema,
       path   => ['t/data/autoqc/dbix_loader/is/update'],
       verbose => 0,
  );
  lives_ok {$db_loader->load()} 'reload updated insert size result';
  $rs = $is_rs->search({});
  is($rs->count, $current_count, 'no new records added');
  $row = $rs->next;
  is(join(q[ ],@{$row->expected_size}), '100 300', 'updated insert size');
  is($row->num_well_aligned_reads, 60, 'updated number well-aligned reads');

  $db_loader = npg_qc::autoqc::db_loader->new(
       schema => $schema,
       path   => ['t/data/autoqc/dbix_loader/is'],
       update => 0,
  );
  warnings_exist {$db_loader->load()}
    [qr(Skipped t/data/autoqc/dbix_loader/is/12187_2\.insert_size\.json),
     qr(0 json files have been loaded)],
    'file skipped warning';
  $rs = $is_rs->search({});
  is($rs->count, $current_count, 'no new records added');
  $row = $rs->next;
  is(join(q[ ],@{$row->expected_size}), '100 300', 'insert size not updated');
  is($row->num_well_aligned_reads, 60, 'number well-aligned reads not updated');

  $db_loader = npg_qc::autoqc::db_loader->new(
       schema => $schema,
       path   => ['t/data/autoqc/dbix_loader/is/more'],
       update => 0,
       verbose => 0,
  );
  lives_ok {$db_loader->load()} 'load new insert size result';
  is($is_rs->search({})->count, $current_count+1, 'a new records added');
}

{
  my $is_rs = $schema->resultset('InsertSize');
  $is_rs->delete_all();
  my $db_loader = npg_qc::autoqc::db_loader->new(
       schema => $schema,
       path   => ['t/data/autoqc/dbix_loader/is/more',
                  't/data/autoqc/dbix_loader/is/update',
                  't/data/autoqc/dbix_loader/is'
                 ],
       verbose => 0,
  );
  my $count;
  lives_ok {$count = $db_loader->load()} 'loading from multiple paths';
  is($count, 3, '3 loaded records reported');
  is($is_rs->search({})->count, 2, 'two records created');
}

{
  my $is_rs = $schema->resultset('InsertSize');
  $is_rs->delete_all();

  my $db_loader = npg_qc::autoqc::db_loader->new(
       schema => $schema,
       json_file => ['t/data/autoqc/dbix_loader/is/12187_2.insert_size.json',
                     't/data/autoqc/insert_size/6062_8#1.insert_size.json'],
  );
  warnings_exist  {eval {$db_loader->load()} }
    [qr(Loaded t/data/autoqc/dbix_loader/is/12187_2\.insert_size\.json),
     qr(Loading aborted, transaction has rolled back)
    ],
    'attempted to load both files';
  is ($is_rs->search({})->count, 0, 'table is still empty, ie transaction has been rolled back');

  $db_loader = npg_qc::autoqc::db_loader->new(
       schema => $schema,
       json_file => ['t/data/autoqc/dbix_loader/is/12187_2.insert_size.json',
                     't/data/autoqc/insert_size/6062_8#1.insert_size.json'],
       verbose => 0,
  );
  throws_ok {$db_loader->load()} qr/Loading aborted, transaction has rolled back/,
    'error loading a set of files with the last file corrupt';
  is ($is_rs->search({})->count, 0, 'table is empty, ie transaction has been rolled back');
}

$schema->resultset('InsertSize')->delete_all();
my $path = 't/data/autoqc/dbix_loader/run';
my $num_lane_jsons = 11;
my $num_plex_jsons = 44;
{
  my $db_loader = npg_qc::autoqc::db_loader->new(
       schema => $schema,
       verbose => 0,
       path => [$path],
       id_run => [233],
  );
  is($db_loader->load(), 0, 'no files loaded - filtering by id');

  $db_loader = npg_qc::autoqc::db_loader->new(
       schema => $schema,
       verbose => 0,
       path => [$path],
       id_run => [12233],
       lane => [3,5],
  );
  is($db_loader->load(), 0, 'no files loaded - filtering by lane');

  $db_loader = npg_qc::autoqc::db_loader->new(
       schema => $schema,
       verbose => 0,
       path => [$path],
       id_run => [12233],
       lane => [1,2],
       check => [qw(pulldown_metrics some_other)],
  );
  is($db_loader->load(), 0, 'no files loaded - filtering by check name');

  $db_loader = npg_qc::autoqc::db_loader->new(
       schema => $schema,
       verbose => 0,
       path => [$path]
  );
  is ($db_loader->load(), $num_lane_jsons, 'all json files loaded to the db');
  my $count = 0;
  foreach my $table (qw(Adapter InsertSize SpatialFilter
                        GcFraction RefMatch QXYield UpstreamTags
                        SequenceError TagMetrics TagsReporters)) {
    $count +=$schema->resultset($table)->search({})->count;
  }
  is($count, $num_lane_jsons, 'number of new records in the db is correct');

  is ($db_loader->load(), $num_lane_jsons, 'loading the same files again updates all files');

  $db_loader = npg_qc::autoqc::db_loader->new(
       schema => $schema,
       verbose => 0,
       path => [$path],
       update => 0,
  );
  is ($db_loader->load(), 0, 'loading the same files again with update option false'); 
}

{
  my $db_loader = npg_qc::autoqc::db_loader->new(
       schema => $schema,
       verbose => 0,
       path => [$path, "$path/lane"],
       update => 0,
  );
  is ($db_loader->load(), $num_plex_jsons, 'loading from two paths without update');
  my $total_count = 0;
  my $plex_count = 0;
  my $tag_zero_count = 0;
  my @tables = qw(Adapter InsertSize GcFraction RefMatch QXYield Genotype
                  SequenceError BamFlagstats PulldownMetrics GcBias
                  AlignmentFilterMetrics);
  foreach my $table (@tables) {
    $total_count +=$schema->resultset($table)->search({})->count;
    $plex_count +=$schema->resultset($table)->search({tag_index => {'>', -1},})->count;
    $tag_zero_count +=$schema->resultset($table)->search({tag_index => 0,})->count;
  }

  foreach my $table (qw(TagMetrics UpstreamTags TagsReporters SpatialFilter)) {
    $total_count +=$schema->resultset($table)->search({})->count;
  }
  is ($plex_count, $num_plex_jsons, 'number of plexes loaded');
  is ($total_count, $num_plex_jsons+$num_lane_jsons, 'number of records loaded');
  is ($tag_zero_count, 8, 'number of tag zero records loaded');
}

{
  my $rs = $schema->resultset('BamFlagstats');
  is ($rs->search({human_split => 'all'})->count, 6, '6 bam flagstats records for target files');
  is ($rs->search({human_split => 'human'})->count, 2, '2 bam flagstats records for human files');
  is ($rs->search({human_split => 'phix'})->count, 1, '1 bam flagstats records for phix files');
}

1;
