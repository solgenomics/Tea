package Tea::Controller::network_ajax;

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

 sub get_network :Path('/expression_viewer/get_network/') :Args(0) {
     my ( $self, $c ) = @_;
#     my $corr_filter = $c->req->param("corr_filter_to_set_genes");
#	 my $query_gene = $query_gene_array[0];
#	 my @genes;


     print STDERR "Made it inside ajax request\n";

#     ($genes) = _get_correlated_genes_for_plot($c,$corr_filter,$corr_index_path,$query_gene);

     my $message_back = "Returned ajax";
	my @nodes = (
    {
       id => 0,
       name  => "Solyc01g102660",
#       name => "50",
#       name => "70",
    },
    {
       id => 1,
       name => "Solyc03g095290",
#       sample1_exp    => "150",
#       sample2_exp     => "140",
    },

    {
       id => 2,
       name => "Solyc03g116570",
#       sample1_exp    => "300",
#       sample2_exp     => "330",
    },

    {
       id => 3,
       name  => "Solyc04g016470",
    },

  );

     	my @edges = (
    {
       id => 0,
       source  => 1,
       target => 2,
       weight => 0.35,
    },
    {
       id => 1,
       source  => 2,
       target => 3,
       weight => 0.1,
    },

    {
       id => 2,
       source  => 1,
       target => 3,
       weight => 0.9,
    },

    {
       id => 3,
       source  => 0,
       target => 3,
       weight => 0.4,
    },

    {
       id => 4,
       source  => 0,
       target => 2,
       weight => 0.6,
    },

    {
       id => 5,
       source  => 0,
       target => 1,
       weight => 0.2,
    },

  );

     my $json_string;
     my $json_string = new JSON;
     $json_string = encode_json(\@nodes);
     my $json_string2;
     my $json_string2 = new JSON;
     $json_string2 = encode_json(\@edges);

#     print STDERR $json_string;
#     $c->stash->{rest} = returnmessage => $json_string;
#     my $json_string = 9;
    $c->stash->{rest} = {
#	$c->stash->{rest} = expression_to_plot1 => $sample1_test;
#	$c->stash->{rest} = expression_to_plot2 => $sample2_test;
	node_genes_to_plot => $json_string,
	edges_to_plot => $json_string2,

    };

     return;
}
