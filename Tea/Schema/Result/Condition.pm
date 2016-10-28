use utf8;
package Tea::Schema::Result::Condition;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tea::Schema::Result::Condition

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<condition>

=cut

__PACKAGE__->table("condition");

=head1 ACCESSORS

=head2 condition_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'condition_condition_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 figure_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'condition_figure_id_seq'

=cut

__PACKAGE__->add_columns(
  "condition_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "condition_condition_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "figure_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "condition_figure_id_seq",
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</condition_id>

=back

=cut

__PACKAGE__->set_primary_key("condition_id");

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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-10-27 17:08:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LFLXJmZUWFpLF3heeCIYQA
# These lines were loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/Condition.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package Tea::Schema::Result::Condition;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tea::Schema::Result::Condition

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<condition>

=cut

__PACKAGE__->table("condition");

=head1 ACCESSORS

=head2 condition_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'condition_condition_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 figure_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'condition_figure_id_seq'

=cut

__PACKAGE__->add_columns(
  "condition_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "condition_condition_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "figure_id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "condition_figure_id_seq",
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</condition_id>

=back

=cut

__PACKAGE__->set_primary_key("condition_id");

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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-10-27 08:57:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LCsCE645jhnkYX32eHcyMg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
# End of lines loaded from '/home/noe/cxgn/Tea/Tea/Schema/Result/Condition.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
