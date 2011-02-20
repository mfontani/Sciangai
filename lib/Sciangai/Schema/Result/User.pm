package Sciangai::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Sciangai::Schema::Result::User

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=head2 password

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=head2 name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=head2 created

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 is_active

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 32 },
  "password",
  { data_type => "char", default_value => "", is_nullable => 0, size => 64 },
  "name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 64 },
  "created",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "is_active",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("username", ["username"]);

=head1 RELATIONS

=head2 pages

Type: has_many

Related object: L<Sciangai::Schema::Result::Page>

=cut

__PACKAGE__->has_many(
  "pages",
  "Sciangai::Schema::Result::Page",
  { "foreign.last_modified_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07007 @ 2011-02-19 16:35:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sxaZwu69oS7y39Plyxruow


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
