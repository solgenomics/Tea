#!/usr/bin/perl

=head1 NAME

 TEA_import_project_metadata.pl
 script to import metadata to the SGN Tomato Expression Atlas (TEA)


=head1 SYPNOSIS

 TEA_import_project_metadata.pl -d <dbname> -H <host> -u <user> -p <password> -i <TEA_project_input_template.txt> -f <path_to_image_files>


=head1 DESCRIPTION

 Using the information from the template file TEA_project_input_template.txt,
 this script will fill out in the database the metadata of the expression project.
 It will insert information and image file names for organisms, projects, experiments, organs, stages,
 tissues and possible tratments.

=head1 AUTHOR

  Noe Fernandez-Pozo
  nf232@cornell.edu

=cut


use strict;
use warnings;
use DBIx::Class;
use Tea::Schema;
use Getopt::Std;


sub help {
  print STDERR <<EOF;
  $0:

  Using the information from the template file TEA_project_input_template.txt,
  this script will insert in the database the metadata of the expression project.
  It will insert information and image file names for organisms, projects, experiments, organs, stages,
  tissues and possible tratments.


    Usage:
       
       TEA_import_project_metadata.pl -d <db_name> -H <host> -u <user_name> -p <password> -t <template_file> -i <image_files_path>

    Mandatory options:

      -d <db_name>                 Database name
      -H <host>                    Database host
      -u <user_name>               Database user
      -p <password>                Database password
      -t <template_file>           TEA metadata template TEA_project_input_template.txt
      -i <image_files_path>        Path to directory containing image_files
    
    Other options:
      
      -h                           Print this help
      
      
    Example:
      
      TEA_import_project_metadata.pl -d expression_db -H localhost -u postgres -p 'password' -t TEA_project_input_template.txt -i expr_viewer/images


EOF
exit (1);
}

our ($opt_d, $opt_u, $opt_p, $opt_t, $opt_i, $opt_H, $opt_h);
getopts("d:u:p:t:i:H:h");

if (!$opt_i || !$opt_t) {
    print "Input data missing:\n";
    print "To import the metadata to the database you must provide\n";
    print "the SGN TEA template file and the path to the images\n\n";
    help();
}
if (!$opt_d || !$opt_u || !$opt_p || !$opt_H) {
    print "Database info missing:\n";
    print "To import the metadata to the database you must provide\n";
    print "database name, host, user and password\n\n";
    help();
}
if ($opt_h) {
    help();
}


my $dbname = $opt_d;
my $host = $opt_H;
my $username = $opt_u;
my $password = $opt_p;

my $input_file = $opt_t;
my $path_to_img = $opt_i;

my $schema = Tea::Schema->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");

my ($organism_species,$organism_variety,$organism_id,$organism_description);
my ($project_id,$project_name,$project_contact,$project_description,$indexed_dir,$expr_unit);
my ($experiment_name,$experiment_description,$experiment_id);
my ($layer_name,$layer_description,$bg_color,$layer_type,$layer_image,$img_width,$img_height,$cube_ordinal,$img_ordinal,$parent_id);


open (my $info_fh, "<", $input_file) or die("Input file not found");

