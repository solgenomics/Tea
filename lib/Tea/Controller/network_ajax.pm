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

sub _get_correlated_genes_edges {
    my $c = shift;
    my $corr_filter = shift;
    my $corr_index_path = shift;
    my $query_gene = shift;

    my @genes; my @edges;

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

    my $hits = $lucy_corr->search(
        query      => $query_gene,
        sort_spec  => $sort_spec,
        num_wanted => 10000,
      );

    my $id = 0;
    my $gene_id = 0;
    my $gene_id2 = 1;

    push @genes, {
              id => $gene_id,
              name => $query_gene,
              query => 'true'
          };

    while ( my $hit = $lucy_corr->next ) {

        if ($query_gene eq $hit->{gene1} && $hit->{correlation} >= $corr_filter) {
            push @genes, {
                id => $gene_id2,
                name => $hit->{gene2}
            };
            push @edges, {
                id => $id,
                source => $gene_id,
                target => $gene_id2,
                weight => $hit->{correlation} + 0,
            };
        } elsif ($query_gene eq $hit->{gene2} && $hit->{correlation} >= $corr_filter) {
            push @genes, {
                id => $gene_id2,
                name => $gene_id2
            };
            push @edges, {
                id => $id,
                source => $gene_id,
                target => $gene_id2,
                weight => $hit->{correlation} + 0,
            };
        }
        $id++; $gene_id2++;
    }

    return (\@genes,\@edges);
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
    my $schema = $self->schema;
    my $project_id = $c->req->param("projectid");
    my $corr_filter_value = $c->req->param("corrfiltervalue"); # '0.6';
    my $query_gene = $c->req->param("inputgene"); 
    my $project_rs = $schema->resultset('Project')->search({project_id => $project_id})->single;
    my $corr_path = $c->config->{correlation_indexes_path};
    my $corr_index_path = $corr_path."/".$project_rs->indexed_dir;
print Dumper $query_gene;

    my ($genes,$edges) = _get_correlated_genes_edges($c,$corr_filter_value,$corr_index_path,$query_gene);

    my $message_back = "Returned ajax";

    my $json_string = new JSON;
    my $json_string2 = new JSON;

    $json_string = encode_json($genes);
    $json_string2 = encode_json($edges);


    $c->stash->{rest} = {

        genes => $json_string,
        edges => $json_string2,

    };

    return;
}
