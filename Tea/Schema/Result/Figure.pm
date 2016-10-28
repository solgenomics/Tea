use utf8;
package Tea::Schema::Result::Figure;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tea::Schema::Result::Figure

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<figure>

=cut

__PACKAGE__->table("figure");

=head1 ACCESSORS

=head2 figure_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'figure_figure_id_seq'

=head2 figure_name

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 cube_stage_name

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 project_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'figure_project_id_seq'

=cut

__PACKAGE__->add_columns(
  "figure_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "figure_figure_id_seq",
  },
  "figure_name",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "cube_stage_name",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "project_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "figure_project_id_seq",
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</figure_id>

=back

=cut

__PACKAGE__->set_primary_key("figure_id");

=head1 RELATIONS

=head2 conditions

Type: has_many

Related object: L<Tea::Schema::Result::Condition>

=cut

__PACKAGE__->has_many(
  "conditions",
  "Tea::Schema::Result::Condition",
  { "foreign.figure_id" => "self.figure_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 figure_layers

Type: has_many

Related object: L<Tea::Schema::Result::FigureLayer>

=cut

__PACKAGE__->has_many(
  "figure_layers",
  "Tea::Schema::Result::FigureLayer",
  { "foreign.figure_id" => "self.figure_id" },
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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-10-27 17:08:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Z3wlDOHEN43kuTNcC7USpw
# These lines were loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/Figure.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package Tea::Schema::Result::Figure;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tea::Schema::Result::Figure

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<figure>

=cut

__PACKAGE__->table("figure");

=head1 ACCESSORS

=head2 figure_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'figure_figure_id_seq'

=head2 cube_stage_name

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 project_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'figure_project_id_seq'

=cut

__PACKAGE__->add_columns(
  "figure_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "figure_figure_id_seq",
  },
  "cube_stage_name",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "project_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "figure_project_id_seq",
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</figure_id>

=back

=cut

__PACKAGE__->set_primary_key("figure_id");

=head1 RELATIONS

=head2 conditions

Type: has_many

Related object: L<Tea::Schema::Result::Condition>

=cut

__PACKAGE__->has_many(
  "conditions",
  "Tea::Schema::Result::Condition",
  { "foreign.figure_id" => "self.figure_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 figure_layers

Type: has_many

Related object: L<Tea::Schema::Result::FigureLayer>

=cut

__PACKAGE__->has_many(
  "figure_layers",
  "Tea::Schema::Result::FigureLayer",
  { "foreign.figure_id" => "self.figure_id" },
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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-10-27 08:57:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3IKPVtDO2bIn64HTRM/bPA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
# End of lines loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/Figure.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
