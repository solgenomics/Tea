//draw the stage name.
function draw_stage_name(x_offset,y_offset,one_tissue_layer,canvas,img_width,stg_label,title_y_offset) {
  stg_name = stg_label.replace(/_/g," ");

    var stage_img_text = new Kinetic.Text({
      x: x_offset,
      y: y_offset + 20 - title_y_offset,
      align: "center",
      text: stg_name,
      fontSize: 20,
      fontFamily: 'Helvetica',
      fill: 'black',
      width: img_width-10,
    });
    one_tissue_layer.add(stage_img_text);
    canvas.add(one_tissue_layer);
}


function iterate_by_stage(n,stage_h,stage_ids_a,j_index,x_offset,y_offset,prev_stage,prev_stage2,title_y_offset,highest_row,canvas_width) {
  
  var next_stage = "";
  var next_short_name = "";
  var img_name = stage_h[stage_ids_a[n]]["image_name"];
  var img_width = stage_h[stage_ids_a[n]]["image_width"]*1;
  var img_height = stage_h[stage_ids_a[n]]["image_height"]*1;
  var stage_name = stage_h[stage_ids_a[n]]["stage_name"];
  
  var next_img_width;
  
  if (stage_h[stage_ids_a[n+1]]) {
    next_img_width = stage_h[stage_ids_a[n+1]]["image_width"]*1
  } 
  else {
    next_img_width = img_width;
  }
  
  if (img_height > highest_row) {
    highest_row = img_height;
  }
  
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
  else if (stage_short_name == prev_stage && x_offset + img_width + next_img_width <= canvas_width) {
    x_offset = x_offset + img_width;
  }
  //new line -- if starting a set of stages or over the limit
  else if (stage_short_name == next_short_name || x_offset + img_width + next_img_width > canvas_width) {
    x_offset = 0;
    j_index = 1;
    y_offset = y_offset + highest_row + title_y_offset*2;
    highest_row = 0;
  }
  //new line -- if not belong to a set of stages
  else if (stage_short_name != prev_stage && prev_stage2 && prev_stage == prev_stage2) {
    x_offset = 0;
    j_index = 1;
    y_offset = y_offset + highest_row + title_y_offset*2;
    highest_row = 0;
  }
  //same line
  else {
    x_offset = x_offset + img_width;
  }
  
  return [x_offset,y_offset,j_index,stage_name,img_name,img_width,img_height,stage_short_name,highest_row];
}