# Start a transaction. Every database change from here on will only be
# committed into the database if the try block succeeds.
use Try::Tiny;
my $exception;
try {
  $schema->txn_do(sub {
    # SQL: BEGIN;

    while (my $line = <$info_fh>) {
      chomp($line);

      # lets fill out the organism table
      if ($line =~ /^organism_species:\s*(.+)\s*/) {
          $organism_species = $1;
      }

      if ($line =~ /^organism_variety:\s*(.+)\s*/) {
          $organism_variety = $1;
      }
      
      if ($line =~ /^organism_description:\s*(.+)\s*/) {
          $organism_description = $1;
      }
      
      if ($line =~ /^\#\s*organism\s*-\s*end/) {
      
          my $organism_all_rs = $schema->resultset('Organism');
          my $organism_rs = $schema->resultset('Organism')->single({
            species => $organism_species,
            variety => $organism_variety,
          });
          
          if (!$organism_rs || !$organism_rs->species) {
            print "Organism $organism_species $organism_variety DOES NOT EXIST on the database!\n\n";
            print "Create? [Y|n]> ";

            if (<STDIN> !~ m/no*/i) {
              $organism_rs = $schema->resultset('Organism')->find_or_new({
                  species => $organism_species,
                  variety => $organism_variety,
              });
        
              if ($organism_rs->in_storage) {
                  print "this organism is already in the database\n";
                  print_one_row($organism_rs);
              }
              else {
                  check_commit($organism_rs,$organism_all_rs,"Organism");
              }
          
              print "commited.\n";
            } else {
              print  "Not commited. Exiting\n";
              exit;
            }
          }
          $organism_id = $organism_rs->organism_id;
      } # organism end
      
      # lets fill out the project table
      if ($line =~ /^project_name:\s*(.+)\s*$/) {
          $project_name = $1;
      }
      if ($line =~ /^project_contact:\s*(.+)\s*$/) {
          $project_contact = $1;
      }
      if ($line =~ /^project_description:\s*(.+)\s*$/) {
          $project_description = $1;
      }
      if ($line =~ /^expr_unit:\s*(.+)\s*$/) {
          $expr_unit = $1;
      }
      if ($line =~ /^index_dir_name:\s*(.+)\s*$/) {
          $indexed_dir = $1;
      }
      if ($line =~ /^\#\s*project\s*-\s*end/) {
          my $project_all_rs = $schema->resultset('Project');
          my $project_rs = $schema->resultset('Project')->find_or_new({
              name => $project_name,
              contact => $project_contact,
              description => $project_description,
              expr_unit => $expr_unit,
              organism_id => $organism_id,
              indexed_dir => $indexed_dir,
          });
          if ($project_rs->in_storage) {
              print "this project is already in the database\n";
              print_one_row($project_rs);
          }
          else {
              check_commit($project_rs,$project_all_rs,"Project");
          }
          $project_id = $project_rs->project_id;
      } # project end
      
      
      
      
      
      # lets fill out the experiment table
      
      #START EXPERIMENT OPEN
      if ($line =~ /^\#\s*experiment/i) {
          $experiment_name = "";
          $experiment_description = "";
          $experiment_id = 0;
          $layer_name = "";
          $layer_description = "";
          $layer_type = "";
          $bg_color = "";
          $layer_image = "";
          $img_width = 0;
          $img_height = 0;
          $cube_ordinal = 0;
          $img_ordinal = 0;
          $parent_id = 0;
      }
      
      if ($line =~ /^experiment_name:\s*(.+)\s*$/) {
          $experiment_name = $1;
      }
      if ($line =~ /^experiment_description:\s*(.+)\s*$/) {
          $experiment_description = $1;
      }
      
      if ($line =~ /^\#\s*write\s*experiment\s*metadata/i) {

          # lets fill out the experiment table
          my $experiment_all_rs = $schema->resultset('Experiment');
          my $experiment_rs = $schema->resultset('Experiment')->find_or_new({
              name => $experiment_name,
              description => $experiment_description,
              project_id => $project_id,
          });
          
          if ($experiment_rs->in_storage) {
              print "this experiment is already in the database\n";
              print_one_row($experiment_rs);
          }
          else {
              check_commit($experiment_rs,$experiment_all_rs,"Experiment");
          }
          # print "experiment_id1: ".$experiment_rs->experiment_id."\n";
          $experiment_id = $experiment_rs->experiment_id;
      } # write experiment metadata
      
      
      
      # lets fill out the layer tables
      my $layer_rs;
      if ($line =~ /^layer_name:\s*(.+)\s*$/) {
          $layer_name = $1;
      }
      if ($line =~ /^layer_description:\s*(.+)\s*$/) {
          $layer_description = $1;
      }
      if ($line =~ /^layer_type:\s*(.+)\s*$/) {
          $layer_type = $1;
      }
      if ($line =~ /^bg_color:\s*(.+)\s*$/) {
          $bg_color = $1;
      }
      if ($line =~ /^layer_image*:\s*(.+)\s*$/) {
          $layer_image = $1;
      }
      if ($line =~ /^image_width*:\s*(\d+)\s*$/) {
          $img_width = $1;
      }
      if ($line =~ /^image_height*:\s*(\d+)\s*$/) {
          $img_height = $1;
      }
      if ($line =~ /^cube_ordinal*:\s*(\d+)\s*$/) {
          $cube_ordinal = $1;
      }
      if ($line =~ /^img_ordinal*:\s*(\d+)\s*$/) {
          $img_ordinal = $1;
      }
      if ($line =~ /^\#\s*layer\s*-\s*end/) {
          
        # checking the layer type
        my $layer_type_all_rs = $schema->resultset('LayerType');
        my $layer_type_rs = $schema->resultset('LayerType')->single({layer_type => $layer_type});
    
        if (!$layer_type_rs || !$layer_type_rs->layer_type_id) {
            print "Layer type $layer_type DOES NOT EXIST on the database!\n\n";
            print "Create? [Y|n]> ";
  
            if (<STDIN> !~ m/no*/i) {
                $layer_type_rs = $schema->resultset('LayerType')->new({
                    layer_type => $layer_type,
                });
                
                check_commit($layer_type_rs,$layer_type_all_rs,$layer_type);
                
                print "commited.\n";
            } else {
                print  "Not commited. Exiting\n";
                exit;
            }
        }
        
        my $layer_info_all_rs = $schema->resultset('LayerInfo');
        my $layer_info_rs = $schema->resultset('LayerInfo')->find_or_new({
            name => $layer_name,
            description => $layer_description,
            bg_color => $bg_color,
        });
        
        if ($layer_info_rs->in_storage) {
            print "the layer info for $layer_name is already in the database\n";
            print_one_row($layer_info_rs);
        }
        else {
          $layer_info_rs = $schema->resultset('LayerInfo')->new({
              name => $layer_name,
              description => $layer_description,
              bg_color => $bg_color,
          });
          check_commit($layer_info_rs,$layer_info_all_rs,$layer_type);
        }
        
        
        if (!$parent_id) {
          $parent_id = 1;
        }
        
        $layer_rs = $schema->resultset('Layer')->find_or_new({
            image_file_name => $layer_image,
            layer_type_id => $layer_type_rs->layer_type_id,
            layer_info_id => $layer_info_rs->layer_info_id,
            parent_id => $parent_id,
            image_width => $img_width,
            image_height => $img_height,
            cube_ordinal => $cube_ordinal,
            img_ordinal => $img_ordinal,
        });
        
        my $layer_all_rs = $schema->resultset('Layer');
        
        if ($layer_rs->in_storage) {
            print "the layer for $layer_image is already in the database\n";
            print_one_row($layer_rs);
        }
        else {
            print "the layer for $layer_image was not found in the database\n";
            $layer_rs = $schema->resultset('Layer')->new({
                image_file_name => $layer_image,
                layer_type_id => $layer_type_rs->layer_type_id,
                layer_info_id => $layer_info_rs->layer_info_id,
                parent_id => $parent_id,
                image_width => $img_width,
                image_height => $img_height,
                cube_ordinal => $cube_ordinal,
                img_ordinal => $img_ordinal,
            });
            check_commit($layer_rs,$layer_all_rs,$layer_type);
        }
        
        # update parent_id for organ and set parent id for stage
        if ($layer_type eq "organ") {
          $parent_id = $layer_rs->layer_id;
          $layer_rs->parent_id($parent_id);
          $layer_rs->update;
        }
        # set the organ as the stage parent_id and then set the parent_id as the stage id for the tissue layers
        if ($layer_type eq "stage") {
          $parent_id = $layer_rs->layer_id;
        }
        
        # update parent_id for the tissue layers
        if ($layer_type eq "tissue" || $layer_type eq "condition") {
          $layer_rs->parent_id($parent_id);
          $layer_rs->update;
        }
        
        # print "experiment_id2: $experiment_id\n";
        
        my $experiment_layer_all_rs = $schema->resultset('ExperimentLayer');
        my $experiment_layer_rs = $schema->resultset('ExperimentLayer')->find_or_new({
            experiment_id => $experiment_id,
            layer_id => $layer_rs->layer_id,
        });
  
        if ($experiment_layer_rs->in_storage) {
            print "this experiment layer is already in the database\n";
            print_one_row($experiment_layer_rs);
        }
        else {
            check_commit($experiment_layer_rs,$experiment_layer_all_rs,"ExperimentLayer");
        }
        
        $layer_description = "";
        $bg_color = "";
        
      } # layer end
      
      
    } # while end
  }); # end txn
} catch {
    $exception = $_;
};

