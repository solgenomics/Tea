package Tea::Controller::Expression_viewer_ajax;

=head1 AUTHOR

Noe Fernandez

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use Moose;
use JSON;
use Bio::Seq;
use Bio::SeqIO;
use Bio::BLAST::Database;
use File::Temp qw | tempfile |;
use Lucy::Simple;
use Array::Utils qw(:all);
use Data::Dumper;

# use Time::HiRes qw( time );

use DBIx::Class;
use strict;
use warnings;
use Tea::Schema;
use DBI;

use Tea::Controller::Expression_viewer_functions;

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
    default => 'application/json',
    stash_key => 'rest',
    map => { 'application/json' => 'JSON', 'text/html' => 'JSON' },
   );

our %urlencode;

=head2 get_stages

get selected info on input and return parent-children info back to input

ARGS: selected project, organ, stage and tissue
Returns: organ, stage and tissue HTML options

=cut

sub get_genes :Path('/expression_viewer/get_genes/') :Args(0) {
  my ($self, $c) = @_;
  
  # get variables from catalyst object
  my $project_id = $c->req->param("project_id");
  
  #connect to database
  my $dbname = $c->config->{dbname};
  my $host = $c->config->{dbhost};
  my $username = $c->config->{dbuser};
  my $password = $c->config->{dbpass};

  my $schema = Tea::Schema->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  
  # get DBIx project resultset
  my $project_rs = $schema->resultset('Project')->search({project_id => $project_id})->single;
  
  my $loci_and_desc_path = $c->config->{loci_and_description_index_path};
  $loci_and_desc_path .= "/".$project_rs->indexed_dir;
  
  my @genes_array;
  
  my $searcher = Lucy::Search::IndexSearcher->new(
      index => $loci_and_desc_path
  );

  my $all_genes = $searcher->hits(
      query => Lucy::Search::MatchAllQuery->new,
      num_wanted => 200000,
  );
  
  # my $counter = 0;
  while ( my $hit = $all_genes->next ) {
    push(@genes_array,$hit->{gene});
    
    # print $hit->{gene}."\n";
    # $counter++;
  }
  
  # print "$counter\n";
  
  $c->stash->{rest} = {
      project_genes => \@genes_array
  };
  
}

=head2 get_stages

get selected info on input and return parent-children info back to input

ARGS: selected project, organ, stage and tissue
Returns: organ, stage and tissue HTML options

=cut

sub get_stages :Path('/expression_viewer/get_stages/') :Args(0) {
  my ($self, $c) = @_;
  
  # my $start = time();
  
  # to store erros as they may happen
  my @errors; 

  # get variables from catalyst object
  my $project_id = $c->req->param("project_id");
  
  # get organ, stage and tissue names
  my @organ_names = $c->req->param("organs[]");
  my @stage_names = $c->req->param("stages[]");
  my @tissue_names = $c->req->param("tissues[]");
  my @condition_names = $c->req->param("conditions[]");
  
  #connect to database
  my $dbname = $c->config->{dbname};
  my $host = $c->config->{dbhost};
  my $username = $c->config->{dbuser};
  my $password = $c->config->{dbpass};

  my $schema = Tea::Schema->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  
  # variables to save the HTML formatted output
  
  my $db_funct = Tea::Controller::Expression_viewer_functions->new();
  
  # getting all the figures from the project
  my $all_figure_rs = $schema->resultset('Figure')->search({project_id => $project_id});
  
  my ($organ_arrayref,$stage_arrayref,$tissue_arrayref,$condition_arrayref) = $db_funct->get_input_options($schema,$all_figure_rs);
  
  # format layers to select options
  my $organ_options_arrayref = $db_funct->names_array_to_option($organ_arrayref);
  my $stage_options_arrayref = $db_funct->names_array_to_option($stage_arrayref);
  my $tissue_options_arrayref = $db_funct->names_array_to_option($tissue_arrayref);
  my $condition_options_arrayref = $db_funct->names_array_to_option($condition_arrayref);
  
  my $organ_options = join("\n", @$organ_options_arrayref);
  my $stage_options = join("\n", "@$stage_options_arrayref");
  my $tissue_options = join("\n", "@$tissue_options_arrayref");
  my $condition_options = join("\n", "@$condition_options_arrayref");
  
  # print STDERR "condition_options: $condition_options\n";
  
  $c->stash->{rest} = {
    organs => $organ_options,
    stages => $stage_options,
    tissues => $tissue_options,
    conditions => $condition_options,
  };
  
}

