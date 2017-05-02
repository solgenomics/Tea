package Tea::Controller::Tea_navigation;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Tea::Controller::Tea_navigation - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut


sub help :Path('/help/') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'help.mas');
}


sub help_input :Path('/help/input') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'help/input_help.mas');
}

sub help_params :Path('/help/input_params') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'help/input_params.mas');
}


sub help_output :Path('/help/output') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'help/output_help.mas');
}

sub find_genes :Path('/help/find_genes') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(template => 'help/find_gene.mas');
}

sub project_menu :Path('/project_menu/') :Args(0) {
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
    $c->stash(template => 'project_menu.mas');
}

sub manage_projects :Path('/expression_viewer/manage_project/') :Args(0) {
    my ( $self, $c ) = @_;
  
    my $dbname = $c->config->{dbname};
    my $host = $c->config->{dbhost};
    my $username = $c->config->{dbuser};
    my $password = $c->config->{dbpass};
    
    my $delete_enabled = $c->config->{delete_project};

    my $schema = Tea::Schema->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
    my $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  
    my @project_ids;
    my %project_names;

    my $all_rs = $schema->resultset("Project");
    while(my $n = $all_rs->next) {
      push (@project_ids,$n->project_id);
      $project_names{$n->project_id} = $n->name;
    }
    
    if ($delete_enabled) {
      $c->stash(project_ids => \@project_ids);
      $c->stash(project_names => \%project_names);
      $c->stash(template => 'Expression_viewer/manage_projects.mas');
    } else {
      $c->stash(template => 'index.mas');
    }
}


=encoding utf8

=head1 AUTHOR

Noe Fernandez

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
