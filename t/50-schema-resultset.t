use strict;
use warnings;
use Test::More tests => 14;
use Test::Exception;
use List::MoreUtils qw(uniq none);
use Moose::Meta::Class;

use npg_tracking::glossary::composition::factory;
use npg_tracking::glossary::composition::factory::rpt_list;
use npg_tracking::glossary::composition::component::illumina;
use t::autoqc_util;

my $schema_package = q[npg_qc::Schema];
use_ok $schema_package;

my $schema;
lives_ok{ $schema = Moose::Meta::Class->create_anon_class(
            roles => [qw/npg_testing::db/])->new_object()
            ->create_test_db($schema_package) } 'test db created';
isa_ok($schema, $schema_package);

# Utility method for saving to a database one-component composition
# if it does not exist already.
# Returns primary key column value for seq_composition
sub _save_composition {
  my $component_h = shift;
  return t::autoqc_util::find_or_save_composition($schema, $component_h);
}

subtest q[results with id_run and position only in the table] => sub {
  plan tests => 3;

  my $h = {id_run => 8926, position => 2};
  my $rs = $schema->resultset('SpatialFilter');
  $rs->create({id_run   => 8926,
               position => 2,
               id_seq_composition => _save_composition($h)
              });
  is ($rs->search_autoqc($h)->count(), 1, 'autoqc search - one results');
  $h->{'tag_index'} = undef;
  lives_and { is $rs->search_autoqc($h)->count(), 1}
    'no error in autoqc search query, one result';
  throws_ok { $schema->resultset('SpatialFilter')->search($h)->count() }
    qr/no such column: tag_index/,
    'error with tag_index as a part of the vanilla DBIx query';
};

subtest q[results with id_run, position and tag_index in the table] => sub {
  plan tests => 15;

  my $is_rs = $schema->resultset('InsertSize');
  my $rid = _save_composition({id_run => 3500, position => 1});
  $is_rs->create({id_run => 3500, position => 1, id_seq_composition => $rid});
  my $rs = $is_rs->search_autoqc({id_run => 3500, position => 1});
  is ($rs->count, 1, 'one result retrieved');
  is ($rs->next->tag_index, undef, 'lane-level result');
  $rs = $is_rs->search_autoqc({id_run => 3500, position => 2});
  is ($rs->count, 0, 'no results retrieved');
  
  $rs = $is_rs->search_autoqc({id_run => 3500, position => 1, tag_index => undef});
  is ($rs->count, 1, 'one result retrieved');
  is ($rs->next->tag_index, undef, 'lane-level result');

  $rs = $is_rs->search_autoqc({id_run => 3500, position => 1, tag_index => 0});
  is ($rs->count, 0, 'no results retrieved');

  foreach my $i ((0 .. 10)) {
    foreach my $p ((1 .. 2)) {
      foreach my $r ((3500, 4000, 5000)) {
        my $id = _save_composition({id_run => $r, position => $p, tag_index => $i});
        $is_rs->create(
          {id_run => $r, position => $p, tag_index => $i, id_seq_composition => $id});
      }
    }
  }
  
  $rs = $is_rs->search_autoqc({id_run => 3500, position => 1});
  is ($rs->count, 12, '12 results retrieved');
  $rs = $is_rs->search_autoqc({id_run => 3500, position => 2});
  is ($rs->count, 11, '11 results retrieved');
  $rs = $is_rs->search_autoqc({id_run => 3500, position => 1, tag_index => undef});
  is ($rs->count, 1, '1 result retrieved');
  $rs = $is_rs->search_autoqc({id_run => 3500, position => 2, tag_index => undef});
  is ($rs->count, 0, 'no results retrieved');
  $rs = $is_rs->search_autoqc({id_run => 3500, position => 1, tag_index => 0});
  is ($rs->count, 1, 'one result retrieved');
  $rs = $is_rs->search_autoqc({id_run => 3500, position => [1,2], tag_index => 0});
  is ($rs->count, 2, 'two results retrieved');
  $rs = $is_rs->search_autoqc({id_run => 3500, position => [1,2], tag_index => [1,3,5,7]});
  is ($rs->count, 8, '8 results retrieved');
  $rs = $is_rs->search_autoqc({tag_index => [1,3]});
  is ($rs->count, 12, '12 results retrieved');
  $rs = $is_rs->search_autoqc({id_run => [3500,5000], position => [1,2], tag_index => undef});
  is ($rs->count, 1, '1 result retrieved');
};

