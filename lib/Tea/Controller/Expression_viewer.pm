package Tea::Controller::Expression_viewer;

use Moose;
use Lucy::Simple;
use Lucy::Search::RangeQuery;
use Lucy::Search::IndexSearcher;
use Lucy::Search::TermQuery;
use Lucy::Search::ANDQuery;
use Lucy::Search::QueryParser;

use JSON;

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
  
  
  my $dbname = $c->config->{dbname};
  my $host = $c->config->{dbhost};
  my $username = $c->config->{dbuser};
  my $password = $c->config->{dbpass};

  my $schema = Tea::Schema->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  my $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  
  # get all organisms for input select
  my $all_organism_rs = $schema->resultset('Organism');
  my @orgs = ();
  my $organism_hr_name;
  my $organism_name;
  
  while(my $org_obj = $all_organism_rs->next) {
    $organism_name = $org_obj->species;

    if ($org_obj->variety) {
      $organism_name .= " ".$org_obj->variety;
    }

    push(@orgs,"<input id=\"organism_".$org_obj->organism_id."\" type='checkbox' class='organism_col' value=\'".$org_obj->organism_id."\'><label for=\"organism_".$org_obj->organism_id."\" class=\"organism_label\">&nbsp;$organism_name</label><br>");
  }
  
  my $organisms_html = join("\n", @orgs);
  $c->stash->{organism_html} = $organisms_html;
  
  
  # my @layer_types = ("organ","stage","tissue");
  #
  # foreach my $type (@layer_types) {
  #
  #   my $stage_rs = $schema->resultset('LayerType')->search({layer_type => $type})->single;
  #   my $layer_stage_rs = $schema->resultset('Layer')->search({layer_type_id => $stage_rs->layer_type_id});
  #
  #   my %html_hash =();
  #
  #   while(my $layer = $layer_stage_rs->next) {
  #       my $stage_rs = $schema->resultset('LayerInfo')->search({layer_info_id => $layer->layer_info_id})->single;
  #       # push(@html_array,"<input type='checkbox'>&nbsp;".$stage_rs->name);
  #       $html_hash{"<input type='checkbox'>&nbsp;".$stage_rs->name} = 1;
  #   }
  #
  #   # my $stages_html = join("<br>", @html_array);
  #   my $stages_html = join("<br>", map {$_} keys %html_hash);
  #   print STDERR "\"$stages_html\"\n";
  #
  #   $c->stash->{$type."_html"} = "\"$stages_html\"";
  # }
  
  
  $c->stash(template => 'Expression_viewer/input.mas');
}

