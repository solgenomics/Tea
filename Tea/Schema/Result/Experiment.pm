use utf8;
package Tea::Schema::Result::Experiment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tea::Schema::Result::Experiment

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<experiment>

=cut

__PACKAGE__->table("experiment");

=head1 ACCESSORS

=head2 experiment_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'experiment_experiment_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 project_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'experiment_project_id_seq'

=cut

__PACKAGE__->add_columns(
  "experiment_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "experiment_experiment_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "project_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "experiment_project_id_seq",
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</experiment_id>

=back

=cut

__PACKAGE__->set_primary_key("experiment_id");

=head1 RELATIONS

=head2 experiment_layers

Type: has_many

Related object: L<Tea::Schema::Result::ExperimentLayer>

=cut

__PACKAGE__->has_many(
  "experiment_layers",
  "Tea::Schema::Result::ExperimentLayer",
  { "foreign.experiment_id" => "self.experiment_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 project

Type: belongs_to

Related object: L<Tea::Schema::Result::Project>

=cut

__PACKAGE__->belongs_to(
  "project",
  "Tea::Schema::Result::Project",
  { project_id => "project_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2015-05-22 20:12:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tfNn0aMpzXW/WZZ5KEtdcg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
