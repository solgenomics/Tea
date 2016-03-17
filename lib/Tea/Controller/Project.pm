package Tea::Controller::Project;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Tea::Controller::Overview - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut


sub index :Path('/project_page/') :Args(0) {
    my ( $self, $c ) = @_;
    
    my $project_id = $c->req->param('project_id');
        
    my $dbname = $c->config->{dbname};
    my $host = $c->config->{dbhost};
    my $username = $c->config->{dbuser};
    my $password = $c->config->{dbpass};

    my $schema = Tea::Schema->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
    my $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;", "$username", "$password");
    
    # print "project_id: $project_id\n";
    
    my $project_rs = $schema->resultset('Project')->search({project_id => $project_id})->single;
    my $organism_rs = $schema->resultset('Organism')->search({organism_id => $project_rs->organism_id})->single;
    
    # print "NAME: ".$project_rs->name."\n";
    
    my $experiment_ids = _get_ids_from_query($schema,"Experiment",[$project_id],"project_id","experiment_id");
    my $project_layer_ids = _get_ids_from_query($schema,"ExperimentLayer",$experiment_ids,"experiment_id","layer_id");
    
    my $organ_ids = _filter_layer_type($schema,$project_layer_ids,"organ","layer_id");
    my $stage_ids = _filter_layer_type($schema,$project_layer_ids,"stage","layer_id");
    my $tissue_ids = _filter_layer_type($schema,$project_layer_ids,"tissue","layer_id");
    
    my ($organ_names,$organ_descriptions,$organ_images,$organ_ordinal) = _get_layer_info($schema,$organ_ids);
    my ($stage_names,$stage_descriptions,$stage_images,$stage_ordinal) = _get_layer_info($schema,$stage_ids);
    my ($tissue_names,$tissue_descriptions,$tissue_images,$tissue_ordinal) = _get_layer_info($schema,$tissue_ids);
    
    my $html_descriptions = _get_html_descriptions($organ_names,$organ_descriptions,$stage_names,$stage_descriptions,$tissue_names,$tissue_descriptions,$organ_ordinal,$stage_ordinal,$tissue_ordinal);
    
    
    my @exp_tables;
    
    foreach my $exp_ids (@{$experiment_ids}) {
    
      my $layer_ids = _get_ids_from_query($schema,"ExperimentLayer",[$exp_ids],"experiment_id","layer_id");
    
      my $html_exp_table = _get_html_table($layer_ids,$organ_names,$organ_images,$stage_names,$stage_images,$tissue_names,$tissue_images,$schema);
      push(@exp_tables,$html_exp_table);
    }
    
    $c->stash(exp_tables => join("\n",@exp_tables));
    $c->stash(layer_description => $html_descriptions);
    
    $c->stash(organism => $organism_rs->species." ".$organism_rs->variety);
    $c->stash(organism_description => $organism_rs->description);
    $c->stash(project_name => $project_rs->name);
    $c->stash(project_description => $project_rs->description);
    $c->stash(project_contact => $project_rs->contact);
    $c->stash(template => 'project.mas');
}

sub _get_layer_info {
  my $schema = shift;
  my $layer_ids = shift;
  
  my %layer_names;
  my %layer_descriptions;
  my %layer_images;
  my %layer_ordinal;
  
  foreach my $layer_id (@{$layer_ids}) {
    my $layer_rs = $schema->resultset('Layer')->search({layer_id => $layer_id})->single;
    my $image_name = $layer_rs->image_file_name;
    my $ordinal = $layer_rs->ordinal;
    
    my $layer_info_rs = $schema->resultset('LayerInfo')->search({layer_info_id => $layer_rs->layer_info_id})->single;
    my $layer_name = $layer_info_rs->name;
    my $layer_description = $layer_info_rs->description;
    
    $layer_names{$layer_id} = $layer_name;
    $layer_descriptions{$layer_id} = $layer_description;
    $layer_images{$layer_id} = $image_name;
    $layer_ordinal{$ordinal} = $layer_id;
  }
  
  return (\%layer_names,\%layer_descriptions,\%layer_images,\%layer_ordinal);
}


