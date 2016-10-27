use utf8;
package Tea::Schema::Result::FigureLayer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tea::Schema::Result::FigureLayer

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<figure_layer>

=cut

__PACKAGE__->table("figure_layer");

=head1 ACCESSORS

=head2 figure_layer_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'figure_layer_figure_layer_id_seq'

=head2 figure_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'figure_layer_figure_id_seq'

=head2 layer_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'figure_layer_layer_id_seq'

=cut

__PACKAGE__->add_columns(
  "figure_layer_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "figure_layer_figure_layer_id_seq",
  },
  "figure_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "figure_layer_figure_id_seq",
  },
  "layer_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "figure_layer_layer_id_seq",
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</figure_layer_id>

=back

=cut

__PACKAGE__->set_primary_key("figure_layer_id");

=head1 RELATIONS

=head2 figure

Type: belongs_to

Related object: L<Tea::Schema::Result::Figure>

=cut

__PACKAGE__->belongs_to(
  "figure",
  "Tea::Schema::Result::Figure",
  { figure_id => "figure_id" },
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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-10-27 08:57:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RtRkVzcu25+gDdVNVr4ypg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
