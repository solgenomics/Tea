package Tea::Controller::Expression_viewer;

use Moose;

# use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }


=head1 NAME

Tea::Controller::Expression_viewer - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path('/Expression_viewer/input/') :Args(0) {
    my ( $self, $c ) = @_;

    # $c->response->body('Matched Tea::Controller::Expression_viewer in Expression_viewer.');
 
    # $c->stash(template => 'Expression_viewer/output.mas');
    $c->stash(template => 'Expression_viewer/input.mas');
	
}

sub get_expression :Path('/Expression_viewer/input2/') :Args(0) {
    my ($self, $c) = @_;
    
    # to store erros as they happen
    my @errors; 
 
    # get variables from catalyst object
    my $params = $c->req->body_params();
	my $query_gene = $c->req->param("input_gene");
	my $expr_path = $c->config->{expression_indexes_path};
	my $corr_path = $c->config->{correlation_indexes_path};
	
    # Send error message to the web if something is wrong
	if (scalar (@errors) > 0){
		my $user_errors = join("<br />", @errors);
		$c->stash->{rest} = {error => $user_errors};
		return;
	}
	
	#------------------------------------- Get Correlation Data
	my @genes;
	my @corr_values;
	my $lucy = Lucy::Simple->new(
	    path     => $corr_path,
	    language => 'en',
	);

	my $sort_spec = Lucy::Search::SortSpec->new(
	     rules => [
		 	Lucy::Search::SortRule->new( field => 'correlation', reverse => 1,),
		 	Lucy::Search::SortRule->new( field => 'gene2', reverse => 0,),
		 	Lucy::Search::SortRule->new( field => 'gene1',),
	     ],
	 );
	
	 my $hits = $lucy->search(
	 	query     => $query_gene,
	 	sort_spec => $sort_spec,
	 	num_wanted => 19,
	 );
	
	while ( my $hit = $lucy->next ) {
		if ($query_gene eq $hit->{gene1}) {
			push(@genes, $hit->{gene2});
		} elsif ($query_gene eq $hit->{gene2}) {
			push(@genes, $hit->{gene1});
		}
		push(@corr_values, $hit->{correlation})
		# print "$hit->{gene1}\t$hit->{gene2}\t$hit->{correlation}\n";
	}
	
	#------------------------------------- Temporal Data
	# my @genes = ("Solyc04g074910", "Solyc05g052140", "Solyc04g076060", "Solyc04g076210", "Solyc04g076010");
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
	    path     => $expr_path,
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

	$c->stash->{genes} = \@genes;
	$c->stash->{stages} = \@stages;
	$c->stash->{tissues} = \@tissues;
	$c->stash->{aoaoa} = \@AoAoA;
	$c->stash->{correlation} = \@corr_values;
	
	# $c->stash->{rest} = {expr=> \%gene_stage_tissue_expr,
	# 					genes => \@genes,
	# 					stages => \@stages,
	# 					tissues => \@tissues,
	# 					aoaoa => \@AoAoA,
	# };
	$c->stash->{template} = '/Expression_viewer/output.mas';
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
