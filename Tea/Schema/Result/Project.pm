use utf8;
package Tea::Schema::Result::Project;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tea::Schema::Result::Project

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<project>

=cut

__PACKAGE__->table("project");

=head1 ACCESSORS

=head2 project_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'project_project_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 contact

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 expr_unit

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 indexed_dir

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 ordinal

  data_type: 'integer'
  is_nullable: 1

=head2 organism_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'project_organism_id_seq'

=cut

__PACKAGE__->add_columns(
  "project_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "project_project_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "contact",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "expr_unit",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "ordinal",
  { data_type => "integer", is_nullable => 1 },
  "indexed_dir",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "organism_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "project_organism_id_seq",
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</project_id>

=back

=cut

__PACKAGE__->set_primary_key("project_id");

=head1 RELATIONS

=head2 figures

Type: has_many

Related object: L<Tea::Schema::Result::Figure>

=cut

__PACKAGE__->has_many(
  "figures",
  "Tea::Schema::Result::Figure",
  { "foreign.project_id" => "self.project_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 organism

Type: belongs_to

Related object: L<Tea::Schema::Result::Organism>

=cut

__PACKAGE__->belongs_to(
  "organism",
  "Tea::Schema::Result::Organism",
  { organism_id => "organism_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-10-27 17:08:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Npr9FNOYWJKcC2BqzcPZZw
# These lines were loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/Project.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package Tea::Schema::Result::Project;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tea::Schema::Result::Project

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<project>

=cut

__PACKAGE__->table("project");

=head1 ACCESSORS

=head2 project_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'project_project_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 contact

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 expr_unit

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 ordinal

  data_type: 'integer'
  is_nullable: 1

=head2 indexed_dir

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 organism_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'project_organism_id_seq'

=cut

__PACKAGE__->add_columns(
  "project_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "project_project_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "contact",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "expr_unit",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "ordinal",
  { data_type => "integer", is_nullable => 1 },
  "indexed_dir",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "organism_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "project_organism_id_seq",
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</project_id>

=back

=cut

__PACKAGE__->set_primary_key("project_id");

=head1 RELATIONS

=head2 figures

Type: has_many

Related object: L<Tea::Schema::Result::Figure>

=cut

__PACKAGE__->has_many(
  "figures",
  "Tea::Schema::Result::Figure",
  { "foreign.project_id" => "self.project_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 organism

Type: belongs_to

Related object: L<Tea::Schema::Result::Organism>

=cut

__PACKAGE__->belongs_to(
  "organism",
  "Tea::Schema::Result::Organism",
  { organism_id => "organism_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-10-27 08:57:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:w4OeuLp91rRWc+Ui4YyEKg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
# End of lines loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/Project.pm'


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
