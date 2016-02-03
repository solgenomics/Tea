package Tea::Controller::Expression_viewer;

use Moose;
use Lucy::Simple;
use Lucy::Search::RangeQuery;
use Lucy::Search::IndexSearcher;
use Lucy::Search::TermQuery;
use Lucy::Search::ANDQuery;
use Lucy::Search::QueryParser;
use Data::Dumper qw(Dumper);
use Array::Utils qw(:all);

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

    push(@orgs,"<div class=\"radio\">\n<label><input id=\"organism_".$org_obj->organism_id."\" type='radio' class='organism_col' name=\"optradio\" value=\'".$org_obj->organism_id."\'> $organism_name</label>\n</div>\n");
    # push(@orgs,"<input id=\"organism_".$org_obj->organism_id."\" type='checkbox' class='organism_col' value=\'".$org_obj->organism_id."\'><label for=\"organism_".$org_obj->organism_id."\" class=\"organism_label\">&nbsp;$organism_name</label><br>");
  }
  
  my $organisms_html = join("\n", @orgs);
  $c->stash->{organism_html} = $organisms_html;
  $c->stash(template => 'Expression_viewer/input.mas');
}


sub _get_correlation {
  my $c = shift;
  my $corr_filter = shift;
  my $current_page = shift;
  my $corr_index_path = shift;
  my $query_gene = shift;
  my $to_download = shift;
  
  my @genes;
	my @corr_values;
	my $total_corr_genes = 0;
  my %corr_hash;
  
  # to store erros as they may happen
  my @errors; 
  
	# get correlation filter value (it is 100 higher when it comes from the input slider)
	if ($corr_filter > 1) {
		$corr_filter = $corr_filter/100;
	}
  
	# my $total_corr_genes = 0;
  # $current_page = $current_page - 1;

	# Get Correlation Data
	my $lucy_corr = Lucy::Simple->new(
	    path     => $corr_index_path,
	    language => 'en',
	);

	my $sort_spec = Lucy::Search::SortSpec->new(
	     rules => [
		 	Lucy::Search::SortRule->new( field => 'correlation', reverse => 1,),
		 	Lucy::Search::SortRule->new( field => 'gene2', reverse => 0,),
		 	Lucy::Search::SortRule->new( field => 'gene1',),
	     ],
	);
  
  my $hits;
  if ($to_download) {
    $hits = $lucy_corr->search(
      query      => $query_gene,
      sort_spec  => $sort_spec,
      num_wanted => 10000,
    );
  }
  else {
    $hits = $lucy_corr->search(
      query      => $query_gene,
      sort_spec  => $sort_spec,
      num_wanted => 19,
      offset     => $current_page*19,
    );
  }

	$total_corr_genes = $hits;

	if (!$total_corr_genes) {
		push ( @errors , "Not correlated genes found.\n");
		# print STDERR "total_corr_genes: $total_corr_genes\n";
	}

	# Send error message to the web if something is wrong
	if (scalar (@errors) > 0){

		my $user_errors = join("<br />", @errors);
		print STDERR "$user_errors\n";
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
		    index => $corr_index_path,
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
  $corr_hash{$query_gene} = 1;
  
	while ( my $hit = $lucy_corr->next ) {
		if ($query_gene eq $hit->{gene1} && $hit->{correlation} >= $corr_filter) {
			push(@genes, $hit->{gene2});
			$corr_hash{$hit->{gene2}} = $hit->{correlation};
		} elsif ($query_gene eq $hit->{gene2} && $hit->{correlation} >= $corr_filter) {
			push(@genes, $hit->{gene1});
			$corr_hash{$hit->{gene1}} = $hit->{correlation};
		}
		push(@corr_values, $hit->{correlation})
		# print "$hit->{gene1}\t$hit->{gene2}\t$hit->{correlation}\n";
	}
  
  
  
  return (\@genes,\@corr_values,$total_corr_genes,\%corr_hash);
}
  











sub get_expression :Path('/Expression_viewer/output/') :Args(0) {
  my ($self, $c) = @_;
  
  # get variables from catalyst object
  my $params = $c->req->body_params();
	my @query_gene = $c->req->param("input_gene");
	my $corr_filter = $c->req->param("correlation_filter")||0.65;
  my $organism_filter = $c->req->param("organism_filter");
  my $organ_filter = $c->req->param("organ_filter");
  my $stage_filter = $c->req->param("stage_filter");
  my $tissue_filter = $c->req->param("tissue_filter");
  
	my $current_page = $c->req->param("current_page") || 1;
	my $pages_num = $c->req->param("all_pages") || 1;
	my $expr_path = $c->config->{expression_indexes_path};
	my $corr_path = $c->config->{correlation_indexes_path};
	my $loci_and_desc_path = $c->config->{loci_and_description_index_path};
	
  # connect to the db and get the indexed dir name for the selected organism
  my $dbname = $c->config->{dbname};
  my $host = $c->config->{dbhost};
  my $username = $c->config->{dbuser};
  my $password = $c->config->{dbpass};

  my $schema = Tea::Schema->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  my $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  
  my $project_rs = $schema->resultset('Project')->search({organism_id => $organism_filter})->single;
  
  my $corr_index_path = $corr_path."/".$project_rs->indexed_dir;
  my $expr_index_path = $expr_path."/".$project_rs->indexed_dir;
  # indexed dir name saved in $corr_index_path and $expr_index_path
  
  
  my @stages = split(",",$stage_filter);
  my @tissues = split(",",$tissue_filter);
  
  my $image_hash_ref;
  
  my $db_funct = Tea::Controller::Expression_viewer_functions->new();
  
  my $project_ids = $db_funct->get_ids_from_query($schema,"Project",[$organism_filter],"organism_id","project_id");
  my $experiment_ids = $db_funct->get_ids_from_query($schema,"Experiment",$project_ids,"project_id","experiment_id");
  
  # getting all the experiments from the organism
  my $experiment_rs = $schema->resultset('Experiment')->search({project_id => $project_rs->project_id});
  
  # only organism selected
  if (!$stage_filter && !$tissue_filter) {
    my ($organ_arrayref,$stage_arrayref,$tissue_arrayref) = $db_funct->get_input_options($schema,$experiment_rs);

    @stages = @$stage_arrayref;
    @tissues = @$tissue_arrayref;
    my @exp_ids;
    
    while (my $exp_rs = $experiment_rs->next) {
      push(@exp_ids,$exp_rs->experiment_id);
    }

    $image_hash_ref = $db_funct->get_image_hash($schema,$experiment_ids);
  }
  
  # if only stage is selected, get all tissues
  elsif ($stage_filter && !$tissue_filter) {
    
    my $stage_info_ids = $db_funct->get_ids_from_query($schema,"LayerInfo",\@stages,"name","layer_info_id");
    my $stage_ids = $db_funct->get_ids_from_query($schema,"Layer",$stage_info_ids,"layer_info_id","layer_id");
    my $found_exp_ids = $db_funct->get_ids_from_query($schema,"ExperimentLayer",$stage_ids,"layer_id","experiment_id");
    
    my @exp_ids = intersect(@$experiment_ids, @$found_exp_ids);
    
    
    $image_hash_ref = $db_funct->get_image_hash($schema,\@exp_ids);
    
    my $layer_ids = $db_funct->get_ids_from_query($schema,"ExperimentLayer",\@exp_ids,"experiment_id","layer_id");
    my $tissue_info_ids = $db_funct->filter_layer_type($schema,$layer_ids,"tissue","layer_info_id");
    my $tissue_names = $db_funct->get_ids_from_query($schema,"LayerInfo",$tissue_info_ids,"layer_info_id","name");

    @tissues = @{$tissue_names};
  }
  
  # if only tissue is selected, get all stages
  elsif (!$stage_filter && $tissue_filter) {
    
    my $tissue_info_ids = $db_funct->get_ids_from_query($schema,"LayerInfo",\@tissues,"name","layer_info_id");
    my $tissue_ids = $db_funct->get_ids_from_query($schema,"Layer",$tissue_info_ids,"layer_info_id","layer_id");
    my $exp_ids = $db_funct->get_ids_from_query($schema,"ExperimentLayer",$tissue_ids,"layer_id","experiment_id");
    
    my @intersected_layers = intersect(@$experiment_ids,@$exp_ids);
    
    $image_hash_ref = $db_funct->get_image_hash($schema,\@intersected_layers);
    
    my $layer_ids = $db_funct->get_ids_from_query($schema,"ExperimentLayer",\@intersected_layers,"experiment_id","layer_id");
    my $stage_info_ids = $db_funct->filter_layer_type($schema,$layer_ids,"stage","layer_info_id");
    my $stage_names = $db_funct->get_ids_from_query($schema,"LayerInfo",$stage_info_ids,"layer_info_id","name");

    @stages = @{$stage_names};
  }
  elsif ($stage_filter && $tissue_filter) {
    # stages and tissues selected
    
    my $tissue_info_ids = $db_funct->get_ids_from_query($schema,"LayerInfo",\@tissues,"name","layer_info_id");
    my $tissue_ids = $db_funct->get_ids_from_query($schema,"Layer",$tissue_info_ids,"layer_info_id","layer_id");
    my $stage_info_ids = $db_funct->get_ids_from_query($schema,"LayerInfo",\@stages,"name","layer_info_id");
    my $stage_ids = $db_funct->get_ids_from_query($schema,"Layer",$stage_info_ids,"layer_info_id","layer_id");
    
    
    my @intersected_layers = (@$stage_ids,@$tissue_ids);
    
    my $exp_ids = $db_funct->get_ids_from_query($schema,"ExperimentLayer",\@intersected_layers,"layer_id","experiment_id");
    
    $image_hash_ref = $db_funct->get_image_hash($schema,$exp_ids);
    
    my $stage_info_ids = $db_funct->filter_layer_type($schema,\@intersected_layers,"stage","layer_info_id");
    my $stage_names = $db_funct->get_ids_from_query($schema,"LayerInfo",$stage_info_ids,"layer_info_id","name");
    my $tissue_info_ids = $db_funct->filter_layer_type($schema,\@intersected_layers,"tissue","layer_info_id");
    my $tissue_names = $db_funct->get_ids_from_query($schema,"LayerInfo",$tissue_info_ids,"layer_info_id","name");

    @tissues = @{$tissue_names};
    @stages = @{$stage_names};
    
  }
  
  for (@stages) {
     s/ /_/g;
  }
  for (@tissues) {
     s/ /_/g;
  }

  
	my $query_gene = "";
	my @genes;
	my $multiple_genes = 1;
	# print STDERR "array_length = ".scalar(@query_gene)."\n";
	
	my @corr_values;
	
	#check number of input genes
	if (scalar(@query_gene) == 1) {
		$query_gene = shift @query_gene;
		$multiple_genes = 0;
		
		if ($query_gene =~ /\n/) {
			
			$query_gene =~ s/[\n\s,]+/,/g;
			$query_gene =~ s/\.[12]\.*[12]*//g;
			
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
	
	$query_gene =~ s/^s/S/;
  
	#------------------------------------------------------------------------------------------------------------------
  my $total_corr_genes = 0;
  my $genes;
  my $corr_values;
  my $corr_hash;
  
	$current_page = $current_page - 1;
  
	if (!$multiple_genes) {
    my $to_download = 0;
    
    ($genes,$corr_values,$total_corr_genes,$corr_hash) = _get_correlation($c,$corr_filter,$current_page,$corr_index_path,$query_gene,$to_download);
    
    if ($genes && $corr_values) {
      @genes = @$genes;
      @corr_values = @$corr_values;
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
				$gene_stage_tissue_expr{$g}{$s}{$t} = 0.000001;
			}
		}
	}
	
	my $lucy = Lucy::Simple->new(
	    path     => $expr_index_path,
	    language => 'en',
	);
	
  my $lucy_loci_and_desc = Lucy::Simple->new(
      path     => $loci_and_desc_path,
      language => 'en',
  );
	
	foreach my $g (@genes) {
		$lucy->search(
		    query      => $g,
			num_wanted => 10000
		);
		
    $lucy_loci_and_desc->search(
        query      => $g,
      num_wanted => 1,
    );
    
		while ( my $hit = $lucy->next ) {
			# all expression values are multiplied by 1 to transform string into integer or float
			$gene_stage_tissue_expr{$hit->{gene}}{$hit->{stage}}{$hit->{tissue}} = $hit->{expression} * 1;
		}
    
    while ( my $loci_and_desc_hit = $lucy_loci_and_desc->next ) {
      $locus_ids{$loci_and_desc_hit->{gene}} = $loci_and_desc_hit->{locus_id};
      $descriptions{$loci_and_desc_hit->{gene}} = $loci_and_desc_hit->{description};
    }
    
	}
	
	
	my @AoAoA;
	
	for (my $g=0; $g<scalar(@genes); $g++) {
		for (my $s=0; $s<scalar(@stages); $s++) {
			for (my $t=0; $t<scalar(@tissues); $t++) {
				
				$AoAoA[$g][$s][$t] = $gene_stage_tissue_expr{$genes[$g]}{$stages[$s]}{$tissues[$t]};
				
#        print STDERR "$genes[$g]\t$stages[$s]\t$tissues[$t] = $AoAoA[$g][$s][$t]\n";
			}
		}
	}
	
	$corr_filter = $c->req->param("correlation_filter")||0.65;
  # $organism_filter = $c->req->param("organism_filter");
  # $stage_filter = $c->req->param("stage_filter");
  # $tissue_filter = $c->req->param("tissue_filter");
	my @output_gene = $c->req->param("input_gene");
  
  
  # print STDERR "total_corr_genes: $total_corr_genes\n";
  
	
	$c->stash->{genes} = \@genes;
	$c->stash->{stages} = \@stages;
	$c->stash->{tissues} = \@tissues;
	$c->stash->{image_hash} = $image_hash_ref;
	$c->stash->{aoaoa} = \@AoAoA;
	$c->stash->{correlation} = \@corr_values;
	$c->stash->{pages_num} = (int($total_corr_genes/19)+1);
	$c->stash->{current_page} = ($current_page + 1);
	$c->stash->{output_gene} = \@output_gene;
	$c->stash->{correlation_filter} = $corr_filter;
	$c->stash->{organism_filter} = $organism_filter;
	$c->stash->{stage_filter} = $stage_filter;
	$c->stash->{tissue_filter} = $tissue_filter;
  $c->stash->{description} = \%descriptions;
	$c->stash->{index_dir_name} = $project_rs->indexed_dir;
	$c->stash->{project_id} = $project_rs->project_id;
	$c->stash->{project_name} = $project_rs->name;
  $c->stash->{locus_ids} = \%locus_ids;
	
	$c->stash->{template} = '/Expression_viewer/output.mas';
}


sub download_expression_data :Path('/download_expression_data/') :Args(0) {
    my ($self, $c) = @_;
    
	#get parameters from form and config file
	my @query_gene = $c->req->param("input_gene");
  
	my $corr_filter = $c->req->param("correlation_filter");
  my $index_dir_name = $c->req->param("index_dir_name");
  
  my $stage_filter = $c->req->param("stages");
  $stage_filter =~ s/[\[\]\"]//g;
  my $tissue_filter = $c->req->param("tissues");
  $tissue_filter =~ s/[\[\]\"]//g;
  
  my @stages = split(",",$stage_filter);
  my @tissues = split(",",$tissue_filter);

	my $expr_path = $c->config->{expression_indexes_path};
	my $corr_path = $c->config->{correlation_indexes_path};
	my $loci_and_desc_path = $c->config->{loci_and_description_index_path};
	
  # indexed dir name saved in $corr_index_path and $expr_index_path
  my $corr_index_path = $corr_path."/".$index_dir_name;
  my $expr_index_path = $expr_path."/".$index_dir_name;
  





  my $query_gene;
	my @genes;
	my $multiple_genes = 1;
  print STDERR "query_gene: @query_gene\n";
  print STDERR "array_length = ".scalar(@query_gene)."\n";
	
	my @corr_values;
  # my $total_corr_genes = 0;
  
  
	#check number of input genes
  if (scalar(@query_gene) == 1) {
    $query_gene = shift @query_gene;
    $query_gene =~ s/[\[\]\"]//g;
    $query_gene =~ s/[\\n\\r]/,/g;
    print STDERR "query_gene: $query_gene\n";
    
		$multiple_genes = 0;
		
		if ($query_gene =~ /\n/ || $query_gene =~ /,/) {
			
      print STDERR "query_gene: $query_gene\n";
			
			$query_gene =~ s/[\n\s,]+/,/g;
      print STDERR "query_gene: $query_gene\n";
			
			$query_gene =~ s/\.[12]\.*[12]*//g;
      print STDERR "query_gene: $query_gene\n";
			
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
	
	print STDERR "downloading expression data\n";
	print STDERR "multiple_genes: $multiple_genes, query_gene: $query_gene\n";
	print STDERR "genes: @genes\n";
	
	my %corr_values;
  
  
  my $total_corr_genes = 0;
  my $genes;
  my $corr_values;
	my $current_page;
	my $corr_hash;
	my %corr_hash;
  
	if (!$multiple_genes) {
    my $to_download = 1;
    ($genes,$corr_values,$total_corr_genes,$corr_hash) = _get_correlation($c,$corr_filter,$current_page,$corr_index_path,$query_gene,$to_download);
    
    %corr_hash = %$corr_hash;
    @genes = @$genes;
    @corr_values = @$corr_values;
	}
  
  #   if (!$multiple_genes) {
  #
  #     # get correlation filter value (it is 100 higher when it comes from the input slider)
  #     if ($corr_filter > 1) {
  #       $corr_filter = $corr_filter/100;
  #     }
  #
  #     #------------------------------------- Get Correlation Data
  #     # my @genes;
  #     $corr_values{$query_gene} = 1;
  #
  #     my $lucy_corr = Lucy::Simple->new(
  #         path     => $corr_index_path,
  #         language => 'en',
  #     );
  #
  #     my $sort_spec = Lucy::Search::SortSpec->new(
  #          rules => [
  #          Lucy::Search::SortRule->new( field => 'correlation', reverse => 1,),
  #          Lucy::Search::SortRule->new( field => 'gene2', reverse => 0,),
  #          Lucy::Search::SortRule->new( field => 'gene1',),
  #          ],
  #     );
  #
  #     my $hits = $lucy_corr->search(
  #       query      => $query_gene,
  #       sort_spec  => $sort_spec,
  #       num_wanted => 10000,
  #     );
  #
  #     #------------------------------------- Get data after correlation filter
  #     if ($corr_filter > 0.65) {
  #       my $range_query = Lucy::Search::RangeQuery->new(
  #           field         => 'correlation',
  #           lower_term    => $corr_filter,
  #       );
  #       my $searcher = Lucy::Search::IndexSearcher->new(
  #           index => $corr_index_path,
  #       );
  #       my $qparser  = Lucy::Search::QueryParser->new(
  #           schema => $searcher->get_schema,
  #       );
  #       my $term_query = $qparser->parse($query_gene);
  #
  #         my $and_query = Lucy::Search::ANDQuery->new(
  #             children => [ $range_query, $term_query],
  #         );
  #     }
  #
  #     #------------------------------------- save data for filtered genes
  #     while ( my $hit = $lucy_corr->next ) {
  #       if ($query_gene eq $hit->{gene1} && $hit->{correlation} >= $corr_filter) {
  #         push(@genes, $hit->{gene2});
  #         $corr_values{$hit->{gene2}} = $hit->{correlation};
  #       } elsif ($query_gene eq $hit->{gene2} && $hit->{correlation} >= $corr_filter) {
  #         push(@genes, $hit->{gene1});
  #         $corr_values{$hit->{gene1}} = $hit->{correlation};
  #       }
  #     }
  # } # end of !multiple genes
  
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
	    path     => $expr_index_path,
	    language => 'en',
	);
	
  my $lucy_desc = Lucy::Simple->new(
      path     => $loci_and_desc_path,
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
		push(@lines, "$g\t".join("\t", @expr_columns)."\t$corr_hash{$g}\t$descriptions{$g}");
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