if ($exception) {
print "ERROR. There was an error while importing the data. Rolling back all changes\n$exception\n";
}
else {
print "All data commited\n";
}

sub print_one_row {
    my $rs = shift;
    
    my @cols = $rs->result_source->columns;
    
    foreach my $col (@cols) {
        if ($rs->$col) {
            print "$col: ".$rs->$col."\n";
        }
    }
    print "\n";
}

sub print_table_data {
    my $rs = shift;
    
    my @cols = $rs->result_source->columns;
    
    print join("\t|\t",@cols)."\n";
    
    while(my $rs_i = $rs->next) {
        foreach my $col (@cols) {
            print $rs_i->$col."\t\t";
        }
        print "\n";
    }
}

sub check_commit {
    my $rs = shift;
    my $all_rs = shift;
    my $data_type = shift;
    
    print "Please check if your -- $data_type -- entry is similar to any one from the database:\n\n";
    print_table_data($all_rs);
    
    print "\nyour new - $data_type - data:\n";
    print_one_row($rs);
    
    print "Commit? [Y|n]> ";
  
    if (<STDIN> !~ m/no*/i) {
        $rs->insert();
    
        print "commited.\n\n\n\n\n";
    } else {
        print  "Not commited. Exiting\n";
        exit;
    }
}