function draw_expression_images(img_canvas,canvas_w,stage_ids_a,stage_h,tissue_h,gst_expr_hhh,gene_a,tissue_a) {
  
  var x_offset = 0;
  var y_offset = 0;
  var label_y_offset = 70;
  var highest_in_row = 0;
  
  img_canvas.width(canvas_w);
  
  var tissue_layer = new Kinetic.Layer();
  
  prev_stage = "";
  prev_stage2 = "";
  j_index = 0;
  
  img_canvas.height(y_offset+label_y_offset);
  
  //second round to draw only tissue layer over the stage images from the first round (output more reliable?)
  for (var n = 0; n < stage_ids_a.length; n++) {
    
    if (tissue_h[stage_ids_a[n]]) {
      
      var img_canvas_tmp_height = img_canvas.height();
      
      [x_offset,y_offset,j_index,stage_name,img_name,img_width,img_height,stage_short_name,highest_in_row] = iterate_by_stage(n,stage_h,stage_ids_a,j_index,x_offset,y_offset,prev_stage,prev_stage2,label_y_offset,highest_in_row,canvas_w);
      
      var stage_top_label = stage_h[stage_ids_a[n]]["stage_top_label"];
      
      draw_stage_name(x_offset,y_offset,tissue_layer,img_canvas,img_width,stage_top_label,label_y_offset);
      if (img_name) {
        load_stage_image(x_offset,y_offset,tissue_layer,img_canvas,img_name,img_width,img_height);
      }
      
      //display overlapping tissue imgs and group them
      var tissue_img_group = new Kinetic.Group();
      for (var i = 0; i<tissue_h[stage_ids_a[n]]["image_name"].length; i++) {
      
        var tisue_name = tissue_h[stage_ids_a[n]]["tissue_name"][i];
      
        var expr_val = gst_expr_hhh[gene_a[0]][stage_name][tisue_name];
        
        var r = 210;
        var g = 210;
        var b = 210;
        
        if (expr_val != 0.000001) {
          var rgb_color_array = get_expr_color(expr_val);

          r = rgb_color_array[0];
          g = rgb_color_array[1];
          b = rgb_color_array[2];
        }

        var image_name = tissue_h[stage_ids_a[n]]["image_name"][i];
      
        img_width = tissue_h[stage_ids_a[n]]["image_width"][i]*1;
        img_height = tissue_h[stage_ids_a[n]]["image_height"][i]*1;

        load_tissue_image(x_offset,y_offset,r,g,b,tissue_layer,img_canvas,img_width,img_height,tissue_img_group,image_name);
        tissue_layer.draw();
      } //for tissues end

      tissue_expr_popup(img_canvas,tissue_img_group,tissue_h[stage_ids_a[n]],gst_expr_hhh[gene_a[0]][stage_name],tissue_a,x_offset,y_offset,img_width,img_height,canvas_w);

      tissue_layer.draw();

      prev_stage2 = prev_stage;
      prev_stage = stage_short_name;
    }
    
  } //stage for ends
  img_canvas.height(img_canvas_tmp_height+y_offset+highest_in_row);
  
}


//load the bg image for each stage. This will be the bg for the tissue layers
function load_stage_image(x_offset,y_offset,one_tissue_layer,canvas,image_name,img_width,img_height) {
  canvas.add(one_tissue_layer);

  var tmp_imgObj = new Image();

  tmp_imgObj.onload = function() {

    var tmp_stage = new Kinetic.Image({
      x: x_offset,
      y: y_offset,
      image: tmp_imgObj,
      width: img_width,
      height: img_height
    });
    one_tissue_layer.add(tmp_stage);
    canvas.add(one_tissue_layer);
  };

  tmp_imgObj.src = '/static/images/expr_viewer/'+image_name;
}


//load the img for each one of the tissue layers
function load_tissue_image(x_offset,y_offset,r_color,g_color,b_color,one_tissue_layer,canvas,img_width,img_height,imgs_group,image_name) {
    
  one_tissue_layer.add(imgs_group);
    canvas.add(one_tissue_layer);

    var tmp_imgObj = new Image();

    tmp_imgObj.onload = function() {

      var tmp_stage = new Kinetic.Image({
        x: x_offset,
        y: y_offset,
        image: tmp_imgObj,
        width: img_width,
        height: img_height
      });
      imgs_group.add(tmp_stage)
      one_tissue_layer.add(imgs_group);
      canvas.add(one_tissue_layer);

      //fix cache bug
      tmp_stage.cache();
      tmp_stage.filters([Kinetic.Filters.RGB]);
      tmp_stage.red(r_color).green(g_color).blue(b_color);
      tmp_stage.draw();
    };//end of onload

    tmp_imgObj.src = '/static/images/expr_viewer/'+image_name;
}


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



