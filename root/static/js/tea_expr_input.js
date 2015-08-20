$(document).ready(function () {
	
	//open gene id info dialog
	$('#gene_i').click(function () {
		$('#gene_id_help').dialog({
			draggable:true,
			resizable:false,
			modal: true,
			width:300,
			closeOnEscape:true,
			title: "Gene Expression Search",
			open: function(event, ui) { $('.ui-dialog-titlebar-close').blur();},
		});
	});
	
  //open BLAST info dialog
  $('#blast_i').click(function () {
    $('#blast_help').dialog({
      draggable:true,
      resizable:false,
      modal: true,
      width:300,
      closeOnEscape:true,
      title: "BLAST Info",
      open: function(event, ui) { $('.ui-dialog-titlebar-close').blur();},
    });
  });
  
  //open BLAST info dialog
  $('#blast_i2').click(function () {
    $('#blast_help').dialog({
      draggable:true,
      resizable:false,
      modal: true,
      width:300,
      closeOnEscape:true,
      title: "BLAST Info",
      open: function(event, ui) { $('.ui-dialog-titlebar-close').blur();},
    });
  });
  
	//open custom list info dialog
	$('#custom_list_i').click(function () {
		$('#custom_list_help').dialog({
			draggable:true,
			resizable:false,
			modal: true,
			width:300,
			closeOnEscape:true,
			title: "Custom List Info",
			open: function(event, ui) { $('.ui-dialog-titlebar-close').blur();},
		});
	});
	
	//open parameters info dialog
	$('#parameters_i').click(function () {
		$('#parameters_help').dialog({
			draggable:true,
			resizable:false,
			modal: true,
			width:300,
			closeOnEscape:true,
			title: "Parameters and Filters",
			open: function(event, ui) { $('.ui-dialog-titlebar-close').blur();},
		});
	});
	
	//open custom list input dialog
	$('#custom_input_box').click(function () {
		$('#custom_input_dialog').dialog({
			draggable:true,
			resizable:false,
			modal: true,
			width:450,
			closeOnEscape:true,
			title: "Custom List",
			open: function(event, ui) { $('.ui-dialog-titlebar-close').blur(); $('.dialog_text_area').blur();},
		});
	});
	
	//open BLAST input dialog
	$('#blast_input_box').click(function () {
		$('#blast_input_dialog').dialog({
			draggable:true,
			resizable:false,
			modal: true,
			width:460,
			height:470,
			closeOnEscape:true,
			title: "BLAST Search",
			open: function(event, ui) { $('.ui-dialog-titlebar-close').blur(); $('.dialog_text_area').blur();},
		});
	});
	
  
  //get the higest css z-index and add one to move the parameter form to top
  // function move_to_top(obj_id) {
  //   var z_pos = $('#max_z').val();
  //   $(obj_id).css("z-index",z_pos*1 +1);
  //   $('#max_z').val(z_pos*1 +1);
  // }
  
  //move to top when clicking on the parameter dialogs
  // $('.params_box').click(function () {
  //   move_to_top(this);
  // });
  //
  // $('.close_x').click(function () {
  //   $(this).parent().css("display","none");
  // });
  
  //display and move to top when clicking on the parameter names
  // $('#genotype_form').append(organisms_html);
  // $('#genotype_input').click(function () {
  //   move_to_top('#genotype_form');
  //   $('#genotype_form').css("display","inline");
  // });
  //
  // $('#organ_form').append(organs_html);
  // $('#organ_input').click(function () {
  //   move_to_top('#organ_form');
  //   $('#organ_form').css("display","inline");
  // });
  //
  // $('#stage_form').append(stages_html);
  // $('#stage_input').click(function () {
  //   move_to_top('#stage_form');
  //   $('#stage_form').css("display","inline");
  // });
  //
  // $('#tissue_form').append(tissues_html);
  // $('#tissue_input').click(function () {
  //   move_to_top('#tissue_form');
  //   $('#tissue_form').css("display","inline");
  // });
  
  
  
  
  jQuery('.organism_col').change(function() {
    // AJAX communication to get stage, tissue ...
    
    var organism_list = jQuery( "input:checked" ).val();
    // alert("organism_list: "+organism_list);
    // var organ_list = jQuery( '#organ_col' ).val();
    // var organ_list = jQuery( '#organ_part_col' ).val();
    // var stage_list = jQuery( '#stage_col' ).val();
    // var tissue_list = jQuery( '#tissue_col' ).val();
    
    load_wizard(organism_list,null,null,null);
  });
  
  jQuery('.wizard_select').change(function() {
    // AJAX communication to get stage, tissue ...
    
    var organism_list = jQuery( "input:checked" ).val();
    // alert("organism_list: "+organism_list);
    var organ_list = jQuery( '#organ_col' ).val();
    var organ_list = jQuery( '#organ_part_col' ).val();
    var stage_list = jQuery( '#stage_col' ).val();
    // var tissue_list = jQuery( '#tissue_col' ).val();
    
    load_wizard(organism_list,organ_list,stage_list,null);
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
          jQuery('#organ_part_col').html(response.organs);
          jQuery('#stage_col').html(response.stages);
          jQuery('#tissue_col').html(response.tissues);
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
					$('#blast_input_dialog').dialog("close");
					
					$('#blast_res_table').html(response.blast_table);
					$('#blast_div_dialog').dialog({
						draggable:true,
						resizable:true,
						modal: true,
						width:700,
						minWidth:500,
						height:750,
						closeOnEscape:true,
						title: "BLAST Results",
						open: function(event, ui) {$('#selectall').blur();},
					});
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
  });  

  $('.select_none').click(function(event) {
    $(this).parent().children().each(function() {
      $("option",this).prop('selected', false);
    });
  });  


  //select and unselect all checkbox for each parameter form independently
  // $('.check_all').click(function(event) {
  //   if(this.checked) {
  //     // Iterate each checkbox
  //     $(this).parent().children().each(function() {
  //         this.checked = true;
  //     });
  //   }
  //   else {
  //     $(this).parent().children().each(function() {
  //       this.checked = false;
  //     });
  //   }
  // });
  
  
  
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


