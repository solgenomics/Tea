#!/usr/bin/perl

# header names should repeat the same name for each replicate
# header names should start with the name that will be shown on the top of the cube (stages)
# followed by :: to separate it from the name that will be displayed on the diagonal left of the cube (tissues).

use strict;
use warnings;
use Statistics::Basic qw(:all);

if (scalar(@ARGV) != 1) {
	print "Usage: perl format_expr_data.pl <rpkm_tab_delimited_file>\n ";
	exit;
}

my ($rpkm_file) = $ARGV[0];


sub stdev{
        my($data) = @_;
        if(@$data == 1){
					#  print "EXIT FUNCTION!\n";
          return 0;
        }
        my $average = &average($data);
				# print "average: $average\n";
        my $sqtotal = 0;
        foreach(@$data) {
          $sqtotal += ($average-$_) ** 2;
        }
        my $std = ($sqtotal / (@$data-1)) ** 0.5;
        return $std;
}

my %reps_hash;

open (my $fh, $rpkm_file) || die ("\nERROR: the file $rpkm_file could not be found\n");

# read file header to count replicates.
# header names should repeat the same name for each replicate
# header names should start with the name that will be shown on the top of the cube (stages)
# followed by :: to separate it from the name that will be displayed on the diagonal left of the cube (tissues).
my $head_line = <$fh>;
chomp($head_line);
my @head_array = split("\t",$head_line);

my $count = 0;
for (my $num=0; $num < scalar(@head_array); $num++) {
	my $col = $head_array[$num];
	my $next_col = $head_array[$num+1];

	if ($col =~ /::/) {
		if ($col ne $next_col) {
			$count++;
			# print "$col $count Reps\n";
			$reps_hash{$col} = $count;
			$count = 0;
		}
		else {
			$count++;
		}
	}
}


while (my $line = <$fh>) {
	chomp($line);

	my @line_cols = split("\t",$line);

	for (my $i=0; $i < scalar(@head_array); $i++) {
		my $col = $head_array[$i];
		my $next_col = $head_array[$i+1] || "kk";

		if ($col =~ /::/) {
			if ($col ne $next_col) {
				my $sample_name = $head_array[$i];
				my $sample_reps = $reps_hash{$head_array[$i]};

				$sample_name =~ s/ /_/g;
				my ($y_ax, $x_ax) = split("::",$sample_name);

				my $reps="";
				my $sum=0;
				my $ave=0;
        my $expr = 0.00;

				for (my $j=0; $j < $sample_reps; $j++) {
					# print "i: $i, j: $j\n";
					if ($head_array[$i-$j] =~ /::/) {
            my $rep_val1 = $line_cols[$i-$j];
            $expr = sprintf("%.2f",$rep_val1);

            if ($expr < 0) {
              print "ERROR: VALUE $expr < 0 !!!\n";
              exit;
            }

						$reps = $reps.",".$expr;
						$sum += $expr;
					}
				} #end for loop

				$reps =~ s/^,//;
				my @format_reps = split(",",$reps);

				if ($sample_reps > 0) {
					$ave = sprintf("%.2f",($sum/$sample_reps));
				}

				my $sd = &stdev(\@format_reps);
				my $se = sprintf("%.2f",$sd/sqrt($sample_reps) );
				my $gene_name = $line_cols[0];

  			print "$gene_name\t$y_ax\t$x_ax\t$ave\t$se\t$reps\n";

			} #end if col ne
		} #end if ::

	} #end for loop

} #end while loop
