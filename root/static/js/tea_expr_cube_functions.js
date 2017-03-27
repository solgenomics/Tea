
  // pagination code
  function draw_pagination(total_width,page_y,current_page,pages_num,moving_slice_group) {
    
    //x position to start the pagination elements
    var x_margin = total_width-155;
    
    var pages_group = new Kinetic.Group();

    //triangle to first page
    var first_triangle_group = new Kinetic.Group();
    var arrow_first = new Kinetic.Line({
      points: [x_margin-140, page_y+22,x_margin-150, page_y+15,x_margin-140, page_y+8,x_margin-140, page_y+22],
      stroke: "#111",
      strokeWidth: 1,
      closed: true,
      fillLinearGradientStartPoint: {x:x_margin-140, y:page_y+30},
      fillLinearGradientEndPoint: {x:x_margin-140,y:page_y},
      fillLinearGradientColorStops: [0, "#333", 1, "#888"],
      lineCap: 'round',
      tension: 0
    });
    
    var line_first = new Kinetic.Line({
      points: [x_margin-150, page_y+8,x_margin-150, page_y+22],
      stroke: "#111",
      strokeWidth: 1,
    });
    first_triangle_group.add(arrow_first);
    first_triangle_group.add(line_first);

    arrow_first.on('mousedown', function() {
      if (current_page > 1) {
        document.getElementById("page_num").value = 1;
        document.getElementById("search_gene").submit();
      }
    });
    moving_slice_group.add(first_triangle_group);

    //triangle to previous page
    var arrow_prev = new Kinetic.Line({
      points: [x_margin-120, page_y+22,x_margin-130, page_y+15,x_margin-120, page_y+8,x_margin-120, page_y+22],
      stroke: "#111",
      strokeWidth: 1,
      closed: true,
      fillLinearGradientStartPoint: {x:x_margin-120, y:page_y+30},
      fillLinearGradientEndPoint: {x:x_margin-120,y:page_y},
      fillLinearGradientColorStops: [0, "#333", 1, "#888"],
      lineCap: 'round',
      tension: 0
    });
    pages_group.add(arrow_prev);

    arrow_prev.on('mousedown', function() {
      if (current_page > 1) {
        document.getElementById("page_num").value = +current_page - 1;
        document.getElementById("search_gene").submit();
      }
    });

    //print page number links
    var page_index = current_page - 3;
    var page_x_index = x_margin - 105;

    for (var i=0; i<7; i++) {
      if (page_index <= pages_num && page_index > 0) {
        draw_page_numbers(page_index, page_x_index, page_y, pages_group,pages_num);
      }
      page_index++;
      page_x_index = page_x_index + 30;
    }
    moving_slice_group.add(pages_group);

    //underline the current page
    var underline = new Kinetic.Line({
      points: [x_margin - 12, page_y+28, x_margin + 6, page_y+28],
      stroke: "#4387FD",
      strokeWidth: 2,
    });
    pages_group.add(underline);

    //triangle to next page
    var arrow_right = new Kinetic.Line({
      points: [x_margin+110, page_y+22,x_margin+120, page_y+15,x_margin+110, page_y+8,x_margin+110, page_y+22],
      stroke: "#111",
      strokeWidth: 1,
      closed: true,
      fillLinearGradientStartPoint: {x:x_margin-90, y:page_y+30},
      fillLinearGradientEndPoint: {x:x_margin-90,y:page_y},
      fillLinearGradientColorStops: [0, "#333", 1, "#888"],
      lineCap: 'round',
      tension: 0
    });
    pages_group.add(arrow_right);

    arrow_right.on('mousedown', function() {
      if (current_page < pages_num) {
        document.getElementById("page_num").value = +current_page + 1;
        document.getElementById("search_gene").submit();
      }
    });

    //triangle to last page
    var last_triangle_group = new Kinetic.Group();
    var arrow_last = new Kinetic.Line({
      points: [x_margin+130, page_y+22,x_margin+140, page_y+15,x_margin+130, page_y+8,x_margin+130, page_y+22],
      stroke: "#111",
      strokeWidth: 1,
      closed: true,
      fillLinearGradientStartPoint: {x:x_margin-90, y:page_y+30},
      fillLinearGradientEndPoint: {x:x_margin-90,y:page_y},
      fillLinearGradientColorStops: [0, "#333", 1, "#888"],
      lineCap: 'round',
      tension: 0
    });
    var line_last = new Kinetic.Line({
      points: [x_margin+140, page_y+8,x_margin+140, page_y+22],
      stroke: "#111",
      strokeWidth: 1,
    });
    last_triangle_group.add(arrow_last);
    last_triangle_group.add(line_last);
    
    arrow_last.on('mousedown', function() {
      if (current_page < pages_num) {
        document.getElementById("page_num").value = pages_num;
        document.getElementById("search_gene").submit();
      }
    });
    
    pages_group.add(arrow_first);
    pages_group.add(arrow_last);
    
    pages_group.on('mouseover', function() {
        document.body.style.cursor = 'pointer';
    });
    pages_group.on('mouseout', function() {
        document.body.style.cursor = 'default';
    });
    
    
  	moving_slice_group.add(last_triangle_group);

    //text ranking
    var ranking_text = new Kinetic.Text({
      x: x_margin - 50,
      y: page_y + 40,
      text: "Page Ranking "+current_page+"/"+pages_num,
      fontFamily: 'Helvetica',
      fontSize: '16',
      fontVariant: 'small-caps',
      fill: "black"
    });
    moving_slice_group.add(ranking_text);
    
    
    //download button
    var download_group = new Kinetic.Group();
    
    var download_button = new Kinetic.Rect({
      x: x_margin - 120,
      y: page_y + 70,
      width: 230,
      height: 25,
      strokeWidth: 0,
      cornerRadius : 5,
      fill:'#777',
    });
    download_group.add(download_button);
    
    //button text
    var download_text = new Kinetic.Text({
      x: x_margin - 112,
      y: page_y + 74,
      text: "Download expression data",
      fontSize: '18',
      fill: "#fff",
      fontFamily: 'Helvetica',
    });
    download_group.add(download_text);
    
    download_group.on('mouseover', function() {
      download_text.fill("#555");
      download_button.fill("#bbb");
      download_group.draw();
      document.body.style.cursor = 'pointer';
    });
    download_group.on('mouseout', function() {
      download_text.fill("#fff");
      download_button.fill("#777");
      download_group.draw();
      document.body.style.cursor = 'default';
    });
    
    download_group.on('mousedown', function() {
      document.getElementById("download_data").submit();
    });
    
    moving_slice_group.add(download_group);
    
  }


  //function to draw the central page numbers for the cube pagination
  function draw_page_numbers(page_index, page_x_index, y_margin, pages_group, pages_num) {
    
    var central_page = new Kinetic.Text({
      x: page_x_index,
      y: y_margin + 5,
      text: page_index,
      fontSize: '20',
      fill: "#4387FD",
    });
    
    if (page_index >=1 && page_index <=9) {
      central_page.x(page_x_index+5)
    }
    
    central_page.on('mousedown', function() {
      document.getElementById("page_num").value = page_index;
      document.getElementById("search_gene").submit();
    });
    pages_group.add(central_page);
  }


