package Tea::Controller::Expression_viewer_output;

use Moose;
use Lucy::Simple;

# use namespace::autoclean;


BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
    default => 'application/json',
    stash_key => 'rest',
    map => { 'application/json' => 'JSON', 'text/html' => 'JSON' },
   );

our %urlencode;


=head1 NAME

Tea::Controller::Expression_viewer - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut


sub get_expression :Path('/Expression_viewer/result2/') :Args(0) {
    my ($self, $c) = @_;
    
    # to store erros as they happen
    my @errors; 
 
    # get variables from catalyst object
    my $params = $c->req->body_params();
	my $query_gene = $c->req->param("gene");
	my $lucy_path = $c->config->{lucy_indexes_path};
	
	# my $path_to_index = '/home/noe/cxgn/Tea/root/static/expression_indexes/';
	my $lucy = Lucy::Simple->new(
	    path     => $lucy_path,
	    language => 'en',
	);

	$lucy->search(
	    query      => $query_gene,
		num_wanted => 100000
	);
	
	# build data structure
	# my %gene_stage_tissue_expr;
	# my %stage;
	# my %tissue;
	
	my @data_structure = [];
	my @dpa;
	my @mg;
	my @pink;
	
	while ( my $hit = $lucy->next ) {
		if ($hit->{tissue} == 'dpa') {
			push(@dpa, $hit->{expression});
		}
		if ($hit->{tissue} == 'mg') {
			push(@mg, $hit->{expression});
		}
		if ($hit->{tissue} == 'pink') {
			push(@pink, $hit->{expression});
		}
		# $hit->{stage};
	}
	
	@data_structure = [@dpa,@mg,@pink];
	
	
	$c->stash->{rest} = {expr=> \@data_structure};
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
