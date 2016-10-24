package Tea::Controller::Anatomy_viewer;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Tea::Controller::Anatomy_viewer - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub anatomy_viewer :Path('/anatomy_viewer/tomography/') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'anatomy_viewer/anatomy_viewer.mas');
}

sub microscopy :Path('/anatomy_viewer/microscopy/') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'anatomy_viewer/microscopy.mas');
}

sub slm82_pericarp :Path('/anatomy_viewer/microscopy/slm82_pericarp') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'anatomy_viewer/slm82_pericarp.mas');
}

sub slm82_fruit :Path('/anatomy_viewer/microscopy/slm82_fruit') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'anatomy_viewer/slm82_fruit.mas');
}

sub pimpi_fruit :Path('/anatomy_viewer/microscopy/pimpi_fruit') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'anatomy_viewer/pimpi_fruit.mas');
}


sub av_menu :Path('/anatomy_viewer/') :Args(0) {
    my ( $self, $c ) = @_;
  
    my $dbname = $c->config->{dbname};
    my $host = $c->config->{dbhost};
    my $username = $c->config->{dbuser};
    my $password = $c->config->{dbpass};

    my $schema = Tea::Schema->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
    my $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  
    my @project_ids;
    my %project_names;

    my $all_rs = $schema->resultset("Project");
    while(my $n = $all_rs->next) {
      push (@project_ids,$n->project_id);
      $project_names{$n->project_id} = $n->name;
    }
  
    $c->stash(project_ids => \@project_ids);
    $c->stash(project_names => \%project_names);
    $c->stash(template => 'anatomy_viewer/anatomy_menu.mas');

}


=encoding utf8

=head1 AUTHOR

noe,,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