=head2 run_blast

Run blast from expression viewer input and return results to same page using ajax
ARGS: input sequence
Returns: BLAST results

=cut

sub run_blast :Path('/expression_viewer/blast/') :Args(0) {
  my ($self, $c) = @_;
  
  # to store erros as they may happen
  my @errors; 

  # get variables from catalyst object
  my $params = $c->req->body_params();
  my $input_seq1 = $c->req->param("input_seq");
  my $project_id = $c->req->param("project_id");
  
  my $nt_blastdb_path = $c->config->{nt_blastdb_path};
  my $prot_blastdb_path = $c->config->{prot_blastdb_path};
  my $desc_path = $c->config->{loci_and_description_index_path};
  my $tmp_path = $c->config->{tmp_path};
  
  # connect to the db
  my $dbname = $c->config->{dbname};
  my $host = $c->config->{dbhost};
  my $username = $c->config->{dbuser};
  my $password = $c->config->{dbpass};

  my $schema = Tea::Schema->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  my $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  
  # get DBIx project resultset
  my $project_rs = $schema->resultset('Project')->search({project_id => $project_id})->single;
  
  $desc_path .= "/".$project_rs->indexed_dir;
  
  my ($input_name,$input_seq,$blast_program) = _parse_blast_input($input_seq1);
  
  # generate temporary file name for BLAST input.
  my ($seq_fh, $seq_filename) = tempfile("TEAseqXXXXX", DIR=> $tmp_path,);
  
  # create BLAST input file
  _create_blast_input_file($input_name,$input_seq,$seq_filename,$nt_blastdb_path);
  
  my ($res,$aln) = _run_blast_cmd($c,$blast_program,$params,$seq_filename,$nt_blastdb_path,$prot_blastdb_path,$desc_path);
  
  my $blast_table = join("\n", @$res);
  my $blast_alignment = join("<br>", @$aln);
  $blast_alignment =~ s/ /\&nbsp\;/g;
  
  $c->stash->{rest} = {blast_table => "$blast_table",
            blast_alignment => $blast_alignment,
  };
}

=head2 _parse_blast_input

filter input sequence and detects blast program (blastn or blastp)
ARGS: input sequence
Returns: filtered input, input name and blast program

=cut

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

=head2 _create_blast_input_file

Create input file for blast from gene id or pasted sequence
ARGS: gene is, input sequence, file name, path to blast db
Returns: write input file for blast

=cut

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

=head2 _run_blast_cmd

Run blast program and format output for HTML checkboxes in a table
ARGS: blast program, blast options, output file name, blast db path, description file path
Returns: HTML formatted blast results with check box and blast alignment

=cut

