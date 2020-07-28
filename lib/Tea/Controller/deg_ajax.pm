package Tea::Controller::deg_ajax;

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


 sub get_deg :Path('/expression_viewer/deg/') :Args(0) {
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

    my $tmp_path = $c->config->{tmp_path};

    # check if file exist: project_stage1_tissue1_stage2_tissue2
    my $filename = $project_id."_$stage1"."_$tissue1"."_$stage2"."_$tissue2.txt";
    my $deg_out = $project_id."_$stage1"."_$tissue1"."_$stage2"."_$tissue2"."_NOISeq_DEGs.txt";
    my $deg_out2 = $project_id."_$stage2"."_$tissue2"."_$stage1"."_$tissue1"."_NOISeq_DEGs.txt";

    my $output_fh;
    my $rep_num1;
    my $rep_num2;

    my $deg_count;
    my $deg_up_count;
    my $deg_down_count;
    my $deg_up_name;
    my $deg_down_name;


    if (-e "$tmp_path/$deg_out" || -e "$tmp_path/$deg_out2") {
      print STDERR "$deg_out already exist!\n";

      # count DEGs
      my $R = Statistics::R->new();

      $R->run(q`library("NOISeq")`);

      if (-e "$tmp_path/$deg_out") {
        $R->run(' deg_input <- read.delim(paste("'.$tmp_path.'","'.$deg_out.'", sep="/"), header = T, row.names =1) ');
      }
      elsif (-e "$tmp_path/$deg_out2") {
        $R->run(' deg_input <- read.delim(paste("'.$tmp_path.'","'.$deg_out2.'", sep="/"), header = T, row.names =1) ');
      }

      $deg_count = $R->get(' nrow(deg_input) ');

      $deg_up_count = $R->get(' nrow(deg_input[deg_input$M>0,]) ');
      $deg_down_count = $R->get(' nrow(deg_input[deg_input$M<0,]) ');

      $deg_up_name = $R->get(' colnames(deg_input[1]) ');
      $deg_down_name = $R->get(' colnames(deg_input[2]) ');


    }
    else {

      # get the path to the expression and correlation lucy indexes
    	my $expr_path = $c->config->{expression_indexes_path};
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
    	my $expr_index_path = $expr_path."/".$project_rs->indexed_dir;
    	$loci_and_desc_path .= "/".$project_rs->indexed_dir;

    	my %gene_stage_tissue_expr;
    	my %stage;
    	my %tissue;

      my %gene_desc;
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
    			$gene_stage_tissue_expr{$gene_name}{$stage1}{$tissue1} = $hit->{replicates};
        }
  		}

      $lucy->search(
          query    => $stage2,
        num_wanted => 90000000
      );

      while ( my $hit = $lucy->next ) {

        $gene_name = $hit->{gene};

        if ($hit->{stage} eq $stage2 && $hit->{tissue} eq $tissue2) {
    			$gene_stage_tissue_expr{$gene_name}{$stage2}{$tissue2} = $hit->{replicates};
        }
  		}


      # open new file
      open($output_fh, ">$tmp_path/$filename") || die ("\nERROR: the gene expression could not be created\n");

        my $r_header = 1;
        foreach my $gene_name (sort keys %gene_stage_tissue_expr) {
          # print STDERR "$gene_name\t$stage1\t$tissue1\n";
          my @reps1;
          my @reps2;

          # get rep names
          if ($gene_stage_tissue_expr{$gene_name}{$stage1}{$tissue1}) {
            @reps1 = split(",", $gene_stage_tissue_expr{$gene_name}{$stage1}{$tissue1});
          }
          if ($gene_stage_tissue_expr{$gene_name}{$stage2}{$tissue2}) {
            @reps2 = split(",", $gene_stage_tissue_expr{$gene_name}{$stage2}{$tissue2});
          }

          # print header
          if ($r_header) {
            for (my $i = 0; $i <= $#reps1; $i++) {
              print $output_fh "\t".$stage1."_".$tissue1."_rep".($i+1);
            }
            for (my $i = 0; $i <= $#reps2; $i++) {
              print $output_fh "\t".$stage2."_".$tissue2."_rep".($i+1);
            }
            print $output_fh "\n";

            $rep_num1 = scalar(@reps1);
            $rep_num2 = scalar(@reps2);

            $r_header = 0;
          }

          # print expression values
          print $output_fh "$gene_name\t".join("\t", @reps1)."\t".join("\t", @reps2)."\n";

        }


        my $comparison_name = $stage1."_$tissue1"." Vs. $stage2"."_$tissue2";
        my $cond1 = $stage1."_$tissue1";
        my $cond2 = $stage2."_$tissue2";

        my $R = Statistics::R->new();

        $R->run(q`library("NOISeq")`);

        # $R->run(' rpkm_input <- read.delim("'.$filename.'", header = T, row.names =1) ');
        # $R->run(' rpkm_input <- read.delim(paste0("'.$tmp_path.'","'.$filename.'"), header = T, row.names =1) ');
        $R->run(' rpkm_input <- read.delim(paste("'.$tmp_path.'","'.$filename.'", sep="/"), header = T, row.names =1) ');

        # remove all 0 lines
        $R->run(' rpkm_input <- rpkm_input[rowSums(rpkm_input) > 0,] ');

        $R->run(' pvt <- 0.9 ');
        $R->run(' comparison <- "'.$comparison_name.'" ');

        $R->run(' myfactors <- data.frame(Treatment = c(rep("'.$cond1.'",'.$rep_num1.'),rep("'.$cond2.'",'.$rep_num2.')), TreatmentRun =  colnames(rpkm_input)) ');
        $R->run(' mydata <- readData(data = rpkm_input, factors = myfactors) ');

        $R->run(' mynoiseq.rpkm = noiseq(mydata, k=0.5, norm="n", replicates="biological", factor = "Treatment", lc = 1) ');

        #Filter results
        # $R->run(' mynoiseq.rpkm.prob <- mynoiseq.rpkm@results[[1]][mynoiseq.rpkm@results[[1]]$prob > pvt, ] ');
        # $deg_count = $R->get(' nrow(mynoiseq.rpkm.prob) ');
        # $R->run(' mynoiseq.rpkm.prob <- mynoiseq.rpkm.prob[!is.na(mynoiseq.rpkm.prob$prob), ] ');

        $R->run(' mynoiseq.rpkm.deg <- degenes(mynoiseq.rpkm, q = pvt, M = NULL) ');

        $deg_count = $R->get(' nrow(mynoiseq.rpkm.deg) ');

        $deg_up_count = $R->run(' deg_up = nrow(degenes(mynoiseq.rpkm, q = pvt, M = "up")) ');
        $deg_up_count = $R->get(' deg_up ');
        $deg_down_count = $R->run(' deg_down = nrow(degenes(mynoiseq.rpkm, q = pvt, M = "down")) ');
        $deg_down_count = $R->get(' deg_down ');

        $deg_up_name = $R->get(' colnames(mynoiseq.rpkm.deg[1]) ');
        $deg_down_name = $R->get(' colnames(mynoiseq.rpkm.deg[2]) ');

        if ($deg_count > 0) {

          my @gene_desc;
          my $gene_list_arrayref = $R->get(' row.names(mynoiseq.rpkm.deg) ');
          my $gene_description = "Unknown protein";

          my $lucy_desc = Lucy::Simple->new(
        	    path     => $loci_and_desc_path,
        	    language => 'en',
        	);

          if ( eval { \@$gene_list_arrayref } ) {
            foreach my $one_gene (@{$gene_list_arrayref}) {

              $lucy_desc->search(
                  query    => $one_gene,
                num_wanted => 1
              );

              while ( my $hit = $lucy_desc->next ) {
                if ($hit->{description}) {
                  # push(@gene_desc, $hit->{description});
                  $gene_description = $hit->{description};
                }
                # print STDERR "$one_gene: ".$hit->{description}."\n";
              }

              push(@gene_desc, $gene_description);

            }
          }
          else {

            $lucy_desc->search(
                query    => $gene_list_arrayref,
              num_wanted => 1
            );

            while ( my $hit = $lucy_desc->next ) {
              if ($hit->{description}) {
                $gene_description = $hit->{description};
              }
            }
            push(@gene_desc, $gene_description);

          }
          $R->set('description', \@gene_desc);
          $R->run(' deg_result_file = cbind(mynoiseq.rpkm.deg,description) ');

          $R->run(' write.table(deg_result_file, file = paste("'.$tmp_path.'","'.$deg_out.'", sep="/"), sep = "\t", row.names=T, col.names=NA, quote = F) ');
      } # conditional number of rows > 0, DEGs found
      else {
        $R->run(' deg_result_file = mynoiseq.rpkm.deg ');
        $R->run(' write.table(deg_result_file, file = paste("'.$tmp_path.'","'.$deg_out.'", sep="/"), sep = "\t", row.names=T, col.names=NA, quote = F) ');
      }

    } # end of

    $deg_up_name =~ s/_mean$//;
    $deg_up_name =~ s/[\._]+/ /g;
    $deg_down_name =~ s/_mean$//;
    $deg_down_name =~ s/[\._]+/ /g;

print STDERR "deg_count: $deg_count\n";
print STDERR "deg_up_count: $deg_up_count\n";
print STDERR "deg_down_count: $deg_down_count\n";
print STDERR "deg_up_name: $deg_up_name\n";
print STDERR "deg_down_name: $deg_down_name\n";

    $c->stash->{rest} = {
      deg_file => "$tmp_path/$deg_out",
      deg_count => $deg_count,
      deg_up_count => $deg_up_count,
      deg_down_count => $deg_down_count,
      deg_up_name => $deg_up_name,
      deg_down_name => $deg_down_name
    }

}
