use strict;
use warnings;
use Test::More tests => 11;
use Test::Exception;
use Test::Deep;
use File::Spec::Functions qw(catfile);
use File::Temp qw/tempdir/;
use File::Copy;
use t::autoqc_util;

use_ok('npg_qc::autoqc::checks::check');
use_ok('npg_qc::autoqc::results::result');

my $idrun = 2549;
my $path = 't/data/autoqc/090721_IL29_2549/data';
my $tdir = tempdir( CLEANUP => 1 );

subtest 'object creation' => sub {
    plan tests => 2;
    my $check = npg_qc::autoqc::checks::check->new(
      position  => 2,
      qc_in     => $path,
      id_run    => $idrun,
      file_type => 'bam');
    isa_ok($check, 'npg_qc::autoqc::checks::check');
    is($check->file_type, 'bam', 'file type noted');
};

subtest 'validation of attributes' => sub {
    plan tests => 36;
;
    throws_ok {npg_qc::autoqc::checks::check->new(path => $path)}
        qr/Either id_run or position key is undefined/,
        'error on instantiating an object without any id';
    throws_ok {npg_qc::autoqc::checks::check->new(path => $path, id_run => $idrun)}
        qr/Either id_run or position key is undefined/,
        'error on instantiating an object without either a position or rpt_list attr';
    throws_ok {npg_qc::autoqc::checks::check->new(
        position => 17, path => $path, id_run => $idrun)}
        qr/Validation\ failed\ for\ \'NpgTrackingLaneNumber\'/,
        'error on passing to the constructor invalid int as a position';
    throws_ok {npg_qc::autoqc::checks::check->new(
        position => 'dada', path => $path, id_run => $idrun)}
        qr/Validation\ failed\ for\ \'NpgTrackingLaneNumber\'/,
        'error on passing to the constructor position as string';
    throws_ok {npg_qc::autoqc::checks::check->new(
        position => 1.2, path => $path, id_run => $idrun)}
        qr/Validation\ failed\ for\ \'NpgTrackingLaneNumber\'/,
        'error on passing to the constructor position as a float';

    lives_ok {npg_qc::autoqc::checks::check->new(
                            position => 1,
                            qc_in    => $path,
                            id_run   => $idrun,
                            tmp_path => 'nonexisting')}
        'no error for non-existing temp directory if the  writes_tmp_files flag is not set';

    lives_ok {npg_qc::autoqc::checks::check->new(position => 2, id_run => $idrun)}
        'no error on instantiating an object without a path/qc_in attr';
    throws_ok {npg_qc::autoqc::checks::check->new(position => 2, qc_in => 't')}
        qr/Either id_run or position key is undefined/,
        'error on instantiating an object without either a run id or an rpt_list attr';
    throws_ok {npg_qc::autoqc::checks::check->new(
        position => 1, path => 'nonexisting', id_run => -1)}
        qr/Validation\ failed\ for\ \'NpgTrackingRunId\'/,
        'error on passing to the constructor a negative run number';
    throws_ok {npg_qc::autoqc::checks::check->new(
        position => 1, path => 'nonexisting', id_run => q[])}
        qr/Validation\ failed\ for\ \'NpgTrackingRunId\'/,
        'error on passing to the constructor an empty string as a run number';
    lives_ok {npg_qc::autoqc::checks::check->new(
        position => 1, path => 't', id_run => 1)}
        'no error on passing to the constructor a positive run number';
    lives_ok {npg_qc::autoqc::checks::check->new(
        position => 1, path => 't', id_run => q[2])}
        'no error on passing to the constructor a string representing a positive run number';

    throws_ok { npg_qc::autoqc::checks::check->new(position => 2, path => $path,
        id_run => $idrun, tag_index => 1000000)}
        qr/Validation\ failed\ for/,
        'error on passing to the constructor large tag index';
    throws_ok { npg_qc::autoqc::checks::check->new(
        position => 2, path => $path, id_run => $idrun, tag_index => -3)}
        qr/Validation\ failed\ for/,
        'error on passing to the constructor negative tag index that is less than -1';
    throws_ok { npg_qc::autoqc::checks::check->new(
         position => 2, path => $path, id_run => $idrun, tag_index => 10.5)}
        qr/Validation\ failed\ for/,
        'error on passing to the constructor tag index as a float';
    throws_ok { npg_qc::autoqc::checks::check->new(
        position => 2, path => $path, id_run => $idrun, tag_index => undef )}
        qr/Validation\ failed\ for\ \'NpgTrackingTagIndex\'/,
        'does not accept undef for tag_index in the constructor';
    throws_ok { npg_qc::autoqc::checks::check->new(qc_in => 't', rpt_list => 'list') }
        qr/isn't numeric/, 'error if rpt_list format is incorrect';

    my $check;
    lives_ok { $check = npg_qc::autoqc::checks::check->new(qc_in => 't', rpt_list => '6:8')}
        'can create a check object using rpt list attr';
    is ($check->num_components, 1, 'components count is correct');
    is ($check->id_run, undef, 'run id undefined');
    is ($check->position, undef, 'position undefined');
    is ($check->tag_index, undef, 'tag index undefined');
    lives_ok { $check = npg_qc::autoqc::checks::check->new(qc_in => 't', rpt_list => '6:8:9')}
        'can create a check object using rpt list and qc_in attrs';
    is ($check->num_components, 1, 'components count is correct');
    is ($check->id_run, undef, 'run id undefined');
    is ($check->position, undef, 'position undefined');
    is ($check->tag_index, undef, 'tag index undefined');
    lives_ok { $check = npg_qc::autoqc::checks::check->new(
        qc_in => 't', rpt_list => '6:8:9;7:8')}
        'can create a check object using rpt list attr';
    is ($check->num_components, 2, 'components count is correct');
    is ($check->id_run, undef, 'run id undefined');
    is ($check->position, undef, 'position undefined');
    is ($check->tag_index, undef, 'tag index undefined');

    $check = npg_qc::autoqc::checks::check->new(
        position => 2, path => $path, id_run => $idrun );
    throws_ok {$check->path('path')}
        qr/Cannot\ assign\ a\ value\ to\ a\ read-only/, 'check::path is read-only';
    lives_ok {$check->position(3)} 'check::position is read-write';
    throws_ok {$check->id_run(3)}
        qr/Cannot\ assign\ a\ value\ to\ a\ read-only/, 'check::id_run is read-only';
    lives_ok {$check->tag_index(3)} 'check::tag_index is writable';
};

