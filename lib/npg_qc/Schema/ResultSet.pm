package npg_qc::Schema::ResultSet;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
use Carp;
use JSON;
use Try::Tiny;
use Readonly;

extends 'DBIx::Class::ResultSet';

our $VERSION = '0';

Readonly::Scalar my $COMPOSITION_FK_COLUMN_NAME => 'id_seq_composition';

sub search_autoqc {
  my ($self, $query, $size) = @_;

  my $how = {};
  my $values = {};
  my %comp_columns = map { $_ => 1 }
                     $self->result_source()->schema()->source('SeqComponent')
                          ->columns();
  foreach my $col_name (keys %{$query}) {
    # Query by id_run, position and other attributes of the component
    # should be performed against the seq_component table.
    my $aliased = join q[.],
                  $comp_columns{$col_name} ? 'seq_component':'me',
                  $col_name;
    $values->{$aliased} = $query->{$col_name};
  }
  if ($size) {
    $values->{'seq_component_compositions.size'} = $size;
  }
  $how->{'prefetch'} = {'seq_component_compositions' => 'seq_component'};

  return $self->search_rs($values, $how);
}

sub search_via_composition {
  my ($self, $compositions) = @_;

  $compositions ||= [];
  my $query = @{$compositions}
    ? {'seq_composition.digest' => [map { $_->digest } @{$compositions}]}
    : {};
  return $self->search_rs($query,{'prefetch' => 'seq_composition'});
}

sub deflate_unique_key_components {
  my ($self, $values, $only_existing) = @_;

  if (!defined $values) {
    croak q[Values hash should be defined];
  }
  if (ref $values ne q[HASH]) {
    croak q[Values should be a hash];
  }

  my $source = $self->result_source();
  my %constraints = $source->unique_constraints();
  my @names = grep {$_ ne 'primary'} keys %constraints;

  if (@names) {
    if (scalar @names > 1) {
      croak q[Multiple unique constraints in ] . $self->result_class;
    }
    foreach my $col_name (@{$constraints{$names[0]}}) {
      if ($only_existing && !exists $values->{$col_name}) {
        next;
      }
      my $default_value = $source->column_info($col_name)->{'default_value'};
      if (!defined $default_value) {
        next;
      }
      my $col_value = $values->{$col_name};
      if (!defined $col_value) {
        $values->{$col_name} = $default_value;
      } elsif (ref $col_value eq 'HASH') {
        my @keys = keys %{$col_value};
        my $key = pop @keys;
        if (@keys == 0 && (exists $col_value->{$key} && !defined $col_value->{$key})) {
          $values->{$col_name}->{$key} = $default_value;
        }
      }
    }
  }

  return;
}

sub _find_composition {
  my ($self, $digest, $num_components) = @_;

  if (!$digest) {
    croak 'Digest is not defined';
  }
  if (!$num_components) {
    croak 'Number of components is not defined or is zero';
  }
  return $self->result_source()->schema()->resultset('SeqComposition')
                                         ->find({
                            'digest' => $digest,
                            'size'   => $num_components
                                                });
}

sub _validate {
  my ($self, $composition) = @_;
  if (!$composition ||
      (ref $composition ne 'npg_tracking::glossary::composition')) {
    croak 'Composition object argument expected';
  }
  $self->related_resultset('seq_composition'); # gives error if relationship
                                               # is not defined
  return;
}

sub find_seq_composition {
  my ($self, $composition) = @_;
  $self->_validate($composition);
  return $self->_find_composition($composition->digest, $composition->num_components);
}

sub find_or_create_seq_composition {
  my ($self, $composition, $check_digest) = @_;

  $self->_validate($composition);
  my $digest         = $composition->digest;
  my $num_components = $composition->num_components;
  my $schema         = $self->result_source()->schema();
  my $transaction = sub {
    my $composition_row = $self->_find_composition($digest, $num_components);
    # If composition exists, we assume that it's properly defined, i.e.
    # all relevant components and records in the linking table exist.
    if ($composition_row) {
      # If asked, ensure that the found row represents the same composition.
      if ($check_digest &&
           ($composition->freeze ne $composition_row->create_composition()->freeze)) {
        croak "A different composition object with the same digest '$digest' " .
              'already exists in the database';
      }
    } else {
      $composition_row = $schema->resultset('SeqComposition')
                                ->create({
                    'digest' => $digest,
                    'size'   => $num_components
                                         });
      my $pk = $composition_row->id_seq_composition;
      my $component_rs = $schema->resultset('SeqComponent');

      foreach  my $c ($composition->components_list()) {
        my $values = decode_json($c->freeze());

        ##########
        # Through inheritance from the reference finder role some of the
        # autoqc results generated with npg_tracking releases up to and
        # including release 86.3 had subset attribute set to 'all' where
        # it should be undefined, for example, for prexes.
        #
        # See https://github.com/wtsi-npg/npg_tracking/pull/403 for
        # details.
        #
        # It's too late to unset the value at this point. The digest
        # was computed for a composition with subset "all", and a search
        # by composition is based on the digest value.
        #
        if ($values->{'subset'} && $values->{'subset'} eq 'all') {
          croak 'Subset "all" not allowed';
        }

        $values->{'digest'} = $c->digest();
        # Find or (instantiate and save) each component
        my $row = $component_rs->find_or_create($values);
        # Whether the component existed or not, we have to create a new
        # composition membership record for it.
        $row->create_related('seq_component_compositions',
               {$COMPOSITION_FK_COLUMN_NAME => $pk,
                'size'                      => $num_components});
      }
    }

    return $composition_row;
  };

  # When multiple processes are running in parallel they occasionally
  # try to create the same composition or component at roughly the
  # same time. If the 'Duplicate entry' error is due to this, rerunning
  # the transaction should not produce an error since an existing row
  # will be returned.
  my $row;
  try {
    $row = $schema->txn_do($transaction);
  } catch {
    my $e = $_;
    if ($e =~ /Duplicate\ entry/smx) {
      $row = $schema->txn_do($transaction);
    } else {
      croak $e;
    }
  };

  return $row;
}

