package Tea::Controller::d3heatmap_ajax;

use Statistics::R;
use File::Temp qw | tempfile |;
use File::Basename;

use Moose;
use strict;
use warnings;
use JSON;

use Data::Dumper;

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
    default => 'application/json',
    stash_key => 'rest',
    map => { 'application/json' => 'JSON', 'text/html' => 'JSON' },
   );

=head2 draw_dendrogram

from expression data format input for R, get a heatmap and save it on a file

ARGS: schema, table name, query (rs obj), column name, column id
Returns: sorted array of ids matching for the query

=cut

sub draw_dendrogram :Path('/expression_viewer/d3heatmap/') :Args(0) {
  my ($self, $c) = @_;
  
  
  # get variables from AJAX request
  my @genes_array = $c->req->param("genes_array[]");
  my @st_array = $c->req->param("st_array[]");
  my @ti_array = $c->req->param("ti_array[]");
  
  my $tmp_path = $c->config->{tmp_path};
  
  
  if (scalar(@genes_array) <= 1 || scalar(@st_array) + scalar(@ti_array) <= 2) {
    print STDERR "genes: ".scalar(@genes_array).", stages: ".scalar(@st_array).", tissues: ".scalar(@ti_array)."\n";
    
    my $html_text = '<h3 style="margin-top: 200px">The heatmap requires multiple conditions (genes, stages, tissues). Please make another selection.</h3>';
    
    $c->stash->{rest} = {
      html_code => $html_text
    };
    
    return ;
  }
  
  # generate temporary file name for the heatmap file.
  my ($fh, $heatmap_filename) = tempfile("heatmap_tmpXXXXX", DIR=> $tmp_path, SUFFIX => '.html');
    
  my @colnames;
  my %rows;
  
  foreach my $s (@st_array) {
    foreach my $t (@ti_array) {
      push(@colnames,"\"$s.$t\"");
    }
  }
  
  foreach my $g (@genes_array) {
    $rows{$g} = "\"$g\"";
    foreach my $s (@st_array) {
      foreach my $t (@ti_array) {
        
        $rows{$g} .= ",".$c->req->param("gst_hohoh[$g][$s][$t]");
      }
    }
  }
  
  
  my $heatmap_width = scalar(@colnames)*20;
  
  if (scalar(@colnames) <= 150) {
    $heatmap_width = scalar(@colnames)*25;
  }
  if (scalar(@colnames) <= 100) {
    $heatmap_width = scalar(@colnames)*30;
  }
  if (scalar(@colnames) <= 45) {
    $heatmap_width = 1000;
  }
  
  my $R = Statistics::R->new();
  
  $R->run(q`library("d3heatmap")`);
  $R->run(q`library("htmlwidgets")`);
  
  
  my @row_vars;
  for (my $i = 0; $i < scalar(@genes_array); $i++) {
    my $row = "r".$i;
    $R->run(''.$row.' <- c('.$rows{$genes_array[$i]}.')' );
    push(@row_vars,$row);
    
    my $r_row = $R->get($row);
  }
  
  my $row_text = join(",",@row_vars);
  
  $R->run('hm_data <- rbind('.$row_text.')' );
  $R->run('genes <- hm_data[,1]' );
  
  $R->run('hm_data <- hm_data[,2:dim(hm_data)[2]]' );
  $R->run('hm_data <- matrix(as.numeric(unlist(hm_data)), nrow=nrow(hm_data))' );
  $R->run('rownames(hm_data) <- as.character(genes)' );
  
  $R->run('colnames(hm_data) <- c('.join(",",@colnames).')' );
  
  my $matrix = $R->get('hm_data');
  
  $R->run( 'd3r <- d3heatmap(hm_data,cexRow=0.8,cexCol=0.8, colors="YlOrRd",width='.$heatmap_width.', height=700, xaxis_height=230, yaxis_width=140)' );

  $R->run( 'saveWidget(d3r, "'.$heatmap_filename.'", selfcontained = FALSE, libdir = "to_rm")' );
  
  $R->stop();
  
  my @html_code;
  
  while (my $line = <$fh>) {
    chomp($line);
    
    if ($line =~ /<\/*div/) {
      push(@html_code,$line);
    }
    if ($line =~ /^\<script type\=\"application\/json\" data-for\=\"([^\"]+)\"/) {
      push(@html_code,$line);
    }
  }
  
  my $html_text =  join("\n", @html_code);
  
  $c->stash->{rest} = {
    html_code => $html_text
  };
  
}




1;