sub get_expression :Path('/Expression_viewer/output/') :Args(0) {
    my ($self, $c) = @_;
    
    # to store erros as they may happen
    my @errors; 
 
    # get variables from catalyst object
    my $params = $c->req->body_params();
	my @query_gene = $c->req->param("input_gene");
	my $corr_filter = $c->req->param("correlation_filter")||0.65;
  # my $organ_filter = $c->req->param("organ_filter");
  my $stage_filter = $c->req->param("stage_filter");
  my $tissue_filter = $c->req->param("tissue_filter");
  
	my $current_page = $c->req->param("current_page") || 1;
	my $pages_num = $c->req->param("all_pages") || 1;
	my $expr_path = $c->config->{expression_indexes_path};
	my $corr_path = $c->config->{correlation_indexes_path};
	my $desc_path = $c->config->{description_index_path};
	my $locus_path = $c->config->{locus_index_path};
	
  my @stages = split(",",$stage_filter);
  my @tissues = split(",",$tissue_filter);
  
	my $query_gene = "";
	my @genes;
	my $multiple_genes = 1;
	# print STDERR "array_length = ".scalar(@query_gene)."\n";
	
	my @corr_values;
	my $total_corr_genes = 0;
	
	#check number of input genes
	if (scalar(@query_gene) == 1) {
		$query_gene = shift @query_gene;
		$multiple_genes = 0;
		
		if ($query_gene =~ /\n/) {
			
			print STDERR "$query_gene\n";
			
			$query_gene =~ s/[\n\s,]+/,/g;
			print STDERR "$query_gene\n";
			
			$query_gene =~ s/\.[12]\.*[12]*//g;
			print STDERR "$query_gene\n";
			
			@genes = split(",", $query_gene);
			@corr_values = ("list") x scalar(@genes);
			
			my @uniq_genes = uniq(@genes);
			if (scalar(@uniq_genes) >=20) {
				@genes = @uniq_genes[0..19];
			} else {
				@genes = @uniq_genes[0..$#uniq_genes];
			}
			$query_gene = shift @genes;
			
			$multiple_genes = 1;
		}
		
	} elsif (scalar(@query_gene) > 1) {
		@corr_values = ("blast") x scalar(@query_gene);
		my @uniq_genes = uniq(@query_gene);
		
		if (scalar(@uniq_genes) >=20) {
			@genes = @uniq_genes[0..19];
		} else {
			@genes = @uniq_genes[0..$#uniq_genes];
		}
		$query_gene = shift @genes;
	}
	
	# strip gene name
	$query_gene =~ s/^\s+//;
	$query_gene =~ s/\s+$//;
	$query_gene =~ s/\.\d$//;
	$query_gene =~ s/\.\d$//;
	
	#------------------------------------------------------------------------------------------------------------------
	if (!$multiple_genes) {
		# get correlation filter value (it is 100 higher when it comes from the input slider)
		if ($corr_filter > 1) {
			$corr_filter = $corr_filter/100;
		}
		# my $total_corr_genes = 0;
		$current_page = $current_page - 1;

		# Get Correlation Data
		# my @genes;
		# my @corr_values;
		my $lucy_corr = Lucy::Simple->new(
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

		my $hits = $lucy_corr->search(
			query      => $query_gene,
			sort_spec  => $sort_spec,
			num_wanted => 19,
			offset     => $current_page*19,
		);

		$total_corr_genes = $hits;

		if (!$total_corr_genes) {
			push ( @errors , "Gene not found.\n");
			# print STDERR "total_corr_genes: $total_corr_genes\n";
		}

		# Send error message to the web if something is wrong
		if (scalar (@errors) > 0){

			my $user_errors = join("<br />", @errors);
			print STDERR "$user_errors\n";
			# $c->stash->{rest} = {error => $user_errors};
			$c->stash->{error} = $user_errors;
			$c->stash->{template} = '/Expression_viewer/output.mas';
			return;
		}

		# Get page number after correlation filtering
		if ($corr_filter > 0.65) {
			my $range_query = Lucy::Search::RangeQuery->new(
			    field         => 'correlation',
			    lower_term    => $corr_filter,
			);
			my $searcher = Lucy::Search::IndexSearcher->new(
			    index => $corr_path,
			);
			my $qparser  = Lucy::Search::QueryParser->new(
			    schema => $searcher->get_schema,
			);
			my $term_query = $qparser->parse($query_gene);

		    my $and_query = Lucy::Search::ANDQuery->new(
		        children => [ $range_query, $term_query],
		    );

		    # my $hits1 = $searcher->hits( query => $term_query );
		    my $hit_intersect = $searcher->hits( query => $and_query );

			# print STDERR "\n\ntotal number of correlated genes: $hits\n\n";
			# print STDERR "\n\ntotal number of TERM: ".$hits1->total_hits()."\n\n";
			# print STDERR "\n\ntotal number of hit_intersect: ".$hit_intersect->total_hits()."\n\n";

			$total_corr_genes = $hit_intersect->total_hits();
		}

		#------------------------------------- save data for filtered genes
		while ( my $hit = $lucy_corr->next ) {
			if ($query_gene eq $hit->{gene1} && $hit->{correlation} >= $corr_filter) {
				push(@genes, $hit->{gene2});
			} elsif ($query_gene eq $hit->{gene2} && $hit->{correlation} >= $corr_filter) {
				push(@genes, $hit->{gene1});
			}
			push(@corr_values, $hit->{correlation})
			# print "$hit->{gene1}\t$hit->{gene2}\t$hit->{correlation}\n";
		}
	}
#------------------------------------------------------------------------------------------------------------------

	#------------------------------------- Temporal Data
  # my @stages = ("10DPA", "Mature_Green", "Pink");
  # my @tissues = ("Inner_Epidermis", "Parenchyma", "Vascular_Tissue", "Collenchyma", "Outer_Epidermis");
	
	
	# build data structure
	unshift(@genes, $query_gene);
	my %gene_stage_tissue_expr;
	my %stage;
	my %tissue;
	my %descriptions;
	my %locus_ids;
	
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
	
	my $lucy_desc = Lucy::Simple->new(
	    path     => $desc_path,
	    language => 'en',
	);
	
	my $lucy_locus = Lucy::Simple->new(
	    path     => $locus_path,
	    language => 'en',
	);
	
	
	foreach my $g (@genes) {
		$lucy->search(
		    query      => $g,
			num_wanted => 20
		);
		
		$lucy_desc->search(
		    query      => $g,
			num_wanted => 1,
		);
		
		$lucy_locus->search(
		    query      => $g,
			num_wanted => 1,
		);
		
		while ( my $hit = $lucy->next ) {
			# all expression values are multiplied by 1 to transform string into integer or float
			$gene_stage_tissue_expr{$hit->{gene}}{$hit->{stage}}{$hit->{tissue}} = $hit->{expression} * 1
		}
		
		while ( my $desc_hit = $lucy_desc->next ) {
			$descriptions{$desc_hit->{gene}} = $desc_hit->{description};
		}
		
		while ( my $locus_hit = $lucy_locus->next ) {
			$locus_ids{$locus_hit->{gene}} = $locus_hit->{locus_id};
		}
		
	}
	
	
	my @AoAoA;
	
	for (my $g=0; $g<scalar(@genes); $g++) {
		for (my $s=0; $s<scalar(@stages); $s++) {
			for (my $t=0; $t<scalar(@tissues); $t++) {
				
				$AoAoA[$g][$s][$t] = $gene_stage_tissue_expr{$genes[$g]}{$stages[$s]}{$tissues[$t]};
				
				# print STDERR "$genes[$g]\t$stages[$s]\t$tissues[$t] = $AoAoA[$g][$s][$t]\n";
			}
		}
	}
	
	
	$c->stash->{genes} = \@genes;
	$c->stash->{stages} = \@stages;
	$c->stash->{tissues} = \@tissues;
	$c->stash->{aoaoa} = \@AoAoA;
	$c->stash->{correlation} = \@corr_values;
	$c->stash->{pages_num} = (int($total_corr_genes/19)+1);
	$c->stash->{current_page} = ($current_page + 1);
	$c->stash->{correlation_filter} = ($corr_filter);
	$c->stash->{description} = \%descriptions;
	$c->stash->{locus_ids} = \%locus_ids;
	
	$c->stash->{template} = '/Expression_viewer/output.mas';
}


sub download_expression_data :Path('/download_expression_data/') :Args(0) {
    my ($self, $c) = @_;
    
	#get parameters from form and config file
	my $query_gene = $c->req->param("input_gene");
	my $corr_filter = $c->req->param("correlation_filter");
  
  my $stage_filter = $c->req->param("stages");
  $stage_filter =~ s/[\[\]\"]//g;
  my $tissue_filter = $c->req->param("tissues");
  $tissue_filter =~ s/[\[\]\"]//g;
  
  my @stages = split(",",$stage_filter);
  my @tissues = split(",",$tissue_filter);

	my $expr_path = $c->config->{expression_indexes_path};
	my $corr_path = $c->config->{correlation_indexes_path};
	my $desc_path = $c->config->{description_index_path};
	
	# strip gene name
	$query_gene =~ s/^\s+//;
	$query_gene =~ s/\s+$//;
	$query_gene =~ s/\.\d$//;
	$query_gene =~ s/\.\d$//;
	
	print STDERR "downloading expression data\n";
	
	# get correlation filter value (it is 100 higher when it comes from the input slider)
	if ($corr_filter > 1) {
		$corr_filter = $corr_filter/100;
	}
	
	#------------------------------------- Get Correlation Data
	my @genes;
	my %corr_values;
	$corr_values{$query_gene} = 1;
	
	my $lucy_corr = Lucy::Simple->new(
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
	
	my $hits = $lucy_corr->search(
		query      => $query_gene,
		sort_spec  => $sort_spec,
		num_wanted => 10000,
	);
	
	#------------------------------------- Get data after correlation filter
	if ($corr_filter > 0.65) {
		my $range_query = Lucy::Search::RangeQuery->new(
		    field         => 'correlation',
		    lower_term    => $corr_filter,
		);	
		my $searcher = Lucy::Search::IndexSearcher->new( 
		    index => $corr_path,
		);
		my $qparser  = Lucy::Search::QueryParser->new( 
		    schema => $searcher->get_schema,
		);
		my $term_query = $qparser->parse($query_gene);
	
	    my $and_query = Lucy::Search::ANDQuery->new(
	        children => [ $range_query, $term_query],
	    );
	}
	
	#------------------------------------- save data for filtered genes
	while ( my $hit = $lucy_corr->next ) {
		if ($query_gene eq $hit->{gene1} && $hit->{correlation} >= $corr_filter) {
			push(@genes, $hit->{gene2});
			$corr_values{$hit->{gene2}} = $hit->{correlation};
		} elsif ($query_gene eq $hit->{gene2} && $hit->{correlation} >= $corr_filter) {
			push(@genes, $hit->{gene1});
			$corr_values{$hit->{gene1}} = $hit->{correlation};
		}
	}
	
	#------------------------------------- Temporal Data
	unshift(@genes, $query_gene);
  # my @stages = ("10DPA", "Mature_Green", "Pink");
  # my @tissues = ("Inner_Epidermis", "Parenchyma", "Vascular", "Collenchyma", "Outer_Epidermis");
	
	
	#------------------------------------- build data structure
	my %gene_stage_tissue_expr;
	my %stage;
	my %tissue;
	my %descriptions;

	foreach my $g (@genes) {
		foreach my $t (@tissues) {
			foreach my $s (@stages) {
				$gene_stage_tissue_expr{$g}{$t}{$s} = 0;
			}
		}
	}
	
	my $lucy = Lucy::Simple->new(
	    path     => $expr_path,
	    language => 'en',
	);
	
	my $lucy_desc = Lucy::Simple->new(
	    path     => $desc_path,
	    language => 'en',
	);
	
	#------------------------------------- Create header
	my @header;
	my @lines;
	
	push(@header,"gene name");
	
	foreach my $t (@tissues) {
		foreach my $s (@stages) {
			push(@header, "$t:$s RPKM");
		}
	}
	push(@header,"Correlation\tdescription");
	push(@lines, join("\t", @header));
	
	#------------------------------------- get expression and description
	foreach my $g (@genes) {
		$lucy->search(
		    query      => $g,
			num_wanted => 10000,
		);
		
		$lucy_desc->search(
		    query      => $g,
			num_wanted => 1,
		);
		
		while ( my $hit = $lucy->next ) {
			# all expression values are multiplied by 1 to transform string into integer or float
			$gene_stage_tissue_expr{$hit->{gene}}{$hit->{tissue}}{$hit->{stage}} = $hit->{expression} * 1
		}

		while ( my $desc_hit = $lucy_desc->next ) {
			$descriptions{$desc_hit->{gene}} = $desc_hit->{description};
		}
	}
	
	#------------------------------------- create file for downloading
	my @expr_columns;
	
	foreach my $g (@genes) {
		foreach my $t (@tissues) {
			foreach my $s (@stages) {
				push(@expr_columns, $gene_stage_tissue_expr{$g}{$t}{$s});
			}
		}
		push(@lines, "$g\t".join("\t", @expr_columns)."\t$corr_values{$g}\t$descriptions{$g}");
		@expr_columns = [];
		shift(@expr_columns);
	}
	
	my $tab_file = join("\n", @lines);
	my $filename = "TEA_".$query_gene."_cf$corr_filter.txt";

	#------------------------------------- send file
	$c->res->content_type('text/plain');
	$c->res->header('Content-Disposition', qq[attachment; filename="$filename"]);
	$c->res->body($tab_file);
}

sub uniq {
    my %seen;
    grep !$seen{$_}++, @_;
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
