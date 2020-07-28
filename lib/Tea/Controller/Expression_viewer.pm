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

sub index :Path('/expression_viewer/input/') :Args(0) {
  my ( $self, $c ) = @_;

  my $default_gene = $c->config->{default_gene};

  # print STDERR "default_gene: $default_gene\n";

  my $input_gene = $c->req->param("input_gene") || $default_gene;

  # print STDERR "input_gene: $input_gene\n";

  my $dbname = $c->config->{dbname};
  my $host = $c->config->{dbhost};
  my $username = $c->config->{dbuser};
  my $password = $c->config->{dbpass};

  my $delete_enabled = $c->config->{delete_project};

  my $schema = Tea::Schema->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  my $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");

  my $projects_rs = $schema->resultset('Project');

  my @projects = ();
  my %project_name_hash;
  my %project_order_hash;
  my $project_ordinal;

  while(my $proj_obj = $projects_rs->next) {
    my $project_name = $proj_obj->name;
    my $project_id = $proj_obj->project_id;

    if ($proj_obj->ordinal) {
      $project_ordinal = $proj_obj->ordinal;
    }
    else {
      $project_ordinal = $project_id;
    }

    $project_name_hash{$project_id} = $project_name;
    $project_order_hash{$project_ordinal} = $project_id;
  }

  foreach my $key (sort {$a <=> $b} keys %project_order_hash) {
    my $project_id = $project_order_hash{$key};
    my $project_name = $project_name_hash{$project_id};
    push(@projects,"<div id=\"project_radio_div\" class=\"radio\">\n<label><input id=\"project_".$project_id."\" type='radio' class='organism_col' name=\"optradio\" value=\'".$project_id."\'> $project_name</label>\n</div>\n");
  }

  # while(my $proj_obj = $projects_rs->next) {
  #   $project_name = $proj_obj->name;
  #   push(@projects,"<div id=\"project_radio_div\" class=\"radio\">\n<label><input id=\"project_".$proj_obj->project_id."\" type='radio' class='organism_col' name=\"optradio\" value=\'".$proj_obj->project_id."\'> $project_name</label>\n</div>\n");
  #   # push(@projects,"<div id=\"project_radio_div\" class=\"radio\">\n<label><input id=\"organism_".$proj_obj->organism_id."\" type='radio' class='organism_col' name=\"optradio\" value=\'".$proj_obj->organism_id."\'> $project_name</label>\n</div>\n");
  # }

  # print STDERR "input_gene: $input_gene\n";

  # save array info in text variable
  my $projects_html = join("\n", @projects);

  # send variables to TEA input view
  $c->stash->{input_gene} = $input_gene;
  $c->stash->{delete_enabled} = $delete_enabled;
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
    else {
      # print STDERR "gene: $query_gene, hit1: ".$hit->{gene1}.", hit2: ".$hit->{gene2}.", correlation: ".$hit->{correlation}."\n";
    }
		push(@corr_values, $hit->{correlation})
	}


  return (\@genes,\@corr_values,$total_corr_genes,\%corr_hash);
}

