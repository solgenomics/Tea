package Tea::Controller::Expression_viewer_output;

use Moose;
use Lucy::Simple;
use JSON;

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


sub get_expression :Path('/Expression_viewer/result/') :Args(0) {
    my ($self, $c) = @_;
    
    # to store erros as they happen
    my @errors; 
 
    # get variables from catalyst object
    my $params = $c->req->body_params();
	my $query_gene = $c->req->param("gene");
	my $lucy_path = $c->config->{lucy_indexes_path};
	
    # Send error message to the web if something is wrong
	if (scalar (@errors) > 0){
		my $user_errors = join("<br />", @errors);
		$c->stash->{rest} = {error => $user_errors};
		return;
	}
	
	#------------------------------------- Temporal Data
	my @genes = ("Solyc04g074910", "Solyc05g052140", "Solyc04g076060", "Solyc04g076210", "Solyc04g076010");
	unshift(@genes, $query_gene);
	my @stages = ("dpa", "mg", "pink");
	my @tissues = ("ie", "parenchyma", "vascular", "collenchyma", "oe");
	#----------------------------------------------------------------------
	
	
	# build data structure
	my %gene_stage_tissue_expr;
	my %stage;
	my %tissue;
	
	foreach my $g (@genes) {
		foreach my $s (@stages) {
			foreach my $t (@tissues) {
				$gene_stage_tissue_expr{$g}{$s}{$t} = 0;
			}
		}
	}
	
	my $lucy = Lucy::Simple->new(
	    path     => $lucy_path,
	    language => 'en',
	);
	
	foreach my $g (@genes) {
		$lucy->search(
		    query      => $g,
			num_wanted => 100000
		);
		
		while ( my $hit = $lucy->next ) {
			# all expression values are multiplied by 1 to transform string into integer or float
			$gene_stage_tissue_expr{$hit->{gene}}{$hit->{stage}}{$hit->{tissue}} = $hit->{expression} * 1
		}
	}
	
	my @AoAoA;
	
	for (my $g=0; $g<scalar(@genes); $g++) {
		for (my $s=0; $s<scalar(@stages); $s++) {
			for (my $t=0; $t<scalar(@tissues); $t++) {
				$AoAoA[$g][$s][$t] = $gene_stage_tissue_expr{$genes[$g]}{$stages[$s]}{$tissues[$t]};
			}
		}
	}

	$c->stash->{rest} = {expr=> \%gene_stage_tissue_expr,
						genes => \@genes,
						stages => \@stages,
						tissues => \@tissues,
						aoaoa => \@AoAoA,
	};
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
