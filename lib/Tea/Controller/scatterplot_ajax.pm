package Tea::Controller::scatterplot_ajax;

use Statistics::R;
use File::Temp qw | tempfile |;
use File::Basename;

use Moose;
use Lucy::Simple;
use Lucy::Search::RangeQuery;
use Lucy::Search::IndexSearcher;
use Lucy::Search::TermQuery;
use Lucy::Search::ANDQuery;
use Lucy::Search::QueryParser;
use Array::Utils qw(:all);
use List::MoreUtils qw(uniq);

use strict;
use warnings;
use JSON;

use Data::Dumper qw(Dumper);

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
    default => 'application/json',
    stash_key => 'rest',
    map => { 'application/json' => 'JSON', 'text/html' => 'JSON' },
   );

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
    query      => '22.65',
  	num_wanted => 10
  );

	if (!$gene_found_num){
		$c->stash->{errors} = "Gene not found";
		$c->stash->{template} = '/Expression_viewer/output.mas';
		return;
	}
print STDERR "Output: ".$gene_found_num."\n";
return;  
}

sub _get_correlated_genes_for_plot {
    my $c = shift;    
    my $corr_filter = shift;
    my $corr_index_path = shift;    
    my $query_gene = shift;

    my @genes;


    
	if ($corr_filter > 1) {
		$corr_filter = $corr_filter/100;
	}
  
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


    
    $hits = $lucy_corr->search(
      query      => $query_gene,
      sort_spec  => $sort_spec,
      num_wanted => 10000,
    );
    
	while ( my $hit = $lucy_corr->next ) {
    
		if ($query_gene eq $hit->{gene1} && $hit->{correlation} >= $corr_filter) {
			push(@genes, $hit->{gene2});
		} elsif ($query_gene eq $hit->{gene2} && $hit->{correlation} >= $corr_filter) {
			push(@genes, $hit->{gene1});
		}
    else {

    }
	}
    return (\@genes);
}

sub _get_all_genes_for_plot {
    my $c = shift;    
    my $corr_filter = shift;
    my $loci_and_desc_path = shift;    
    my $query_gene = shift;

    my @all_genes;
    my @unique_all_genes;


	my $searcher = Lucy::Search::IndexSearcher->new(
	    index     => $loci_and_desc_path,
	);
    
    my $all_gene_hits = $searcher->hits(
      query      => Lucy::Search::MatchAllQuery->new,
      num_wanted => 200000,
    );
    
	while ( my $hit = $all_gene_hits->next ) {
			push(@all_genes, $hit->{gene});
}
@unique_all_genes = uniq @all_genes;
 
    return (\@unique_all_genes);
}



 sub get_scatterplot_expression :Path('/expression_viewer/scatterplot/') :Args(0) {
        my ( $self, $c ) = @_;
	my @tissues = $c->req->param("ti_array[]");	
	my @stages = $c->req->param("st_array[]");
	my $sample1_tissue = $c->req->param("ti_s1_index");
	my $sample1_stage = $c->req->param("st_s1_index");
	my $sample2_tissue = $c->req->param("ti_s2_index");
	my $sample2_stage = $c->req->param("st_s2_index");	
	my $project_id = $c->req->param("projectid");
	my $corr_filter = $c->req->param("corr_filter_to_set_genes");
	my $gene_set_selector_switch = $c->req->param("gene_set_request");
	print STDERR "S1 stage received: ".$sample1_stage."\n";
	print STDERR "S1 tissue received: ".$sample1_tissue."\n";
	print STDERR "S2 stage received: ".$sample2_stage."\n";
	print STDERR "S2 tissue received: ".$sample2_tissue."\n";
	print STDERR "Correlation filter received: ".$corr_filter."\n";
	
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
	
	# get the array of genes for which expression will be sought
        my @query_gene_array = $c->req->param("genes_to_plot[]");
	my $query_gene = $query_gene_array[0];
	my $genes;
my @genes;

	print STDERR "Selector value: ".$gene_set_selector_switch."\n";
	if ($gene_set_selector_switch == 0) {    
	    ($genes) = _get_correlated_genes_for_plot($c,$corr_filter,$corr_index_path,$query_gene);
	} else {
	    ($genes) = _get_all_genes_for_plot($c,$corr_filter,$expr_index_path,$query_gene);	    
	}
	
	
	if ($genes) {
	    @genes = @$genes;
	}
	
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
	}
	my @gene_name_list;
	
	my @AoAoA;
	
	for (my $g=0; $g<scalar(@genes); $g++) {
		for (my $s=0; $s<scalar(@stages); $s++) {
			for (my $t=0; $t<scalar(@tissues); $t++) {
			    $AoAoA[$g][$s][$t] = $gene_stage_tissue_expr{$genes[$g]}{$stages[$s]}{$tissues[$t]};

			}
		}
	}
	my @select_AoAoA;
	my @sample1_AoAoA;
	my @sample2_AoAoA;
	for (my $g=0; $g<scalar(@genes); $g++) {
		for (my $s=0; $s<scalar(@stages); $s++) {
			for (my $t=0; $t<scalar(@tissues); $t++) {
			    if (($t == $sample1_tissue) && ($s == $sample1_stage)) {
				 $sample1_AoAoA[$g] = $AoAoA[$g][$s][$t];				
			    } elsif ($t == $sample2_tissue && $s == $sample2_stage) {
				 $sample2_AoAoA[$g] = $AoAoA[$g][$s][$t];
			    } else {
			    }

			}
		}
	}
	my @AoH;
for (my $g=0; $g<scalar(@genes); $g++) {
    $AoH[$g] = {
	geneid => $genes[$g],
	sample1_exp => $sample1_AoAoA[$g],
	sample2_exp => $sample2_AoAoA[$g],
    }
	
}

	my $json_string = new JSON;
	$json_string = encode_json(\@AoH);
	
my @combined_sample_array;

	my $combined_sample_string = encode_json(\@combined_sample_array);

    $c->stash->{rest} = {
	expression_to_plot3 => $json_string
    };

   return;
}
