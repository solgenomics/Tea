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

=head2 bg_color

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 description

  data_type: 'text'
  is_nullable: 1

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
  "bg_color",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "description",
  { data_type => "text", is_nullable => 1 },
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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-07-19 09:49:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:u5ki0LSgZ/4A2ep4q24+hA
# These lines were loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/LayerInfo.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

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

=head2 bg_color

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 description

  data_type: 'text'
  is_nullable: 1

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
  "bg_color",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "description",
  { data_type => "text", is_nullable => 1 },
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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-07-18 09:37:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lMNkHxABTPkeapa/VMSo0A
# These lines were loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/LayerInfo.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

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


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2015-10-08 14:06:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eUHt1fnOxKzO2d2wEUMRTQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
# End of lines loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/LayerInfo.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
# End of lines loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/LayerInfo.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
