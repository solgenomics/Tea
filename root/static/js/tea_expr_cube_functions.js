
  // pagination code
  function draw_pagination(page_y,current_page,pages_num,moving_slice_group) {
    
    var x_margin = 960 //x position to start the pagination elements
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

  	first_triangle_group.on('mousedown', function() {
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
    
  	last_triangle_group.on('mousedown', function() {
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
      x: x_margin - 55,
      y: page_y + 40,
      text: "Ranking "+current_page+"/"+pages_num,
			fontFamily: 'Helvetica neue',
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
			stroke: '#aaa',
			strokeWidth: 1,
      cornerRadius : 5,
      fill:'#aaa',
		});
    download_group.add(download_button);
    
    //button text
    var download_text = new Kinetic.Text({
      x: x_margin - 112,
      y: page_y + 73,
      text: "Download expression data",
      fontSize: '18',
      fill: "#efefef",
      fontFamily: 'Helvetica neue',
    });
    download_group.add(download_text);
    
    download_group.on('mouseover', function() {
        document.body.style.cursor = 'pointer';
    });
    download_group.on('mouseout', function() {
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


	function add_slice(n,gene_names_array,aoa,stage_names,tissue_names,tmp_layer,canvas,x_margin,y_margin,color_code,correlation,gene_descriptions,gene_ids,current_page,pages_num,genes_num) {
		
    var top_y_margin = y_margin;
		var sq_size = 20;
		y_margin = y_margin +n*sq_size;
		x_margin = x_margin + 20;
		
		var slice_group = new Kinetic.Group({
			id: "slice_"+n,
		});
		
		var gene_text = new Kinetic.Text({
			x: x_margin -120 - 10*stage_names.length,
			y: y_margin +18 +15*stage_names.length,
			id: "slice_name_"+n,
			text: gene_names_array[n-1],
			fontSize: 16, //20 for CondensedLight
			fontFamily: 'Helvetica',
			// fontFamily: 'CondensedLight',
			fill: "black"
		});
		
		var gene_popup_layer = new Kinetic.Layer();
		canvas.add(gene_popup_layer);
		
		gene_text.on('mouseover', function() {
			var x_pos = this.getAbsolutePosition().x-510;
			var y_pos = this.getAbsolutePosition().y-10;
      document.body.style.cursor = 'pointer';
			
			var gene_description = gene_descriptions[gene_names_array[n-1]];
			var gene_desc = '';
			
			if (gene_description.length > 60) {
				gene_desc = gene_description.slice(0, 60)+" ...";
			} else {
				gene_desc = gene_description;
			}
			
			var gene_popup = new Kinetic.Rect({
        x: x_pos-80,
        y: y_pos,
        fill: '#000000',
        opacity: 0.7,
        width: 530,
        height: 30,
        cornerRadius: 10
			});
			
			var desc_txt = new Kinetic.Text({
				x: x_pos-75,
				y: y_pos+8,
				text: gene_desc,
				fontSize: 16, //20 for CondensedLight
				// fontFamily: 'CondensedLight',
				fontFamily: 'Arial',
				fill: "white"
			});
			if (n>1) {
        var corr_popup = new Kinetic.Rect({
          x: x_pos+455,
          y: y_pos,
          fill: '#000000',
          opacity: 0.8,
          width: 40,
          height: 30,
          cornerRadius: 10
				});
			
				var corr_txt = new Kinetic.Text({
					x: x_pos+460,
					y: y_pos+8,
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
		
		
    // var circle = new Kinetic.Circle({
    //   x: x_margin -155,
    //   y: y_margin +68,
    //   radius: 3,
    //   fill: 'white',
    //   stroke: 'black',
    //   strokeWidth: 1,
    //   id: "circle_"+n,
    //   name: "gene_circle"
    // });

		var moving_slice_group = new Kinetic.Group({
			id: "full_slice_"+n,
		});

		if (n == 1) {
			gene_text.fill("#0000EE");
			// gene_text.fontStyle("bold");
		} else {
			moving_slice_group = new Kinetic.Group({
				id: "full_slice_"+n,
				name: 'slice_up',
			});
		}
	
    // moving_slice_group.add(circle);


		// add stage and tissue names to the first gene
		for (var j=1; j<=stage_names.length; j++) {
			for (var i=tissue_names.length; i>=1; i--) {
        var x_start = x_margin - j*15; //move left next stage row
        // var nx = i*sq_size + x_start;
				var ny = y_margin + j*15;
			
				var rgb_color_array = get_expr_color(aoa[n-1][j-1][i-1]);
				var sqr_color = 'rgb('+rgb_color_array[0]+','+rgb_color_array[1]+','+rgb_color_array[2]+')';
				
        var nx = x_start -15  +i*sq_size + (j-1)*5;
        // nx = nx-15 + (j-1)*5;
				var top_tile = new Kinetic.Line({
					points: [(nx+15), ny, (nx+35), ny, (nx+25), ny+15, nx+5, ny+15],
					fill: sqr_color,
					stroke: 'black',
					strokeWidth: 1,
					closed: true
				});
        // nx = i*sq_size + x_start;
			
				slice_group.add(top_tile);
			  
        //add right tiles for the last tissue
				if (i == tissue_names.length) {
					nx = i*sq_size + x_start-10 + (j-1)*5;
          // nx = nx-10 + (j-1)*5;
					var right_tile = new Kinetic.Line({
						points: [nx+sq_size, ny+15, nx+30, ny, nx+30, ny+sq_size, nx+sq_size, ny+35],
						fill: sqr_color,
						stroke: 'black',
						strokeWidth: 1,
						closed: true
					});
				
					slice_group.add(right_tile);
				}
      
			  //add front tiles for last stages
				if (j == stage_names.length) {
				  nx = i*sq_size + x_start-15 + j*5;
          
					var front_tile = new Kinetic.Rect({
						x: nx,
						y: ny+15,
						width: sq_size,
						height: sq_size,
						fill: sqr_color,
						stroke: 'black',
						strokeWidth: 1,
					});
				
					slice_group.add(front_tile);
				
				}
			
			
				if (j == 1 && n == 1) {
					//add tissue names to top layer
					tissue_name = tissue_names[i-1].replace("_", " "); //replace underscores in tissue names by spaces
					
					var tissue_text = new Kinetic.Text({
						x: x_margin +i*20 -12,
						y: y_margin+8,
						text: tissue_name,
						fontSize: 16, //20 for CondensedLight
						fontFamily: 'Helvetica',
						// fontFamily: 'CondensedLight',
						fill: 'black',
						rotation: 270
					});
					
					moving_slice_group.add(tissue_text);
				}
			}
		}
		
		var page_y = 40 + top_y_margin + 20*sq_size + 15*stage_names.length; //for pagination only
    // var page_y = y_margin + 20*sq_size + 10*stage_names.length; //for pagination only
    
    //draw the pagination on bottom of the cube
    if (n == genes_num) {
      draw_pagination(page_y,current_page,pages_num,moving_slice_group);
    }
		
		
		gene_text.on('mousedown', function() {
      var y_layer_dist = stage_names.length*15 + 5;
      
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
			open_bar_graph_dialog(aoa[n-1],gene_names_array[n-1],correlation[n-2], gene_descriptions[gene_names_array[n-1]], gene_ids[gene_names_array[n-1]], stage_names, tissue_names);
      // circle.fill("red");
			tmp_layer.draw();
		});
		
    slice_group.on('mouseover', function() {
        document.body.style.cursor = 'pointer';
    });
    slice_group.on('mouseout', function() {
        document.body.style.cursor = 'default';
    });
    
    
    // moving_slice_group.add(circle);
		moving_slice_group.add(slice_group);
		moving_slice_group.add(gene_text);
		tmp_layer.add(moving_slice_group);
		canvas.add(tmp_layer);
	}


	function add_stage_names(x_margin,y_margin,stage_name,x_margin2,stages_layer,canvas_tmp) {
		
		stage_name = stage_name.replace("_", " "); //replace underscores in stage names by spaces
		
		//Stages for the cube
		var stage_text = new Kinetic.Text({
			x: x_margin,
			y: y_margin,
			text: stage_name,
			width: 105,
			align: 'right',
			fontSize: 16, //20 for CondensedLight
			fontFamily: 'Helvetica',
			// fontFamily: 'CondensedLight',
			fill: 'black',
			rotation: 30
		});
	
		stages_layer.add(stage_text);
		canvas_tmp.add(stages_layer);
	}


	function add_color_grad_legend(page_width,color_string,tmp_layer,stage) {
	
		var color = ['rgb(80,0,0)','rgb(255,0,0)','rgb(255,130,0)','rgb(255,195,125)','rgb(255,233,199)','rgb(255,255,120)','rgb(255,255,230)'];
	  var x_pos = page_width-50; // margin from right
	  var y_pos = 135; //margin from top
    
		var grad_legend = new Kinetic.Rect({
			x: x_pos,
			y: y_pos,
			width: 20,
			height: 400,
			fillLinearGradientStartPoint: {x:0, y:0},
			fillLinearGradientEndPoint: {x:0,y:400},
			fillLinearGradientColorStops: [0, color[0], 0.2, color[1], 0.4, color[2], 0.6, color[3], 0.75, color[4], 0.9, color[5], 0.99, color[6], 1, 'rgb(255,255,255)'],
			stroke: 'black',
			strokeWidth: 1,
		});
	
		var top_text = new Kinetic.Text({
			x: x_pos-8,
      y: y_pos-20,
			text: "RPKM",
			fontSize: 14,
			fontFamily: 'Helvetica',
			fill: "black",
			align: 'center'
		});
	
		var mid1_text = new Kinetic.Text({
			x: x_pos+25,
			y: y_pos+60,
			text: "300",
			fill: "black"
		});
	
		var mid2_text = new Kinetic.Text({
			x: x_pos+25,
			y: y_pos+140,
			text: "100",
			fill: "black"
		});
	
		var mid3_text = new Kinetic.Text({
			x: x_pos+25,
			y: y_pos+220,
			text: "10",
			fill: "black"
		});
	
		var min2_text = new Kinetic.Text({
			x: x_pos+25,
			y: y_pos+300,
			text: "1",
			fill: "black"
		});
	
		var min_text = new Kinetic.Text({
			x: x_pos+25,
			y: y_pos+395,
			text: "0",
			fill: "black"
		});
	
		tmp_layer.add(grad_legend);
		tmp_layer.add(min_text);
		tmp_layer.add(min2_text);
		tmp_layer.add(mid1_text);
		tmp_layer.add(mid2_text);
		tmp_layer.add(mid3_text);
		tmp_layer.add(top_text);
		
		stage.add(tmp_layer);
	}


	function draw_cube(genes,stages,tissues,expr_val,tmp_layer,tmp_canvas,top_x_start,y_margin,gene_ids,gene_descriptions,current_page,pages_num,page_width) {
		tmp_layer.removeChildren();
		var color_code = $('#color_code').val();
		var genes_num = genes.length;
		
		for (var i=genes_num; i>=1; i--) {
			add_slice(i,genes,expr_val,stages,tissues,tmp_layer,tmp_canvas,top_x_start,y_margin,color_code,corr_values,gene_descriptions,gene_ids,current_page,pages_num,genes_num);
		}
	
		//draw stage names
		for (var i=0; i<stages.length; i++) {
			var x = top_x_start -75 - i*10;
			var y = y_margin -18 + i*15;
			var x2 = top_x_start -650 + i*180;
			add_stage_names(x,y,stages[i],x2,tmp_layer,tmp_canvas);
		}
		
		add_color_grad_legend(page_width,color_code,tmp_layer,tmp_canvas)
	}



