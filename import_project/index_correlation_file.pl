#!/usr/local/bin/perl

use strict;
use warnings;
use Lucy::Simple;
use File::Spec::Functions qw( catfile );
use Lucy::Plan::Schema;
use Lucy::Plan::FullTextType;


if (scalar(@ARGV) != 2) {
	print "Usage: perl index_corr_file.pl <correlation_file.txt> <output_dir_path>\n";
	exit;
}

my ($corr_file,$output_path) = @ARGV;

if (!-e $output_path) {
  `mkdir $output_path`;
}

my $schema = Lucy::Plan::Schema->new;

my $polyanalyzer = Lucy::Analysis::PolyAnalyzer->new(
    language => 'en',
);
my $type = Lucy::Plan::FullTextType->new(
    analyzer => $polyanalyzer,
    sortable => 1,      # default: false
	
);

$schema->spec_field( name => "correlation", type => $type );
$schema->spec_field( name => "gene1", type => $type );
$schema->spec_field( name => "gene2", type => $type );

my $indexer = Lucy::Index::Indexer->new(
    index    => $output_path,
    schema   => $schema,
    create   => 1,
);


# Parse a file and return a hashref with the fields title and content
sub parse_file {
    my $text = shift;
    $text =~ /^([^\t]+)\t([^\t]+)\t([^\t]+)/;

    my $gene1       = $1;
    my $gene2       = $2;
    my $correlation = $3;
	
    return {
        gene1       => $gene1,
        gene2       => $gene2,
        correlation => $correlation,
    };
}

open (my $fh, $corr_file) || die ("\nERROR: the file $corr_file could not be found\n");
while (my $line = <$fh>) {
	chomp($line);
	my $doc = parse_file($line);
	$indexer->add_doc($doc);
}
$indexer->commit;
