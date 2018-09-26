#!/usr/bin/perl

use strict;
use warnings;

if (scalar(@ARGV) != 1) {
	print "Usage: perl format_expr_data.pl <expression_for_cube_file>\n ";
	exit;
}

my ($expr_file) = $ARGV[0];


my %expr_hash;

open (my $fh, $expr_file) || die ("\nERROR: the file $expr_file could not be found\n");
while (my $line = <$fh>) {
	chomp($line);

	my ($name,$cond,$stage,$expr) = split("\t",$line);

  $expr_hash{$name}{$cond}{$stage} = $expr;
}

foreach my $g (sort keys %expr_hash) {
	print "$g";

	foreach my $c (sort keys $expr_hash{$g}) {
		foreach my $s (sort keys $expr_hash{$g}{$c}) {
			print "\t$expr_hash{$g}{$c}{$s}";
		}
	}
	print "\n";
}
