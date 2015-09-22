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
  var img_width = 250;
  var img_height = 450;

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
	
	//set variables
	var x_margin = canvas_width -100 - tissues.length*20 - stages.length*15;
	var y_margin = 100;
  
  var cube_left_pos = x_margin -60 - stages.length*10;
  var images_total_width = img_width //to mesure the total width of the images we are printing, so we can fit them in new rows
  var images_total_height = img_height;
  // var col_num = 0;
  
  var x_offset = 0;
  var y_offset = 0;
  
	// print the tissue colored images
	for (var j = 0; j < stages.length; j++) {
    // col_num++;
    x_offset = images_total_width;
    images_total_width = images_total_width + img_width;
    
    // alert("row_index: "+row_index+", col_num: "+col_num+" modulus: "+col_num % 4);
    
    if (cube_left_pos <= images_total_width) { //1 columns
      // if (col_num % 1 == 0){
        // alert("cube_left_pos: "+cube_left_pos+" images_total_width: "+images_total_width);
        
        images_total_width = img_width;
        x_offset = 0;
        y_offset = y_offset + img_height;
        images_total_height = images_total_height + img_height;
      // }
    }
    
    // else if (cube_left_pos >= 360) { //2 columns
    //   if (col_num % 2 == 0){
    //     col_num = 0;
    //     y_offset = y_offset + img_height;
    //   }
    // }
    // else if (cube_left_pos > 195) { //3 columns
    //   if (col_num % 3 == 0){
    //     col_num = 0;
    //     y_offset = y_offset + img_height;
    //   }
    // }
    // else if (cube_left_pos <= 195) { //4 columns
    //   if (col_num % 4 == 0){
    //     col_num = 0;
    //     y_offset = y_offset + img_height;
    //   }
    // }
    
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
  
  var frame_height = $('#container').css("height");
  var container_height = frame_height.replace("px","");
  
  // alert("container_height: "+container_height+", images_total_height: "+images_total_height)
  if (images_total_height > container_height) {
    $('#container').css("height",images_total_height+"px");
  }
  
  // alert("cube_left_pos: "+cube_left_pos+" images_total_width: "+images_total_width);
  
  
	// ------------- print cube

	var cube_layer = new Kinetic.Layer();
  
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


