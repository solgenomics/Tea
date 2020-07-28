use utf8;
package Tea::Schema::Result::LayerInfo;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tea::Schema::Result::LayerInfo

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<layer_info>

=cut

__PACKAGE__->table("layer_info");

=head1 ACCESSORS

=head2 layer_info_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'layer_info_layer_info_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 bg_color

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 organ

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=cut

__PACKAGE__->add_columns(
  "layer_info_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "layer_info_layer_info_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "bg_color",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "organ",
  { data_type => "varchar", is_nullable => 1, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</layer_info_id>

=back

=cut

__PACKAGE__->set_primary_key("layer_info_id");

=head1 RELATIONS

=head2 layers

Type: has_many

Related object: L<Tea::Schema::Result::Layer>

=cut

__PACKAGE__->has_many(
  "layers",
  "Tea::Schema::Result::Layer",
  { "foreign.layer_info_id" => "self.layer_info_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-04-19 15:22:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sHHMCO4jta9lDSAZ6v+wqQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
