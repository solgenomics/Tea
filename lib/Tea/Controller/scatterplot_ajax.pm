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
  
	# Send error message to the web if something is wrong
	if (!$gene_found_num){
		$c->stash->{errors} = "Gene not found";
		$c->stash->{template} = '/Expression_viewer/output.mas';
		return;
	}
print STDERR "Output: ".$gene_found_num."\n";
return;  
}

 sub get_scatterplot_expression :Path('/expression_viewer/scatterplot/') :Args(0) {
        my ( $self, $c ) = @_;
# temporarily change default gene to the one that actually has correlated genes in this test mini-dataset
	my $default_gene = $c->config->{default_gene};
#	my $default_gene = "Pp3c10_13370V3.1";
	my @tissues = $c->req->param("ti_array[]");	
	my @stages = $c->req->param("st_array[]");
	my $sample1_tissue = $c->req->param("ti_s1_index");
	my $sample1_stage = $c->req->param("st_s1_index");
	my $sample2_tissue = $c->req->param("ti_s2_index");
	my $sample2_stage = $c->req->param("st_s2_index");	
	my $project_id = $c->req->param("projectid");	
#	print STDERR "Received parameter: ".$project_id."\n";
#	my @tissues = split(",",$tissue_filter);
	my @genes = $c->req->param("genes_to_plot[]");
	#	print STDERR "Genes received: ".@genes."\n";
	print STDERR "S1 stage received: ".$sample1_stage."\n";
	print STDERR "S1 tissue received: ".$sample1_tissue."\n";
	print STDERR "S2 stage received: ".$sample2_stage."\n";
	print STDERR "S2 tissue received: ".$sample2_tissue."\n";	
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

	


       	# build data structure
#	my @genes = ('Pp3c19_22960V3.1','Pp3c19_22410V3.1');
#	my @tissues = ('tissue1','tissue2');
#	my @stages = ('Sporophyte_g','Sporophyte_b');
#	unshift(@genes, $default_gene);
	my %gene_stage_tissue_expr;
	my %gene_stage_tissue_sem;
	my %stage;
	my %tissue;
	my %descriptions;
	my %locus_ids;
	_check_gene_exists($c,$expr_index_path,$genes[2]);
	
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
	print STDERR "all genes:".$lucy_loci_and_desc."\n";

	
		
	foreach my $g (@genes) {
		$lucy->search(
		    query      => $g,
			num_wanted => 10000
		);
print STDERR "current g: ".$g."\n";		
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
#      $descriptions{$loci_and_desc_hit->{gene}} = $loci_and_desc_hit->{description};
    }
    
	}
	my @gene_name_list;
	



	
	
	my @AoAoA;
	
	for (my $g=0; $g<scalar(@genes); $g++) {
		for (my $s=0; $s<scalar(@stages); $s++) {
			for (my $t=0; $t<scalar(@tissues); $t++) {
			    print
			    $AoAoA[$g][$s][$t] = $gene_stage_tissue_expr{$genes[$g]}{$stages[$s]}{$tissues[$t]};

			}
		}
	}
	my @select_AoAoA;
	my @sample1_AoAoA;
	my @sample2_AoAoA;
#	my $sample1_tissue = 0;
#	my $sample1_stage = 1;
#	my $sample2_tissue = 1;
#	my $sample2_stage = 1;	
	for (my $g=0; $g<scalar(@genes); $g++) {
		for (my $s=0; $s<scalar(@stages); $s++) {
			for (my $t=0; $t<scalar(@tissues); $t++) {
			    if (($t == $sample1_tissue) && ($s == $sample1_stage)) {
				 $sample1_AoAoA[$g] = $AoAoA[$g][$s][$t];
				print STDERR "Loop: ".$AoAoA[$g][$s][$t]."\n";				
			    } elsif ($t == $sample2_tissue && $s == $sample2_stage) {
				 $sample2_AoAoA[$g] = $AoAoA[$g][$s][$t];								print STDERR "Loop: ".$AoAoA[$g][$s][$t]."\n";
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
#	my @AoH = (
#    {
#       geneid  => "Pp3c19_22960V3.1",
#       sample1_exp => "50",
#       sample2_exp      => "70",
#    },
#    {
#       geneid => "Pp3c19_22500V3.1",
#       sample1_exp    => "150",
#       sample2_exp     => "140",
#    },

#    {
#       geneid => "Pp3c19_22410V3.1",
#       sample1_exp    => "300",
#       sample2_exp     => "330",
#    },
#  );
	my $json_string = new JSON;
	$json_string = encode_json(\@AoH);
print STDERR $json_string;	
	
my @combined_sample_array;

	my $combined_sample_string = encode_json(\@combined_sample_array);

#	my $sample1_test = encode_json(\@sample1_AoAoA);
#	my $sample2_test = encode_json(\@sample2_AoAoA);
		
	
#	my @test_array_of_arrays =([295.756591482681,400],[300,350],[100,50],[500,550],[180,230],[300,350]);
#	my $json_test_string = encode_json(\@test_array_of_arrays);

#	my @test_AoAoA =(@test_array_of_arrays);
#	my $json_test_string2 = encode_json(\@test_AoAoA);

    $c->stash->{rest} = {
#	$c->stash->{rest} = expression_to_plot1 => $sample1_test;
#	$c->stash->{rest} = expression_to_plot2 => $sample2_test;
	expression_to_plot3 => $json_string
    };

	
   return;
}
