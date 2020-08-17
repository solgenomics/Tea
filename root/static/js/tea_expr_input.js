$(document).ready(function () {

  //check input gene before sending form
  $('#search_gene').submit(function() {
    var gene_id = $('#gene_id_input').val();

    if (gene_id) {
      return true;
    } else {
      $('#no_gene_modal').modal();
      return false;
    }
  });

  //check input genes from BLAST output before sending form
  $('#blast_form').submit(function() {

    var check = $( "input[type=checkbox][name=input_gene]:checked" ).val();
    // alert("genes: "+check);

    if (check) {
      // alert("genes found");

      return true;
    } else {
      // alert("NO genes found");

      $('#no_gene_modal').modal();
      return false;
    }
  });

  //check input genes from custom list before sending form
  $('#custom_list_form').submit(function() {
    var custom_names = $('#custom_list').val();

    if (custom_names) {
      return true;
    } else {
      $('#no_gene_modal').modal();
      return false;
    }
  });


  //open BLAST info dialog
  $('#blast_i2').click(function () {
    $('#blast_help').modal();
    $('#blast_help').css("z-index","999999");
  });

	//open custom list input dialog
	$('#custom_input_box').click(function () {
    $('#custom_input_dialog').modal();
	});

	//open BLAST input dialog
  $('#blast_input_box').click(function () {
    $('#blast_input_dialog').modal();
  });


  function intialize_data(get_max,default_gene) {

    //first project selected by default
    $(".organism_col").first().attr("checked", "checked");
    var idSelector = function() { return this.value; };
    var dataset_list = jQuery(".organism_col:checked").map(idSelector).get();

    //get default project stages, tissues, etc
    load_wizard(dataset_list,null,null,null,null);

    //get default project gene names for autocomplete function and add default gene
    get_project_genes(dataset_list, default_gene);

    if (get_max) {
      get_max_expr(dataset_list);
    }

  }

  intialize_data(1,1);


  jQuery('.organism_col').click(function() {
    intialize_data(0,0);
  });


  jQuery('.wizard_select').change(function() {
    // AJAX communication to get stage, tissue ...
    var idSelector = function() { return this.value; };
    var dataset_list = jQuery(".organism_col:checked").map(idSelector).get();

    $( '.organism_filter' ).val(dataset_list);
    $( '.organ_filter' ).val( $( '#organ_part_col' ).val());
    $( '.stage_filter' ).val( $( '#stage_col' ).val());
    $( '.tissue_filter' ).val( $( '#tissue_col' ).val());
    $( '.condition_filter' ).val( $( '#condition_col' ).val());
  });


//update data sets when changing species
  jQuery('#sel1').change(function() {
    var selected_sps = $("#sel1").val();

    $.ajax({
      url: '/expression_viewer/get_datasets/',
      timeout: 600000,
      method: 'POST',
      data: { 'organism_id': selected_sps},
      success: function(response) {
        if (response.error) {
          alert("ERROR: "+response.error);
          // enable_ui();
        } else {
          $( "#organism_col" ).html( response.datasets );

          intialize_data(1,1);

          jQuery('.organism_col').click(function() {
            intialize_data(0,0);
          });

        }
      },
      error: function(response) {
        alert("An error occurred on the species selection menu request");
        // enable_ui();
      }
    });

  });


 // get array with the gene names from the project for the autocomplete function
  function get_max_expr(dataset_list){
    $.ajax({
      url: '/expression_viewer/get_max_expr/',
      timeout: 600000,
      method: 'POST',
      data: { 'project_id': dataset_list[0]},
      success: function(response) {
        if (response.error) {
          alert("ERROR: "+response.error);
          // enable_ui();
        } else {
          max_value = response.project_max_val;
          $( "#expr_amount" ).val( 1+" - "+max_value );
          $( "#expr_amount" ).val( $( "#expr_slider" ).slider( "values", 0 )+" - "+$( "#expr_slider" ).slider( "values", 1 ) );
          $( ".expr_min_scale" ).val( $( "#expr_slider" ).slider( "value", 0 ) );
          $( ".expr_max_scale" ).val( $( "#expr_slider" ).slider( "value", 1 ) );
          $( "#expr_slider" ).slider("option","max",max_value);
        }
      },
      error: function(response) {
        alert("An error occurred. The service may not be available right now.");
        // enable_ui();
      }
    });

  }


  function load_wizard(dataset_list,organ_list,stage_list,tissue_list,condition_list){

    $.ajax({
      url: '/expression_viewer/get_stages/',
      timeout: 600000,
      method: 'POST',
      data: { 'project_id': dataset_list[0], 'organs': organ_list, 'stages': stage_list, 'tissues': tissue_list, 'conditions': condition_list},
      success: function(response) {
        if (response.error) {
          alert("ERROR: "+response.error);
          // enable_ui();
        } else {
          // alert("stages: "+response.stages);
          $('#organ_part_col').html("");
          $('#stage_col').html("");
          $('#tissue_col').html("");
          $('#condition_col').html("");
          $('#organ_part_col').html(response.organs);
          $('#stage_col').html(response.stages);
          $('#tissue_col').html(response.tissues);
          $('#condition_col').html(response.conditions);

          for (layer_name in organ_list) {
            $("#"+organ_list[layer_name]).prop('selected', true);
          }
          for (layer_name in stage_list) {
            $("#"+stage_list[layer_name]).prop('selected', true);
          }
          for (layer_name in tissue_list) {
            // alert("layer_name: "+tissue_list[layer_name])
            $("#"+tissue_list[layer_name]).prop('selected', true);
          }
          for (layer_name in condition_list) {
            $("#"+condition_list[layer_name]).prop('selected', true);
          }

          $( '.organism_filter' ).val(dataset_list);
          $( '.organ_filter' ).val( $( '#organ_part_col' ).val());
          $( '.stage_filter' ).val( $( '#stage_col' ).val());
          $( '.tissue_filter' ).val( $( '#tissue_col' ).val());
          $( '.condition_filter' ).val( $( '#condition_col' ).val());
          // alert("ajax msg"+dataset_list)
        }
      },
      error: function(response) {
        alert("An error occurred. The service may not be available right now.");
        // enable_ui();
      }
    });

  }


	//AJAX communication to run BLAST
	$('#blast_button').click(function () {
		var blast_seq = $('#blast_sequence').val();
		var blast_hits = $('#blast_hits').val();
		var blast_evalue = $('#blast_eval').val();
		var blast_alignment = 0;
		var blast_filter = 0;

    var project_id = jQuery(".organism_col:checked").map(idSelector).get()[0];

		if ($('#blast_filter').is(":checked")) {
			blast_filter = 1;
		};
		if ($('#blast_alignment').is(":checked")) {
			blast_alignment = 1;
		};

		$.ajax({
			url: '/expression_viewer/blast/',
			timeout: 600000,
			method: 'POST',
			data: { 'input_seq': blast_seq, 'blast_hits': blast_hits, 'blast_alignment': blast_alignment, 'blast_evalue': blast_evalue, 'blast_filter': blast_filter, 'project_id': project_id },
			beforeSend: function(){
				// disable_ui();
			},
			success: function(response) {
				if (response.error) {
					alert("ERROR: "+response.error);
					// enable_ui();
				} else {
          $('#blast_input_dialog').modal("hide");

					$('#blast_res_table').html(response.blast_table);
          $('#blast_div_dialog').modal();

					if (blast_alignment) {
						$('#blast_aln_p').html(response.blast_alignment);
						$('#blast_aln_div').css('display','inline');
					}
				}
			},
			error: function(response) {
				alert("An error occurred. The service may not be available right now.");
				// enable_ui();
			}
		});
	});

  //select boxes for expression parameters Genotypes, Organs...
  $('.select_all').click(function(event) {
    $(this).parent().children().each(function() {
      $("option",this).prop('selected', true);
    });

    var idSelector = function() { return this.value; };
    var dataset_list = jQuery(".organism_col:checked").map(idSelector).get();
    var organ_list = jQuery( '#organ_part_col' ).val();
    var stage_list = jQuery( '#stage_col' ).val();
    var tissue_list = jQuery( '#tissue_col' ).val();
    var condition_list = jQuery( '#condition_col' ).val();

    // load_wizard(dataset_list,organ_list,stage_list,tissue_list);
  });

  $('.select_none').click(function(event) {
    $(this).parent().children().each(function() {
      $("option",this).prop('selected', false);
    });

    var idSelector = function() { return this.value; };
    var dataset_list = jQuery(".organism_col:checked").map(idSelector).get();
    var organ_list = jQuery( '#organ_part_col' ).val();
    var stage_list = jQuery( '#stage_col' ).val();
    var tissue_list = jQuery( '#tissue_col' ).val();
    var condition_list = jQuery( '#condition_col' ).val();

    // load_wizard(dataset_list,organ_list,stage_list,tissue_list);
  });


  //select and unselect all checkbox on BLAST output dialog
	$('#selectall').click(function () {
	        $('.blast_checkbox').prop('checked', isChecked('selectall'));
	});

	function isChecked(checkboxId) {
	    var id = '#'+checkboxId;
	    return $(id).is(":checked");
	}
	$("#selectall").removeAttr("checked");
});