sub _check_gene_exists {
  my $c = shift;
  my $lucy_path = shift;
  my $query_gene = shift;
  my $dataset_name = shift;

  # test gene exist
	my $lucy = Lucy::Simple->new(
	    path     => $lucy_path,
	    language => 'en',
	);

  my $gene_found_num = $lucy->search(
    query      => $query_gene,
  	num_wanted => 10
  );

#### CODE for PEATmoss gene lookup ###
  my $application_name = $c->config->{name};
  my $input_type = $c->req->param("input_type") || "gene_id";

# For all other applications
  if ($application_name ne "PEATmoss") {

  	# Send error message to the web if something is wrong
  	if (!$gene_found_num){
  		$c->stash->{errors} = "Gene not found";
  		$c->stash->{template} = '/Expression_viewer/output.mas';
  		return;
  	}

  }
  else {

    if ($gene_found_num){
      ### Gene found in PEATmoss
      # print STDERR "GENE found in PEATmoss, right gene version\n";

      return $query_gene;
    }
    else {
      ### Gene not found in PEATmoss go to lookup DB
      if ($input_type eq "custom_list") {
        $c->stash->{errors} = $c->stash->{errors}."\n <a href=\"https://peatmoss.online.uni-marburg.de/ppatens_db/pp_search_output.php?search_keywords=$query_gene\" target=\"_blank\">$query_gene</a><br>";
        $c->stash->{template} = '/Expression_viewer/output.mas';
        return;
      }


      my $gene_version;

      if ($dataset_name =~ /RNA-seq/ || $dataset_name =~ /v3\.3/) {
        $gene_version = "3.3";
      }
      if ($dataset_name =~ /CombiMatrix/ || $dataset_name =~ /v1\.2/) {
        $gene_version = "1.2_Phypa";
      }
      if ($dataset_name =~ /NimbleGen/ || $dataset_name =~ /v1\.6/) {
        $gene_version = "1.6";
      }

      # Connect to PpGML DB
      my $pp_db = $c->config->{lookup_db};
      my $pp_host = $c->config->{lookup_host};
      my $pp_user = $c->config->{lookup_user};
      my $pp_psw = $c->config->{lookup_psw};

      my $dbh = DBI->connect("dbi:Pg:dbname=$pp_db;host=$pp_host;", "$pp_user", "$pp_psw");
      $dbh->begin_work;

      # find gene_id
      my $sth = $dbh->prepare("SELECT gene_id FROM gene WHERE gene_name = \'$query_gene\'");
      $sth->execute() or die $sth->errstr;

      my @gene_id = $sth->fetchrow_array();
      my $query_gene_id = $gene_id[0];

      $sth->finish();

      # Gene not found
      if (!$query_gene_id) {

        # print STDERR "Wrong gene\n";

        $c->stash->{errors} = "The gene $query_gene was not found in ".$dataset_name.".<br>Please, check if there is a typo or try to find it in the <a href=\"https://peatmoss.online.uni-marburg.de/ppatens_db/pp_search_output.php?search_keywords=$query_gene\">PpGML DB</a>";
        $c->stash->{template} = '/Expression_viewer/output.mas';

        $dbh->disconnect();
        return $query_gene;
      }
      else {

        # print STDERR "GENE FOUND ALTER $query_gene_id\n";

        #find genes from v3.3 in other versions
        my $sth = $dbh->prepare("SELECT gene_name,genome_version FROM gene JOIN gene_gene ON(gene_id=gene_id2) WHERE gene_id1=$query_gene_id;");
        $sth->execute() or die "SQL query failed!";

        my @lookup_array;
        my $other_version_found = 0;
        my $alternative_gene = 0;
        my @all_genes_found;

        while ( @lookup_array = $sth->fetchrow_array() ) {

          my $lookup_gene = $lookup_array[0];
          my $lookup_gene_v = $lookup_array[1];

          if ($gene_version eq $lookup_gene_v) {
            $other_version_found++;
            $alternative_gene = $lookup_gene;
            push(@all_genes_found,"<a class=\"multiple_lookup_gene\" href=\"#\" value=\"$lookup_gene\">$lookup_gene</a>");
            # push(@all_genes_found,"<a class=\"multiple_lookup_gene\" href=\"/expression_viewer/input?input_gene=$lookup_gene\">$lookup_gene</a>");
          }
        }

        # store ID for current gene version
        my $gene_current_v;

        if (!$other_version_found) {
          #find genes from other versions in v3.3
          my $sth = $dbh->prepare("SELECT gene_id,gene_name,genome_version FROM gene JOIN gene_gene ON(gene_id=gene_id1) WHERE gene_id2=$query_gene_id;");
          $sth->execute() or die "SQL query 2 failed!";

          while ( @lookup_array = $sth->fetchrow_array() ) {

            my $lookup_gene_id = $lookup_array[0];
            my $lookup_gene = $lookup_array[1];
            my $lookup_gene_v = $lookup_array[2];

            # print STDERR "lookup_gene_id: $lookup_gene_id\n";
            $gene_current_v = $lookup_gene_id;

            if ($gene_version eq $lookup_gene_v) {
              $other_version_found++;
              $alternative_gene = $lookup_gene;
              push(@all_genes_found,"<a class=\"multiple_lookup_gene\" href=\"#\" value=\"$lookup_gene\">$lookup_gene</a>");
              # push(@all_genes_found,"<a class=\"multiple_lookup_gene\" href=\"/expression_viewer/input?input_gene=$lookup_gene\">$lookup_gene</a>");
            }
          }

        }

        if (!$other_version_found && $gene_current_v && $gene_version ne "3.3") {
          #find genes from other versions in other versions using current version as reference

          # print STDERR "curent gene ID: $gene_current_v\n";

          my $sth = $dbh->prepare("SELECT gene_name,genome_version FROM gene JOIN gene_gene ON(gene_id=gene_id2) WHERE gene_id1=$gene_current_v;");
          $sth->execute() or die "SQL query 3 failed!";

          while ( @lookup_array = $sth->fetchrow_array() ) {

            my $lookup_gene = $lookup_array[0];
            my $lookup_gene_v = $lookup_array[1];

            if ($gene_version eq $lookup_gene_v) {
              $other_version_found++;
              $alternative_gene = $lookup_gene;
              push(@all_genes_found,"<a class=\"multiple_lookup_gene\" href=\"#\" value=\"$lookup_gene\">$lookup_gene</a>");
              # push(@all_genes_found,"<a class=\"multiple_lookup_gene\" href=\"/expression_viewer/input?input_gene=$lookup_gene\">$lookup_gene</a>");
            }
          }

        }

        # print STDERR "GENE FOUND ALTER? $other_version_found\n";

        $sth->finish();
        $dbh->disconnect();

        if ($other_version_found == 1) {
          # print STDERR "other version found $query_gene\n";

          #one gene from another version found
          return $alternative_gene;
        }
        elsif ($other_version_found > 1) {
          # print STDERR "several found $query_gene\n";

          #Multiple genes from another version found
          my $multiple_genes_html = join("<br>", @all_genes_found);

          $c->stash->{errors} = "Multiple genes were found for v$gene_version:<br>$multiple_genes_html";
          $c->stash->{template} = '/Expression_viewer/output.mas';

          return $alternative_gene;
        }
        else {
          # print STDERR "no gene? $query_gene\n";

          $c->stash->{errors} = "Gene not found";
          $c->stash->{template} = '/Expression_viewer/output.mas';
          return $query_gene;
        }

      }


    } # looking for gene in PEATmoss
  } # end of App conditional
} # end of _check_gene_exists