subtest q[results with id_run, position, tag_index and subset in the table] => sub {
  plan tests => 9;

  my $fs_rs = $schema->resultset('BamFlagstats');
  foreach my $i ((0 .. 10)) {
    foreach my $p ((1 .. 2)) {
      foreach my $r ((3500, 4000, 5000)) {
        foreach my $s (qw/all human phix/) {
          my $id = _save_composition({
             id_run      => $r,
             position    => $p,
             tag_index   => $i,
             subset      => $s eq 'all' ? undef : $s,
          });
          $fs_rs->create({
             id_run             => $r,
             position           => $p,
             tag_index          => $i,
             subset             => $s,
             human_split        => $s,
             id_seq_composition => $id
          });
        }
      }
    }
  }

  my $rs = $fs_rs->search_autoqc({id_run => 3500, position => 1});
  is ($rs->count, 33, '33 results retrieved');
  $rs = $fs_rs->search_autoqc({id_run => 3500, position => 1, tag_index => undef});
  is ($rs->count, 0, 'no results retrieved');
  $rs = $fs_rs->search_autoqc({id_run => 3500, position => 1, tag_index => 0});
  is ($rs->count, 3, '3 results retrieved');
  $rs = $fs_rs->search_autoqc({id_run => 3500, position => [1,2], tag_index => 0});
  is ($rs->count, 6, '6 results retrieved');
  $rs = $fs_rs->search_autoqc({id_run => 4000, position => [1,2], tag_index => 3, subset => undef});
  is ($rs->count, 2, '2 results retrieved');
  $rs = $fs_rs->search_autoqc({id_run => 5000, position => 1, tag_index => 3, subset => 'human'});
  is ($rs->count, 1, 'one result retrieved');
  $rs = $fs_rs->search_autoqc({id_run => 5000, position => 1, tag_index => 3, subset => 'yhuman'});
  is ($rs->count, 0, 'no results retrieved');
  $rs = $fs_rs->search_autoqc({subset => ['phix']});
  is ($rs->count, 66, '66 results retrieved');
  $rs = $fs_rs->search_autoqc({subset => undef});
  is ($rs->count, 66, '66 results retrieved');
};

sub _seq_summary_data {
  my $id = shift;
  return {id_seq_composition => $id,
          sequence_format    => 'cram',
          header             => 'my header',
          seqchksum          => '123456789',
          seqchksum_sha512   => '1122334455667788',
          md5                => 'gjsgfjfhgjs',
         };
}

sub _samtools_data {
  my ($id, $filter) = @_;
  return {id_seq_composition => $id,
          filter             => $filter,
          stats              => 'ffhgfhgfh',
         };
}

