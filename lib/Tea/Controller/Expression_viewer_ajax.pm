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

use DBIx::Class;
use strict;
use warnings;
use Tea::Schema;
use DBI;

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
    default => 'application/json',
    stash_key => 'rest',
    map => { 'application/json' => 'JSON', 'text/html' => 'JSON' },
   );

our %urlencode;


sub get_stages :Path('/Expression_viewer/get_stages/') :Args(0) {
  my ($self, $c) = @_;
  
  # to store erros as they may happen
  my @errors; 

  # get variables from catalyst object
  # my $params = $c->req->body_params();
  my @organism_ids = $c->req->param("organisms");
  my @organ_ids = $c->req->param("organs");
  my @stage_ids = $c->req->param("stages");
  my @tissue_ids = $c->req->param("tissues");
  
  my $dbname = $c->config->{dbname};
  my $host = $c->config->{dbhost};
  my $username = $c->config->{dbuser};
  my $password = $c->config->{dbpass};

  my $schema = Tea::Schema->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  my $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
  
  # my @organism_ids;
  
  # get organism ids
  # my $all_rs = $schema->resultset("Organism");
  # while(my $n = $all_rs->next) {
  #   foreach my $sps (@organisms) {
  #     my ($species_name, $variety) = split("-",$sps);
  #
  #     if ($n->variety) {
  #       if ($n->species eq $species_name && $n->variety eq $variety) {
  #         push (@organism_ids,$n->organism_id);
  #       }
  #     }
  #     elsif ($n->species eq $species_name) {
  #       push (@organism_ids,$n->organism_id);
  #     }
  #   }
  # }
  
  my $project_ids = _get_ids_from_query($schema,"Project",\@organism_ids,"organism_id","project_id");
  my $experiment_ids = _get_ids_from_query($schema,"Experiment",$project_ids,"project_id","experiment_id");
  
  my @organ_options;
  my @stage_options;
  my @tissue_options;
  
  # only organism selected
  if ($organ_ids[0] || $stage_ids[0] || $tissue_ids[0]){
    print scalar(@organ_ids)."\n\n";
    print scalar(@stage_ids)."\n\n";
    print scalar(@tissue_ids)."\n\n";
  }
  else {
    
    my $layer_ids = _get_ids_from_query($schema,"ExperimentLayer",$experiment_ids,"experiment_id","layer_id");
    my $organ_ids = _filter_layer_type($schema,$layer_ids,"organ","layer_id");
    my $stage_ids = _filter_layer_type($schema,$layer_ids,"stage","layer_id");
    my $tissue_ids = _filter_layer_type($schema,$layer_ids,"tissue","layer_id");
    
    my $organ_options = _array_to_option($schema,$organ_ids);
    my $stage_options = _array_to_option($schema,$stage_ids);
    my $tissue_options = _array_to_option($schema,$tissue_ids);
    
    @organ_options = @{$organ_options};
    @stage_options = @{$stage_options};
    @tissue_options = @{$tissue_options};
    
  }

  
  
  # #layer ids for this experiment
  # my $layer_ids = _get_ids_from_query($schema,"ExperimentLayer",[$exp_id],"experiment_id","layer_id");
  #
  # # organ options
  # if (@organ_ids) {
  #   # experiment for these organs
  #   my $exp_ids = _get_ids_from_query($schema,"ExperimentLayer",\@organ_ids,"layer_id","experiment_id");
  #   my $layer_ids = _get_ids_from_query($schema,"ExperimentLayer",$exp_ids,"experiment_id","layer_id");
  #
  #   $organ_options = _array_to_option($schema,\@organ_ids);
  # }
  # else {
  #   $organ_ids = _filter_layer_type($schema,$layer_ids,"organ");
  #   $organ_options = _array_to_option($schema,$organ_ids);
  # }
  # # stage options
  # if (@stage_ids) {
  #   $stage_options = _array_to_option($schema,\@stage_ids);
  # }
  # else {
  #   $stage_ids = _filter_layer_type($schema,$layer_ids,"stage");
  #   $stage_options = _array_to_option($schema,$stage_ids);
  # }
  # #tissue options
  # if (@tissue_ids) {
  #   $tissue_options = _array_to_option($schema,\@tissue_ids);
  # }
  # else {
  #   $tissue_ids = _filter_layer_type($schema,$layer_ids,"tissue");
  #   $tissue_options = _array_to_option($schema,$tissue_ids);
  # }
  
  
  
  

  # my $organ_names = _get_ids_from_query($schema,"LayerInfo",$organ_ids,"layer_info_id","name");
  # my $organ_options = _array_to_option($organ_ids);
  #
  # my $stage_ids = _filter_layer_type($schema,$layer_ids,"stage");
  # my $stage_names = _get_ids_from_query($schema,"LayerInfo",$stage_ids,"layer_info_id","name");
  # my $stage_options = _array_to_option($stage_names);
  #
  # my $tissue_ids = _filter_layer_type($schema,$layer_ids,"tissue");
  # my $tissue_names = _get_ids_from_query($schema,"LayerInfo",$tissue_ids,"layer_info_id","name");
  # my $tissue_options = _array_to_option($tissue_names);
  
  print STDERR join("\n", "@organ_options")."\n";
  print STDERR join("\n", "@stage_options")."\n";
  print STDERR join("\n", "@tissue_options")."\n";
  
  my $organ_options = join("\n", "@organ_options");
  my $stage_options = join("\n", "@stage_options");
  my $tissue_options = join("\n", "@tissue_options");
  
  $c->stash->{rest} = {
    organs => $organ_options,
    stages => $stage_options,
    tissues => $tissue_options,
  };
}







