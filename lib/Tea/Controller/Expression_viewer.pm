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

Get variables from configuration file, connect to database
and send to Expression_viewer/input.mas the project list formatted in HTML

=cut

sub index :Path('/Expression_viewer/input/') :Args(0) {
  my ( $self, $c ) = @_;
  
  my $default_gene = $c->config->{default_gene};
	my $input_gene = $c->req->param("input_gene") || $default_gene;
  my $dbname = $c->config->{dbname};
  my $host = $c->config->{dbhost};
  my $username = $c->config->{dbuser};
  my $password = $c->config->{dbpass};

  my $schema = Tea::Schema->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  my $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  
  # get all projects for input select
  my $projects_rs = $schema->resultset('Project');
  my @projects = ();
  my $project_name;
  
  while(my $proj_obj = $projects_rs->next) {
    $project_name = $proj_obj->name;
    push(@projects,"<div id=\"project_radio_div\" class=\"radio\">\n<label><input id=\"project_".$proj_obj->project_id."\" type='radio' class='organism_col' name=\"optradio\" value=\'".$proj_obj->project_id."\'> $project_name</label>\n</div>\n");
    # push(@projects,"<div id=\"project_radio_div\" class=\"radio\">\n<label><input id=\"organism_".$proj_obj->organism_id."\" type='radio' class='organism_col' name=\"optradio\" value=\'".$proj_obj->organism_id."\'> $project_name</label>\n</div>\n");
  }
  
  # save array info in text variable
  my $projects_html = join("\n", @projects);
  
  # send variables to TEA input view
  $c->stash->{input_gene} = $input_gene;
  $c->stash->{project_html} = $projects_html;
  $c->stash(template => 'Expression_viewer/input.mas');
}

=head2 _get_correlation

Get correlation values for the query gene and the correlated genes in the cube for that page

ARGV: correlation filter, current page, path to correlation index, query gene, 
number of genes for cube and boolean to specify if data are for downloading

Return: list of genes, correlation values, number of correlated genes, 
and hash of genes and correlation values

=cut

sub _get_correlation {
  my $c = shift;
  my $corr_filter = shift;
  my $current_page = shift;
  my $corr_index_path = shift;
  my $query_gene = shift;
  my $to_download = shift;
  my $genes_in_cube = shift;
  
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
      num_wanted => $genes_in_cube-1,
      offset     => $current_page*($genes_in_cube-1),
    );
  }

	$total_corr_genes = $hits;

  # if (!$total_corr_genes) {
  #   push ( @errors , "No correlated genes found\n");
  #     print STDERR "total_corr_genes: $total_corr_genes\n";
  # }

	# Send error message to the web if something is wrong
  # if (scalar (@errors) > 0){
  #
  #   my $user_errors = join("<br />", @errors);
  #   print STDERR "$user_errors\n";
  #   $c->stash->{errors} = $user_errors;
  #   $c->stash->{template} = '/Expression_viewer/output.mas';
  #   return;
  # }

  # print STDERR "corr_filter: $corr_filter\n";

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

    my $hit_intersect = $searcher->hits( query => $and_query );

    # print STDERR "\n\ntotal number of correlated genes: $hits\n\n";
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
  
sub _check_gene_exists {
  my $c = shift;
  my $lucy_path = shift;
  my $query_gene = shift;
  
  # test gene exist
	my $lucy = Lucy::Simple->new(
	    path     => $lucy_path,
	    language => 'en',
	);
	
  my $gene_found_num = $lucy->search(
    query      => $query_gene,
  	num_wanted => 10
  );
  
  # print "gene_found_num: $gene_found_num\n";
  
	# Send error message to the web if something is wrong
	if (!$gene_found_num){
		$c->stash->{errors} = "Gene not found";
		$c->stash->{template} = '/Expression_viewer/output.mas';
		return;
	}
  
  
}


=head2 get_expression

Get expression values and send all data needed to output view