// function to draw the tiles of the cube. It is called several times to draw just the initial top, front and right tiles and then the top tiles from each gene when clicking on the gene name
  function add_tiles_and_stage_name(n,s_index,t_index,x_margin,y_margin,aoa,sq_size,slice_group,stage_names,tissue_names,bg_color_hash,tile_popup_layer,draw_names,draw_top,draw_right,draw_front) {
        
        // get expression color
        var expr_val = aoa[n-1][s_index-1][t_index-1];
        
        if (expr_val == 0.000001) {
          expr_val = "ND";
        }
        
        var sqr_color = 'rgb(210,210,210)';

        if (expr_val != "ND") {
          var rgb_array = get_expr_color(expr_val);
          sqr_color = 'rgb('+rgb_array[0]+','+rgb_array[1]+','+rgb_array[2]+')';
        }
        
        //set coordinates
        var x_start = x_margin - t_index*15; //move left next stage row
        var ny = y_margin + t_index*15;

        var nx = x_start -15  +s_index*sq_size + (t_index-1)*5;
        var top_tile_id = "top_"+n+"_"+(t_index-1)+"_"+(s_index-1);
        
        //change underscores by spaces
        var stage_name = stage_names[s_index-1].replace(/_/g, " ");
        var tissue_name = tissue_names[t_index-1].replace(/_/g, " ");
        
        //create top tiles
        if (draw_top) {
          
          var top_tile = new Kinetic.Line({
            id: top_tile_id,
            points: [(nx+15), ny, (nx+35), ny, (nx+25), ny+15, nx+5, ny+15],
            fill: sqr_color,
            stroke: 'rgb(50,50,50)',
            strokeWidth: 1,
            closed: true
          });
          
          //show values on mouseover
          top_tile.on('mouseover', function() {
            var top_tile_y = this.getAbsolutePosition().y+ny;
          
            top_tile.fill("#529dfb");
            top_tile.draw();
          
            var tile_txt = new Kinetic.Text({
              x: nx,
              y: top_tile_y + 7 - sq_size*2,
              text: stage_name+" - "+tissue_name+": "+expr_val,
              fontSize: 16,
              align: 'right',
              fontFamily: 'Helvetica',
              fill: "black"
            });
          
            tile_txt.x(nx-tile_txt.width()+25);
          
            var tile_popup = new Kinetic.Rect({
              x: tile_txt.x()-5,
              y: top_tile_y - sq_size*2,
              fill: '#fff',
              opacity: 0.9,
              width: tile_txt.width()+10,
              height: 30,
              cornerRadius: 5,
              stroke: 'rgb(100,100,100)',
              strokeWidth: 1,
            });

            tile_popup_layer.add(tile_popup);
            tile_popup_layer.moveToTop();
            tile_popup_layer.add(tile_txt);
            tile_popup_layer.draw();
          }); //close mouseover

          //on mouseout remove popups
          top_tile.on('mouseout', function() {
            top_tile.fill(sqr_color);
            top_tile.draw();
          
            tile_popup_layer.removeChildren();
            tile_popup_layer.draw();
          });
        
          slice_group.add(top_tile);
        
        }; //close create top tiles
        
        // draw right tile
        if (draw_right) {
          if (s_index == stage_names.length) {
            nx = s_index*sq_size + x_start-10 + (t_index-1)*5;
            
            var right_tile = new Kinetic.Line({
              points: [nx+sq_size, ny+15, nx+30, ny, nx+30, ny+sq_size, nx+sq_size, ny+35],
              fill: sqr_color,
              stroke: 'rgb(50,50,50)',
              strokeWidth: 1,
              closed: true
            });
            
            slice_group.add(right_tile);
          };
        }; // close draw right tile
      
        //add front tiles for last stages
        if (draw_front) {
          if (t_index == tissue_names.length) {
            nx = s_index*sq_size + x_start-15 + t_index*5;
          
            var front_tile = new Kinetic.Rect({
              x: nx,
              y: ny+15,
              width: sq_size,
              height: sq_size,
              fill: sqr_color,
              stroke: 'rgb(50,50,50)',
              strokeWidth: 1,
            });
            
            slice_group.add(front_tile);
          }
        }
        
        //add stage names to top
        if (draw_names) {
          if (t_index == 1 && n == 1) {
            
            var bg_color = bg_color_hash[stage_names[s_index-1]];
            
            if (bg_color) {
              
              var text_bg_color = new Kinetic.Rect({
                x: x_margin +s_index*20 -15,
                y: y_margin+10,
                width: y_margin,
                height: 20,
                fill: bg_color,
                rotation: 270
              });
              
              slice_group.add(text_bg_color);
            }
            
            var stage_text = new Kinetic.Text({
              x: x_margin +s_index*20 -12,
              y: y_margin+8,
              text: stage_name,
              fontSize: 16,
              fontFamily: 'Helvetica',
              fill: 'black',
              rotation: 270
            });
            
            slice_group.add(stage_text);
          }
        } // close add stage names to top
  }


