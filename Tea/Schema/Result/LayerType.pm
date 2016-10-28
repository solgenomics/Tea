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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-10-27 17:08:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XWyLDEVfXcH7qDSuWXmjJw
# These lines were loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/LayerType.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-10-27 08:57:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KolX/+qn3gwGwDUKNuG2Yg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
# End of lines loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/LayerType.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
