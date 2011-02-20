package Sciangai::Schema::Result::Page;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Sciangai::Schema::Result::Page

=cut

__PACKAGE__->table("page");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 256

=head2 is_live

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 1

=head2 revision

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 contents

  data_type: 'blob'
  is_nullable: 0

=head2 last_modified

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 last_modified_by

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 256 },
  "is_live",
  { data_type => "tinyint", default_value => 1, is_nullable => 1 },
  "revision",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "contents",
  { data_type => "blob", is_nullable => 0 },
  "last_modified",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "last_modified_by",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 last_modified_by

Type: belongs_to

Related object: L<Sciangai::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "last_modified_by",
  "Sciangai::Schema::Result::User",
  { id => "last_modified_by" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07007 @ 2011-02-19 16:35:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gAZO0Xss2ClSk2RmFW1KlQ

sub _markdown_to_html
{
    my $self = shift;
    eval "require Text::MultiMarkdown";
    return Text::MultiMarkdown::markdown(shift);
}

sub contents_html
{
    my $self = shift;
    my $contents = $self->contents;
    return $self->_markdown_to_html($contents);
}

sub as_hashref {
    my $self = shift;
    my $user = $self->last_modified_by;
    return {
        ( map { $_ => $self->$_ }
              qw/id name is_live revision contents last_modified/ ),
         contents_html => $self->contents_html,
         last_modified_by => { ( map { $_ => $user->$_ } qw/id username name created is_active/ ), },
    }
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