// function to draw gene name, description and correlation popup when mouse over gene name and the gene top tiles when clicking on gene name
  function add_slice(n,gene_names_array,aoa,stage_names,tissue_names,tmp_layer,canvas,x_margin,y_margin,color_code,correlation,gene_descriptions,gene_ids,current_page,pages_num,genes_num,expr_unit,bg_color_hash,layer_drawn_h) {
    
    var top_y_margin = y_margin;
    var sq_size = 20;
    y_margin = y_margin +n*sq_size;
    x_margin = x_margin + 20;
    
    var slice_group = new Kinetic.Group({
      id: "slice_"+n,
    });
    
    var gene_text = new Kinetic.Text({
      x: x_margin - 10*tissue_names.length,
      y: y_margin +18 +15*tissue_names.length,
      id: "slice_name_"+n,
      // text: gene_test,
      text: gene_names_array[n-1],
      fontSize: 16,
      fontFamily: 'Helvetica',
      fill: "black"
    });
    
    gene_text.x(gene_text.x()-gene_text.width());
    
    
    var gene_popup_layer = new Kinetic.Layer();
    canvas.add(gene_popup_layer);

    gene_text.on('mouseover', function() {
      var x_pos = this.getAbsolutePosition().x;
      var y_pos = this.getAbsolutePosition().y;
      document.body.style.cursor = 'pointer';
      
      var gene_description = gene_descriptions[gene_names_array[n-1]];
      var gene_desc = gene_description;
      
      if (!gene_description) {
        gene_desc = "unknown protein";
      }
      
      var desc_font_size = 16;

      var desc_txt = new Kinetic.Text({
        x: 5,
        y: y_pos-2,
        text: gene_desc,
        fontSize: desc_font_size,
        width: x_pos-80,
        align: 'left',
        fontFamily: 'Helvetica',
        fill: "white"
      });
      
      var desc_height = 30;
      if (desc_txt.height() > desc_font_size) {
          desc_height = 50;
      }
      if (desc_txt.height() > desc_font_size*2) {
          desc_height = 65;
      }
      

      var gene_popup = new Kinetic.Rect({
        x: 0,
        // x: x_pos-80,
        y: y_pos-10,
        fill: '#000000',
        opacity: 0.8,
        width: x_pos-60,
        // width: 450,
        height: desc_height,
        cornerRadius: 5
      });
      
      
      if (n>1) {
        var corr_popup = new Kinetic.Rect({
          x: x_pos-50,
          y: y_pos-10,
          fill: '#000000',
          opacity: 0.8,
          width: 40,
          height: 30,
          cornerRadius: 5
        });
        
        var corr_txt = new Kinetic.Text({
          x: x_pos-45,
          y: y_pos-3,
          text: correlation[n-2],
          fontSize: 16,
          fontFamily: 'Helvetica',
          fill: "white"
        });

        gene_popup_layer.add(corr_popup);
        gene_popup_layer.moveToTop();
        gene_popup_layer.add(corr_txt);
      }
      gene_popup_layer.add(gene_popup);
      gene_popup_layer.moveToTop();
      gene_popup_layer.add(desc_txt);
      gene_popup_layer.draw();
    });
    
    gene_text.on('mouseout', function() {
      document.body.style.cursor = 'default';
      gene_popup_layer.removeChildren();
      gene_popup_layer.draw();
    });
    
    var moving_slice_group = new Kinetic.Group({
      id: "full_slice_"+n,
    });

    if (n == 1) {
      gene_text.fill("#0000EE");
      for (var j=1; j<=tissue_names.length; j++) {
        for (var i=stage_names.length; i>=1; i--) {
          add_tiles_and_stage_name(1,i,j,x_margin,y_margin,aoa,sq_size,slice_group,stage_names,tissue_names,bg_color_hash,gene_popup_layer,1,1,1,1);
        }
      }
      
    } else {
      moving_slice_group = new Kinetic.Group({
        id: "full_slice_"+n,
        name: 'slice_up',
      });
      
      for (var j=1; j<=tissue_names.length; j++) {
        for (var i=stage_names.length; i>=1; i--) {
          add_tiles_and_stage_name(n,i,j,x_margin,y_margin,aoa,sq_size,slice_group,stage_names,tissue_names,bg_color_hash,gene_popup_layer,0,0,1,1);
        }
      }
      
    }
    
    var genes_number_in_cube = 15; //for pagination only
    var page_y = 70 + top_y_margin + genes_number_in_cube*sq_size + 15*tissue_names.length; //for pagination only
    
    //draw the pagination on bottom of the cube
    if (n == genes_num) {
      var canvas_width = canvas.width();
      draw_pagination(canvas_width,page_y,current_page,pages_num,moving_slice_group);
    }
    
    gene_text.on('mousedown', function() {
      
      if (!layer_drawn_h[gene_names_array[n-1]]) {
        for (var j=1; j<=tissue_names.length; j++) {
          for (var i=stage_names.length; i>=1; i--) {
            add_tiles_and_stage_name(n,i,j,x_margin,y_margin,aoa,sq_size,slice_group,stage_names,tissue_names,bg_color_hash,gene_popup_layer,0,1,0,0);
          }
        }
        
        layer_drawn_h[gene_names_array[n-1]] = 1;
      }
      
      // var y_layer_dist = stage_names.length*15 + 5;
      var y_layer_dist = tissue_names.length*15 + 5;
      
      for (var i=0;i<=gene_names_array.length;i++) {
        if (i>=n) {
          
          var other_layer = canvas.find("#full_slice_"+i);
          
          if (moving_slice_group.name() == "slice_down") {
            other_layer.move({
              y: -y_layer_dist
            });
          } else if (moving_slice_group.name() == "slice_up") {
            other_layer.move({
              y: y_layer_dist
            });
          }
        }
      }
      
      if (moving_slice_group.name() == "slice_up") {
        moving_slice_group.name("slice_down");
      } else if (moving_slice_group.name() == "slice_down") {
        moving_slice_group.name("slice_up");
      }
      tmp_layer.draw();
    });
    
    slice_group.on('mousedown', function() {
      open_bar_graph_dialog(aoa[n-1],gene_names_array[n-1],correlation[n-2], gene_descriptions[gene_names_array[n-1]], gene_ids[gene_names_array[n-1]], stage_names, tissue_names, expr_unit);
      tmp_layer.draw();
    });
    
    slice_group.on('mouseover', function() {
        document.body.style.cursor = 'pointer';
    });
    slice_group.on('mouseout', function() {
        document.body.style.cursor = 'default';
    });
    
    moving_slice_group.add(slice_group);
    moving_slice_group.add(gene_text);
    tmp_layer.add(moving_slice_group);
    canvas.add(tmp_layer);
    
  }


  function add_tissue_names(x_margin,y_margin,tissue_name,x_margin2,tmp_cube_layer,canvas_tmp,bg_color_hash) {
    
    var bg_color = bg_color_hash[tissue_name];
    
    tissue_name = tissue_name.replace(/_/g, " "); //replace underscores in stage names by spaces
    
    //Tissue names for the cube
    var tissue_text = new Kinetic.Text({
      x: x_margin-112,
      y: y_margin-92,
      text: tissue_name,
      width: 250,
      align: 'right',
      fontSize: 16,
      fontFamily: 'Helvetica',
      fill: 'black',
      rotation: 35
    });
    
    if (tissue_name) {
      if (bg_color) {
        var text_bg_color = new Kinetic.Rect({
          // x: x_margin-55,
          // y: y_margin-52,
          x: x_margin+84,
          y: y_margin+66,
          width: tissue_text.width(),
          // width: tissue_name.length*9,
          // width: 250,
          height: 19,
          fill: bg_color,
          rotation: 215
        });
      
        tmp_cube_layer.add(text_bg_color);
      }
    }
    
    tmp_cube_layer.add(tissue_text);
    canvas_tmp.add(tmp_cube_layer);
  }


  function add_color_grad_legend(tmp_layer,stage,expr_unit) {
    
    var color = ['rgb(80,0,0)','rgb(255,0,0)','rgb(255,130,0)','rgb(255,195,125)','rgb(255,233,199)','rgb(255,255,120)','rgb(255,255,230)'];
    var x_pos = 20; // margin from right
    var y_pos = 15; //margin from top
    
    var grad_legend = new Kinetic.Rect({
      x: x_pos+10,
      y: y_pos+20,
      width: 20,
      height: 400,
      fillLinearGradientStartPoint: {x:0, y:0},
      fillLinearGradientEndPoint: {x:0,y:400},
      fillLinearGradientColorStops: [0, color[0], 0.2, color[1], 0.4, color[2], 0.6, color[3], 0.75, color[4], 0.9, color[5], 0.98, color[6]],
      // fillLinearGradientColorStops: [0, color[0], 0.2, color[1], 0.4, color[2], 0.6, color[3], 0.75, color[4], 0.9, color[5], 0.99, color[6], 1, 'rgb(255,255,255)'],
      stroke: 'rgb(50,50,50)',
      strokeWidth: 1,
    });
  
    var legend_bottom = new Kinetic.Rect({
      x: x_pos+11,
      y: y_pos+414,
      width: 18,
      height: 5,
      fill: 'rgb(255,255,255)',
      // fill: 'rgb(220,220,220)',
      strokeWidth: 0
    });
  
    var top_text = new Kinetic.Text({
      x: x_pos+2,
      y: y_pos,
      text: expr_unit,
      fontSize: 14,
      fontFamily: 'Helvetica',
      fill: "black",
      align: 'center'
    });
    
		var mid1_text = new Kinetic.Text({
			x: x_pos+35,
			y: y_pos+80,
			text: "300",
			fill: "black"
		});
	
		var mid2_text = new Kinetic.Text({
			x: x_pos+35,
			y: y_pos+160,
			text: "100",
			fill: "black"
		});
	
		var mid3_text = new Kinetic.Text({
			x: x_pos+35,
			y: y_pos+240,
			text: "10",
			fill: "black"
		});
	
		var min2_text = new Kinetic.Text({
			x: x_pos+35,
			y: y_pos+320,
			text: "1",
			fill: "black"
		});
	
		var min_text = new Kinetic.Text({
			x: x_pos+35,
			y: y_pos+415,
			text: "0",
			fill: "black"
		});
	
		var no_data_square = new Kinetic.Rect({
			x: x_pos+10,
			y: y_pos+430,
			width: 20,
			height: 20,
			fill: 'rgb(210,210,210)',
      // fill: 'white',
			stroke: 'rgb(50,50,50)',
			strokeWidth: 1,
		});
    
		var no_data_text = new Kinetic.Text({
			x: x_pos,
			y: y_pos+455,
			text: "No data",
			fill: "black"
    });


    tmp_layer.add(no_data_text);
    tmp_layer.add(no_data_square);
    tmp_layer.add(grad_legend);
    tmp_layer.add(legend_bottom);
    tmp_layer.add(min_text);
    tmp_layer.add(min2_text);
    tmp_layer.add(mid1_text);
    tmp_layer.add(mid2_text);
    tmp_layer.add(mid3_text);
    tmp_layer.add(top_text);

    stage.add(tmp_layer);
  }


  function draw_cube(genes,stages,tissues,expr_val,tmp_layer,tmp_canvas,top_x_start,y_margin,gene_ids,gene_descriptions,current_page,pages_num,page_width,expr_unit,bg_color_hash) {
    tmp_layer.removeChildren();
    var color_code = $('#color_code').val();
    var genes_num = genes.length;
    
    var layer_drawn_hash = new Object();
    
    for (var i=genes_num; i>=1; i--) {
      add_slice(i,genes,expr_val,stages,tissues,tmp_layer,tmp_canvas,top_x_start,y_margin,color_code,corr_values,gene_descriptions,gene_ids,current_page,pages_num,genes_num,expr_unit,bg_color_hash,layer_drawn_hash);
    }
    
    //draw tissue names
    for (var i=0; i<tissues.length; i++) {
      var x = top_x_start -75 - i*10;
      var y = y_margin -18 + i*15;
      var x2 = top_x_start -650 + i*180;
      add_tissue_names(x,y,tissues[i],x2,tmp_layer,tmp_canvas,bg_color_hash);
    }
    
    //define the legend canvas
    var legend_canvas = new Kinetic.Stage({
      container: "container_legend",
      width: 98,
      height: 498
    });
    var legend_layer = new Kinetic.Layer();
    
    add_color_grad_legend(legend_layer,legend_canvas,expr_unit)
  }

  function setup_cube(canvas,canvas_h,canvas_w,cube_x_margin,gene_a,stage_a,tissue_a,AoAoA,locus_id,gene_desc,c_page,pages_number,expr_unit,bg_color_hash) {
    
    var frame_height = $('#container').css("height");
    var container_height = frame_height.replace("px","");
    
    if (canvas_h > container_height) {
      $('#container').css("height",canvas_h+"px");
    }
    
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
    
    draw_cube(gene_a,stage_a,tissue_a,AoAoA,cube_layer,canvas,top_x_start,y_margin,locus_id,gene_desc,c_page,pages_number,canvas_w,expr_unit,bg_color_hash);
  }