sub _get_filtered_layers {

  my $layers_rs = shift;
  my $condition_layer_ids = shift;
  my $schema = shift;
  my $organ_filter = shift;
  my $layer_filter = shift;
  my $organ_names = shift;
  my $layer_names = shift;
  my $cube_layer_name_hash = shift;
  my $layer_type = shift;

  my @selected_layer_ids;
  my @layer_cube_names;

  # iterate by all stages
  while (my $s = $layers_rs->next) {

    # get stages for selected condition and project
    if ($$condition_layer_ids{$s->layer_id}) {

      # get layer info obj
      my $layer_info_rs = $schema->resultset('LayerInfo')->search({layer_info_id => $s->layer_info_id})->single;

      my $layer_info_name = $layer_info_rs->name;

      $layer_info_name =~ s/ /_/g;

      # get layer figure id
      my $st_figure = $schema->resultset('FigureLayer')->search({layer_id => $s->layer_id});

      while (my $fig = $st_figure->next) {
        my $st_figure_id = $fig->figure_id;

        # to select stages only for selected organs
        if ($organ_filter) { # ---------------------- organ

          if ($$organ_names{$layer_info_rs->organ}) {

            # to select stages only for selected organs and stages/tissues
            if ($layer_filter) { # ---------------------- organ and stage/tissue

              if ($$layer_names{$layer_info_name}) {
                # save layer id and name in arrays
                push(@selected_layer_ids,$s->layer_id);
                push(@layer_cube_names,$layer_info_name);
              }

            }
            else { # ---------------------- only organ
              # save layer id and name in arrays
              push(@selected_layer_ids,$s->layer_id);
              push(@layer_cube_names,$layer_info_name);
            }

          }
        }
        else {# ----------------------  No organ filter
          # to select stages only for selected organs and stages/tissues
          if ($layer_filter) { # ---------------------- stage/tissue only

            if ($$layer_names{$layer_info_name}) {
              push(@selected_layer_ids,$s->layer_id);
              push(@layer_cube_names,$layer_info_name);
            }

          }
          else {# ---------------------- condition only
            # save layer id and name in arrays
            push(@selected_layer_ids,$s->layer_id);
            push(@layer_cube_names,$layer_info_name);
          }

        } # organ filter end

      } # while fig end

    } # layer from selected figure end

  } # while end

  @layer_cube_names = uniq(@layer_cube_names);

  return (\@selected_layer_ids,\@layer_cube_names);
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
  my $input_type = $c->req->param("input_type") || "gene_id";
  my $all_genes_list_arrayref = $c->req->param("custom_gene_list");

  my $expr_min_scale = $c->req->param("expression_min_scale");
  my $expr_max_scale = $c->req->param("expression_max_scale");

  if ($expr_min_scale !~ /\d/) {
    $expr_min_scale = "default";
  }
  if ($expr_max_scale !~ /\d/) {
    $expr_max_scale = "default";
  }

  if ($expr_min_scale =~ /\d/ || $expr_max_scale =~ /\d/) {
    if ($expr_min_scale == 0 && $expr_max_scale == 500) {
      $expr_min_scale = "default";
      $expr_max_scale = "default";
    }
  }

  my @all_genes_list;

  # Get application name
  my $application_name = $c->config->{name};

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

  my @output_gene = $c->req->param("input_gene");

  if ($input_type eq "gene_id") {
    $query_gene[0] =~ s/\s//g;

    if ($application_name eq "PEATmoss") {
        $query_gene[0] = _check_gene_exists($c,$expr_index_path,$query_gene[0],$project_rs->name);
        $output_gene[0] = $query_gene[0];
    }
    else {
        _check_gene_exists($c,$expr_index_path,$query_gene[0],$project_rs->name);
    }

  }
  elsif ($input_type eq "custom_list" && $application_name eq "PEATmoss") {
    my @custom_gene_list = split("\n",$output_gene[0]);
    foreach my $g (@custom_gene_list) {
      # print STDERR "gene in list: $g\n";
      if ($g =~ /\w/) {
        _check_gene_exists($c,$expr_index_path,$g,$project_rs->name);
      }
    }
    if($c->stash->{errors}) {
      $c->stash->{errors} = "The genes below were not found in this data set. Please check spelling and gene version. Click on the gene names to try to find the correct gene name.<br>".$c->stash->{errors}."\n";
    }

  }


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

  # get the figure resultset for the selected project
  my $figure_rs = $schema->resultset('Figure')->search({project_id => $project_rs->project_id});

  my %fig_stage_name;

  while (my $fig = $figure_rs->next) {
    $fig_stage_name{$fig->figure_id} = $fig->cube_stage_name;
  }

  # get the figure ids for the selected project
  my $figure_ids = $db_funct->get_ids_from_query($schema,"Figure",[$project_id],"project_id","figure_id");

  # save all the layer ids from the figures of the project in arrayref and hash
  my $this_project_all_layer_ids = $db_funct->get_ids_from_query($schema,"FigureLayer",$figure_ids,"figure_id","layer_id");
  my %all_layer_ids_in_project=map{$_=>1} @$this_project_all_layer_ids;


  # no filters selected
  if (!$organ_filter && !$stage_filter && !$tissue_filter && !$condition_filter) {

    # get the figure resultset for the selected project
    $figure_rs = $schema->resultset('Figure')->search({project_id => $project_rs->project_id});

    my ($organ_arrayref,$stage_arrayref,$tissue_arrayref,$condition_arrayref) = $db_funct->get_input_options($schema,$figure_rs);
    @tissues = @$tissue_arrayref;
    @stages = @$stage_arrayref;

    ($stage_ids_arrayref,$stage_hashref,$tissue_hashref) = $db_funct->get_image_hash($schema,$this_project_all_layer_ids);
  }
  # organs, stages and/or tissues selected
  else {

    # to store selected organs
    my %organ_names;

    # to select layers only from selected organs
    if ($organ_filter) {
      # save all organ in a hash
      %organ_names=map{$_=>1} @organs;
    }

    my %stage_in_organ;
    my %selected_stages;

    # names of all tissues for selected stages
    my @all_tissues_in_selected_stages;
    # layer_ids of all tissues for selected stages
    my @selected_tissue_ids;
    # for selected stages and project, key = tissue_id, value = tissue_name
    my %tissues_in_stages;

    $figure_rs = $schema->resultset('Figure')->search({project_id => $project_rs->project_id});
    my ($organ_arrayref,$stage_arrayref,$tissue_arrayref,$condition_arrayref) = $db_funct->get_input_options($schema,$figure_rs);

    my %stage_names;
    if ($stage_filter) {
      # save selected stage names in a hash
      %stage_names=map{$_=>1} @stages;
    }
    else{
      @stages = @$stage_arrayref;
      %stage_names=map{$_=>1} @stages;
    }

    my %tissue_names;
    if ($tissue_filter) {
      # save selected tissue names in a hash
      %tissue_names=map{$_=>1} @tissues;
    }
    else{
      @tissues = @$tissue_arrayref;
      %tissue_names=map{$_=>1} @tissues;
    }

    # get figures for selected condition or keep using @figure_ids for all figures from the project
    if ($condition_filter) {

      my $cond_figure_ids = $db_funct->get_ids_from_query($schema,"Condition",\@conditions,"name","figure_id");
      my @cond_filtered_figure_ids = intersect(@$figure_ids,@$cond_figure_ids);

      $figure_ids = \@cond_filtered_figure_ids;
    }

    # get all condition filtered layer ids
    my $cond_layer_ids = $db_funct->get_ids_from_query($schema,"FigureLayer",$figure_ids,"figure_id","layer_id");
    # save all condition filtered layer ids in a hash
    my %cond_layer_ids=map{$_=>1} @$cond_layer_ids;

    my @selected_stage_ids;

    # get stage layer type
    my $stage_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "stage"})->single;

    # get all stage layer obj
    my $all_stages_layer_rs = $schema->resultset('Layer')->search({layer_type_id => $stage_layer_type_rs->layer_type_id},{order_by => 'cube_ordinal'});
    # my $all_stages_layer_rs = $schema->resultset('Layer')->search({layer_type_id => $stage_layer_type_rs->layer_type_id});

    my ($selected_stage_ids,$stage_names,$selected_tissue_ids,$tissue_names);

    ($selected_stage_ids,$stage_names) = _get_filtered_layers($all_stages_layer_rs,\%cond_layer_ids,$schema,$organ_filter,$stage_filter,\%organ_names,\%stage_names,\%fig_stage_name,"stage");

    if ($selected_stage_ids) {
      @selected_stage_ids = @$selected_stage_ids;
    }

    @stages = @$stage_names;

    # get tissue layer type
    my $tissue_layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "tissue"})->single;

    # get all tissue layer obj
    my $all_tissues_layer_rs = $schema->resultset('Layer')->search({layer_type_id => $tissue_layer_type_rs->layer_type_id},{order_by => 'cube_ordinal'});

    ($selected_tissue_ids,$tissue_names) = _get_filtered_layers($all_tissues_layer_rs,\%cond_layer_ids,$schema,$organ_filter,$tissue_filter,\%organ_names,\%tissue_names,\%tissue_names,"tissue");

    @selected_tissue_ids = @$selected_tissue_ids;
    @tissues = @$tissue_names;

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
  my @corr_values;

  #check number of input genes
  if ($input_type eq "gene_id") {
    $query_gene = shift @query_gene;
  }
  elsif ($input_type eq "custom_list" || $input_type eq "blast") {
    # Custom list and BLAST input

    my @uniq_genes;

    if ($input_type eq "custom_list") {
      $query_gene = shift @query_gene;
      $query_gene =~ s/^\s+//;
      $query_gene =~ s/[\n\s,]+/,/g;

      if ($query_gene =~ /solyc\d\dg\d{6}/i) {
        $query_gene =~ s/\.[12]\.*[12]*$//g;
      }

      @genes = split(",", $query_gene);
      @uniq_genes = uniq(@genes);
    }
    elsif ($input_type eq "blast") {
      @uniq_genes = uniq(@query_gene);
    }

    if ($all_genes_list_arrayref) {
      $all_genes_list_arrayref =~ s/[\"\[\]]//g;
      @all_genes_list = split(",", $all_genes_list_arrayref);
    } else {
      @all_genes_list = @uniq_genes;
    }

    my $array_start = $cube_gene_number*($current_page-1)-1;
    my $array_end = $cube_gene_number*$current_page;

    if ($array_end >= scalar(@all_genes_list)) {
      $array_end = scalar(@all_genes_list);
    }
    if ($array_start < 0) {
      $array_start = 0;
    }

    if ($all_genes_list_arrayref) {
      $query_gene = $all_genes_list[0];
      @genes = @all_genes_list[$array_start..$array_end-1];
      shift @genes;
    } else {
      @genes = @all_genes_list[$array_start..$array_end-1];
      $query_gene = shift @genes;
    }

    if ($input_type eq "custom_list") {
      @corr_values = ("list") x scalar(@genes);
    } elsif ($input_type eq "blast") {
      @corr_values = ("blast") x scalar(@genes);
    }

	}

	# strip gene name
	$query_gene =~ s/^\s+//;
	$query_gene =~ s/\s+$//;

  # hardcoded only for tomato genes
  if ($query_gene =~ /solyc/i) {
  	$query_gene =~ s/\.\d$//;
  	$query_gene =~ s/\.\d$//;
  	$query_gene = lc($query_gene);
  	$query_gene =~ s/^s/S/;
  }

  #------------------------------------------------------------------------------------------------------------------

  # my $is_private = 0;
  # # Send restrictec access message for M82 dataset
  # if ($project_rs->name =~ /S.lycopersicum M82/i) {
  #   if ($input_type eq "gene_id" && $query_gene ne "Solyc01g102660") {
  #     $is_private = 1;
  #   }
  #
  #   if ($input_type ne "gene_id") {
  #     $is_private = 1;
  #   }
  #
  #   if ($is_private) {
  #     $c->stash->{errors} = "At present all queries for the <i>S. pimpinellifolium</i> fruit development dataset are publicly open.<br> The full <i>S. lycopersicum</i> M82 fruit development dataset will be released shortly; however, the tools and functionality for <i>S. lycopersicum</i> M82 can be demoed now using the default gene Solyc01g102660 to search by Gene ID.";
  #     $c->stash->{template} = '/Expression_viewer/output.mas';
  #     return;
  #   }
  # }


# print STDERR "$query_gene\n";
  #------------------------------------------------------------------------------------------------------------------
  my $total_corr_genes = 0;
  my $genes;
  my $corr_values;
  my $corr_hash;

  $current_page = $current_page - 1;

  if ($input_type eq "gene_id") {
    my $to_download = 0;

    ($genes,$corr_values,$total_corr_genes,$corr_hash) = _get_correlation($c,$corr_filter,$current_page,$corr_index_path,$query_gene,$to_download,$cube_gene_number);

    if ($genes && $corr_values) {
      @genes = @$genes;
      @corr_values = @$corr_values;
    }
  }

  #------------------------------------------------------------------------------------------------------------------

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
        $gene_stage_tissue_sem{$g."_".$s."_".$t} = 0.000001;
        # $gene_stage_tissue_sem{$g}{$s}{$t} = 0.000001;
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

      if ($hit->{expression} >0) {
        my $sem_val = 0;
        if ($hit->{sem} && $hit->{expression}) {
          $sem_val = $hit->{sem} / $hit->{expression};
        }
        $gene_stage_tissue_sem{$hit->{gene}."_".$hit->{stage}."_".$hit->{tissue}} = $sem_val;
        # $gene_stage_tissue_sem{$hit->{gene}}{$hit->{stage}}{$hit->{tissue}} = $sem_val;
      }
      else {
        $gene_stage_tissue_sem{$hit->{gene}."_".$hit->{stage}."_".$hit->{tissue}} = 0
        # $gene_stage_tissue_sem{$hit->{gene}}{$hit->{stage}}{$hit->{tissue}} = 0
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
      }
    }
  }

  my $deg_tab = $c->config->{deg_tab}||0;

  my $expr_imgs_tab = $c->config->{expr_imgs_tab} // 1;

  $corr_filter = $c->req->param("correlation_filter")||0.65;

  my $total_page_number;
  if ($input_type eq "gene_id") {
    $total_page_number = int($total_corr_genes/$cube_gene_number)+1;
  } else {
    $total_page_number = int(scalar(@all_genes_list)/$cube_gene_number)+1;
  }

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

  $c->stash->{pages_num} = $total_page_number;
  $c->stash->{current_page} = ($current_page + 1);
  $c->stash->{input_type} = $input_type;
  $c->stash->{custom_gene_list} = \@all_genes_list;

  $c->stash->{output_gene} = \@output_gene;
  $c->stash->{correlation_filter} = $corr_filter;
  $c->stash->{expression_min_scale} = $expr_min_scale;
  $c->stash->{expression_max_scale} = $expr_max_scale;
  $c->stash->{organism_filter} = $project_id;
  $c->stash->{stage_filter} = $stage_filter;
  $c->stash->{tissue_filter} = $tissue_filter;
  $c->stash->{condition_filter} = $condition_filter;
  $c->stash->{organ_filter} = $organ_filter;

  $c->stash->{description} = \%descriptions;
  $c->stash->{project_id} = $project_rs->project_id;
  $c->stash->{project_name} = $project_rs->name;
  $c->stash->{project_expr_unit} = $project_rs->expr_unit;
  $c->stash->{locus_ids} = \%locus_ids;

  $c->stash->{deg_tab} = $deg_tab;
  $c->stash->{expr_imgs_tab} = $expr_imgs_tab;

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

	my $input_type = $c->req->param("input_type") || "gene_id";
	my $output_type = $c->req->param("output_type") || "expr_rpkm";

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
  $query_gene = $query_gene[0];

  $query_gene =~ s/[\[\]\"]//g;
  $query_gene =~ s/\\n/,/g;
  $query_gene =~ s/\\r/,/g;

	#check number of input genes
  if ($input_type eq "gene_id") {
    # $query_gene = shift @query_gene;
    # print STDERR "query_gene: $query_gene\n";

		$multiple_genes = 0;

  }
  elsif ($input_type eq "custom_list") {

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

    @genes = @uniq_genes[0..$#uniq_genes];

    $query_gene = shift @genes;

    $multiple_genes = 1;
  }

  elsif ($input_type eq "blast") {
    @corr_values = ("blast") x scalar(@query_gene);
    @genes = split(",", $query_gene);

    my @uniq_genes = uniq(@genes);

    @genes = @uniq_genes[0..$#uniq_genes];

    $query_gene = shift @genes;
  }

  # strip gene name
  $query_gene =~ s/^\s+//;
  $query_gene =~ s/\s+$//;

  if ($query_gene =~ /^solyc/i) {
    $query_gene =~ s/\.\d$//;
    $query_gene =~ s/\.\d$//;
  }

  # print STDERR "downloading expression data\n";
  # print STDERR "multiple_genes: $multiple_genes, query_gene: $query_gene\n";
  # print STDERR "genes: @genes\n";

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


	unshift(@genes, $query_gene);


	#------------------------------------- build data structure
	my %gene_stage_tissue_expr;
	my %stage;
	my %tissue;
	my %descriptions;

	foreach my $g (@genes) {
		foreach my $t (@tissues) {
			foreach my $s (@stages) {
				$gene_stage_tissue_expr{$g}{$t}{$s} = "NA";
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
      if ($output_type eq "expr_rpkm") {
  			$gene_stage_tissue_expr{$hit->{gene}}{$hit->{tissue}}{$hit->{stage}} = $hit->{expression} * 1;
      }
      elsif ($output_type eq "expr_se") {
  			$gene_stage_tissue_expr{$hit->{gene}}{$hit->{tissue}}{$hit->{stage}} = $hit->{sem} * 1;
      }
      elsif ($output_type eq "expr_reps") {
        # print STDERR "\n\nREPLICATES: ".$hit->{replicates}."\n\n";
  			$gene_stage_tissue_expr{$hit->{gene}}{$hit->{tissue}}{$hit->{stage}} = $hit->{replicates};
      }
      else {
  			$gene_stage_tissue_expr{$hit->{gene}}{$hit->{tissue}}{$hit->{stage}} = $hit->{expression} * 1;
      }
		}

		while ( my $desc_hit = $lucy_desc->next ) {
			$descriptions{$desc_hit->{gene}} = $desc_hit->{description};
		}
	}

  #------------------------------------- Create header
	my @header;
	my @lines;

	push(@header,"gene name");

my %not_empty_col;
my $all_na = 1;

	foreach my $t (@tissues) {
    $all_na = 1;
		foreach my $s (@stages) {
      $all_na = 1;


      foreach my $g (@genes) {
        if ($gene_stage_tissue_expr{$g}{$t}{$s} ne "NA") {
          $all_na =0;
        }
        # print STDERR "Testing NA columns: $g $t $s ".$gene_stage_tissue_expr{$g}{$t}{$s}."\n";
        # print STDERR "All NA?: $all_na\n";
      }

      if (!$all_na) {
        push(@header, "$t:$s");
        $not_empty_col{$t}{$s} = 1;
      }


			# push(@header, "$t:$s ".$project_rs->expr_unit);
		}
	}

  if ($input_type eq "gene_id") {
  	push(@header,"Correlation\tdescription");
  }
  else {
  	push(@header,"description");
  }
	push(@lines, join("\t", @header));


	#------------------------------------- create file for downloading
	my @expr_columns;

	foreach my $g (@genes) {
		foreach my $t (@tissues) {
			foreach my $s (@stages) {

        if ($not_empty_col{$t}{$s}) {
  				push(@expr_columns, $gene_stage_tissue_expr{$g}{$t}{$s});
        }

			}
		}

    if ($input_type eq "gene_id") {
  		push(@lines, "$g\t".join("\t", @expr_columns)."\t$corr_hash{$g}\t$descriptions{$g}");
    }
    else {
      push(@lines, "$g\t".join("\t", @expr_columns)."\t$descriptions{$g}");
    }


		@expr_columns = [];
		shift(@expr_columns);
	}

	my $tab_file = join("\n", @lines);
	my $filename = $query_gene."_".$output_type."_cf$corr_filter.txt";

  if ($input_type eq "blast") {
    $filename = "blast_list_".$output_type.".txt";
  }

  if ($input_type eq "custom_list") {
    $filename = "custom_list_".$output_type.".txt";
  }


	#------------------------------------- send file
	$c->res->content_type('text/plain');
	$c->res->header('Content-Disposition', qq[attachment; filename="$filename"]);
	$c->res->body($tab_file);
}

=head2 download_deg

Download DEG file

ARGV: DEG file path

Return: print file with DEG results

=cut

sub download_deg_result :Path('/download_DEG_file/') :Args(0) {
  my ($self, $c) = @_;

	#get parameters from form and config file
	my $full_file_name = $c->req->param("deg_file");
  my $file_name = $full_file_name;
  $file_name =~ s/.+\///;

  # print STDERR "deg_file: $file_name\n";
  open (my $fh, '<', $full_file_name);

  #------------------------------------- send file
	$c->res->content_type('text/plain');
	$c->res->header('Content-Disposition', qq[attachment; filename="$file_name"]);
  $c->res->body( $fh );

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