subtest 'accessors tests' => sub {
    plan tests => 36;

    my @checks = ();
    push @checks, npg_qc::autoqc::checks::check->new(
        position => 2, path => $path, id_run => $idrun );
    push @checks, npg_qc::autoqc::checks::check->new(
        path => $path, rpt_list => "${idrun}:2" );
    for my $check (@checks) {
        is($check->tag_index, undef, 'tag index undefined');
        isa_ok($check->result, 'npg_qc::autoqc::results::result');
        is($check->result->id_run, $idrun, 'run id propagated');
        is($check->result->position, 2, 'position propagated');
        is($check->result->path, 't/data/autoqc/090721_IL29_2549/data', 'path propagated');
        is($check->result->tag_index, undef, 'tag index undefined');
        ok(!$check->result->has_tag_index, 'tag index is not set');
        is($check->can_run, 1, 'can_run getter ok');
        is($check->get_id_run, $idrun, 'id run retrieved');
        is($check->to_string,
            'npg_qc::autoqc::checks::check {"components":[{"id_run":2549,"position":2}]}',
            'object string representation');
    }

    my $c = npg_qc::autoqc::checks::check->new(
        path     => $path,
        rpt_list => "2:5:1;1:2:44;1:3:44;2:6:1"
    );
    is($c->get_id_run, undef, 'id run cannot be inferred');
    is($c->result->filename_root,
      '90b32bf73573b149c95c3fcd6d7288e0cfb998c682ff8efae46cdc79505a3249',
      'filename root from digest');
    $c = npg_qc::autoqc::checks::check->new(
        rpt_list      => "2:5:1;1:2:44;1:3:44;2:6:1",
        filename_root => 'XAFTU'
    );
    is($c->result->filename_root, 'XAFTU', 'filename root as given');

    @checks = ();
    push @checks, npg_qc::autoqc::checks::check->new(
        position => 2, path  => $path, id_run => $idrun, tag_index => 5 );
     push @checks, npg_qc::autoqc::checks::check->new(
        path => $path, rpt_list => "${idrun}:2:5" );
    for my $check (@checks) {
        isa_ok($check->result, 'npg_qc::autoqc::results::result');
        is($check->result->id_run, $idrun, 'run id propagated');
        is($check->result->position, 2, 'position propagated');
        is($check->result->tag_index, 5, 'tag index propagated');
        ok($check->result->has_tag_index, 'tag index is set');
    }

    my $check = npg_qc::autoqc::checks::check->new(
        position => 1, path => 't', id_run => 2549,);
    is ($check->tag_label, q[], 'empty string as a tag label');
    $check = npg_qc::autoqc::checks::check->new(
        path => 't', rpt_list => '2549:1',);
    is ($check->tag_label, q[], 'empty string as a tag label');
    
    $check = npg_qc::autoqc::checks::check->new(
        position => 1, path => 't', id_run => 2549, tag_index => 22);
    is ($check->tag_label, q[#22], 'tag label for tag_index 22');
};

subtest 'input and output directories' => sub {
    plan tests => 10;

    lives_ok { npg_qc::autoqc::checks::check->new(rpt_list => '6:8:9')}
        'object constructor - qc_in and qc_out are optional';
    lives_ok {npg_qc::autoqc::checks::check->new(position => 1, id_run => 2)}
        'object constructor - qc_in and qc_out are optional';
    throws_ok {npg_qc::autoqc::checks::check->new(
        position => 1, qc_in => 'nonexisting', id_run => $idrun)}
        qr/does not exist or is not readable/, 'if set, qc_in should exist';
    throws_ok {npg_qc::autoqc::checks::check->new(
        position => 1, qc_out => 'nonexisting', id_run => $idrun)}
        qr/does not exist or is not writable/, 'if set, qc_out should exist';

    my $check;
    lives_ok { $check = npg_qc::autoqc::checks::check->new(
                            position => 1,
                            qc_in    => $tdir,
                            id_run   => $idrun)
    } 'object constructor - qc_out is optional';
    is($check->qc_out, $tdir, 'qc out is set to qc_in');

    lives_ok { $check = npg_qc::autoqc::checks::check->new(
                            position => 1,
                            qc_out   => $tdir,
                            id_run   => $idrun)
    } 'object constructor - qc_in is optional';
    ok(!$check->has_qc_in, 'qc_in is not set');
    is($check->qc_in, undef, 'qc_in undefined if not given');
    $check = npg_qc::autoqc::checks::check->new(
                            position => 1,
                            id_run   => $idrun);
    throws_ok {$check->qc_out}
      qr/qc_out should be defined/,
      'output directory cannot be built if input is not given';     
};

subtest 'temporary directory and path tests' => sub {
    plan tests => 3;

    my $check = npg_qc::autoqc::checks::check->new(
                            position => 1,
                            qc_in    => $path,
                            id_run   => $idrun);
    my $tmp_dir = $check->tmp_path;
    ok($tmp_dir =~ /^\/tmp\//smx, 'temp dir created in /tmp');
    ok(-e $tmp_dir, 'tmp directory created');

    $check = npg_qc::autoqc::checks::check->new(
                            position => 1,
                            qc_in    => $path,
                            id_run   => $idrun,
                            tmp_path => 't/data/autoqc');
    is($check->tmp_path, 't/data/autoqc', 'tmp dir as set');
};

subtest 'finding input' => sub {
    plan tests => 15;

    my $check = npg_qc::autoqc::checks::check->new(
                position  => 3,
                path      => $path,
                id_run    => 2549);
    is (join( q[ ], $check->get_input_files()), "$path/2549_3.fastq",
        'one fastqcheck input files found; no _1 to identify the end');

    $check = npg_qc::autoqc::checks::check->new(
                position  => 2,
                path      => $path,
                id_run    => 2549,
                file_type => q[bam]);
    is (join( q[ ], $check->get_input_files()), "$path/2549_2.bam", 'bam file for a lane found');

    $check =    npg_qc::autoqc::checks::check->new(
                path      => $path,
                position  => 6,
                id_run    => 2549,
                tag_index => 1,
                file_type => q[bam]);
    is (join( q[ ], $check->get_input_files()), "$path/2549_6#1.bam",
        'bam file for a plex found');

    $check = npg_qc::autoqc::checks::check->new(
                position  => 4,
                path      => $path,
                id_run    => 2549);
    throws_ok { $check->execute }
      qr/Neither .+ file found/,
      'error when no input files found';
    
    $check = npg_qc::autoqc::checks::check->new(
                position    => 4,
                input_files => [],
                id_run      => 2549);
    throws_ok { $check->execute }
    qr/input_files array cannot be empty/,
      'error when input_files array is empty';

    $check = npg_qc::autoqc::checks::check->new(
                position    => 4,
                input_files => ["$path/2549_6#1.bam", "$path/2549_4.fastq"],
                id_run      => 2549);
    throws_ok { $check->execute }
    qr/Some of input files do not exist/,
      'error when input_files array contains a file that does not exist';

    $check = npg_qc::autoqc::checks::check->new(
                position    => 4,
                input_files => ["$path/2549_6#1.bam", "$path/2549_2.bam"],
                id_run      => 2549);
    my $count;
    lives_ok { $count = $check->execute } 'no error all input files exist';
    is ($count, 2, 'correct number of input files returned');

    throws_ok { npg_qc::autoqc::checks::check->new(
                    rpt_list  => '2549:1',
                    file_type => q[fastqcheck])->input_files() }
        qr/Input file\(s\) are not given, qc_in should be defined/,
        'cannot infer input files without qc_in';

    throws_ok { npg_qc::autoqc::checks::check->new(
                    rpt_list  => '2549:1:1;2549:2:1',
                    file_type => q[fastq])->input_files() }
        qr/Input file\(s\) are not given, qc_in should be defined/,
        'cannot infer input files for multiple components';
   
    my $found = "$tdir/2549#1.stats";
    copy 't/data/samtools_stats/27053_1#1.single.stats', $found
      or die 'Faile to copy a test file';
    my $files; 
    lives_ok { $files = npg_qc::autoqc::checks::check->new(
                    rpt_list  => '2549:1:1;2549:2:1',
                    qc_in     => $tdir,
                    file_type => q[stats])->input_files() }
        'can infer and find input files for multiple components';
    is_deeply ($files, [$found], 'correct input file');

    mkdir "$tdir/xxx";
    $found = "$tdir/xxx/xx11yy22.stats";
    open my $fh, '>', $found or die 'Cannot create a test file';
    print $fh 'test stats file';
    close $fh;
    lives_ok { $files = npg_qc::autoqc::checks::check->new(
                    rpt_list      => '2549:1:1;2549:2:1',
                    qc_in         => "$tdir/xxx",
                    filename_root => 'xx11yy22',
                    file_type     => q[stats])->input_files() }
        'can infer and find input file using a set filename_root attr';
    is_deeply ($files, [$found], 'correct input file');

    lives_ok { npg_qc::autoqc::checks::check->new(
                    rpt_list  => '2549:1;45:7',
                    input_files => [qw(some other)])->input_files() }
        'no qc_in, input files supplied - OK';
};

subtest 'creating a result object' => sub {
    plan tests => 42;

    my $check = npg_qc::autoqc::checks::check->new(
        position => 1, path => 't', id_run => 2549,);
    like($check->result->get_info('Check'), qr{npg_qc::autoqc::checks::check},
        'check name and version number in the info');
    ok($check->result->get_info('Check_version'), 'check version exists');
    is($check->result->path, 't', 'path is set');
    is($check->result->id_run, 2549, 'run id');
    is($check->result->position, 1, 'position');
    is($check->result->tag_index, undef, 'tag index undefined');
    ok($check->result->has_composition, 'composition attr set');
     is($check->result->num_components, 1, 'one component');

    $check = npg_qc::autoqc::checks::check->new(
        position => 1, id_run => 2549, tag_index => 4);
    like($check->result->get_info('Check'), qr{npg_qc::autoqc::checks::check},
        'check name and version number in the info');
    ok($check->result->get_info('Check_version'), 'check version exists');
    is($check->result->path, undef, 'path is not set');
    is($check->result->id_run, 2549, 'run id');
    is($check->result->position, 1, 'position');
    is($check->result->tag_index, 4, 'tag index');
    ok($check->result->has_composition, 'composition attr set');
    is($check->result->num_components, 1, 'one component');

    $check = npg_qc::autoqc::checks::check->new(
        position => 1, id_run => 2549, tag_index => 0);
    is($check->result->path, undef, 'path is not set');
    is($check->result->id_run, 2549, 'run id');
    is($check->result->position, 1, 'position');
    is($check->result->tag_index, 0, 'tag index zero');
    ok($check->result->has_composition, 'composition attr set');
    is($check->result->num_components, 1, 'one component');

    $check = npg_qc::autoqc::checks::check->new(rpt_list => '2549:1');
    is($check->result->id_run, 2549, 'run id');
    is($check->result->position, 1, 'position');
    is($check->result->tag_index, undef, 'tag index undefined');
    ok($check->result->has_composition, 'composition attr set');
    is($check->result->num_components, 1, 'one component');
    $check = npg_qc::autoqc::checks::check->new(rpt_list => '2549:1:4');
    is($check->result->id_run, 2549, 'run id');
    is($check->result->position, 1, 'position');
    is($check->result->tag_index, 4, 'tag index');
    ok($check->result->has_composition, 'composition attr set');
    is($check->result->num_components, 1, 'one component');
    $check = npg_qc::autoqc::checks::check->new(rpt_list => '2549:1:0');
    is($check->result->id_run, 2549, 'run id');
    is($check->result->position, 1, 'position');
    is($check->result->tag_index, 0, 'tag index zero');
    ok($check->result->has_composition, 'composition attr set');
    is($check->result->num_components, 1, 'one component');

    $check = npg_qc::autoqc::checks::check->new(rpt_list => '2549:1:4;2549:1:0');
    is($check->result->id_run, undef, 'run id undefined');
    is($check->result->position, undef, 'position undefined');
    is($check->result->tag_index, undef, 'tag index undefined');
    ok($check->result->has_composition, 'composition attr set');
    is($check->result->num_components, 2, 'two components');    
};

subtest 'filename generation' => sub {
    plan tests => 7;

    my $check = npg_qc::autoqc::checks::check->new(
        position => 1, qc_in => 't', id_run => 5,);
    throws_ok { $check->create_filename() } qr/File name root is required/,
      'file name root is required';
    is($check->create_filename('5_1'), '5_1.fastq');
    is($check->create_filename('5_1', 1), '5_1_1.fastq');
    is($check->create_filename('5_1', 2), '5_1_2.fastq');

    $check = npg_qc::autoqc::checks::check->new(
        position => 1, path => 't', id_run => 5, tag_index => 3);
    is($check->create_filename('5_1#3', 1), '5_1#3_1.fastq');

    $check = npg_qc::autoqc::checks::check->new(
        position => 1, qc_in => 't', id_run => 5, tag_index => 3,
        file_type => 'stats', suffix => 'F0xB00');    
    is($check->create_filename('5_1#3'), '5_1#3_F0xB00.stats');

    $check = npg_qc::autoqc::checks::check->new(qc_in => 't', rpt_list => '2549:1;2549:9');
    lives_ok { $check->create_filename('2549_1-9') }
      'can create file name for multiple components';
};

subtest 'running the check' => sub {
    plan tests => 7;

    my $check = npg_qc::autoqc::checks::check->new(
                id_run    => 2549,
                position  => 6,
                tag_index => 1,
                file_type => q[fastq],
                qc_in     => $path,
                qc_out    => $tdir);
    is($check->can_run(), 1, 'can run');
    is($check->entity_has_human_reference(), 0,
      'no lims accessor - reference cannot be considered as human');
    $check->run();
    isa_ok($check->result(), 'npg_qc::autoqc::results::result');
    my $jpath = "$tdir/2549_6#1.result.json";
    ok(-e $jpath, 'output json file exists');
    my $result = npg_qc::autoqc::results::result->load($jpath);
    isa_ok($result, 'npg_qc::autoqc::results::result');
    is($result->id_run, 2549, 'run id');
    is($result->position, 6, 'position');
};

1;
