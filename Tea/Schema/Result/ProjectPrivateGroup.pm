use utf8;
package Tea::Schema::Result::ProjectPrivateGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tea::Schema::Result::ProjectPrivateGroup

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<project_private_group>

=cut

__PACKAGE__->table("project_private_group");

=head1 ACCESSORS

=head2 project_private_group_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'project_private_group_project_private_group_id_seq'

=head2 project_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'project_private_group_project_id_seq'

=head2 private_group_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'project_private_group_private_group_id_seq'

=cut

__PACKAGE__->add_columns(
  "project_private_group_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "project_private_group_project_private_group_id_seq",
  },
  "project_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "project_private_group_project_id_seq",
  },
  "private_group_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "project_private_group_private_group_id_seq",
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</project_private_group_id>

=back

=cut

__PACKAGE__->set_primary_key("project_private_group_id");

=head1 RELATIONS

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

=head2 private_group

Type: belongs_to

Related object: L<Tea::Schema::Result::PrivateGroup>

=cut

__PACKAGE__->belongs_to(
  "private_group",
  "Tea::Schema::Result::PrivateGroup",
  { private_group_id => "private_group_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);



1;
