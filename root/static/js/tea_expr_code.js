$(document).ready(function () {
  
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
  
  function get_stage_short_name(s_name) {
    //function to remove the extensions stem, equatorial and stylar from the stage name
    //This way we could group images from the same stage when the belong to different sections of the fruit
    
    short_name = s_name;
    
    if (s_name.match(/stem$/)) {
      short_name = s_name.replace(" stem","");
    }
    if (s_name.match(/equatorial$/)) {
      short_name = s_name.replace(" equatorial","");
    }
    if (s_name.match(/stylar$/)) {
      short_name = s_name.replace(" stylar","");
    }
    
    return short_name;
  }
  
  function get_canvas_height(stage_ids_array,stage_hash,canvas_fix_width,canvas_fix_height,title_y) {
    
    var img_total_width = 0;
    var one_img_width = stage_hash[stage_ids_array[0]]["image_width"]*1;
    var one_img_height = stage_hash[stage_ids_array[0]]["image_height"]*1;
    
    img_total_width = one_img_width*stage_ids_array.length;
    
    var col_num = stage_ids_array.length;
    var row_num = 1;
    
    if (img_total_width > canvas_fix_width) {
      col_num = Math.floor(canvas_fix_width/one_img_width);
    }
    
    //fit all stage to available space
    
    //classify images by stages
    var next_stage = "";
    var next_short_name = "";
    var prev_stage = "";
    var prev_stage2 = "";
    var next_stage = "";
    var j_index = 0;
    
  	for (var j = 0; j < stage_ids_array.length; j++) {
      
      var stage_name = stage_hash[stage_ids_array[j]]["stage_name"].replace(/_/g," ");
      var stage_short_name = get_stage_short_name(stage_name);
    
      // if (stages[j+1]) {
      if (stage_hash[stage_ids_array[j+1]]) {
        next_stage = stage_hash[stage_ids_array[j+1]]["stage_name"].replace(/_/g," ");
        next_short_name = get_stage_short_name(next_stage);
      }
      else {
        next_stage = "";
        next_short_name = "";
      }
      
      j_index++;
      
      if (j == 0) {
        row_num = 1
      }
      //same line -- if same stage and not over limit
      else if (stage_short_name == prev_stage && j_index <= col_num) {

      }
      //new line -- if starting a set of stages or over the limit
      else if (stage_short_name == next_short_name || j_index > col_num) {
        j_index = 1;
        row_num++
      }
      //new line -- if not belong to a set of stages
      else if (stage_short_name != prev_stage && prev_stage2 && prev_stage == prev_stage2) {
        j_index = 1;
        row_num++
      }
      
      prev_stage2 = prev_stage;
      prev_stage = stage_short_name;
    }
    
    var img_total_height = (one_img_height+title_y)*row_num;
    
    if (img_total_height < canvas_fix_height) {
      img_total_height = canvas_fix_height;
    }
    
    return [img_total_height,col_num];
  }
  
  
  // function setup_cube(setup_cube,canvas_h,canvas_w,cube_x_margin,gene_a,stage_a,tissue_a,AoAoA,locus_id,gene_desc,c_page,pages_number,expr_unit,bg_color_hash,gst_sem_hohoh) {
  function setup_cube(setup_cube,canvas_h,canvas_w,cube_x_margin,gene_a,stage_a,tissue_a,AoAoA,locus_id,gene_desc,c_page,pages_number,expr_unit,bg_color_hash,gst_sem_hohoh) {
    
    var frame_height = $('#container').css("height");
    var container_height = frame_height.replace("px","");

    if (canvas_h > container_height) {
      $('#container').css("height",canvas_h+"px");
    }
  
    // //define the cube canvas
    // var canvas = new Kinetic.Stage({
    //   container: "container",
    //   width: canvas_w,
    //   height: canvas_h
    // });
  
    //for y_margin (top margin) for the cube, to have space for the stages names
    var longest_stage = 0;
    for (var j = 0; j < stage_a.length; j++) {
      if (stage_a[j].length > longest_stage) {
        longest_stage = stage_a[j].length;
      }
    }

  	var y_margin = longest_stage*7;
  
  	var cube_layer = new Kinetic.Layer();
  
  	//margins for the cube
  	var top_x_start = cube_x_margin + (tissue_a.length*15);
	
	
  	draw_cube(gene_a,stage_a,tissue_a,AoAoA,cube_layer,canvas,top_x_start,y_margin,locus_id,gene_desc,c_page,pages_number,canvas_w,expr_unit,bg_color_hash,gst_sem_hohoh);
    
  }
  
  
  function iterate_by_stage(n,stage_h,stage_ids_a,j_index,x_offset,y_offset,next_stage,next_short_name,prev_stage,prev_stage2,col_num,title_y_offset) {
    
    var img_name = stage_h[stage_ids_a[n]]["image_name"];
    var img_width = stage_h[stage_ids_a[n]]["image_width"]*1;
    var img_height = stage_h[stage_ids_a[n]]["image_height"]*1;
    var stage_name = stage_h[stage_ids_a[n]]["stage_name"];
    
    //cluster the images by stage name. Remove stem, equatorial and stylar for short names
    var stage_short_name = get_stage_short_name(stage_name.replace(/_/g," "));
  
    //check next image
    if (stage_h[stage_ids_a[n+1]]) {
      next_stage = stage_h[stage_ids_a[n+1]]["stage_name"].replace(/_/g," ");
      next_short_name = get_stage_short_name(next_stage);
    }
    else {
      next_stage = "";
      next_short_name = "";
    }

    //sum x and y offsets to print the tissue images
    j_index++;
  
    //first stage
    if (n == 0) {
      x_offset = 0;
      y_offset = 0 + title_y_offset;
    }
    //same line -- if same stage and not over limit
    else if (stage_short_name == prev_stage && j_index <= col_num) {
      x_offset = x_offset + img_width;
    }
    //new line -- if starting a set of stages or over the limit
    else if (stage_short_name == next_short_name || j_index > col_num) {
      x_offset = 0;
      j_index = 1;
      y_offset = y_offset + img_height;
    }
    //new line -- if not belong to a set of stages
    else if (stage_short_name != prev_stage && prev_stage2 && prev_stage == prev_stage2) {
      x_offset = 0;
      j_index = 1;
      y_offset = y_offset + img_height;
    }
    //same line
    else {
        x_offset = x_offset + img_width;
    }
    
    return [x_offset,y_offset,j_index,stage_name,img_name,img_width,img_height,stage_short_name];
  }
  
  function draw_expression_images(img_canvas,canvas_h,canvas_w,stage_ids_a,stage_h,tissue_h,gst_expr_hhh,gene_a,tissue_a) {
    
    var x_offset = 0;
    var y_offset = 0;
    var label_y_offset = 70;
    
    //set canvas height
    var height_and_col = get_canvas_height(stage_ids_a,stage_h,canvas_w,canvas_h,label_y_offset);
    var images_total_height = height_and_col[0];
    var col_num = height_and_col[1];
    
    img_canvas.width(canvas_w);
    img_canvas.height(images_total_height);
    
    var tissue_layer = new Kinetic.Layer();
    
    x_offset = 0;
    y_offset = 0;
    prev_stage = "";
    prev_stage2 = "";
    next_stage = "";
    next_short_name = "";
    j_index = 0;
    
    
    //second round to draw only tissue layer over the stage images from the first round (output more reliable?)
    for (var n = 0; n < stage_ids_a.length; n++) {
      
      if (tissue_h[stage_ids_a[n]]) {
        
        
        [x_offset,y_offset,j_index,stage_name,img_name,img_width,img_height,stage_short_name] = iterate_by_stage(n,stage_h,stage_ids_a,j_index,x_offset,y_offset,next_stage,next_short_name,prev_stage,prev_stage2,col_num,label_y_offset);
        
        var stage_top_label = stage_h[stage_ids_a[n]]["stage_top_label"];
        
        draw_stage_name(x_offset,y_offset,tissue_layer,img_canvas,img_width,stage_top_label,label_y_offset);
        // load_stage_image(x_offset,y_offset,tissue_layer,img_canvas,img_name,img_width,img_height);
        
        //display overlapping tissue imgs and group them
        var tissue_img_group = new Kinetic.Group();
        for (var i = 0; i<tissue_h[stage_ids_a[n]]["image_name"].length; i++) {
        
        
          var tisue_name = tissue_h[stage_ids_a[n]]["tissue_name"][i];
        
          var expr_val = gst_expr_hhh[gene_a[0]][stage_name][tisue_name];
          
          // alert("gst_expr_hhh: "+gst_expr_hhh[gene_a[0]]);
          // alert("expr_val: "+expr_val+", gene: "+gene_a[0]+", stage_name: "+stage_name+", tisue_name: "+tisue_name);
          
          var rgb_color_array = get_expr_color(expr_val);

          var r = rgb_color_array[0];
          var g = rgb_color_array[1];
          var b = rgb_color_array[2];

          var image_name = tissue_h[stage_ids_a[n]]["image_name"][i];
        
          img_width = tissue_h[stage_ids_a[n]]["image_width"][i]*1;
          img_height = tissue_h[stage_ids_a[n]]["image_height"][i]*1;

          // alert("x_offset: "+x_offset+", y_offset: "+y_offset+", r: "+r+", g: "+g+", b: "+b+", img_width: "+img_width+", img_height: "+img_height+", image_name: "+image_name);
          
          load_tissue_image(x_offset,y_offset,r,g,b,tissue_layer,img_canvas,img_width,img_height,tissue_img_group,image_name);
          tissue_layer.draw();
        } //for tissues end

        tissue_expr_popup(img_canvas,tissue_img_group,tissue_h[stage_ids_a[n]],gst_expr_hhh[gene_a[0]][stage_name],tissue_a,x_offset,y_offset,img_width,img_height,canvas_w);

        tissue_layer.draw();

        prev_stage2 = prev_stage;
        prev_stage = stage_short_name;
      }
      
    } //stage for ends
    
  }
  
  //start code to draw cube and Expression images ----------------------------------------
  
	//return error if input gene was not found
	if (!genes[0]) {
		alert("Gene id not found or gene not expressed");
	}
  
	//display query gene name
	$('#gene').val(genes[0]);
  
	//set correlation filter value
	$('#correlation_filter').val(correlation_filter);
  
  
  //set canvas width
  var canvas_width = 1025;
  var canvas_height = 1200;

  //set variables
  var x_margin = canvas_width -50 - stages.length*20 - tissues.length*15;


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
  setup_cube(canvas,canvas_height,canvas_width,x_margin,genes,stages,tissues,aoaoa,gene_locus_id,gene_descriptions,current_page,pages_num,expression_unit,bg_color_hash,gst_sem_hohoh);


  //print Expression images
  var expr_imgs_loaded = 0;
  var img_canvas;
  
  $("#expr_imgs_tab").click(function(){
    // alert("images: "+expr_imgs_loaded);
    if (!expr_imgs_loaded) {
      
      $("#loading_modal").modal("show");
      
      //define canvas for Expression Images
      img_canvas = new Kinetic.Stage({
        container: "container_tissues",
        width: 1025,
        height: 1200
      });
      
      
      draw_expression_images(img_canvas,canvas_height,canvas_width,stage_ids_array,stage_hash,tissue_hash,gst_expr_hohoh,genes,tissues);
      expr_imgs_loaded = 1;
      
      setTimeout($("#loading_modal").modal("hide"), 5000);
    }
  });
  
  //get d3heatmap html file
  var d3heatmap_loaded = 0;
  $("#heatmap_tab").click(function(){
    
    if (!d3heatmap_loaded) {
    
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
      // alert("heatmap: "+heatmap_filename);
      
      // document.getElementById('my_iframe').src = heatmap_filename;
    }
    
  });
  
  
  
  
  
  //code to change tabs content
  $("#cube_tab").on('click', function(e)  {
    var currentAttrValue = jQuery(this).attr('href');
    // Show/Hide Tabs
    $(currentAttrValue).show().siblings().hide();
    // jQuery('.tabs ' + currentAttrValue).show().siblings().hide();

    // Change/remove current tab to active
    $(this).parent('li').addClass('active').siblings().removeClass('active');

    e.preventDefault();
  });
  
});