ARGV: query gene, correlation filter, selection of project, organ, stage and tissue,
current page for cube, total number of pages, path to description, expression and correlation index

Return: list of genes, stages and tissues, hash with expression values (HoHoH), stages ids, stage_info HoH,
tissue_info HoHoA, AoAoA, correlation values, number of pages, current page, gene list for output,
correlation filter, selection of project, stage and tissues, descriptions, project_id, project name, 
and hash of locus id (to link to SGN)

=cut


sub get_expression :Path('/expression_viewer/output/') :Args(0) {
  my ($self, $c) = @_;
  
  my $cube_gene_number = 15;
  
  # get variables from catalyst object
  my $params = $c->req->body_params();
	my @query_gene = $c->req->param("input_gene");
	my $corr_filter = $c->req->param("correlation_filter")||0.65;
  my $project_id = $c->req->param("organism_filter");
  my $organ_filter = $c->req->param("organ_filter");
  my $stage_filter = $c->req->param("stage_filter");
  my $tissue_filter = $c->req->param("tissue_filter");
  my $condition_filter = $c->req->param("condition_filter");
  
	my $current_page = $c->req->param("current_page") || 1;
	my $pages_num = $c->req->param("all_pages") || 1;
  
  # get the path to the expression and correlation lucy indexes
	my $expr_path = $c->config->{expression_indexes_path};
	my $corr_path = $c->config->{correlation_indexes_path};
	my $loci_and_desc_path = $c->config->{loci_and_description_index_path};

  # connect to the db
  my $dbname = $c->config->{dbname};
  my $host = $c->config->{dbhost};
  my $username = $c->config->{dbuser};
  my $password = $c->config->{dbpass};

  my $schema = Tea::Schema->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  my $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  
  # get DBIx project resultset
  my $project_rs = $schema->resultset('Project')->search({project_id => $project_id})->single;
  
  # set the path to the expression and correlation indexes
  my $corr_index_path = $corr_path."/".$project_rs->indexed_dir;
  my $expr_index_path = $expr_path."/".$project_rs->indexed_dir;
  $loci_and_desc_path .= "/".$project_rs->indexed_dir;
  
  
  _check_gene_exists($c,$expr_index_path,$query_gene[0]);
  
  
  # getting the organs, stages tissues and treatments selected at input page
  my @stages = split(",",$stage_filter);
  my @tissues = split(",",$tissue_filter);
  my @organs = split(",",$organ_filter);
  my @conditions = split(",",$condition_filter);
  
  # variables to store values needed for the Expression images
  my $stage_ids_arrayref;
  my $stage_hashref;
  my $tissue_hashref;
  
  # open a connection to the functions on Expression_viewer_function controller
  my $db_funct = Tea::Controller::Expression_viewer_functions->new();
  
  # get the figure ids for the selected project
  my $figure_ids = $db_funct->get_ids_from_query($schema,"Figure",[$project_id],"project_id","figure_id");
  
  # get the figure resultset for the selected project
  my $figure_rs = $schema->resultset('Figure')->search({project_id => $project_rs->project_id});
  my $figure_rs2 = $schema->resultset('Figure')->search({project_id => $project_rs->project_id});
  
  # save all the layer ids from the figures of the project in arrayref and hash
  my $this_project_all_layer_ids = $db_funct->get_ids_from_query($schema,"FigureLayer",$figure_ids,"figure_id","layer_id");
  my %all_layer_ids_in_project=map{$_=>1} @$this_project_all_layer_ids;
  
  
  # no filters selected
  if (!$organ_filter && !$stage_filter && !$tissue_filter && !$condition_filter) {
      
      while (my $fig = $figure_rs->next) {
        
        my $cube_stage_name = $fig->cube_stage_name;
        push(@stages, $cube_stage_name);
      }
      
      ($stage_ids_arrayref,$stage_hashref,$tissue_hashref) = $db_funct->get_image_hash($schema,$this_project_all_layer_ids);
      
      
      my ($organ_arrayref,$stage_arrayref,$tissue_arrayref,$condition_arrayref) = $db_funct->get_input_options($schema,$figure_rs2);
      
      @tissues = @$tissue_arrayref;
      @stages = uniq(@stages);
  }
  # organs, stages and/or tissues selected
  else {
    
    # selected organ ids for the selected project
    my @organs_in_project_ids;
    my %organs_in_project;
    
    # names of all stages for selected project and organs
    my @all_stages_in_selected_organs;
    # layer_ids of all stages for selected project and organs
    my @selected_stage_ids;
    # for selected organs and project, key = stage_id, value = stage_name
    my %stage_in_organ;
    # selected stage_ids = 1
    my %selected_stages;
    
    # names of all tissues for selected stages
    my @all_tissues_in_selected_stages;
    # layer_ids of all tissues for selected stages
    my @selected_tissue_ids;
    # for selected stages and project, key = tissue_id, value = tissue_name
    my %tissues_in_stages;
    
    # Get Organ info
    my $organ_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "organ"})->single;
      
    # get selected organ layer ids or all organ layer ids
    if (!$organ_filter) {
      my $all_organs_layer_rs = $schema->resultset('Layer')->search({layer_type_id => $organ_layer_type_rs->layer_type_id});
      while (my $o = $all_organs_layer_rs->next) {
        if ($all_layer_ids_in_project{$o->layer_id}) {
          $organs_in_project{$o->layer_id} = 1;
        }
      }
    } else {
      my $organ_info_ids = $db_funct->get_ids_from_query($schema,"LayerInfo",\@organs,"name","layer_info_id");
      my $organ_ids = $db_funct->get_ids_from_query($schema,"Layer",$organ_info_ids,"layer_info_id","layer_id");
      @organs_in_project_ids = intersect(@$this_project_all_layer_ids,@$organ_ids);
      %organs_in_project=map{$_=>1} @organs_in_project_ids;
    }
    
    
    
    # Get Stage info
    
    # get stage layer type
    my $stage_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "stage"})->single;
    
    # get all stage layer obj
    my $all_stages_layer_rs = $schema->resultset('Layer')->search({layer_type_id => $stage_layer_type_rs->layer_type_id});
    
    # iterate by all stages
    while (my $s = $all_stages_layer_rs->next) {
      
      # get stages for selected organs and project
      if ($organs_in_project{$s->parent_id} && $all_layer_ids_in_project{$s->layer_id}) {
        
        # get layer info obj
        my $layer_info_rs = $schema->resultset('LayerInfo')->search({layer_info_id => $s->layer_info_id})->single;
        
        # save layer id and name in hash and arrays
        $stage_in_organ{$s->layer_id} = $layer_info_rs->name;
        push(@all_stages_in_selected_organs,$layer_info_rs->name);
        push(@selected_stage_ids,$s->layer_id);
      }
    }
    # @all_stages_in_selected_organs = uniq(@all_stages_in_selected_organs);
    
    # get selected stage layer ids or all stage layer ids
    if ($stage_filter) {
      my $stage_info_ids = $db_funct->get_ids_from_query($schema,"LayerInfo",\@stages,"name","layer_info_id");
      my $stage_ids = $db_funct->get_ids_from_query($schema,"Layer",$stage_info_ids,"layer_info_id","layer_id");
      
      @stages = ();
      @selected_stage_ids = ();
      foreach my $st_id (@$stage_ids) {
        if ($stage_in_organ{$st_id}) {
          push(@stages,$stage_in_organ{$st_id});
          push(@selected_stage_ids,$st_id);
          $selected_stages{$st_id} = 1;
        }
      }
      # remove repeated names to avoid errors in cube
      @stages = uniq(@stages);
    } else {
      # remove repeated names to avoid errors in cube
      @stages = uniq(@all_stages_in_selected_organs);
      %selected_stages = %stage_in_organ;
    }
    
    
    
    # Get Tissue info
    
    # get tissue layer type
    my $tissue_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "tissue"})->single;
    
    # get all tissue layer obj
    my $all_tissues_layer_rs = $schema->resultset('Layer')->search({layer_type_id => $tissue_layer_type_rs->layer_type_id},{order_by => 'cube_ordinal'});
    
    # iterate by all tissues
    while (my $t = $all_tissues_layer_rs->next) {
      
      # get tissues for selected stages and project
      if ($selected_stages{$t->parent_id} && $all_layer_ids_in_project{$t->layer_id}) {
        
        # get layer info obj
        my $layer_info_rs = $schema->resultset('LayerInfo')->search({layer_info_id => $t->layer_info_id})->single;
        
        # save layer id and name in hash and arrays
        $tissues_in_stages{$t->layer_id} = $layer_info_rs->name;
        push(@all_tissues_in_selected_stages,$layer_info_rs->name);
        push(@selected_tissue_ids,$t->layer_id);
      }
    }
    # remove repeated names to avoid errors in cube
    @all_tissues_in_selected_stages = uniq(@all_tissues_in_selected_stages);
    
    # get selected tissue layer ids or all tissue layer ids
    if ($tissue_filter) {
      my $tissue_info_ids = $db_funct->get_ids_from_query($schema,"LayerInfo",\@tissues,"name","layer_info_id");
      my $tissue_ids = $db_funct->get_ids_from_query($schema,"Layer",$tissue_info_ids,"layer_info_id","layer_id");
      
      my %tissue_filter_ids=map{$_=>1} @$tissue_ids;
      
      @tissues = ();
      my @selected_tissue_ids_sorted;
      foreach my $tis_id (@selected_tissue_ids) {
        if ($tissue_filter_ids{$tis_id}) {
          push(@tissues,$tissues_in_stages{$tis_id});
          push(@selected_tissue_ids_sorted,$tis_id);
        }
      }
      @selected_tissue_ids = @selected_tissue_ids_sorted;
      # remove repeated tissue names to avoid errors in cube
      @tissues = uniq(@tissues);
    } else {
      @tissues = @all_tissues_in_selected_stages;
    }
    
    #------------------------------------------------------------------ image hash
    
    my @selected_stage_and_tissue_ids = (@selected_stage_ids,@selected_tissue_ids);
    
    ($stage_ids_arrayref,$stage_hashref,$tissue_hashref) = $db_funct->get_image_hash($schema,\@selected_stage_and_tissue_ids);
  } # end of organs, stages and/or tissues selected
  
  
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
      if ($query_gene =~ /solyc\d\dg\d{6}/i) {
  			$query_gene =~ s/\.[12]\.*[12]*$//g;
			}
      
			@genes = split(",", $query_gene);
			@corr_values = ("list") x scalar(@genes);
			
			my @uniq_genes = uniq(@genes);
			if (scalar(@uniq_genes) >= $cube_gene_number) {
				@genes = @uniq_genes[0..$cube_gene_number-1];
			} else {
				@genes = @uniq_genes[0..$#uniq_genes];
			}
			$query_gene = shift @genes;
			
			$multiple_genes = 1;
		}
		
	} elsif (scalar(@query_gene) > 1) {
		@corr_values = ("blast") x scalar(@query_gene);
		my @uniq_genes = uniq(@query_gene);
		
		if (scalar(@uniq_genes) >= $cube_gene_number) {
			@genes = @uniq_genes[0..$cube_gene_number-1];
		} else {
			@genes = @uniq_genes[0..$#uniq_genes];
		}
		$query_gene = shift @genes;
	}
	
	# strip gene name
	$query_gene =~ s/^\s+//;
	$query_gene =~ s/\s+$//;
	
  if ($query_gene =~ /solyc/i) {
  	$query_gene =~ s/\.\d$//;
  	$query_gene =~ s/\.\d$//;
  	$query_gene = lc($query_gene);
  	$query_gene =~ s/^s/S/;
  }
  
	#------------------------------------------------------------------------------------------------------------------
  my $total_corr_genes = 0;
  my $genes;
  my $corr_values;
  my $corr_hash;
  
	$current_page = $current_page - 1;
  
	if (!$multiple_genes) {
    my $to_download = 0;
    
    ($genes,$corr_values,$total_corr_genes,$corr_hash) = _get_correlation($c,$corr_filter,$current_page,$corr_index_path,$query_gene,$to_download,$cube_gene_number);
    
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
	my %gene_stage_tissue_sem;
	my %stage;
	my %tissue;
	my %descriptions;
	my %locus_ids;
	
	foreach my $g (@genes) {
		foreach my $s (@stages) {
			foreach my $t (@tissues) {
				$gene_stage_tissue_expr{$g}{$s}{$t} = 0.000001;
				$gene_stage_tissue_sem{$g}{$s}{$t} = 0.000001;
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
      # print STDERR "".$hit->{gene}."\t".$hit->{stage}."\t".$hit->{tissue}."\t".$hit->{expression}."\n";
      
			$gene_stage_tissue_expr{$hit->{gene}}{$hit->{stage}}{$hit->{tissue}} = $hit->{expression} * 1;
      
      if ($hit->{expression} >0) {
        my $sem_val = 0;
        if ($hit->{sem} && $hit->{expression}) {
          $sem_val = $hit->{sem} / $hit->{expression};
        }
  			$gene_stage_tissue_sem{$hit->{gene}}{$hit->{stage}}{$hit->{tissue}} = $sem_val;
      }
      else {
        $gene_stage_tissue_sem{$hit->{gene}}{$hit->{stage}}{$hit->{tissue}} = 0
      }
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
        
        # print STDERR "$genes[$g]\t$stages[$s]\t$tissues[$t]\t".$gene_stage_tissue_expr{$genes[$g]}{$stages[$s]}{$tissues[$t]}."\n";
				
			}
		}
	}
	
  
  
	$corr_filter = $c->req->param("correlation_filter")||0.65;
	my @output_gene = $c->req->param("input_gene");
  
  # print STDERR "total_corr_genes: $total_corr_genes\n";
  print Dumper $stage_ids_arrayref;
  
	$c->stash->{genes} = \@genes;
	$c->stash->{stages} = \@stages;
	$c->stash->{tissues} = \@tissues;
	$c->stash->{conditions} = \@conditions;
  
	$c->stash->{gst_expr_hohoh} = \%gene_stage_tissue_expr;
	$c->stash->{gst_sem_hohoh} = \%gene_stage_tissue_sem;
	$c->stash->{stage_ids_array} = $stage_ids_arrayref;
	$c->stash->{stage_hash} = $stage_hashref;
	$c->stash->{tissue_hash} = $tissue_hashref;
  
	$c->stash->{aoaoa} = \@AoAoA;
	$c->stash->{correlation} = \@corr_values;
	$c->stash->{pages_num} = (int($total_corr_genes/$cube_gene_number)+1);
	$c->stash->{current_page} = ($current_page + 1);
	$c->stash->{output_gene} = \@output_gene;
	$c->stash->{correlation_filter} = $corr_filter;
	$c->stash->{organism_filter} = $project_id;
	$c->stash->{stage_filter} = $stage_filter;
	$c->stash->{tissue_filter} = $tissue_filter;
  $c->stash->{description} = \%descriptions;
	$c->stash->{project_id} = $project_rs->project_id;
	$c->stash->{project_name} = $project_rs->name;
	$c->stash->{project_expr_unit} = $project_rs->expr_unit;
  $c->stash->{locus_ids} = \%locus_ids;
  
	$c->stash->{template} = '/Expression_viewer/output.mas';
}


=head2 download_expression_data

Get expression and correlation values for the selected samples and save results in a file

ARGV: query gene, correlation filter, selection of stage and tissue, path to expression and correlation index

Return: print file with expression and correlation data for each gene, stage and tissue

=cut

sub download_expression_data :Path('/download_expression_data/') :Args(0) {
  my ($self, $c) = @_;
  
  my $cube_gene_number = 15;
  
  
	#get parameters from form and config file
	my @query_gene = $c->req->param("input_gene");
  my $project_id = $c->req->param("organism_filter");
  
	my $corr_filter = $c->req->param("correlation_filter");
  my $index_dir_name = $c->req->param("index_dir_name");
  
  my $stage_filter = $c->req->param("stages");
  $stage_filter =~ s/[\[\]\"]//g;
  my $tissue_filter = $c->req->param("tissues");
  $tissue_filter =~ s/[\[\]\"]//g;
  
  my @stages = split(",",$stage_filter);
  my @tissues = split(",",$tissue_filter);


  # get the path to the expression and correlation lucy indexes
	my $expr_path = $c->config->{expression_indexes_path};
	my $corr_path = $c->config->{correlation_indexes_path};
	my $loci_and_desc_path = $c->config->{loci_and_description_index_path};
	
  # connect to the db
  my $dbname = $c->config->{dbname};
  my $host = $c->config->{dbhost};
  my $username = $c->config->{dbuser};
  my $password = $c->config->{dbpass};

  my $schema = Tea::Schema->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  my $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  
  # get DBIx project resultset
  my $project_rs = $schema->resultset('Project')->search({project_id => $project_id})->single;
  
  # set the path to the expression and correlation indexes
  my $corr_index_path = $corr_path."/".$project_rs->indexed_dir;
  my $expr_index_path = $expr_path."/".$project_rs->indexed_dir;
  $loci_and_desc_path .= "/".$project_rs->indexed_dir;
  

  my $query_gene;
	my @genes;
	my $multiple_genes = 1;
  # print STDERR "query_gene: @query_gene\n";
  # print STDERR "array_length = ".scalar(@query_gene)."\n";
	
	my @corr_values;
  # my $total_corr_genes = 0;
  
  
	#check number of input genes
  if (scalar(@query_gene) == 1) {
    $query_gene = shift @query_gene;
    $query_gene =~ s/[\[\]\"]//g;
    $query_gene =~ s/\\n/,/g;
    $query_gene =~ s/\\r/,/g;
    # print STDERR "query_gene: $query_gene\n";
    
		$multiple_genes = 0;
		
		if ($query_gene =~ /\n/ || $query_gene =~ /,/) {
			
      # print STDERR "query_gene: $query_gene\n";
			
			$query_gene =~ s/[\n\s,]+/,/g;
      # print STDERR "query_gene: $query_gene\n";
			
      if ($query_gene =~ /solyc\d\dg\d{6}/i) {
  			$query_gene =~ s/\.[12]\.*[12]*//g;
        # print STDERR "query_gene: $query_gene\n";
      }
			
			@genes = split(",", $query_gene);
			@corr_values = ("list") x scalar(@genes);
			
			my @uniq_genes = uniq(@genes);
			if (scalar(@uniq_genes) >= $cube_gene_number) {
				@genes = @uniq_genes[0..$cube_gene_number-1];
			} else {
				@genes = @uniq_genes[0..$#uniq_genes];
			}
			$query_gene = shift @genes;
			
			$multiple_genes = 1;
		}
		
  } elsif (scalar(@query_gene) > 1) {
    @corr_values = ("blast") x scalar(@query_gene);
    my @uniq_genes = uniq(@query_gene);

    if (scalar(@uniq_genes) >= $cube_gene_number) {
      @genes = @uniq_genes[0..$cube_gene_number-1];
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
    ($genes,$corr_values,$total_corr_genes,$corr_hash) = _get_correlation($c,$corr_filter,$current_page,$corr_index_path,$query_gene,$to_download,$cube_gene_number);
    
    %corr_hash = %$corr_hash;
    @genes = @$genes;
    @corr_values = @$corr_values;
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



=head2 uniq

Remove repeated entries from an array and return uniq array
ARGV: array

Return: array with uniq entries

=cut

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
