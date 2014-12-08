package Tea::Controller::Expression_viewer_ajax;

use Moose;
use JSON;
use Bio::Seq;
use Bio::SeqIO;
use Bio::BLAST::Database;
use File::Temp qw | tempfile |;
use Lucy::Simple;

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
    default => 'application/json',
    stash_key => 'rest',
    map => { 'application/json' => 'JSON', 'text/html' => 'JSON' },
   );

our %urlencode;


sub run_blast :Path('/Expression_viewer/blast/') :Args(0) {
    my ($self, $c) = @_;
    
    # to store erros as they may happen
    my @errors; 
 
    # get variables from catalyst object
    my $params = $c->req->body_params();
	my $input_seq1 = $c->req->param("input_seq");
	my $nt_blastdb_path = $c->config->{nt_blastdb_path};
	my $prot_blastdb_path = $c->config->{prot_blastdb_path};
	my $desc_path = $c->config->{description_index_path};
	my $tmp_path = $c->config->{tmp_path};
	
	my ($input_name,$input_seq,$blast_program) = _parse_blast_input($input_seq1);
	
	# generate temporary file name for BLAST input.
	my ($seq_fh, $seq_filename) = tempfile("TEAseqXXXXX", DIR=> $tmp_path,);
	
	# create BLAST input file
	_create_blast_input_file($input_name,$input_seq,$seq_filename,$nt_blastdb_path);
	
	my $res = _run_blast_cmd($blast_program,$seq_filename,$nt_blastdb_path,$prot_blastdb_path,$desc_path);
	
	my $blast_table = join("\n", @$res);
	$c->stash->{rest} = {msg => "$blast_table"};
}

sub _parse_blast_input {
	my $input = shift;
	
	# strip gene name
	$input =~ s/^\s+//;
	$input =~ s/\s+$//;
	
	my $valid_nt = 0;
	my $blast_prog = "blastn";
	my $input_name = "";
	
	if ($input =~ />/) {
		# fasta sequences
		
		my @lines = split("\n",$input);
		if ($lines[0] =~ />/) {
			$input_name = shift(@lines);
			$input_name =~ s/>//;
			$input_name =~ s/[\|\s\,\-\.\#\(\)\%\'\"\[\]\{\}\:\;\=\+\\\/]+/_/gi;
			
			$input = join "", @lines;
			$input =~ s/[\n\s\,\-\.\#\(\)\%\'\"\[\]\{\}\:\;\=\+\\\/]+//gi;
		}
		foreach my $line (@lines) {
			if ($line !~ />/) {
				$valid_nt += $line=~ tr/acgtACGTNn /acgtACGTNn /;
			}
		}
		
	} else {
		if ($input =~ /Solyc/i) {
			# Solyc Ids
			$blast_prog = "blastn";
			
			$input =~ s/\.\d$//;
			$input =~ s/\.\d$//;
		} else {
			# sequence with not Id
			$input =~ s/[\n\s\d\,\-\.\#\(\)\%\'\"\[\]\{\}\:\;\=\+\\\/]+//gi;
			$input_name = "input_seq";
			$valid_nt += $input=~ tr/acgtACGTNn /acgtACGTNn /;
		}
	}
	
	if ($input !~ /^Solyc/) {
		if ($valid_nt >= length($input)*0.9) {
			$blast_prog = "blastn";
		} else {
			$blast_prog = "blastp";
		}
		# print "valid_nt: $valid_nt, input length: ".length($input)."\n";
	}
	return ($input_name,$input,$blast_prog);
}


sub _create_blast_input_file {
	my $id = shift;
	my $input_seq = shift;
	my $file_name = shift;
	my $nt_blastdb_path = shift;
	
	# get sequence for Solyc id
	if ($input_seq =~ /Solyc/i) {
		my $fs = Bio::BLAST::Database->open(full_file_basename => "$nt_blastdb_path",);
		if ($fs->get_sequence($input_seq)) {
			my $seq_obj = $fs->get_sequence($input_seq);
			$input_seq = $seq_obj->seq();
		}
	}
	
	# Lets create the BLAST input fasta file
	my $seq = Bio::Seq->new(-seq=>$input_seq, -id=> $id || "temp");
	my $io = Bio::SeqIO->new(-format=>'fasta', -file=>">".$file_name.".fasta");
	$io->write_seq($seq);
	$io->close();

	if (! -e $file_name.".fasta") { die "BLAST input file failed to be created."; }
	
}


sub _run_blast_cmd {
	my $blast_program = shift;
	my $seq_filename = shift;
	my $nt_blastdb_path = shift;
	my $prot_blastdb_path = shift;
	my $desc_path = shift;
	my $blastdb_path = $nt_blastdb_path;
	
	if ($blast_program eq "blastp") {
		$blastdb_path = "$prot_blastdb_path";
	# } else {
	# 	$blastdb_path = "$nt_blastdb_path";
	}
	
	my $blast_cmd = "blastall -p $blast_program -i $seq_filename.fasta -d $blastdb_path -e 1e-3 -m 8 -v 50 -b 50 -o $seq_filename.txt";
	my $blast_error = system($blast_cmd);
	print STDERR "$blast_cmd\n";

	my @res;
	push(@res, "<tr><th width='10'></th><th>Subject</th><th>Id \%</th><th>e val</th><th>Score</th><th>Description</th></tr>");
	
	if ($blast_error) {
		print STDERR "blast_error: $blast_error\n";
		return;
	} else {
		my $lucy_desc = Lucy::Simple->new(
		    path     => $desc_path,
		    language => 'en',
		);
		
		my $blast_file = "$seq_filename.txt";
		
		if (-e $blast_file) {
			open (my $blast_fh, "<", $blast_file) || die ("\nERROR: the file ".$blast_file." could not be found\n");
			while (my $line = <$blast_fh>) {
				chomp($line);
				
				# print STDERR "$line\n";
				
				# split lines by tabs getting each column value in a variable
				my ($query,$subject,$identity,$alignment_length,$mismatch,$gapopen,$qstart,$qend,$sstart,$send,$evalue,$bitscore) = split("\t",$line);
				
				$subject =~ s/\.\d$//;
				$subject =~ s/\.\d$//;
	
				$lucy_desc->search(
				    query      => $subject,
					num_wanted => 1,
				);
	
				while ( my $desc_hit = $lucy_desc->next ) {
					my $desc = $desc_hit->{description};
					my $tr_type = "<tr>";
					if ($#res % 2 == 0) {
					} else {
						$tr_type = "<tr class='alt'>"
					}
					push(@res, "$tr_type<td><input type=\"checkbox\" class=\"blast_checkbox\" onclick=resetSelectAll(); value=\"$subject\" name=\"input_gene\"></td><td>$subject</td><td>$identity</td><td>$evalue</td><td>$bitscore</td><td>".$desc."</td></tr>");
				}
				
			}
		} else {
			print STDERR "BLAST output does not exist\n";
			return;
		}
	}
	
	return \@res;
}

=head1 AUTHOR

Noe Fernandez

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


1;