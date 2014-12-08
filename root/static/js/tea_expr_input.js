$(document).ready(function () {
	
	//open gene id info dialog
	$('#gene_i').click(function () {
		$('#gene_id_help').dialog({
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
	
	//open custom list info dialog
	$('#custom_list_i').click(function () {
		$('#custom_list_help').dialog({
			draggable:true,
			resizable:false,
			modal: true,
			width:300,
			closeOnEscape:true,
			title: "BLAST Info",
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
			title: "BLAST Info",
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
			open: function(event, ui) { $('.ui-dialog-titlebar-close').blur();},
		});
	});
	
	//open BLAST input dialog
	$('#blast_input_box').click(function () {
		$('#blast_input_dialog').dialog({
			draggable:true,
			resizable:false,
			modal: true,
			width:450,
			closeOnEscape:true,
			title: "BLAST Search",
			open: function(event, ui) { $('.ui-dialog-titlebar-close').blur();},
		});
	});
	
	//AJAX communication to run BLAST
	$('#blast_button').click(function () {
		input_seq = $('#blast_sequence').val();
		
		// alert("sending: "+input_seq);
		
		$.ajax({
			url: '/Expression_viewer/blast/',
			timeout: 600000,
			method: 'POST',
			data: { 'input_seq': input_seq },
			beforeSend: function(){
				// disable_ui();
			},
			success: function(response) {
				if (response.error) {
					alert("ERROR: "+response.error);
					// enable_ui();
				} else {
					$('#blast_input_dialog').dialog("close");
					
					$('#blast_res_dialog').html(response.msg);
					$('#blast_div_dialog').dialog({
					draggable:true,
					resizable:true,
					modal: true,
					width:700,
					minWidth:500,
					minHeight:300,
					maxHeight:1100,
					closeOnEscape:true,
					title: "BLAST Results",
					});
					// alert("Hello= "+response.msg);
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


