use utf8;
package Tea::Schema::Result::Layer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tea::Schema::Result::Layer

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<layer>

=cut

__PACKAGE__->table("layer");

=head1 ACCESSORS

=head2 layer_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'layer_layer_id_seq'

=head2 image_file_name

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 image_width

  data_type: 'integer'
  is_nullable: 1

=head2 image_height

  data_type: 'integer'
  is_nullable: 1

=head2 cube_ordinal

  data_type: 'integer'
  is_nullable: 1

=head2 img_ordinal

  data_type: 'integer'
  is_nullable: 1

=head2 layer_type_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'layer_layer_type_id_seq'

=head2 layer_info_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'layer_layer_info_id_seq'

=cut

__PACKAGE__->add_columns(
  "layer_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "layer_layer_id_seq",
  },
  "image_file_name",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "image_width",
  { data_type => "integer", is_nullable => 1 },
  "image_height",
  { data_type => "integer", is_nullable => 1 },
  "cube_ordinal",
  { data_type => "integer", is_nullable => 1 },
  "img_ordinal",
  { data_type => "integer", is_nullable => 1 },
  "layer_type_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "layer_layer_type_id_seq",
  },
  "layer_info_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "layer_layer_info_id_seq",
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</layer_id>

=back

=cut

__PACKAGE__->set_primary_key("layer_id");

=head1 RELATIONS

=head2 figure_layers

Type: has_many

Related object: L<Tea::Schema::Result::FigureLayer>

=cut

__PACKAGE__->has_many(
  "figure_layers",
  "Tea::Schema::Result::FigureLayer",
  { "foreign.layer_id" => "self.layer_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 layer_info

Type: belongs_to

Related object: L<Tea::Schema::Result::LayerInfo>

=cut

__PACKAGE__->belongs_to(
  "layer_info",
  "Tea::Schema::Result::LayerInfo",
  { layer_info_id => "layer_info_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 layer_type

Type: belongs_to

Related object: L<Tea::Schema::Result::LayerType>

=cut

__PACKAGE__->belongs_to(
  "layer_type",
  "Tea::Schema::Result::LayerType",
  { layer_type_id => "layer_type_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-10-27 08:57:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/IR1mzk5ZF9rI7BBvEsDHg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