subtest q[results linked to a composition] => sub {
  plan tests => 39;

  my $component_rs   = $schema->resultset('SeqComponent');
  my $composition_rs = $schema->resultset('SeqComposition');
  my $com_com_rs     = $schema->resultset('SeqComponentComposition');
  my $samtools_rs    = $schema->resultset('SamtoolsStats');
  my $summary_rs     = $schema->resultset('SequenceSummary');

  my $stash = {};

  foreach my $i ((0 .. 10)) {
    foreach my $p ((1 .. 2)) {
      foreach my $r ((35000, 40000, 50000)) {
        foreach my $s (('human', undef, 'phix')) {
          my $component_h = {id_run => $r, position => $p, tag_index => $i, subset => $s};
          my $component =
            npg_tracking::glossary::composition::component::illumina->new($component_h);
          my $f = npg_tracking::glossary::composition::factory->new();
          $f->add_component($component);
          my $composition = $f->create_composition();
          $component_h->{'digest'} = $component->digest;
          my $component_row = $component_rs->create($component_h);
          if ($r == 40000 && $p == 1 && !defined $s) {
            $stash->{$i}->{'component'} = $component;
            $stash->{$i}->{'row'} = $component_row;
          }
          my $composition_row = $composition_rs->create(
            {size => 1, digest => $composition->digest});
          $com_com_rs->create({
             size               => 1,
             id_seq_component   => $component_row->id_seq_component,
             id_seq_composition => $composition_row->id_seq_composition
                              });
      
          $summary_rs->create(
            _seq_summary_data($composition_row->id_seq_composition));
          $samtools_rs->create(
            _samtools_data($composition_row->id_seq_composition, 'f1'));
          $samtools_rs->create(
            _samtools_data($composition_row->id_seq_composition, 'f2'));

          if ($r == 50000 && $p == 1 && !defined $s) {
            $f = npg_tracking::glossary::composition::factory->new();
            $f->add_component($component);
            $f->add_component($stash->{$i}->{'component'});
            $composition     = $f->create_composition();
            $composition_row = $composition_rs->create(
              {size => 2, digest => $composition->digest});
            $com_com_rs->create({
              size               => 2,
              id_seq_component   => $component_row->id_seq_component,
              id_seq_composition => $composition_row->id_seq_composition
                                });
            $com_com_rs->create({
              size               => 2,
              id_seq_component   => $stash->{$i}->{'row'}->id_seq_component,
              id_seq_composition => $composition_row->id_seq_composition
                                });
            $summary_rs->create(
              _seq_summary_data($composition_row->id_seq_composition));
            $samtools_rs->create(
              _samtools_data($composition_row->id_seq_composition, 'f1'));
            $samtools_rs->create(
              _samtools_data($composition_row->id_seq_composition, 'f2'));
          }
        }
      }
    }
  }

  my $rs = $summary_rs->search_autoqc({id_run => 35000, position => 1});
  is ($rs->count, 33, '33 results retrieved');
  $rs = $summary_rs->search_autoqc({id_run => 35000, position => 1}, 1);
  is ($rs->count, 33, '33 results retrieved');
  $rs = $summary_rs->search_autoqc({id_run => 35000, position => 1}, 2);
  is ($rs->count, 0, 'no results retrieved');

  $rs = $samtools_rs->search_autoqc({id_run => 35000, position => 1});
  is ($rs->count, 66, '66 results retrieved');
  $rs = $samtools_rs->search_autoqc({id_run => 35000, position => 1}, 1);
  is ($rs->count, 66, '66 results retrieved');
  $rs = $samtools_rs->search_autoqc({id_run => 35000, position => 1}, 2);
  is ($rs->count, 0, 'no results retrieved');

  $rs = $summary_rs->search_autoqc({id_run => 35000, position => 1, tag_index => undef});
  is ($rs->count, 0, 'no results retrieved');
  $rs = $summary_rs->search_autoqc({id_run => 35000, position => 1, tag_index => 0});
  is ($rs->count, 3, '3 results retrieved');
  $rs = $summary_rs->search_autoqc({id_run => 35000, position => [1,2], tag_index => 3});
  is ($rs->count, 6, '6 results retrieved');
  $rs = $summary_rs->search_autoqc({id_run => 35000, position => [1,2], tag_index => 3, subset => undef});
  is ($rs->count, 2, '2 results retrieved');
  $rs = $samtools_rs->search_autoqc({id_run => 35000, position => [1,2], tag_index => 3, subset => undef});
  is ($rs->count, 4, '4 results retrieved');
  $rs = $summary_rs->search_autoqc({id_run => 35000, position => 1, tag_index => 3, subset => 'human'});
  is ($rs->count, 1, 'one result retrieved');
  $rs = $summary_rs->search_autoqc({id_run => 35000, position => 1, tag_index => 3, subset => 'yhuman'});
  is ($rs->count, 0, 'no results retrieved');

  $rs = $summary_rs->search_autoqc({id_run => 35000, subset => ['phix']});
  is ($rs->count, 22, '22 results retrieved');
  $rs = $summary_rs->search_autoqc({id_run => 35000, subset => undef});
  is ($rs->count, 22, '22 results retrieved');

  $rs = $summary_rs->search_autoqc({id_run => 50000, subset => 'human'}, 1);
  is ($rs->count, 22, '22 results retrieved');
  $rs = $summary_rs->search_autoqc({id_run => 50000, subset => 'human'}, 2);
  is ($rs->count, 0, 'no results retrieved');
  $rs = $summary_rs->search_autoqc({id_run => 50000, subset => undef}, 1);
  is ($rs->count, 22, '22 results retrieved');
  $rs = $summary_rs->search_autoqc({id_run => 50000, subset => undef}, 2);
  is ($rs->count, 11, '11 results retrieved');
  $rs = $summary_rs->search_autoqc({id_run => 50000, subset => undef});
  is ($rs->count, 33, '33 results retrieved');
  $rs = $samtools_rs->search_autoqc({id_run => 50000, subset => undef}, 1);
  is ($rs->count, 44, '44 results retrieved');

  $rs = $samtools_rs->search_autoqc({id_run => 50000, subset => undef}, 2);
  is ($rs->count, 22, '22 results retrieved');
  my $result_row = $rs->next;
  isa_ok ($result_row, 'npg_qc::Schema::Result::SamtoolsStats');
  my $sccs = $result_row->seq_component_compositions();
  isa_ok ($sccs, 'npg_qc::Schema::ResultSet'); 
  is ($sccs->count, 1, 'one related linking object');
  my $scc = $sccs->next();
  isa_ok ($scc, 'npg_qc::Schema::Result::SeqComponentComposition');
  is ($scc->size, 2, 'composition size is 2');
  my $scomp = $scc->seq_component();
  isa_ok ($scomp, 'npg_qc::Schema::Result::SeqComponent');
  my $sc = $result_row->seq_composition();
  isa_ok ($sc, 'npg_qc::Schema::Result::SeqComposition');
  is ($sc->size, 2, 'composition size is 2');
  $sccs = $result_row->seq_component_compositions();
  isa_ok ($sccs, 'npg_qc::Schema::ResultSet'); 
  is ($sccs->count, 1, 'one related linking object');
  $scc = $sccs->next();
  isa_ok ($scc, 'npg_qc::Schema::Result::SeqComponentComposition');
  is ($scc->size, 2, 'composition size is 2');
  my $c = $result_row->composition();
  isa_ok ($c, 'npg_tracking::glossary::composition');
  is ($c->num_components, 2, 'two-component composition');
  is ($c->get_component(0)->id_run, 40000, 'run id of the first component');
  is ($c->get_component(1)->id_run, 50000, 'run id of the second component');

  $rs = $samtools_rs->search_autoqc({id_run => 50000, subset => undef});
  is ($rs->count, 66, '66 results retrieved');
};