sub _run_blast_cmd {
	my $c = shift;
	my $blast_program = shift;
	my $params = shift;
	my $seq_filename = shift;
	my $nt_blastdb_path = shift;
	my $prot_blastdb_path = shift;
	my $desc_path = shift;
	my $blastdb_path = $nt_blastdb_path;
	
	my $hits = $c->req->param("blast_hits");
	my $blast_alignment = $c->req->param("blast_alignment");
	my $evalue = $c->req->param("blast_evalue");
	my $blast_filter = $c->req->param("blast_filter");
	my $filter_val = "T";
	my $blast_format = "8";
	
	if (!$blast_filter) {
		$filter_val = "F";
	}
	
	if ($blast_alignment) {
		$blast_format = "0";
	}
	
	if ($blast_program eq "blastp") {
		$blastdb_path = "$prot_blastdb_path";
	# } else {
	# 	$blastdb_path = "$nt_blastdb_path";
	}
	
	my $blast_cmd = "blastall -p $blast_program -i $seq_filename.fasta -d $blastdb_path -F $filter_val -e $evalue -m $blast_format -v $hits -b $hits -o $seq_filename.txt";
	my $blast_error = system($blast_cmd);
	print STDERR "$blast_cmd\n";

	my $aln_true = 0;
	my @aln_file;
	my @res;
	if ($blast_alignment) {
		push(@res, "<tr><th width='10'></th><th style=\"text-align: left;\">Subject</th><th>e val</th><th>Score</th><th style=\"text-align: left; padding-left: 10px;\">Description</th></tr>");
	} else {
		push(@res, "<tr><th width='10'></th><th style=\"text-align: left;\">Subject</th><th>Id \%</th><th>e val</th><th>Score</th><th style=\"text-align: left; padding-left: 10px;\">Description</th></tr>");
	}
	
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
				if ($blast_alignment) {
					
					if ($line =~ /^>/) {
						$aln_true = 1;
					}
					
					if ($line =~ /^Solyc/) {
						# my ($subject,$kk1,$kk2,$bitscore,$evalue) = split(/\s+/,$line);
						my @blast_m0 = split(/\s+/,$line);
						
						my $subject = $blast_m0[0];
						my $evalue = $blast_m0[-1];
						my $bitscore = $blast_m0[-2];
						
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
							push(@res, "$tr_type<td><input type=\"checkbox\" class=\"blast_checkbox\" onclick=resetSelectAll(); value=\"$subject\" name=\"input_gene\"></td><td style=\"text-align: left;\">$subject</td><td>$evalue</td><td>$bitscore</td><td style=\"text-align: left; padding-left: 10px;\">".$desc."</td></tr>");
						}
						
					} elsif ($aln_true) {
						push(@aln_file, "$line\n");
					} else {
						next;
					}
				} else {
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
						push(@res, "$tr_type<td><input type=\"checkbox\" class=\"blast_checkbox\" onclick=resetSelectAll(); value=\"$subject\" name=\"input_gene\"></td><td style=\"text-align: left;\">$subject</td><td>$identity</td><td>$evalue</td><td>$bitscore</td><td style=\"text-align: left; padding-left: 10px;\">".$desc."</td></tr>");
					}
				}
				
				if ($line =~ /Database\:/) {
					$aln_true = 0;
				}
				
			}
		} else {
			print STDERR "BLAST output does not exist\n";
			return;
		}
	}
	
	return (\@res,\@aln_file);
	# return \@res;
}

sub external_data_transfer :Path('/external_data_transfer') :Args(2) {
	my $self = shift;
	my $c = shift;
	my $data_source = shift;
	my $trial_id = shift;

	my $trial_name = $c->req->param('trial_name');
	my $export_type = $c->req->param('type');
	$trial_name =~ s/ //g;
	$trial_name =~ s/\s//g;

	my $dbname = $c->config->{dbname};
	my $host = $c->config->{dbhost};
	my $username = $c->config->{dbuser};
	my $password = $c->config->{dbpass};
	my $base_path = $c->config->{base_path};
	my $temp_path = $c->config->{tmp_path};
	my $correlation_index_dir = $c->config->{correlation_indexes_path};
	my $expression_index_dir = $c->config->{expression_indexes_path};
	my $description_index_dir = $c->config->{loci_and_description_index_path};

	my $data_source_url;
	my $data_loading_script;
	my $index_dir_prefix;
	if ($data_source eq 'cassbase'){
		$data_source_url = 'https://cassbase.org';
		$data_loading_script = "$base_path/cassbase/bin/cea_load.sh";
		$index_dir_prefix = "cass_index_";
	}
	$c->response->headers->header( "Access-Control-Allow-Origin" => $data_source_url );

	my @args = ($data_loading_script, $data_source_url, $trial_id, $base_path, $correlation_index_dir, $expression_index_dir, $description_index_dir, $temp_path, 'false', 'true', $host, $dbname, $username, $password, $index_dir_prefix.$trial_name, $export_type, $trial_name);
	#print STDERR Dumper \@args;
	system('bash', @args) == 0
		or die "system @args failed: $?";

	$c->stash->{rest} = { success => 1 };
}



1;
