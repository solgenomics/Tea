#!/usr/bin/perl

use strict;
use warnings;


if (scalar(@ARGV) != 2) {
	print "Usage: perl index_description_file.pl <description_file.txt> <output_dir_path>\n";
	exit;
}

my ($desc_file,$output_path) = @ARGV;


use Lucy::Simple;
use File::Spec::Functions qw( catfile );

my $lucy = Lucy::Simple->new(
    path     => $output_path,
    language => 'en',
);

# Parse a file and return a hashref with the fields title and content
sub parse_file {
    my $text = shift;
    $text =~ /^([^\t]+)\t([^\t]+)\t([^\t]+)/;

    my $locus_id = $1;
    my $gene = $2;
    my $description = $3;
	
    return {
        gene        => $gene,
        locus_id    => $locus_id,
        description => $description,
    };
}

open (my $fh, $desc_file) || die ("\nERROR: the file $desc_file could not be found\n");
while (my $line = <$fh>) {
	chomp($line);
	my $doc = parse_file($line);
	$lucy->add_doc($doc);
}