subtest q[retrieve results for compositions with arbitrary number of components] => sub {
  plan tests => 423;

  my $component_rs   = $schema->resultset('SeqComponent');
  my $composition_rs = $schema->resultset('SeqComposition');
  my $com_com_rs     = $schema->resultset('SeqComponentComposition');
  my $samtools_rs    = $schema->resultset('SamtoolsStats');

  my $r = 60000;
  #####
  # Create records for four lane-level results
  #
  foreach my $p ((1 .. 4)) {
    my $component_h = {id_run => $r, position => $p};
    my $component =
            npg_tracking::glossary::composition::component::illumina->new($component_h);
     my $f = npg_tracking::glossary::composition::factory->new();
     $f->add_component($component);
     my $composition = $f->create_composition();
     $component_h->{'digest'} = $component->digest;
     my $component_row = $component_rs->create($component_h);
     my $composition_row = $composition_rs->create(
            {size => 1, digest => $composition->digest});
     $com_com_rs->create({
             size               => 1,
             id_seq_component   => $component_row->id_seq_component,
             id_seq_composition => $composition_row->id_seq_composition
                              });
     $samtools_rs->create(
              _samtools_data($composition_row->id_seq_composition, 'f1'));
  }

  #####
  # Create records for six plex-level results for merged entities (merge across four lanes)
  #
  foreach my $i ((0 .. 5)) {
    my $f = npg_tracking::glossary::composition::factory->new();
    my @component_rows = ();
    foreach my $p ((1 .. 4)) {
      my $component_h = {'id_run' => $r, 'position' => $p, 'tag_index' => $i};
      my $component =
            npg_tracking::glossary::composition::component::illumina->new($component_h);
      $f->add_component($component);
      $component_h->{'digest'} = $component->digest;
      push @component_rows, $component_rs->create($component_h);
    }
    my $composition = $f->create_composition();
    my $composition_row = $composition_rs->create(
            {size => 4, digest => $composition->digest});
    foreach my $component_row (@component_rows) {
      $com_com_rs->create({
             size               => 4,
             id_seq_component   => $component_row->id_seq_component,
             id_seq_composition => $composition_row->id_seq_composition
                              });
    }

    $samtools_rs->create(
              _samtools_data($composition_row->id_seq_composition, 'f1'));
  }

  #####
  # Search for all results for lane 1
  #
  my @rows = $samtools_rs->search_autoqc({'id_run' => $r, 'position' => 1})
                          ->search({}, {order_by => 'tag_index'})->all();
  is (scalar @rows, 7, 'seven results returned');
  my $lane = shift @rows;
  is ($lane->composition->num_components, 1, 'single component composition');
  my $lcomp = $lane->composition->get_component(0);
  is ($lcomp->tag_index, undef, 'tag index undefined');
  is ($lcomp->position, 1, 'position is 1');
  is ($lcomp->id_run, $r, "run id is $r");
  
  foreach my $i ((0 .. 5)) {
    is ($rows[$i]->composition->num_components, 4, 'four-component composition');
    foreach my $n ((0 .. 3)) {
      my $comp = $rows[$i]->composition->get_component($n);
      is ($comp->tag_index, $i, "component No $n -  tag index is $i");
      is ($comp->position, $n+1, "component No $n - position is $n+1");
      is ($comp->id_run, $r, "component No $n - run id is $r");
    }
  }

  #####
  # Search for all plex-level results for individual lanes
  #
  for my $l ((1 .. 4)) {
    @rows = $samtools_rs->search_autoqc(
            {'id_run' => $r, 'position' => $l, 'tag_index' => {'!=' => undef}})
                        ->search({}, {order_by => 'tag_index'})->all();
    is (scalar @rows, 6, "six results returned for lane $l");
    foreach my $i ((0 .. 5)) {
      is ($rows[$i]->composition->num_components, 4, 'four-component composition');
      foreach my $n ((0 .. 3)) {
        my $comp = $rows[$i]->composition->get_component($n);
        is ($comp->tag_index, $i, "component No $n -  tag index is $i");
        is ($comp->position, $n+1, "component No $n - position is $n+1");
        is ($comp->id_run, $r, "component No $n - run id is $r");
      }
    }
  }

  #####
  # Search for all plex-level results for a run
  #
  @rows = $samtools_rs->search_autoqc(
            {'id_run' => $r, 'tag_index' => {'!=' => undef}})->all();
  is (scalar @rows, 6, "six results returned for a run");
  map {is ($_->composition->num_components, 4, 'four-component composition')} @rows;
  
  #####
  # Search for all plex-level results for lanes 1 and 2
  #
  @rows = $samtools_rs->search_autoqc(
            {'id_run' => $r, position => [1,2], 'tag_index' => {'!=' => undef}})->all();
  is (scalar @rows, 6, "six results returned for a run");
  map {is ($_->composition->num_components, 4, 'four-component composition')} @rows;

  #####
  # Search for lane-level results for lane 1
  #
  @rows = $samtools_rs->search_autoqc(
            {'id_run' => $r, 'position' => 1, 'tag_index' => undef})->all();
  is (scalar @rows, 1, "one lane-level result for lane 1");
  is ($rows[0]->composition->num_components, 1, 'single component composition');

  #####
  # Search for lane-level results for lanes 1 and 2
  #
  @rows = $samtools_rs->search_autoqc(
            {'id_run' => $r, 'position' => [1,2], 'tag_index' => undef})->all();
  is (scalar @rows, 2, "two lane-level results");
  map {is ($_->composition->num_components, 1, 'single component composition')} @rows;

  #####
  # Search for lane-level results for a run
  #
  @rows = $samtools_rs->search_autoqc(
            {'id_run' => $r, 'tag_index' => undef})->all();
  is (scalar @rows, 4, "four lane-level results");
  map {is ($_->composition->num_components, 1, 'single component composition')} @rows;
};

