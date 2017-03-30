#!/usr/bin/perl

use strict;
use warnings;
use Lucy::Simple;
use File::Spec::Functions qw( catfile );

if (scalar(@ARGV) != 2) {
	print "Usage: perl index_expression_file.pl <expression_file.txt> <output_dir_path>\n";
	exit;
}

my ($expr_file,$output_path) = @ARGV;


if (!-e $output_path) {
  `mkdir $output_path`;
}

my $lucy = Lucy::Simple->new(
    path     => $output_path,
    language => 'en',
);

# Parse a file and return a hashref with the fields title and content
sub parse_file {
    my $text = shift;
    $text =~ /^([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)/;

    my $gene = $1;
    my $stage = $2;
    my $tissue = $3;
    my $expression = sprintf("%.2f",$4);
    my $sem = sprintf("%.2f",$5);
    my $replicates = $6;
	
    return {
        gene       => $gene,
        stage      => $stage,
        tissue     => $tissue,
        expression => $expression,
        sem => $sem,
        replicates => $replicates,
    };
}

open (my $fh, $expr_file) || die ("\nERROR: the file $expr_file could not be found\n");
while (my $line = <$fh>) {
	chomp($line);
	my $doc = parse_file($line);
	$lucy->add_doc($doc);
}


