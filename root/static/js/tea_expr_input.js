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
	
  // input filter options
  $('#genotype_input').click(function () {
    $('.params_box').css("display","none");
    var genotype_form = $('#genotype_form').html();
    $('#genotype_form').html(genotype_form);
    $('#genotype_form').css("display","inline");
  });
  
  
  $('#organ_input').click(function () {
    $('.params_box').css("display","none");
    var organ_form = $('#organ_form').html();
    $('#organ_form').html(organ_form);
    $('#organ_form').css("display","inline");
  });
  
  
  
  
  
  
  
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
	
	$('#selectall').click(function () {
	        $('.blast_checkbox').prop('checked', isChecked('selectall'));
	});
	
	function isChecked(checkboxId) {
	    var id = '#' + checkboxId;
	    return $(id).is(":checked");
	}
	$("#selectall").removeAttr("checked");
});