subtest q[mixed queries for results linked to a composition] => sub {
  plan tests => 8;

  my $samtools_rs = $schema->resultset('SamtoolsStats');

  my $query = {'id_run' => 35000, 'position' => 1, 'tag_index' => 2};
  my @rows = $samtools_rs->search_autoqc($query)->all();
  is (scalar @rows, 6, 'six results for a tag');
  @rows = uniq map { $_->filter() } @rows;
  is (join(q[,], sort @rows),'f1,f2', 'results for two filters');
    
  $query->{'filter'} = 'some';
  @rows = $samtools_rs->search_autoqc($query)->all();
  is (scalar @rows, 0, 'no results - filter value does not exist');
  
  $query->{'filter'} = 'f1';
  @rows = $samtools_rs->search_autoqc($query)->all();
  is (scalar @rows, 3, 'three results for f1 filter');
 
  $query->{'filter'} = 'f2';
  @rows = $samtools_rs->search_autoqc($query)->all();
  is (scalar @rows, 3, 'three results for f2 filter');

  $query->{'subset'} = undef;
  @rows = $samtools_rs->search_autoqc($query)->all();
  is (scalar @rows, 1, 'one results for f2 filter, target subset');

  $query->{'subset'} = 'phix';
  @rows = $samtools_rs->search_autoqc($query)->all();
  is (scalar @rows, 1, 'one results for f2 filter, phix subset');

  $query->{'subset'} = [qw(phix human)];
  @rows = $samtools_rs->search_autoqc($query)->all();
  is (scalar @rows, 2, 'two results for f2 filter, phix and human subsets');
};

