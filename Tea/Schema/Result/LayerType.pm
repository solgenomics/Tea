use utf8;
package Tea::Schema::Result::LayerType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tea::Schema::Result::LayerType

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<layer_type>

=cut

__PACKAGE__->table("layer_type");

=head1 ACCESSORS

=head2 layer_type_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'layer_type_layer_type_id_seq'

=head2 layer_type

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=cut

__PACKAGE__->add_columns(
  "layer_type_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "layer_type_layer_type_id_seq",
  },
  "layer_type",
  { data_type => "varchar", is_nullable => 0, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</layer_type_id>

=back

=cut

__PACKAGE__->set_primary_key("layer_type_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<layer_type_layer_type_key>

=over 4

=item * L</layer_type>

=back

=cut

__PACKAGE__->add_unique_constraint("layer_type_layer_type_key", ["layer_type"]);

=head1 RELATIONS

=head2 layers

Type: has_many

Related object: L<Tea::Schema::Result::Layer>

=cut

__PACKAGE__->has_many(
  "layers",
  "Tea::Schema::Result::Layer",
  { "foreign.layer_type_id" => "self.layer_type_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2015-10-08 14:06:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3RGmpSeLOdhLJ4XpPKzgsQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