sub _get_ids_from_query {
  my $schema = shift;
  my $table_name = shift;
  my $query = shift;
  my $column_name = shift;
  my $column_id = shift;
  
  my %res_ids;
  
  my $all_rs = $schema->resultset($table_name);
  while(my $n = $all_rs->next) {
  
    foreach my $sps (@{$query}) {
      
      # print STDERR "Sps: $sps\n";
      
      if ($n->$column_name eq $sps) {
        $res_ids{$n->$column_id} = 1;
        # print STDERR "------------- Sps: $sps\n";
        
      }
    }
  }
  my @res_ids;
  if ($column_id =~ /id/) {
    @res_ids = sort {$a <=> $b} keys %res_ids;
  } else {
    @res_ids = sort keys %res_ids;
  }
  
  return \@res_ids;
}

sub _filter_layer_type {
  my $schema = shift;
  my $layer_ids = shift;
  my $layer_type = shift;
  my $returned_column = shift;
  
  my %res_ids;
  
  my $layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "$layer_type"})->single;
  
  my $all_rs = $schema->resultset("Layer");
  while(my $n = $all_rs->next) {
    if ($n->layer_type_id eq $layer_type_rs->layer_type_id) {
      foreach my $sps (@{$layer_ids}) {
        if ($n->layer_id eq $sps) {
            $res_ids{$n->$returned_column} = 1;
        }
      }
    }
  }
  my @res_ids = sort {$a <=> $b} keys %res_ids;

  return \@res_ids;
}

sub _array_to_option {
  my $schema = shift;
  my $ids_arrayref = shift;
  
  my @res;
  my %res;
  
  foreach my $layer_id (@{$ids_arrayref}) {
    
    my $layer_info_ids = _get_ids_from_query($schema,"Layer",[$layer_id],"layer_id","layer_info_id");
    my $layer_names = _get_ids_from_query($schema,"LayerInfo",$layer_info_ids,"layer_info_id","name");
    
    $res{$layer_names->[0]} = $layer_id;
  }
  
  foreach my $name (sort(keys %res)) {
    push(@res,"<option value=\"$res{$name}\">".$name."</option>");
  }
  
  return \@res;
}


# sub _array_to_option {
#   my $array = shift;
#   my @res;
#
#   foreach my $e (@{$array}) {
#     push(@res,"<option value=\"$e\">$e</option>");
#   }
#   return \@res;
# }
#
#


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
  
  my ($res,$aln) = _run_blast_cmd($c,$blast_program,$params,$seq_filename,$nt_blastdb_path,$prot_blastdb_path,$desc_path);
  
  my $blast_table = join("\n", @$res);
  my $blast_alignment = join("<br>", @$aln);
  $blast_alignment =~ s/ /\&nbsp\;/g;
  
  $c->stash->{rest} = {blast_table => "$blast_table",
            blast_alignment => $blast_alignment,
  };
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



1;