use utf8;
package Tea::Schema::Result::Organism;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tea::Schema::Result::Organism

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<organism>

=cut

__PACKAGE__->table("organism");

=head1 ACCESSORS

=head2 organism_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'organism_organism_id_seq'

=head2 species

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=head2 variety

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "organism_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "organism_organism_id_seq",
  },
  "species",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "variety",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "description",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</organism_id>

=back

=cut

__PACKAGE__->set_primary_key("organism_id");

=head1 RELATIONS

=head2 projects

Type: has_many

Related object: L<Tea::Schema::Result::Project>

=cut

__PACKAGE__->has_many(
  "projects",
  "Tea::Schema::Result::Project",
  { "foreign.organism_id" => "self.organism_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-10-27 17:08:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:x5qVrc0tRLnm4VRWUZhWEQ
# These lines were loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/Organism.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package Tea::Schema::Result::Organism;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tea::Schema::Result::Organism

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<organism>

=cut

__PACKAGE__->table("organism");

=head1 ACCESSORS

=head2 organism_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'organism_organism_id_seq'

=head2 species

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=head2 variety

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "organism_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "organism_organism_id_seq",
  },
  "species",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "variety",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "description",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</organism_id>

=back

=cut

__PACKAGE__->set_primary_key("organism_id");

=head1 RELATIONS

=head2 projects

Type: has_many

Related object: L<Tea::Schema::Result::Project>

=cut

__PACKAGE__->has_many(
  "projects",
  "Tea::Schema::Result::Project",
  { "foreign.organism_id" => "self.organism_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-10-27 08:57:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:z7i8n4bBuxgTNdXGhUIf+w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
# End of lines loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/Organism.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
