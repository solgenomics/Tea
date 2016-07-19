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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-07-19 09:49:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ShvY9hjq8oBHAaHs4GB0+Q
# These lines were loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/Experiment.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-07-18 09:37:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RT0ZDIt92BU3GJE8SJCyrQ
# These lines were loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/Experiment.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

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


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2015-10-08 14:06:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZITuJmnFEQ8/j+dTxw8mhg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
# End of lines loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/Experiment.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
# End of lines loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/Experiment.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
