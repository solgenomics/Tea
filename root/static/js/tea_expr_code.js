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
  // var img_width = 450;
  // var img_height = 500;
  
  // //set image dimensions
  var img_width = 200;
  var img_height = 350;

  //set image coordinates
  var img_y = 0;
  
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

	// ------------- print tissue images
	// http://www.html5canvastutorials.com/tutorials/html5-canvas-image-loader/
	
  var row_index = stages.length*15 + tissues.length*20
  var col_num = 0 //to count how many stages we are printing, so we can fit them in new rows
  
  var x_offset = 0;
  var y_offset = 0;
  
  // alert("row_index: "+row_index);
  
	// print the tissue colored images
	for (var j = 0; j < stages.length; j++) {
		col_num++;
    
    // alert("row_index: "+row_index+", col_num: "+col_num+" modulus: "+col_num % 4);
    
    if (row_index >550) { //1 columns
      if (col_num % 1 == 0){
        col_num = 0;
        y_offset = y_offset + img_height;
      }
    }
    else if (row_index >= 360) { //2 columns
      if (col_num % 2 == 0){
        col_num = 0;
        y_offset = y_offset + img_height;
      }
    }
    else if (row_index > 195) { //3 columns
      if (col_num % 3 == 0){
        col_num = 0;
        y_offset = y_offset + img_height;
      }
    }
    else if (row_index <= 195) { //4 columns
      if (col_num % 4 == 0){
        col_num = 0;
        y_offset = y_offset + img_height;
      }
    }
    
    x_offset = img_width*col_num;
    // x_offset = 190*col_num;
    
    // x_offset = 0;
    // y_offset = 360;
    
    load_stage_image(aoaoa,x_offset,y_offset,tissue_layer,canvas,stages[j],img_width,img_height);
    
		for (var i = 0; i<tissues.length; i++) {
			
			var expr_val = aoaoa[0][j][i];
			var rgb_color_array = get_expr_color(expr_val);
			
			var r = rgb_color_array[0];
			var g = rgb_color_array[1];
			var b = rgb_color_array[2];
			
			load_tissue_image(i,j,aoaoa,x_offset,y_offset,r,g,b,tissue_layer,canvas,stages[j],tissues[i],img_width,img_height);
		}
		tissue_layer.cache();
		tissue_layer.draw();
	}
  
	// ------------- print cube

	var cube_layer = new Kinetic.Layer();

	//set variables
	var x_margin = canvas_width -100 - tissues.length*20 - stages.length*15;
	var y_margin = 100;
	
	//margins for the cube
	var top_x_start = x_margin + (stages.length*15);
	
	//return error if input gene was not found
	if (!genes[0]) {
		alert("Gene id not found or gene not expressed");
		enable_ui();
	}
	
	//display query gene name
	$('#gene').val(genes[0]);
	
	//set correlation filter value
	$('#correlation_filter').val(correlation_filter);
	
	//display link to SGN and query gene description
	document.getElementById("gene_name").innerHTML = "<a href='http://solgenomics.net/locus/"+gene_locus_id[genes[0]]+"/view' target='_blank'><img src='/static/images/sgn_logo.png' height='30' style='margin-bottom: -10px;' title='Connect to SGN for metadata associated with this gene'/> "+genes[0]+"</a>";
	document.getElementById("gene_desc").innerHTML = gene_descriptions[genes[0]];
	
	draw_cube(genes,stages,tissues,aoaoa,cube_layer,canvas,top_x_start,y_margin,gene_locus_id,gene_descriptions,current_page,pages_num,canvas_width);
	
});


