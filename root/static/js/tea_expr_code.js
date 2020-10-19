$(document).ready(function () {

  //Code to draw cube and Expression images ----------------------------------------

	//return error if input gene was not found
  // if (!genes[0]) {
  //   alert("Gene id not found or gene not expressed");
  // }

	//display query gene name
	$('#gene').val(genes[0]);

	//set correlation filter value
	$('#correlation_filter').val(correlation_filter);


  //set canvas width
  var canvas_width = 1025;
  var canvas_height = 1200;

  //set variables
  var cube_width = stages.length*20 + tissues.length*15;
  var x_margin = canvas_width -40 - cube_width;

  //increase canvas width when cube is too large
  if (cube_width + 500 > canvas_width) {
    canvas_width = cube_width + 500;
    x_margin = canvas_width -40 - cube_width;
    var container_width = canvas_width + 35;
    $('.output_width').css("width",container_width+"px");
  }

  var bg_color_hash = new Object();

  for (var n = 0; n < stage_ids_array.length; n++) {

    if (stage_hash[stage_ids_array[n]]["bg_color"]) {
      var stage_name = stage_hash[stage_ids_array[n]]["stage_name"];
      bg_color_hash[stage_name] = stage_hash[stage_ids_array[n]]["bg_color"];
    }

    if (tissue_hash[stage_ids_array[n]]) {

      for (var i = 0; i<tissue_hash[stage_ids_array[n]]["tissue_name"].length; i++) {
        var tissue_name = tissue_hash[stage_ids_array[n]]["tissue_name"][i];
        var tissue_color = tissue_hash[stage_ids_array[n]]["bg_color"][tissue_name];

        if (tissue_color) {
          bg_color_hash[tissue_name] = tissue_color;
        }
      }//end for

    }//end if
  }


  //define the cube canvas
  var canvas = new Kinetic.Stage({
    container: "container",
    width: canvas_width,
    height: canvas_height
  });


  //print cube
  setup_cube(canvas,canvas_height,canvas_width,x_margin,genes,stages,tissues,aoaoa,gene_locus_id,gene_descriptions,current_page,pages_num,expression_unit,bg_color_hash,expression_min_scale,expression_max_scale);


  //print Expression images
  var expr_imgs_loaded = 0;
  var img_canvas;

  $("#expr_imgs_tab").click(function(){
    // alert("images: "+expr_imgs_loaded);

    // $('#dwl_expr_data').css("display","none");
		// $('#dwl_cube').css("display","inline-block");

    if (!expr_imgs_loaded) {

      $("#loading_modal").modal("show");

      //define canvas for Expression Images
      img_canvas = new Kinetic.Stage({
        container: "container_tissues",
        width: 1025,
        height: 1200
      });


      draw_expression_images(img_canvas,canvas_width,stage_ids_array,stage_hash,tissue_hash,gst_expr_hohoh,genes,tissues,expression_min_scale,expression_max_scale);
      expr_imgs_loaded = 1;

      setTimeout($("#loading_modal").modal("hide"), 5000);
    }
  });

  //get d3heatmap html file
  var d3heatmap_loaded = 0;
  $("#heatmap_tab").click(function(){

    // $('#dwl_expr_data').css("display","none");
    // $('#dwl_cube').css("display","none");

    if (!d3heatmap_loaded) {
	for (i in stages) {
	    stages[i] = stages[i].replace(/ /g,"_");
	}
	for (i in tissues) {
	    tissues[i] = tissues[i].replace(/ /g,"_");
	}

      $.ajax({
            url: '/expression_viewer/d3heatmap/',
            timeout: 600000,
            method: 'POST',
            data: { 'gst_hohoh': gst_expr_hohoh, 'genes_array': genes, 'st_array': stages, 'ti_array': tissues},
            success: function(response) {
              if (response.error) {
                alert("ERROR: "+response.error);
              } else {
                $('#container_heatmap').append(response.html_code);
                window.HTMLWidgets.staticRender();

                // alert("hi: "+response.heatmap_file);
                heatmap_filename = response.heatmap_file;
              }
            },
            error: function(response) {
              alert("An error occurred. The service may not be available right now.");
            }
      });
      d3heatmap_loaded = 1;
    }
  });

// show / hide legend
	$('#cube_tab, #expr_imgs_tab, #scatterplots_tab, #deg_tab').on("click", function(){
		$("#legend_box").css("display","block");
		$("#hide_legend").css("display","block");
		$("#color_scale_box").css("display","block");
	});

	$('#heatmap_tab, #network_tab').on("click", function(){
		$("#legend_box").css("display","none");
		$("#hide_legend").css("display","none");
		$("#color_scale_box").css("display","none");
	});

// show / hide legend by user
  $("#hide_legend").click(function(){
      $("#legend_box").animate({
          width: 'toggle'
      });
      if ($("#legend_close").hasClass("glyphicon-remove")) {
        $("#legend_close").removeClass("glyphicon-remove");
        $("#legend_close").addClass("glyphicon-info-sign");
      }
      else {
        $("#legend_close").addClass("glyphicon-remove");
        $("#legend_close").removeClass("glyphicon-info-sign");
      }
  });


// show download expression and save img button
$('#cube_tab').click(function(){
	$("#dwl_expr_data").css("display","block");
	$("#dwl_cube").css("display","block");
});

// show save img button
$('#expr_imgs_tab').click(function(){
	$("#dwl_cube").css("display","block");
	$("#dwl_expr_data").css("display","none");
});

// hide download expression and save img button
$('#heatmap_tab, #scatterplots_tab, #deg_tab, #network_tab').on("click", function(){
	$("#dwl_expr_data").css("display","none");
	$("#dwl_cube").css("display","none");
});




  $("#dwl_cube").click(function(){

    // download canvas as image when Expression Cube tab is active
    if ($("#cube_tab").hasClass('active')) {
      canvas.toDataURL({
        callback: function(imageURL) {
           var a = $("#dwl_cube_link")
               .attr("href", imageURL)
               .appendTo("body");
           a[0].click();
         }
      });
    }

    // download canvas as image when Expression images tab is active
    if ($("#expr_imgs_tab").hasClass('active')) {
      img_canvas.toDataURL({
        callback: function(imageURL) {
           var a = $("#dwl_cube_link")
               .attr("href", imageURL)
               .appendTo("body");
           a[0].click();
         }
      });
    }

    // download canvas as image when Heatmap tab is active
    if ($("#heatmap_tab").hasClass('active')) {
      alert("This heatmap is not available for downloading");
    }

    // download canvas as image when Scatterplots tab is active
    if ($("#scatterplots_tab").hasClass('active')) {
	alert("Scatterplot images are not currently available for downloading");
    }

  });


  //code to change tabs content
  $("#cube_tab").on('click', function(e)  {

    // $('#dwl_expr_data').css("display","inline-block");
    // $('#dwl_cube').css("display","inline-block");

    var currentAttrValue = jQuery(this).attr('href');
    // Show/Hide Tabs
    $(currentAttrValue).show().siblings().hide();

    // Change/remove current tab to active
    $(this).parent('li').addClass('active').siblings().removeClass('active');

    e.preventDefault();
  });


  // to download the expression data
  $("#dwl_expr_data").click(function(){
		$("#download_modal").modal("show");
  });

  $("#download_from_modal").click(function(){
		//get expr type value
		var expr_type = $("input[name='expr_type']:checked"). val();

		// alert("dwl type: "+expr_type);

		//set correlation filter value
		$('#output_type').val(expr_type);

    $("#download_data").submit();
  });

  // to download the DEG data
  $("#degOutput").click(function(){
    $("#download_deg").submit();
  });

});
