$(document).ready(function () {

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
	

  jQuery("#organism_3").attr("checked", "checked");
  var idSelector = function() { return this.value; };
  var organism_list = jQuery(".organism_col:checked").map(idSelector).get();
  load_wizard(organism_list,null,null,null);
  
  
  // jQuery('.organism_col').change(function() {
  jQuery('#organism_col').click(function() {
    
    // AJAX communication to get stage, tissue ...
    var idSelector = function() { return this.value; };
    var organism_list = jQuery(".organism_col:checked").map(idSelector).get();
    
    load_wizard(organism_list,null,null,null);
  });
  
  jQuery('.wizard_select').change(function() {
    // AJAX communication to get stage, tissue ...
    var idSelector = function() { return this.value; };
    var organism_list = jQuery(".organism_col:checked").map(idSelector).get();
    
    // var organism_list = jQuery( "input:checked" ).val();
    // alert("organism_list: "+organism_list);
    // var organ_list = jQuery( '#organ_col' ).val();
    var organ_list = jQuery( '#organ_part_col' ).val();
    var stage_list = jQuery( '#stage_col' ).val();
    var tissue_list = jQuery( '#tissue_col' ).val();
    // var tissue_list = jQuery( '#tissue_col' ).children(":selected").attr("id");
    
    // alert("tissue_list: "+tissue_list);
    
    load_wizard(organism_list,organ_list,stage_list,tissue_list);
  });
  
  
  function load_wizard(organism_list,organ_list,stage_list,tissue_list){
    
    $.ajax({
      url: '/Expression_viewer/get_stages/',
      timeout: 600000,
      method: 'POST',
      data: { 'organisms': organism_list, 'organs': organ_list, 'stages': stage_list, 'tissues': tissue_list},
      success: function(response) {
        if (response.error) {
          alert("ERROR: "+response.error);
          // enable_ui();
        } else {
          // alert("stages: "+response.stages);
          $('#organ_part_col').html("");
          $('#stage_col').html("");
          $('#tissue_col').html("");
          $('#organ_part_col').html(response.organs);
          $('#stage_col').html(response.stages);
          $('#tissue_col').html(response.tissues);
          
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
          
          $( '.organism_filter' ).val(organism_list);
          $( '.organ_filter' ).val( $( '#organ_part_col' ).val());
          $( '.stage_filter' ).val( $( '#stage_col' ).val());
          $( '.tissue_filter' ).val( $( '#tissue_col' ).val());
          
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

		if ($('#blast_filter').is(":checked")) {
			blast_filter = 1;
		};
		if ($('#blast_alignment').is(":checked")) {
			blast_alignment = 1;
		};
		
		$.ajax({
			url: '/Expression_viewer/blast/',
			timeout: 600000,
			method: 'POST',
			data: { 'input_seq': blast_seq, 'blast_hits': blast_hits, 'blast_alignment': blast_alignment, 'blast_evalue': blast_evalue, 'blast_filter': blast_filter },
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
						$('#blast_res_div').css('height','300px');
					} else {
						$('#blast_res_div').css('height','600px');
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
    var organism_list = jQuery(".organism_col:checked").map(idSelector).get();
    var organ_list = jQuery( '#organ_part_col' ).val();
    var stage_list = jQuery( '#stage_col' ).val();
    var tissue_list = jQuery( '#tissue_col' ).val();
    
    load_wizard(organism_list,organ_list,stage_list,tissue_list);
  });  

  $('.select_none').click(function(event) {
    $(this).parent().children().each(function() {
      $("option",this).prop('selected', false);
    });
    
    var idSelector = function() { return this.value; };
    var organism_list = jQuery(".organism_col:checked").map(idSelector).get();
    var organ_list = jQuery( '#organ_part_col' ).val();
    var stage_list = jQuery( '#stage_col' ).val();
    var tissue_list = jQuery( '#tissue_col' ).val();
    
    load_wizard(organism_list,organ_list,stage_list,tissue_list);
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