sub _get_html_descriptions {
  my $organ_names = shift;
  my $organ_descriptions = shift;
  my $stage_names = shift;
  my $stage_descriptions = shift;
  my $tissue_names = shift;
  my $tissue_descriptions = shift;
  my $organ_ordinal = shift;
  my $stage_ordinal = shift;
  my $tissue_ordinal = shift;
  
  my @html;
  
  push (@html,"<table style=\"width:100%;\"><tr><th>Organ</th></tr>");
  foreach my $ordinal (sort keys %{$organ_ordinal}) {
    my $name = $organ_names->{$organ_ordinal->{$ordinal}};
    my $description = $organ_descriptions->{$organ_ordinal->{$ordinal}};
    if ($name) {
      push (@html,"<tr><td>".$name."</td><td>".$description."</td></tr>");
    }
  }
  
  push (@html,"<tr><td>&nbsp;</td></tr><tr><th>Stages</th></tr>");
  foreach my $ordinal (sort keys %{$stage_ordinal}) {
    my $name = $stage_names->{$stage_ordinal->{$ordinal}};
    my $description = $stage_descriptions->{$stage_ordinal->{$ordinal}};
    if ($name) {
      push (@html,"<tr><td>".$name."</td><td>".$description."</td></tr>");
    }
  }
  
  push (@html,"<tr><td>&nbsp;</td></tr><tr><th>Tissues</th></tr>");
  foreach my $ordinal (sort keys %{$tissue_ordinal}) {
    my $name = $tissue_names->{$tissue_ordinal->{$ordinal}};
    my $description = $tissue_descriptions->{$tissue_ordinal->{$ordinal}};
    if ($name) {
      push (@html,"<tr><td>".$name."</td><td>".$description."</td></tr>");
    }
  }
  
  push (@html,"</table>");
  
  return join("\n",@html);
}


sub _get_html_table {
  my $layer_ids = shift;
  my $organ_names = shift;
  my $organ_images = shift;
  my $stage_names = shift;
  my $stage_images = shift;
  my $tissue_names = shift;
  my $tissue_images = shift;
  my $schema = shift;
  
  my @html;
  
  my %layer_ordinal;
  
  foreach my $layer_id (@{$layer_ids}) {
    my $layer_rs = $schema->resultset('Layer')->search({layer_id => $layer_id})->single;
    # if ($layer_rs->ordinal) {
      $layer_ordinal{$layer_rs->ordinal} = $layer_id;
    # }
  }
  
  
  push (@html,"<table class=\"project_imgs\"><tr>");
  
  # foreach my $layer_id (@{$layer_ids}) {
  
  foreach my $layer_id (@{$layer_ids}) {
    if ($organ_names->{$layer_id}) {
      push (@html,"<th>".$organ_names->{$layer_id}."</th>");
      
    }
  }
  foreach my $layer_id (@{$layer_ids}) {
    if ($stage_names->{$layer_id}) {
      push (@html,"<th>".$stage_names->{$layer_id}."</th>");
      
    }
  }
  
  foreach my $ordinal (sort keys %layer_ordinal) {
    my $layer_id = $layer_ordinal{$ordinal};
    if ($tissue_names->{$layer_id}) {
      push (@html,"<th>".$tissue_names->{$layer_id}."</th>");
    }
  }
  push (@html,"</tr><tr>");
  
  foreach my $ordinal (sort keys %layer_ordinal) {
    my $layer_id = $layer_ordinal{$ordinal};
    if ($organ_images->{$layer_id}) {
      push (@html, "<td><img src=\"/static/images/expr_viewer/".$organ_images->{$layer_id}."\" width=\"100\"></td>\n");
    }
  }
  foreach my $layer_id (@{$layer_ids}) {
    if ($stage_images->{$layer_id}) {
      push (@html, "<td><img src=\"/static/images/expr_viewer/".$stage_images->{$layer_id}."\" width=\"100\"></td>\n");
    }
  }
  
  foreach my $ordinal (sort keys %layer_ordinal) {
    my $layer_id = $layer_ordinal{$ordinal};
    if ($tissue_images->{$layer_id}) {
      push (@html, "<td><img src=\"/static/images/expr_viewer/".$tissue_images->{$layer_id}."\" width=\"100\"></td>\n");
    }
  }
  
  push (@html,"</tr></table><br><br>");
  
  return join("\n",@html);
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
      if ($n->$column_name eq $sps) {
        $res_ids{$n->$column_id} = 1;
      }
    }
  }
  my @res_ids;
  if ($column_id =~ /id/) {
    @res_ids = sort {$a <=> $b} keys %res_ids;
  } else {
    # for my $key (sort {$a <=> $b} keys %res_ids) {
    #   push(@res_ids, $res_ids{$key});
    # }
    
    @res_ids = sort keys %res_ids;
  }
  
  return \@res_ids;
}

sub _filter_layer_type {
  my $schema = shift;
  my $layer_ids = shift;
  my $layer_type = shift;
  my $return_column = shift;
  
  my %res_ids;
  
  my $layer_type_rs = $schema->resultset('LayerType')->search({layer_type => "$layer_type"})->single;
  
  my $all_rs = $schema->resultset("Layer");
  while(my $n = $all_rs->next) {
    if ($n->layer_type_id eq $layer_type_rs->layer_type_id) {
      foreach my $sps (@{$layer_ids}) {
        if ($n->layer_id eq $sps) {
          $res_ids{$sps} = $n->$return_column;
        }
      }
    }
  }
  my @res_ids;
  for my $key (sort {$a <=> $b} keys %res_ids) {
    push(@res_ids, $res_ids{$key});
  }

  return \@res_ids;
}

=encoding utf8

=head1 AUTHOR

noe,,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
