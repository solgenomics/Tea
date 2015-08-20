package Tea::Controller::Overview;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Tea::Controller::Overview - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut


sub index :Path('/overview/') :Args(0) {
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
    $c->stash(template => 'overview.mas');
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