subtest q[error finding a composition] => sub {
  plan tests => 4;

  my $rs = $schema->resultset('SeqComponent');

  throws_ok {$rs->find_or_create_seq_composition()}
    qr/Composition object argument expected/, 'no argument - error';
  throws_ok {$rs->find_or_create_seq_composition({1=>2})}
    qr/Composition object argument expected/, 'wrong argument type - error';

  ok(!$rs->result_source()->has_relationship('seq_composition'),
    'is not directly related to seq_composition');

  my $f = npg_tracking::glossary::composition::factory->new();
  $f->add_component(npg_tracking::glossary::composition::component::illumina
                    ->new({id_run => 1, position => 3}));
  throws_ok { $rs->find_or_create_seq_composition($f->create_composition()) }
    qr/result source 'SeqComponent' has no such relationship seq_composition/,
    'error invoking method on a resultset that does not have seq_composition relationship';
};

subtest q[not saving composition subset value "all"] => sub {
  plan tests => 2;

  my $ssrs = $schema->resultset('SamtoolsStats');
  ok($ssrs->result_source()->has_relationship('seq_composition'),
    'is linked to seq_composition');

  my $f = npg_tracking::glossary::composition::factory->new();
  $f->add_component(npg_tracking::glossary::composition::component::illumina
    ->new({id_run => 9999, position => 3, subset => 'all'}));
  $f->add_component(npg_tracking::glossary::composition::component::illumina
    ->new({id_run => 9999, position => 4, subset => 'all'}));
  throws_ok { $ssrs->find_or_create_seq_composition($f->create_composition()) }
    qr/Subset \"all\" not allowed/,
    'error creating composition with "all" subset';
};

my $id_run;