function tissue_expr_popup(canvas,tissue_img_group,t_hash,expr_hash,tissues,x_offset,y_offset,img_width,img_height,canvas_width) {
  
    //set values to show popup to the left of last column image
    var panel_width = 300;
    var margin = 30;
    var tissue_num = t_hash["tissue_name"].length;
    
    //calculate panel size
    var panel_height = 2*margin+tissue_num*margin;
    if (t_hash["image_height"][0] > panel_height) {
      y_offset = y_offset + (t_hash["image_height"][0]-panel_height)/4;
    }
    
    var x_arrow = x_offset+img_width;
    var y_arrow = y_offset+50+panel_height/2;
    var last_column = 0;
    
    //calculate panel midle arrow position
    if (x_offset+img_width+panel_width > canvas_width) {
      x_offset = x_offset - img_width - panel_width;
      x_arrow = x_offset+img_width+panel_width;
      last_column = 1;
    }
    
    //create layer to display expression popup
    var tissue_popup_layer = new Kinetic.Layer();
    canvas.add(tissue_popup_layer);
    
    tissue_img_group.on('mouseover', function() {
      document.body.style.cursor = 'pointer';
      
      var arrow_group = new Kinetic.Group();
      
      if (last_column) {
        
        var left_arrow = new Kinetic.Line({
          points: [x_arrow+30,y_arrow-15,    x_arrow,y_arrow-30,    x_arrow,y_arrow,    x_arrow+30,y_arrow-15],
          stroke: "#aaa",
          strokeWidth: 1,
          closed: true,
          fill: '#fff',
          lineCap: 'round',
          tension: 0
        });
        var arrow_junction = new Kinetic.Line({
          points: [x_arrow+28,y_arrow-15,    x_arrow-2,y_arrow-30,    x_arrow-2,y_arrow,    x_arrow+28,y_arrow-15],
          stroke: "#fff",
          strokeWidth: 1,
          closed: true,
          fill: '#fff',
          lineCap: 'round',
          tension: 0
        });
        
      } else {
        
        var left_arrow = new Kinetic.Line({
          points: [x_arrow-30,y_arrow-15,    x_arrow,y_arrow-30,    x_arrow,y_arrow,    x_arrow-30,y_arrow-15],
          stroke: "#aaa",
          strokeWidth: 1,
          closed: true,
          fill: '#fff',
          lineCap: 'round',
          tension: 0
        });
      
        var arrow_junction = new Kinetic.Line({
          points: [x_arrow-28,y_arrow-15,    x_arrow+2,y_arrow-30,    x_arrow+2,y_arrow,    x_arrow-28,y_arrow-15],
          stroke: "#fff",
          strokeWidth: 1,
          closed: true,
          fill: '#fff',
          lineCap: 'round',
          tension: 0
        });
        
      }
      
    	arrow_group.add(left_arrow);
    	arrow_group.add(arrow_junction);
      
      var tissue_popup = new Kinetic.Rect({
        x: x_offset+img_width,
        y: y_offset+50,
        fill: '#fff',
        opacity: 0.95,
        stroke: '#aaa',
        strokeWidth: 1,
        width: panel_width,
        height: panel_height,
        cornerRadius: 5,
      });
      // tissue_popup_layer.add(tissue_popup);
      // tissue_popup.draw();
      arrow_group.add(tissue_popup);
      arrow_junction.moveToTop();
    	tissue_popup_layer.add(arrow_group);
      
      for (var i=0; i<t_hash["tissue_name"].length; i++) {
        
        var expr_val = expr_hash[t_hash["tissue_name"][i]];
        if (expr_val == 0.000001) {
          expr_val = "NA";
        }
        var tissue_name = t_hash["tissue_name"][i].replace("_"," ");

        var tissue_desc_txt = new Kinetic.Text({
          x: x_offset+img_width+10,
          y: y_offset+50+margin+(i*margin),
          text: tissue_name+": "+expr_val,
          fontSize: 18,
          opacity: 1,
          fontFamily: 'Arial',
          fill: "#000"
        });
        // tissue_popup_layer.moveToTop();
        tissue_popup_layer.add(tissue_desc_txt);
        // tissue_popup_layer.cache();
        tissue_popup_layer.moveToTop();
        tissue_popup_layer.draw();
      }
    });

    tissue_img_group.on('mouseout', function() {
      document.body.style.cursor = 'default';
      tissue_popup_layer.removeChildren();
      tissue_popup_layer.draw();
    });
  
}

