$(document).ready(function () {

  //temporal variables
  var organ_bg_image = '/static/images/expr_viewer/slm82_pericarp_bg.png';
  
	//set canvas dimensions
	var canvas_width = 1120;
	var canvas_height = 1200;
	
  //define the canvas
	var canvas = new Kinetic.Stage({
		container: "container",
		width: canvas_width,
		height: canvas_height
	});
	var tissue_layer = new Kinetic.Layer();

  //set image dimensions
  var img_width = 200;
  var img_height = 360;
  
  //set image coordinates
  var img_y = 60;
  
  //create organ bg image
	var organBg_imgObj = new Image();
	organBg_imgObj.onload = function() {

		var tp = new Kinetic.Image({
			x: 0,
			y: img_y,
			image: organBg_imgObj,
			width: img_width,
			height: img_height
		});
		tissue_layer.add(tp);
		canvas.add(tissue_layer);
	};

	organBg_imgObj.src = organ_bg_image;


  var dpa_bg_imgObj = new Image();
  dpa_bg_imgObj.onload = function() {

    var tissue_bg = new Kinetic.Image({
      x: 190,
      y: img_y,
      image: dpa_bg_imgObj,
      width: img_width,
      height: img_height
    });
    tissue_layer.add(tissue_bg);
    canvas.add(tissue_layer);
  };

  var mg_bg_imgObj = new Image();
  mg_bg_imgObj.onload = function() {

    var tissue_bg2 = new Kinetic.Image({
      x: 380,
      y: img_y,
      image: mg_bg_imgObj,
      width: img_width,
      height: img_height
    });
    tissue_layer.add(tissue_bg2);
    canvas.add(tissue_layer);
  };

  var pink_bg_imgObj = new Image();
  pink_bg_imgObj.onload = function() {

    var tissue_bg3 = new Kinetic.Image({
      x: 570,
      y: img_y,
      image: pink_bg_imgObj,
      width: img_width,
      height: img_height
    });
    tissue_layer.add(tissue_bg3);
    canvas.add(tissue_layer);
  };

  dpa_bg_imgObj.src = '/static/images/expr_viewer/dpa_bg.png';
  mg_bg_imgObj.src = '/static/images/expr_viewer/mg_bg.png';
  pink_bg_imgObj.src = '/static/images/expr_viewer/pink_bg.png';

	// -------------------------------------------------------------------------------------
	// http://www.html5canvastutorials.com/tutorials/html5-canvas-image-loader/
		
	// print the tissue colored images
	for (var j = 0; j < stages.length; j++) {
		
		var x_offset = 190 + 190*j;
		// var x_offset = 200 + 190*j;

		for (var i = 0; i<tissues.length; i++) {
			
			var expr_val = aoaoa[0][j][i];
			var rgb_color_array = get_expr_color(expr_val);
			
			var r = rgb_color_array[0];
			var g = rgb_color_array[1];
			var b = rgb_color_array[2];
			
			loadImage(i,j,aoaoa,x_offset,r,g,b,tissue_layer,canvas,stages[j],tissues[i]);
		}
		tissue_layer.cache();
		tissue_layer.draw();
	}
	// -------------------------------------------------------------------------------------

	var cube_layer = new Kinetic.Layer();

	//set variables
	var x_margin = canvas_width -100 - tissues.length*20 - stages.length*15;
	var y_margin = 100;

	var last_x_margin = 125 + stages.length*20;
	var last_y_margin = 155 + stages.length*15;
	
	//margins for the cube
	var right_x_start = x_margin + 5 + tissues.length*20;
	var top_x_start = x_margin + (stages.length*15);
	
	//return error if input gene was not found
	if (!genes[0]) {
		alert("Gene not found");
		enable_ui();
	}
	
	//display query gene name
	$('#gene').val(genes[0]);
	
	//set correlation filter value
	$('#correlation_filter').val(correlation_filter);
	
	//display link to SGN and query gene description
	document.getElementById("gene_name").innerHTML = "<a href='http://solgenomics.net/locus/"+gene_locus_id[genes[0]]+"/view' target='_blank'><img src='/static/images/sgn_logo.png' height='30' style='margin-bottom: -10px;' title='Connect to SGN for metadata associated with this gene'/> "+genes[0]+"</a>";
	document.getElementById("gene_desc").innerHTML = gene_descriptions[genes[0]];
	
	draw_cube(genes,stages,tissues,aoaoa,cube_layer,canvas,x_margin,last_y_margin,top_x_start,y_margin,right_x_start, gene_locus_id, gene_descriptions, current_page, pages_num, canvas_width);
	
	//remove loading wheel
  // enable_ui();
	
});