subtest q[finding existing composition] => sub {
  plan tests => 17;

  my $rs_component   = $schema->resultset('SeqComponent');
  my $rs_composition = $schema->resultset('SeqComposition');
  my $rs_cc          = $schema->resultset('SeqComponentComposition');
  my $ssrs           = $schema->resultset('SamtoolsStats');

  my @ids = sort { $a <=> $b } map {$_->id_run()} $rs_component->search()->all();
  $id_run = @ids ? pop @ids : 0;
  $id_run++;

  my @values = (
    [{id_run => $id_run,position => 1}],
    [{id_run => $id_run,position => 1}, {id_run => $id_run,position => 2}],
    [{id_run => $id_run,position => 1,subset=>'phix'}],
    [{id_run => $id_run,position => 1,tag_index => 22},
     {id_run => $id_run,position => 1,tag_index => 23}],
    [{id_run => $id_run,position => 1,tag_index => 0}],
    [{id_run => $id_run,position => 1,tag_index => 22,subset => 'human'},
     {id_run => $id_run,position => 1,tag_index => 23,subset => 'human'}],
    [{id_run => $id_run,position => 1,tag_index => 22,subset => 'phix'},
     {id_run => $id_run,position => 1,tag_index => 23,subset => 'phix'}],  
  );  

  my $count = 0;

  foreach my $values_array (@values) {

    my $f = npg_tracking::glossary::composition::factory->new();
    my @component_ids = ();
    foreach my $value (@{$values_array}) {
      my $component = npg_tracking::glossary::composition::component::illumina
                      ->new($value);
      $f->add_component($component);
      my %temp = %{$value};
      $temp{'digest'} = $component->digest();
      push @component_ids, $rs_component->find_or_create(\%temp)->id_seq_component();
    }
    my $composition = $f->create_composition();
    my $num_components = $composition->num_components;
    my $pk_value = $rs_composition->create(
      {digest => $composition->digest, size => $num_components}
    )->id_seq_composition;
    foreach my $id (@component_ids) {
      $rs_cc->create({'size'               => $num_components,
                      'id_seq_component'   => $id,
                      'id_seq_composition' => $pk_value,
                     });
    }

    my $row = $ssrs->find_or_create_seq_composition($composition);
    isa_ok($row, 'npg_qc::Schema::Result::SeqComposition');
    is($row->id_seq_composition, $pk_value, 'existing row returned');

    if ($count == 1) {
      # Test that composition created by explicitly specifying undefined
      # values can still be found.
      my $f = npg_tracking::glossary::composition::factory->new();
      foreach my $value (@{$values_array}) {
        $f->add_component(npg_tracking::glossary::composition::component::illumina
                          ->new(%{$value}, tag_index => undef, subset => undef));
      }
      my $c = $f->create_composition();
      $row = $ssrs->find_or_create_seq_composition($c);
      is($row->id_seq_composition, $pk_value, 'existing row returned');

      my $row_to_change = $rs_component->search(
        {id_run => $id_run,position => 1,tag_index => undef, subset => undef})->next();
      $row_to_change or die 'Failed to find existing row';
      $row_to_change->update({subset => 'human'});
      my $d = $c->digest;
      throws_ok {$ssrs->find_or_create_seq_composition($c, 1)}
        qr/A different composition object with the same digest '$d' already exists in the database/,
        'error detecting composition digest clash';
      $row_to_change->update({subset => undef});
      lives_ok {$ssrs->find_or_create_seq_composition($c, 1)}
        'no error after removing the clash';
    }

    $count++;
  }  
};

