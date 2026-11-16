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


  // ---- tissue toggles for the cube ----------------------------------------
  // The heatmap tab rewrites the global stages/tissues arrays (spaces -> underscores),
  // which would break the bg_color_hash lookups on a later redraw, so keep copies.
  var cube_stages = stages.slice();
  var cube_tissues = tissues.slice();

  var hidden_tissues = {};
  var storage_key = "tea_cube_hidden_tissues_" + project_id;

  //restore the selection after a page change (pagination reloads the page)
  try {
    var saved = JSON.parse(window.sessionStorage.getItem(storage_key) || "[]");
    for (var s = 0; s < saved.length; s++) {
      if (cube_tissues.indexOf(saved[s]) > -1) { hidden_tissues[saved[s]] = 1; }
    }
  } catch (e) {}

  function visible_tissue_indices() {
    var idx = [];
    for (var i = 0; i < cube_tissues.length; i++) {
      if (!hidden_tissues[cube_tissues[i]]) { idx.push(i); }
    }
    return idx;
  }

  //never leave the cube empty
  if (visible_tissue_indices().length == 0) { hidden_tissues = {}; }

  function save_hidden_tissues() {
    try {
      window.sessionStorage.setItem(storage_key, JSON.stringify(Object.keys(hidden_tissues)));
    } catch (e) {}
  }

  //draw the cube with only the tissues that are currently switched on
  function draw_visible_cube() {
    var idx = visible_tissue_indices();

    var vis_tissues = idx.map(function(i) { return cube_tissues[i]; });
    var vis_aoaoa = aoaoa.map(function(gene) {
      return gene.map(function(stage_vals) {
        return idx.map(function(i) { return stage_vals[i]; });
      });
    });

    //keep the cube anchored on the right whatever the number of tissues
    var vis_x_margin = canvas_width - 40 - (cube_stages.length*20 + vis_tissues.length*15);

    canvas.destroyChildren();
    setup_cube(canvas,canvas_height,canvas_width,vis_x_margin,genes,cube_stages,vis_tissues,vis_aoaoa,gene_locus_id,gene_descriptions,current_page,pages_num,expression_unit,bg_color_hash,expression_min_scale,expression_max_scale);
  }

  //switch one tissue on/off (from its chip or from its label in the cube)
  var tissue_buttons = {};

  function toggle_tissue(tissue_name) {
    if (hidden_tissues[tissue_name]) {
      delete hidden_tissues[tissue_name];
    } else if (visible_tissue_indices().length > 1) {
      hidden_tissues[tissue_name] = 1;
    } else {
      return; //keep at least one tissue on
    }
    if (tissue_buttons[tissue_name]) {
      tissue_buttons[tissue_name].toggleClass("off", !!hidden_tissues[tissue_name]);
    }
    save_hidden_tissues();

    //redraw after the current Kinetic event has finished: when triggered from a cube label,
    //the node that received the click is destroyed by the redraw
    setTimeout(draw_visible_cube, 0);
  }

  //called by the tissue labels of the cube (tea_expr_cube_functions.js) when clicked:
  //clicking a visible tissue label hides it; it stays listed in the selector bar to bring it back
  window.tea_cube_label_clicked = function(tissue_name) {
    if (!hidden_tissues[tissue_name]) { toggle_tissue(tissue_name); }
  };

  function build_tissue_toggles() {
    var $box = $("#cube_tissue_buttons");
    if (!$box.length || cube_tissues.length < 2) {
      $("#cube_tissue_toggles").hide();
      return;
    }

    $box.empty();
    $.each(cube_tissues, function(i, tissue_name) {
      var $btn = $('<button type="button" class="tissue_toggle"></button>');
      var $swatch = $('<span class="tissue_swatch"></span>');
      if (bg_color_hash[tissue_name]) { $swatch.css("background-color", bg_color_hash[tissue_name]); }
      $btn.append($swatch).append(document.createTextNode(tissue_name.replace(/_/g, " ")));
      $btn.toggleClass("off", !!hidden_tissues[tissue_name]);

      $btn.on("click", function() {
        toggle_tissue(tissue_name);
      });
      tissue_buttons[tissue_name] = $btn;
      $box.append($btn);
    });

    $("#cube_tissue_all").on("click", function() {
      if (Object.keys(hidden_tissues).length == 0) { return; }
      hidden_tissues = {};
      $box.find(".tissue_toggle").removeClass("off");
      save_hidden_tissues();
      draw_visible_cube();
    });
  }

  //print cube
  build_tissue_toggles();
  draw_visible_cube();

  //the toggles only make sense for the cube tab
  $('#cube_tab').on("click", function() { $("#cube_tissue_toggles").show(); });
  $('#grid_tab, #expr_imgs_tab, #heatmap_tab, #scatterplots_tab, #deg_tab, #network_tab').on("click", function() {
    $("#cube_tissue_toggles").hide();
  });


  //print Expression images
  var expr_imgs_loaded = 0;
  var img_canvas;

  //draw the Expression images the first time they are needed: on load when they are
  //the landing tab, otherwise when their tab is clicked
  function load_expression_images() {
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
  }

  $("#expr_imgs_tab").click(load_expression_images);

  //Expression grid: flat stage x tissue view of the query gene (read-only)
  var expr_grid_loaded = 0;
  var grid_canvas;

  function load_expression_grid() {
    if (!expr_grid_loaded && $("#container_grid").length) {
      grid_canvas = new Kinetic.Stage({
        container: "container_grid",
        width: 600,
        height: 600
      });

      draw_expression_grid(grid_canvas,cube_stages,cube_tissues,genes[0],aoaoa[0],expression_unit,expression_min_scale,expression_max_scale);
      expr_grid_loaded = 1;
    }
  }

  $("#grid_tab").click(load_expression_grid);

  //The landing tab (the first one, see output.mas) is drawn right away; the buttons and the
  //cube tissue selectors are set to the state they have for that tab
  if ($("#grid_tab").hasClass("active")) {
    load_expression_grid();
  } else if ($("#expr_imgs_tab").hasClass("active")) {
    load_expression_images();
  }

  if (!$("#cube_tab").hasClass("active")) {
    $("#dwl_expr_data").css("display","none");
    $("#cube_tissue_toggles").hide();
  }

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
	$('#cube_tab, #grid_tab, #expr_imgs_tab, #scatterplots_tab, #deg_tab').on("click", function(){
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
$('#grid_tab, #expr_imgs_tab').click(function(){
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

    // download canvas as image when Expression grid tab is active
    if ($("#grid_tab").hasClass('active') && grid_canvas) {
      grid_canvas.toDataURL({
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
