package Tea::Controller::Expression_r_dendrogram;

use Statistics::R;
use File::Temp qw | tempfile |;
use File::Basename;

use Moose;
use strict;
use warnings;

use Data::Dumper;


=head2 draw_dendrogram

from expression data format input for R, get a heatmap and save it on a file

ARGS: schema, table name, query (rs obj), column name, column id
Returns: sorted array of ids matching for the query

=cut

sub draw_dendrogram {
  my $self = shift;
  my $tmp_path = shift;
  my $gst_hohoh = shift;
  my $genes_arrayref = shift;
  my $st_arrayref = shift;
  my $ti_arrayref = shift;
  
  if (scalar(@{$genes_arrayref}) <= 1 || scalar(@{$st_arrayref}) + scalar(@{$ti_arrayref}) <= 1) {
    return '<h3 style="margin-top: 200px">The heatmap requires multiple conditions (genes, stages, tissues). Please make another selection.</h3>';
  }
  
  # generate temporary file name for the heatmap file.
  my ($fh, $heatmap_filename) = tempfile("heatmap_tmpXXXXX", DIR=> $tmp_path, SUFFIX => '.html');
    
  my @colnames;
  my %rows;
  
  # join(",",@{$genes_arrayref});
  
  foreach my $s (@{$st_arrayref}) {
    foreach my $t (@{$ti_arrayref}) {
      push(@colnames,"\"$s.$t\"");
    }
  }
  
  
  foreach my $g (@{$genes_arrayref}) {
    $rows{$g} = "\"$g\"";
    foreach my $s (@{$st_arrayref}) {
      foreach my $t (@{$ti_arrayref}) {
        
        $rows{$g} .= ",$$gst_hohoh{$g}{$s}{$t}";
        
      }
    }
  }
  
  # `R -e 'library("d3heatmap");library("htmlwidgets");genes<-`.join(",",@{$genes_arrayref}).`;stages<-`.join(",",@colnames).`;hm_data <- rbind(`.$row_text.`);d3r <- d3heatmap(hm_data,cexRow=0.6,cexCol=0.7, colors="YlOrRd");'`
  
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
  
  # $R->set('genes', join(",",@{$genes_arrayref}) );
  # $R->set('stages', join(",",@colnames) );
  
  my @row_vars;
  for (my $i = 0; $i < scalar(@{$genes_arrayref}); $i++) {
    my $row = "r".$i;
    $R->run(''.$row.' <- c('.$rows{$$genes_arrayref[$i]}.')' );
    # $R->set("$row", $rows{$$genes_arrayref[$i]} );
    push(@row_vars,$row);
    
    my $r_row = $R->get($row);
    # print Dumper($r_row);
  }
  
  my $row_text = join(",",@row_vars);
  
  $R->run('hm_data <- rbind('.$row_text.')' );
  $R->run('genes <- hm_data[,1]' );
  
  $R->run('hm_data <- hm_data[,2:dim(hm_data)[2]]' );
  $R->run('hm_data <- matrix(as.numeric(unlist(hm_data)), nrow=nrow(hm_data))' );
  $R->run('rownames(hm_data) <- as.character(genes)' );
  
  # $R->run('rownames(hm_data) <- genes' );
  $R->run('colnames(hm_data) <- c('.join(",",@colnames).')' );
  
  my $matrix = $R->get('hm_data');
  # print Dumper($matrix);
  
  
  # my $matrix = $R->get('dim(hm_data)');
  # my $matrix = $R->get('hm_data[,2:dim(hm_data)[2]]');
  # print Dumper($matrix);
  # my $r_genes = $R->get('genes');
  # print Dumper($r_genes);
  # my $r_stages = $R->get('stages');
  # print Dumper($r_stages);
  
  $R->run( 'd3r <- d3heatmap(hm_data,cexRow=0.8,cexCol=0.8, colors="YlOrRd",width='.$heatmap_width.', height=700, xaxis_height=230, yaxis_width=140)' );
  # $R->run( 'setwd("/home/noe/Desktop/")' );
  $R->run( 'saveWidget(d3r, "'.$heatmap_filename.'", selfcontained = FALSE, libdir = "to_rm")' );
  # $R->run( 'saveWidget(d3r, "'.$heatmap_filename.'", selfcontained = TRUE, libdir = NULL)' );
  
  $R->stop();
  
  my @html_code;
  # my $div_id;
  push(@html_code, '<script src="/static/js/d3heatmap_libs/htmlwidgets-0.7/htmlwidgets.js"></script>');
  push(@html_code, '<script src="/static/js/d3heatmap_libs/d3-3.5.3/./d3.min.js"></script>');
  push(@html_code, '<link  href="/static/js/d3heatmap_libs/d3heatmapcore-0.0.0/heatmapcore.css" rel="stylesheet" />');
  push(@html_code, '<script src="/static/js/d3heatmap_libs/d3heatmapcore-0.0.0/heatmapcore.js"></script>');
  push(@html_code, '<script src="/static/js/d3heatmap_libs/d3-tip-0.6.6/index.js"></script>');
  push(@html_code, '<script src="/static/js/d3heatmap_libs/d3heatmap-binding-0.6.1.1/d3heatmap.js"></script>');
  
  while (my $line = <$fh>) {
    chomp($line);
    
    if ($line =~ /<\/*div/) {
      push(@html_code,$line);
    }
    if ($line =~ /^\<script type\=\"application\/json\" data-for\=\"([^\"]+)\"/) {
      # $div_id = $1;
      push(@html_code,$line);
    }
  }
  # open my $fh, '<', $heatmap_filename;
  # my $html_code = do { local $/; <$fh> };
  # try toHTML R function
  
  # push(@html_code, '<script type="application/htmlwidget-sizing" data-for="'.$div_id.'">{"viewer":{"width":1000,"height":700,"padding":15,"fill":false},"browser":{"width":1000,"height":700,"padding":0,"fill":false}}</script>');
  
  
  return join("\n", @html_code);
}




1;