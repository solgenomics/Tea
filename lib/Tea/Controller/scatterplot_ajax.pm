package Tea::Controller::scatterplot_ajax;

use Statistics::R;
# use File::Temp qw | tempfile |;
# use File::Basename;

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

# use Data::Dumper qw(Dumper);

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
    default => 'application/json',
    stash_key => 'rest',
    map => { 'application/json' => 'JSON', 'text/html' => 'JSON' },
   );

 sub get_scatterplot_expression :Path('/expression_viewer/scatterplot/') :Args(0) {
    my ( $self, $c ) = @_;
    my @tissues = $c->req->param("ti_array[]");
    my @stages = $c->req->param("st_array[]");
    my $sample1_tissue = $c->req->param("ti_s1_index");
    my $sample1_stage = $c->req->param("st_s1_index");
    my $sample2_tissue = $c->req->param("ti_s2_index");
    my $sample2_stage = $c->req->param("st_s2_index");
    my $project_id = $c->req->param("projectid");

    my $stage1 = $stages[$sample1_stage];
    my $stage2 = $stages[$sample2_stage];
    my $tissue1 = $tissues[$sample1_tissue];
    my $tissue2 = $tissues[$sample2_tissue];

   	# get the path to the expression and correlation lucy indexes
  	my $expr_path = $c->config->{expression_indexes_path};

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
  	my $expr_index_path = $expr_path."/".$project_rs->indexed_dir;

  	my %gene_stage_tissue_expr;
  	my %stage;
  	my %tissue;
  	my %descriptions;
  	my %locus_ids;
    my $gene_name;

  	my $lucy = Lucy::Simple->new(
  	    path     => $expr_index_path,
  	    language => 'en',
  	);

    $lucy->search(
        query    => $stage1,
      num_wanted => 90000000
    );

    while ( my $hit = $lucy->next ) {

      $gene_name = $hit->{gene};

      if ($hit->{stage} eq $stage1 && $hit->{tissue} eq $tissue1) {
        $gene_stage_tissue_expr{$gene_name}{$stage1}{$tissue1} = $hit->{expression};
      }
    }

    $lucy->search(
        query    => $stage2,
      num_wanted => 90000000
    );

    while ( my $hit = $lucy->next ) {

      $gene_name = $hit->{gene};

      if ($hit->{stage} eq $stage2 && $hit->{tissue} eq $tissue2) {
        $gene_stage_tissue_expr{$gene_name}{$stage2}{$tissue2} = $hit->{expression};
      }
    }

  	my @gene_name_list;
  	my @AoH;

    my $counter = 0;
    foreach my $g (sort keys %gene_stage_tissue_expr) {

      $AoH[$counter] = {
          geneid => $g,
          sample1_exp => $gene_stage_tissue_expr{$g}{$stage1}{$tissue1},
          sample2_exp => $gene_stage_tissue_expr{$g}{$stage2}{$tissue2},
      };

      $counter++;
  	}

  	my $json_string = new JSON;
  	$json_string = encode_json(\@AoH);

    $c->stash->{rest} = {
    	expression_to_plot3 => $json_string
    };

   return;
}