sub composition_fk_column_name {
  return $COMPOSITION_FK_COLUMN_NAME;
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
__END__

=head1 NAME

npg_qc::Schema::ResultSet

=head1 SYNOPSIS

=head1 DESCRIPTION

A parent class for ResultSet objects in npg_qc::Schema DBIx binding.

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 SUBROUTINES/METHODS

=head2 search_autoqc

Search for tables that are linked to the seq_composition table.
A ResultSet object is returned in any context.

The "size" argument, if defined and evaluated to true, limits the results
to compositions with the number of components equal to the value of the argument.

  my $rset = $rs->search_autoqc($query, $size);

If the "size" argument is not defined or is zero, the search will be for all
compositions that have a component defined by the search query - the first argument.
The query parameters might be any attributes of the component (columns of
the seq_component table). The query keys that do not match columns of the
seq_component table are assumed to be the names of the columns in the table
this resultset object represents.

  $srs = $schema->resultset("SequenceSummary");

  # all rows for a lane
  $srs->search_autoqc({id_run => 17967, position => 1 });
  # rows for a lane-level result
  $srs->search_autoqc({id_run => 17967, position => 1, tag_index => undef });
  # rows for tag 45 results
  $srs->search_autoqc({id_run => 17967, position => 1, tag_index => 45 });
  # rows for tag 45 results, default subset
  $srs->search_autoqc({id_run => 17967, position => 1, tag_index => 45, subset => undef });
  # rows for tag 45 results, phix subset
  $srs->search_autoqc({id_run => 17967, position => 1, tag_index => 45, subset => 'phix' });
  # rows for tag 45 results, default subset where there is one component only
  $srs->search_autoqc({id_run => 17967, position => 1, tag_index => 45, subset => 'phix' }, size => 1);
  # rows for tag 45 results, default subset where the component the query defines is one of two components
  $srs->search_autoqc({id_run => 17967, position => 1, tag_index => 45, subset => 'phix' }, size => 2);

=head2 search_via_composition

Search for tables that are linked to the seq_composition table.
A ResultSet object for this resultset is returned in any context.

The only argument is an array of npg_tracking::glossary::composition composition
objects, which might be empty or undefined. For each composition object the 
search brings either one or none table rows.

  $rs->search_via_composition($composition);

If compositions array is empty or undefined, all table rows are returned.

  $rs->search_via_composition();
 
Gives an error if this resultset does not have a relationship to
the seq_composition table.

=head2 deflate_unique_key_components

Takes a hash key reference of column names and column values,
deflates unique key components if needed, ensuring that if this hash reference
is used for querying, correct results will be produced. Changes values in-place.
  
  my $rs = $schema->resultset('SomeTable');
  $rs->deflate_unique_key_components($values);

If the second boolean argument is true, will not deflate the values that are
not in the hash.

  my $only_existing = 1;
  $rs->deflate_unique_key_components($values, $only_existing);

=head2 find_seq_composition

Given a npg_tracking::glossary::composition object, finds a database
record for this composition. Id found, a npg_qc::Schema::Result::SeqComposition
row is returned, otherwise an undefined value is returned.

=head2 find_or_create_seq_composition

A factory method. Given a npg_tracking::glossary::composition object,
either finds a database record for this composition or creates one.
A found or created npg_qc::Schema::Result::SeqComposition row is
returned. If a row is created, all relevant (not already existing)
component rows are created and a a record is created in a linking table
for every component-composition pair.

Gives an error if this resultset does not have a relationship to
the seq_composition table.

If a true value is given as a second attrubute and a composition object is
found, a check for a clash of sha256 digest of composition objects is performed.
Error is raised if the clashing digests are detected.

=head2 composition_fk_column_name

 Returns the name of the column with a foreign key linking this table to the
 seq_composition table.

=head1 DEPENDENCIES

=over

=item Moose

=item MooseX::MarkAsMethods

=item Carp

=item DBIx::Class::ResultSet

=item JSON

=item Try::Tiny

=item Readonly

=back

=head1 INCOMPATIBILITIES

This code does not work with MooseX::NonMoose hence false inline_constructor
option is used when calling ->make_immutable. This might make the code slower
than it could have been.

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

Marina Gourtovaia <lt>mg8@sanger.ac.uk<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2017 GRL Genome Research Limited

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

