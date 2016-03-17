$(document).ready(function () {
  
  jQuery('.tabs .tab-links a').on('click', function(e)  {
    var currentAttrValue = jQuery(this).attr('href');

    // Show/Hide Tabs
    jQuery(currentAttrValue).show().siblings().hide();
    // jQuery('.tabs ' + currentAttrValue).show().siblings().hide();

    // Change/remove current tab to active
    jQuery(this).parent('li').addClass('active').siblings().removeClass('active');

    e.preventDefault();
  });
     
     
  function get_canvas_height(stages_array,canvas_fix_width,canvas_fix_height) {

    var img_total_width = 0;

    img_total_width = image_hash[stages_array[0]]["bg"]["image_width"]*stages_array.length;
    
    var col_num = Math.ceil(img_total_width/canvas_fix_width);
    var row_num = stages_array.length/col_num;
    
    var img_total_height = image_hash[stages_array[0]]["bg"]["image_height"]*row_num;
    
    if (img_total_height < canvas_fix_height) {
      img_total_height = canvas_fix_height;
    }
    
    // alert("row: "+row_num+", col: "+col_num+", total width: "+images_total_width+", total height: "+images_total_height);
    return [img_total_height,col_num];
  }
  
	//set canvas width
  var canvas_width = 1120;
  var canvas_height = 1200;
  
  //set variables
	var x_margin = canvas_width -100 - stages.length*20 - tissues.length*15;
  
  //for y_margin for the cube
  var longest_stage = 0;
  for (var j = 0; j < stages.length; j++) {
    if (stages[j].length > longest_stage) {
      longest_stage = stages[j].length;
    }
  }
  // alert("longest stage: "+longest_stage);
	var y_margin = longest_stage*7;

  // var cube_left_pos = x_margin -60 - tissues.length*10;

  var x_offset = 0;
  var y_offset = 0;
  
  
  //set canvas height
  var height_and_col = get_canvas_height(stages,canvas_width,canvas_height);
  var images_total_height = height_and_col[0];
  var col_num = height_and_col[1];
  
  //define the cube canvas
  var canvas = new Kinetic.Stage({
    container: "container",
    width: canvas_width,
    height: canvas_height
  });

  //define the tissue canvas
  var img_canvas = new Kinetic.Stage({
    container: "container_tissues",
    width: canvas_width,
    height: images_total_height
  });
  var tissue_layer = new Kinetic.Layer();


  //set image coordinates
  var img_y = 0;
  
  
	// print the tissue colored images
	for (var j = 0; j < stages.length; j++) {
    
    load_stage_image(x_offset,y_offset,tissue_layer,img_canvas,stages[j],image_hash);
    
    var tissue_img_group = new Kinetic.Group();
		for (var i = 0; i<tissues.length; i++) {
			
			var expr_val = aoaoa[0][j][i];
			var rgb_color_array = get_expr_color(expr_val);
			
			var r = rgb_color_array[0];
			var g = rgb_color_array[1];
			var b = rgb_color_array[2];
      
      // alert("expr_val: "+expr_val);
			
      // if (expr_val > 0) {
        var stage_name = stages[j].replace(/_/g," ");
        var tisue_name = tissues[i];
        
        if (typeof(image_hash[stage_name][tisue_name]) !== 'undefined') {
          
        // if (typeof(image_hash[stages[j]][tissues[i]]["image_name"]) !== 'undefined') {
          var image_name = image_hash[stage_name][tisue_name]["image_name"];
          img_width = image_hash[stage_name][tisue_name]["image_width"]*1;
          img_height = image_hash[stage_name][tisue_name]["image_height"]*1;
          
          load_tissue_image(i,j,aoaoa,x_offset,y_offset,r,g,b,tissue_layer,img_canvas,stages[j],tissues[i],img_width,img_height,tissue_img_group,image_name,expr_val);
        // }
        }
      // }
      
		}
    tissue_expr_popup(img_canvas,tissue_img_group,aoaoa,j,tissues,x_offset,y_offset,img_width,img_height,canvas_width);
    
    // tissue_layer.cache(); //when commented fixed warnings
		tissue_layer.draw();
    
    //sum x and y offsets to print the tissue images
    var j_index = j+1;
    
    if (j_index % col_num != 0) {
      x_offset = x_offset + image_hash[stages[j]]["bg"]["image_width"]*1;
    } 
    else {
      x_offset = 0;
      y_offset = y_offset + image_hash[stages[j]]["bg"]["image_height"]*1;
    }
	}
  
  var frame_height = $('#container').css("height");
  var container_height = frame_height.replace("px","");
  
  if (canvas_height > container_height) {
    $('#container').css("height",canvas_height+"px");
  }
  
  
	// ------------- print cube

	var cube_layer = new Kinetic.Layer();
  
	//margins for the cube
	var top_x_start = x_margin + (tissues.length*15);
  // var top_x_start = x_margin + (stages.length*15);
	
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
	document.getElementById("gene_name").innerHTML = "<a href='http://solgenomics.net/locus/"+gene_locus_id[genes[0]]+"/view' target='_blank'><img src='/static/images/sgn_logo.png' height='30' style='margin-bottom: 10px;' title='Connect to SGN for metadata associated with this gene'/> "+genes[0]+"</a>";
	document.getElementById("gene_desc").innerHTML = gene_descriptions[genes[0]];
  document.getElementById("project_desc").innerHTML = "<a href='/project_page?project_id="+project_id+"' target='_blank'>"+project_name+"</a>";
	
	draw_cube(genes,stages,tissues,aoaoa,cube_layer,canvas,top_x_start,y_margin,gene_locus_id,gene_descriptions,current_page,pages_num,canvas_width);
	
});


