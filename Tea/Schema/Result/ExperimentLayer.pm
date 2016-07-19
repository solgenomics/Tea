use utf8;
package Tea::Schema::Result::ExperimentLayer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tea::Schema::Result::ExperimentLayer

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<experiment_layer>

=cut

__PACKAGE__->table("experiment_layer");

=head1 ACCESSORS

=head2 experiment_layer_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'experiment_layer_experiment_layer_id_seq'

=head2 experiment_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'experiment_layer_experiment_id_seq'

=head2 layer_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'experiment_layer_layer_id_seq'

=cut

__PACKAGE__->add_columns(
  "experiment_layer_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "experiment_layer_experiment_layer_id_seq",
  },
  "experiment_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "experiment_layer_experiment_id_seq",
  },
  "layer_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "experiment_layer_layer_id_seq",
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</experiment_layer_id>

=back

=cut

__PACKAGE__->set_primary_key("experiment_layer_id");

=head1 RELATIONS

=head2 experiment

Type: belongs_to

Related object: L<Tea::Schema::Result::Experiment>

=cut

__PACKAGE__->belongs_to(
  "experiment",
  "Tea::Schema::Result::Experiment",
  { experiment_id => "experiment_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 layer

Type: belongs_to

Related object: L<Tea::Schema::Result::Layer>

=cut

__PACKAGE__->belongs_to(
  "layer",
  "Tea::Schema::Result::Layer",
  { layer_id => "layer_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-07-19 09:49:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EMZuJoduUJVfnbFH0uwqMw
# These lines were loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/ExperimentLayer.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package Tea::Schema::Result::ExperimentLayer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tea::Schema::Result::ExperimentLayer

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<experiment_layer>

=cut

__PACKAGE__->table("experiment_layer");

=head1 ACCESSORS

=head2 experiment_layer_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'experiment_layer_experiment_layer_id_seq'

=head2 experiment_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'experiment_layer_experiment_id_seq'

=head2 layer_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'experiment_layer_layer_id_seq'

=cut

__PACKAGE__->add_columns(
  "experiment_layer_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "experiment_layer_experiment_layer_id_seq",
  },
  "experiment_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "experiment_layer_experiment_id_seq",
  },
  "layer_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "experiment_layer_layer_id_seq",
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</experiment_layer_id>

=back

=cut

__PACKAGE__->set_primary_key("experiment_layer_id");

=head1 RELATIONS

=head2 experiment

Type: belongs_to

Related object: L<Tea::Schema::Result::Experiment>

=cut

__PACKAGE__->belongs_to(
  "experiment",
  "Tea::Schema::Result::Experiment",
  { experiment_id => "experiment_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 layer

Type: belongs_to

Related object: L<Tea::Schema::Result::Layer>

=cut

__PACKAGE__->belongs_to(
  "layer",
  "Tea::Schema::Result::Layer",
  { layer_id => "layer_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-07-18 09:37:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IcdDjbsniZw+ofGEmBb0mg
# These lines were loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/ExperimentLayer.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package Tea::Schema::Result::ExperimentLayer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tea::Schema::Result::ExperimentLayer

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<experiment_layer>

=cut

__PACKAGE__->table("experiment_layer");

=head1 ACCESSORS

=head2 experiment_layer_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'experiment_layer_experiment_layer_id_seq'

=head2 layer_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'experiment_layer_layer_id_seq'

=head2 experiment_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'experiment_layer_experiment_id_seq'

=cut

__PACKAGE__->add_columns(
  "experiment_layer_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "experiment_layer_experiment_layer_id_seq",
  },
  "layer_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "experiment_layer_layer_id_seq",
  },
  "experiment_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "experiment_layer_experiment_id_seq",
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</experiment_layer_id>

=back

=cut

__PACKAGE__->set_primary_key("experiment_layer_id");

=head1 RELATIONS

=head2 experiment

Type: belongs_to

Related object: L<Tea::Schema::Result::Experiment>

=cut

__PACKAGE__->belongs_to(
  "experiment",
  "Tea::Schema::Result::Experiment",
  { experiment_id => "experiment_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 layer

Type: belongs_to

Related object: L<Tea::Schema::Result::Layer>

=cut

__PACKAGE__->belongs_to(
  "layer",
  "Tea::Schema::Result::Layer",
  { layer_id => "layer_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2015-10-08 14:06:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QCMWihbheBs/1jOKNOJSjw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
# End of lines loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/ExperimentLayer.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
# End of lines loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/ExperimentLayer.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
