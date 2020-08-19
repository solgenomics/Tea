use utf8;
package Tea::Schema::Result::PrivateGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tea::Schema::Result::private_group

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<private_group>

=cut

__PACKAGE__->table("private_group");

=head1 ACCESSORS

=head2 private_group_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'private_group_private_group_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=cut

__PACKAGE__->add_columns(
  "private_group_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "private_group_private_group_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</private_group_id>

=back

=cut

__PACKAGE__->set_primary_key("private_group_id");

=head1 RELATIONS

=head2 project_private_groups

Type: has_many

Related object: L<Tea::Schema::Result::ProjectPrivateGroup>

=cut

__PACKAGE__->has_many(
  "project_private_groups",
  "Tea::Schema::Result::ProjectPrivateGroup",
  { "foreign.private_group_id" => "self.private_group_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


1;
