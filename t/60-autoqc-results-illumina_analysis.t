use strict;
use warnings;
use Test::More tests => 3;
use Test::Exception;

use_ok ('npg_qc::autoqc::results::illumina_analysis');

#### subtest q[Object type] => sub {
####     plan tests => 4;
####     my $r = npg_qc::autoqc::results::genotype_call->new(id_run => 24135, position => 1, tag_index => 1, path => q[mypath]);
####     isa_ok ($r, 'npg_qc::autoqc::results::genotype_call');
####     is($r->check_name(), 'genotype call', 'check name');
####     is($r->class_name(), 'genotype_call', 'class name');
####     is ($r->filename4serialization(), '24135_1#1.genotype_call.json', 'default file name');
#### };

subtest q[NovaSeq] => sub {
    plan tests => 15;
    my $r_from_json;
    my $json_path = q[t/data/26261.illumina_analysis.json];
    lives_ok{ $r_from_json = npg_qc::autoqc::results::illumina_analysis->load($json_path); }
              q[Loaded from json];
    isa_ok ( $r_from_json, 'npg_qc::autoqc::results::illumina_analysis' );

    my $expected = {
      1 => {
        1 => 0.729827716946602,
        4 => 0.725119539846977
      },
      2 => {
        1 => 0.730749591564139,
        4 => 0.725799171254039
      },
      3 => {
        1 => 0.723879835257928,
        4 => 0.718298812086383
      },
      4 => {
        1 => 0.726539225627979,
        4 => 0.72141629892091
      }
    };
    my $actual = $r_from_json->aligned_mean();
    is_deeply ($actual, $expected, 'aligned_mean');

    $expected = {
      1 => {
        1 => 0.0146529963028342,
        4 => 0.0149956082237995
      },
      2 => {
        1 => 0.0162900823530457,
        4 => 0.0159316243053525
      },
      3 => {
        1 => 0.0170099269662763,
        4 => 0.0186949295763636
      },
      4 => {
        1 => 0.0160134281235872,
        4 => 0.0156766963314264
      }
    };
    $actual = $r_from_json->aligned_stdev();
    is_deeply ($actual, $expected, 'aligned_stdev');

    $expected = {
      1 => 74.8258662548348,
      2 => 75.6833538819352,
      3 => 76.3401988048662,
      4 => 76.5976080215582
    };
    $actual = $r_from_json->cluster_pf_mean();
    is_deeply ($actual, $expected, 'cluster_pf_mean');

    $expected = {
      1 => 1.72348790121062,
      2 => 1.02418930249387,
      3 => 1.1894155129928,
      4 => 1.09582888609973
    };
    $actual = $r_from_json->cluster_pf_stdev();
    is_deeply ($actual, $expected, 'cluster_pf_stdev');

    $expected = {
      1 => 3061802.61431624,
      2 => 3096890.18482906,
      3 => 3123767.64850427,
      4 => 3134300.58653846
    };
    $actual = $r_from_json->cluster_count_pf_mean();
    is_deeply ($actual, $expected, 'cluster_count_pf_mean');

    $expected = {
      1 => 70523.4703691533,
      2 => 41908.8430363188,
      3 => 48669.7409527728,
      4 => 44840.2660234705
    };
    $actual = $r_from_json->cluster_count_pf_stdev();
    is_deeply ($actual, $expected, 'cluster_count_pf_stdev');

    $expected = {
      1 => 2865847247,
      2 => 2898689213,
      3 => 2923846519,
      4 => 2933705349
    };
    $actual = $r_from_json->cluster_count_pf_total();
    is_deeply ($actual, $expected, 'cluster_count_pf_total');

    $expected = {
      1 => 2215791.40792371,
      2 => 2241183.87996083,
      3 => 2260634.79191703,
      4 => 2268257.35827295
    };
    $actual = $r_from_json->cluster_density_pf_mean();
    is_deeply ($actual, $expected, 'cluster_density_pf_mean');

    $expected = {
      1 => 51037.0260219498,
      2 => 30328.9486662863,
      3 => 35221.7328853217,
      4 => 32450.3858345576
    },
    $actual = $r_from_json->cluster_density_pf_stdev();
    is_deeply ($actual, $expected, 'cluster_density_pf_stdev');

    $expected = {
      1 => 4.65910237492488e-09,
      2 => 4.65910237492488e-09,
      3 => 4.65910237492488e-09,
      4 => 4.65910237492488e-09
    };
    $actual = $r_from_json->cluster_density_stdev();
    is_deeply ($actual, $expected, 'cluster_density_stdev');

    $expected = {
      1 => 84.4681499836258,
      2 => 86.7737758698452,
      3 => 86.3295566888503,
      4 => 87.5020701707984
    };
    $actual = $r_from_json->occupied_mean();
    is_deeply ($actual, $expected, 'occupied_mean');

    $expected = {
      1 => 3.15664983763036,
      2 => 1.23449400818654,
      3 => 1.91265374843535,
      4 => 1.5523701135365
    };
    $actual = $r_from_json->occupied_stdev();
    is_deeply ($actual, $expected, 'occupied_stdev');

    $expected = {
                    1 => 84.4681499836258,
                    2 => 86.7737758698452,
                    3 => 86.3295566888503,
                    4 => 87.5020701707984
                   };
    $actual = $r_from_json->occupied_mean();
    is_deeply ($actual, $expected, 'occupied_mean');
};

subtest q[MiSeq] => sub {
    plan tests => 7;
    my $r_from_json;
    my $json_path = q[t/data/27801.illumina_analysis.json];
    lives_ok{ $r_from_json = npg_qc::autoqc::results::illumina_analysis->load($json_path); }
              q[Loaded from json];
    isa_ok ( $r_from_json, 'npg_qc::autoqc::results::illumina_analysis' );

    my $expected = {
      1 => 777968.321428571
    };
    my $actual = $r_from_json->cluster_count_mean();
    is_deeply ($actual, $expected, 'cluster_count_mean');

    $expected = {
      1 => 11580.81271073
    };
    $actual = $r_from_json->cluster_count_stdev();
    is_deeply ($actual, $expected, 'cluster_count_stdev');

    $expected = {
      1 => 21783113
    };
    $actual = $r_from_json->cluster_count_total();
    is_deeply ($actual, $expected, 'cluster_count_total');

    $expected = {
      1 => 1172015.91964286
    };
    $actual = $r_from_json->cluster_density_mean();
    is_deeply ($actual, $expected, 'cluster_density_mean');

    $expected = {
      1 => 23345.0142310551
    };
    $actual = $r_from_json->cluster_density_stdev();
    is_deeply ($actual, $expected, 'cluster_density_stdev');
}