subtest q[creating new composition from new and existing components] => sub {
  plan tests => 64;

  my @values = (
    [{id_run => $id_run,position => 2}],
    [{id_run => $id_run,position => 3}, {id_run => $id_run,position => 2}],
    [{id_run => $id_run,position => 2,subset=>'phix'}],
    [{id_run => $id_run,position => 1,tag_index => 22},
     {id_run => $id_run,position => 1,tag_index => 23},
     {id_run => $id_run,position => 1,tag_index => 24}],
    [{id_run => $id_run,position => 1,tag_index => 12},
     {id_run => $id_run,position => 1,tag_index => 13},
     {id_run => $id_run,position => 1,tag_index => 14}],
    [{id_run => $id_run,position => 3,tag_index => 0}],
    [{id_run => $id_run,position => 1,tag_index => 22,subset => 'human'},
     {id_run => $id_run,position => 1,tag_index => 24,subset => 'human'}],
    [{id_run => $id_run,position => 1,tag_index => 25,subset => 'phix'},
     {id_run => $id_run,position => 1,tag_index => 26,subset => 'phix'}],  
  );  

  my @existing_pks = map { $_->id_seq_composition }
                     $schema->resultset('SeqComposition')->search({})->all();
  my $rs_component = $schema->resultset('SeqComponent');
  my $num_existing_components = $rs_component->search({})->count();

  my $ssrs = $schema->resultset('SamtoolsStats');

  foreach my $values_array (@values) {

    my $f = npg_tracking::glossary::composition::factory->new();
    foreach my $value (@{$values_array}) {
      my $component = npg_tracking::glossary::composition::component::illumina
                      ->new($value);
      $f->add_component($component);
    }
    my $composition = $f->create_composition();
    my $num_components = $composition->num_components;
 
    my $row = $ssrs->find_or_create_seq_composition($composition);
    isa_ok($row, 'npg_qc::Schema::Result::SeqComposition');

    my $pk_value = $row->id_seq_composition;
    ok((none { $_== $pk_value } @existing_pks), 'a new row returned');
    is($row->size, $num_components, 'composition size recorded corectly');
    my @sizes = map { $_->size } $row->seq_component_compositions()->all();
    is(scalar @sizes, $num_components, 'correct number of linking records created');
    @sizes = uniq @sizes;
    ok ((scalar @sizes == 1 && $sizes[0] == $num_components),
     'composition size recorded corectly in a linking table');
    ok($row->create_composition()->digest() eq $composition->digest(),
      'composition and component records created correctly');

    foreach my $value (@{$values_array}) {
      my $digest = npg_tracking::glossary::composition::component::illumina
                   ->new($value)->digest;
      my %temp = %{$value};
      for my $key (qw/tag_index subset/) {
        if (!exists $temp{$key}) {
          $temp{$key} = undef;
        }
      }
      is ($rs_component->search(\%temp)->single()->digest, $digest,
        'component digest recorded correctly');
    }
  }

  is($rs_component->search({})->count(), $num_existing_components + 10,
    '10 new components are added');
};

subtest q[search by composition] => sub {
  plan tests => 9;
  
  my $rs = $schema->resultset('InsertSize');

  my $total = $rs->search({})->count();
  lives_and ( sub {is $rs->search_via_composition([])->count(), $total },
    'can have an empty array');
  lives_and ( sub {is $rs->search_via_composition()->count(), $total },
    'can have an undefined array');

  my $c = npg_tracking::glossary::composition::factory::rpt_list
            ->new(rpt_list => q(350:1) )->create_composition();
  is ($rs->search_via_composition([$c])->count, 0, 'no rows found');

  $c = npg_tracking::glossary::composition::factory::rpt_list
            ->new(rpt_list => q(3500:1) )->create_composition();
  my $found_rs = $rs->search_via_composition([$c]);
  is ($found_rs->count, 1, 'one row found');
  my $row = $found_rs->next();
  isa_ok ($row, 'npg_qc::Schema::Result::InsertSize');
  is ($row->seq_composition()->digest, $c->digest, 'correct digest');

  my $c1 = npg_tracking::glossary::composition::factory::rpt_list
            ->new(rpt_list => q(3500:1:1) )->create_composition();
  $found_rs = $rs->search_via_composition([$c, $c1]);
  is ($found_rs->count, 2, 'two rows found');
  is ($found_rs->next()->seq_composition()->digest, $c->digest, 'correct digest');
  is ($found_rs->next()->seq_composition()->digest, $c1->digest, 'correct digest');
};

1;
