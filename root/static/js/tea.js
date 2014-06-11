
$(document).ready(function () {
	// $('#color_code').val("rg");
	
	function dump(arr,level) {
		var dumped_text = "";
		if(!level) level = 0;

		//The padding given at the beginning of the line.
		var level_padding = "";
		for(var j=0;j<level+1;j++) level_padding += "    ";

		if(typeof(arr) == 'object') { //Array/Hashes/Objects 
			for(var item in arr) {
				var value = arr[item];
	
				if(typeof(value) == 'object') { //If it is an array,
					dumped_text += level_padding + "'" + item + "' ...\n";
					dumped_text += dump(value,level+1);
				} else {
					dumped_text += level_padding + "'" + item + "' => \"" + value + "\"\n";
				}
			}
		} else { //Stings/Chars/Numbers etc.
			dumped_text = "===>"+arr+"<===("+typeof(arr)+")";
		}
		return dumped_text;
	}


	function getGeneInfo(gene) {
		
		$.ajax({
			url: 'http://192.168.1.166:3000/api/tea',
			dataType: 'jsonp', // Notice! JSONP <-- P (lowercase)
			timeout: 600000,
			data: { 'gene_name': gene},
			success: function(response) {
				document.getElementById("gene_name").innerHTML = "<a href='http://solgenomics.net/feature/"+response.gene_id+"/details' target='_blank'><img src='/static/images/sgn_logo.png' height='25' title='Connect to SGN for metadata associated with this gene'/> "+response.gene_name+"</a>";
				document.getElementById("gene_desc").innerHTML = response.description;
			},
			error: function(response) {
				alert("An error occurred. The service may not be available right now.");
			}
		});
	}


	function print_bar_chart(t_names,s_names,sxt_values, gene_name) {
		jQuery("#bar_graph").empty();
	
		// alert("data: "+sxt_values);
		
		var plot1 = $.jqplot('bar_graph', sxt_values, {
			title: '',
			animate: true,
			seriesDefaults:{
				shadow: false,
				renderer:$.jqplot.BarRenderer,
				rendererOptions: {
					fillToZero: true,
					barDirection: 'vertical',
					animation: {
						speed: 1000
					},
				},
			},
			series: [
				{label: '10DPA'},
				{label: 'Mature green'},
				{label: 'Pink'},
			],
			highlighter: {
				show: true,
				showMarker:false,
				tooltipAxes: 'y',
				tooltipLocation: 'n',
				formatString:'<div id="bar_tooltip" class="jqplot-highlighter"><p>%s</p></tr></div>'
			},
			axesDefaults: {
				tickRenderer: $.jqplot.CanvasAxisTickRenderer ,
			},
			axes: {
				xaxis: {
					renderer: $.jqplot.CategoryAxisRenderer,
					ticks: t_names,
					tickOptions: {
						angle: -45,
						showGridline: false,
						fontSize: '12pt',
						textColor: 'black',
						fontFamily: 'Arial'
					}
				},
				yaxis: {
					pad: 1.5,
					min: 0,
					tickOptions: {
						angle: 0,
						formatString: "%#.2f  ",
						fontSize: '10pt',
						textColor: 'black',
						fontFamily: 'Arial'
					            },
					labelRenderer: $.jqplot.CanvasAxisLabelRenderer
				}
				        },
			grid: {
				background: "white",
				borderColor: "black",
			},
			seriesColors: ['#20608E','#C80000', '#008800', '#60208E', '#008888'],
			legend: {
				labels: s_names,
				show: true,
				showSwatches: true,
				location: 'ne',
				placement: 'outsideGrid'
			}
		});
		
		
		$.ajax({
			url: 'http://192.168.1.166:3000/api/tea',
			dataType: 'jsonp', // Notice! JSONP <-- P (lowercase)
			timeout: 600000,
			data: { 'gene_name': gene_name},
			success: function(response) {
				document.getElementById("gene_dialog").innerHTML = "<a href='http://solgenomics.net/feature/"+response.gene_id+"/details' target='_blank'><img src='/static/images/sgn_logo.png' height='25' title='Connect to SGN for metadata associated with this gene'/> "+response.gene_name+"</a>";
				document.getElementById("desc_dialog").innerHTML = response.description;
			},
			error: function(response) {
				alert("An error occurred. The service may not be available right now.");
			}
		});
		
	}


	function open_bar_graph_dialog(stage_tissue_values, gene_name) {

		var tissue_names = ["Inner epidermis","Parenchyma","Vascular tissue","Collenchyma","Outer epidermis"];
		var stage_names = ["10DPA", "Mature green", "Pink"];
		// var stage_tissue_values = [[146.25, 180.23, 20.12, 221.16, 60.12],[133.53, 284.63, 38.37, 169.95, 264.21],[12.35, 31.26, 3.18, 10.38, 37.21]];
	
		$(function() {
			$( "#dialog" ).dialog({
				minWidth: 600,
				draggable: true,
				resizable: false,
			});
			$('.ui-dialog :button').blur();
			print_bar_chart(tissue_names,stage_names,stage_tissue_values,gene_name);
		});

	}


	function add_slice(n,gene_names_array,aoa,stage_names,tissue_names,tmp_layer,stage,x_margin,y_margin,color_code) {
		var sq_size = 20;
		y_margin = y_margin +n*sq_size;
		x_margin = x_margin + 20;
		
		var slice_group = new Kinetic.Group({
			id: "slice_"+n,
		});
		
		if (n>1) {
			var moving_slice_group = new Kinetic.Group({
				id: "full_slice_"+n,
				name: 'slice_up',
				// draggable: true,
		        dragBoundFunc: function(pos) {
		          return {
		            x: this.getAbsolutePosition().x,
		            y: pos.y
		          }
		        }
			});
		} else {
			var moving_slice_group = new Kinetic.Group({
				id: "full_slice_"+n,
			});
		}
	
		var gene_text = new Kinetic.Text({
			x: x_margin -140,
			y: y_margin +63,
			id: "slice_name_"+n,
			// text: "Solyc00g0000009",
			text: gene_names_array[n-1],
			fontSize: 14,
			fontFamily: 'Helvetica',
			fill: "black"
		});
		
		
		var circle = new Kinetic.Circle({
		        x: x_margin -150,
		        y: y_margin +69,
		        radius: 3,
		        fill: 'white',
		        stroke: 'black',
		        strokeWidth: 1,
				id: "circle_"+n,
				name: "gene_circle"
		});
		moving_slice_group.add(circle);
		if (n<=1) {
			circle.fill("red");
		}
		
		for (var j=1; j<=stage_names.length; j++) {
			for (var i=tissue_names.length; i>=1; i--) {
				var x_start = x_margin - j*15;
				var nx = i*sq_size + x_start;
				var ny = y_margin + j*15;
			
				var sqr_color = get_expr_color(color_code, aoa[n-1][j-1][i-1]);
				
				nx = nx-15 + (j-1)*5; //change cube orientation
				var top_tile = new Kinetic.Line({
			        points: [(nx+15), ny, (nx+35), ny, (nx+25), ny+15, nx+5, ny+15],
			        // points: [(nx+15), ny, (nx+35), ny, (nx+20), ny+15, nx, ny+15],
			        fill: sqr_color,
			        stroke: 'black',
			        strokeWidth: 1,
			        closed: true
				});
				nx = i*sq_size + x_start; //change cube orientation
			
				slice_group.add(top_tile);
			
			
				if (j == stage_names.length) {
				
					var front_tile = new Kinetic.Rect({
						x: nx,
						y: ny+15,
						width: sq_size,
						height: sq_size,
						fill: sqr_color,
						stroke: 'black',
						strokeWidth: 1,
						// id: "hm"+nx+ny
					});
				
					slice_group.add(front_tile);
				
				}
			
				if (i == tissue_names.length) {
					nx = nx-10 + (j-1)*5;
					var right_tile = new Kinetic.Line({
						points: [nx+sq_size, ny+15, nx+30, ny, nx+30, ny+sq_size, nx+sq_size, ny+35],
				        // points: [nx+sq_size, ny+15, nx+35, ny, nx+35, ny+sq_size, nx+sq_size, ny+35],  //change cube orientation
				        fill: sqr_color,
				        stroke: 'black',
				        strokeWidth: 1,
				        closed: true
					});
				
					slice_group.add(right_tile);
				}
			
				if (j == 1 && n == 1) {
					//add tissue names to top layer
					var tissue_text = new Kinetic.Text({
						x: x_margin +i*20 -10,
						// x: x_margin +i*20 +3, //change cube orientation
						y: y_margin +5,
						text: tissue_names[i-1],
						fontSize: 14,
						fontFamily: 'Helvetica',
						fill: 'black',
						rotation: 270
					});
					
					moving_slice_group.add(tissue_text);
				}
			}
		}
	
	
	
		gene_text.on('mousedown', function() {
			// var all_circles = stage.find(".gene_circle");
			// all_circles.fill("white");
			// circle.fill("red");
			
			for (var i=0;i<=gene_names_array.length;i++) {
				// alert("i: "+i);
				
				// if (i<n) {
				// 	// disappear_animation(other_layer);
				// 	other_layer.opacity(0);
				// } else {
				// 	other_layer.opacity(1);
				// }
				
				
				if (i>=n) {
					var other_layer = stage.find("#full_slice_"+i);
					
					if (moving_slice_group.name() == "slice_down") {
						other_layer.move({
							y: -50
						});
					} else if (moving_slice_group.name() == "slice_up") {
						other_layer.move({
							y: 50
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
		
			// writeMessage("one layer");
		});
	
		slice_group.on('mousedown', function() {
			var all_circles = stage.find(".gene_circle");
			all_circles.fill("white");
			open_bar_graph_dialog(aoa[n-1],gene_names_array[n-1]);
			circle.fill("red");
			tmp_layer.draw();
		});
		
		// gene_text.on('mousedown', function() {
		// 	getGeneInfo(gene_names_array[n-1]);
		// });
		
		
		moving_slice_group.add(circle);
		moving_slice_group.add(slice_group);
		moving_slice_group.add(gene_text);
		tmp_layer.add(moving_slice_group);
		stage.add(tmp_layer);

	}


	function add_stage_names(x_margin,y_margin,stage_name,x_margin2,stages_layer,canvas_tmp) {
		
		//Stages for the cube
		var stage_text = new Kinetic.Text({
			x: x_margin,
			y: y_margin,
			text: stage_name,
			width: 100,
			align: 'right',
			fontSize: 14,
			fontFamily: 'Helvetica',
			fill: 'black',
			rotation: 30
			// rotation: 45 //change cube orientation
		});
	
		//stages for tissue images
		var stage_text_pict = new Kinetic.Text({
			x: x_margin2 -50,
			y: 70,
			text: stage_name,
			fontSize: 16,
			width: 100,
			align: 'center',
			fontFamily: 'Helvetica',
			fill: 'black',
		});
	
		stages_layer.add(stage_text_pict);
		stages_layer.add(stage_text);
		canvas_tmp.add(stages_layer);
	}


	function get_expr_color(color_code,expr_val) {
	
		//get a color from expression value
		var tmp_color;
		// alert(expr_val);
		var color = Math.round(200 + expr_val/155);
		
		if (expr_val <= 1) {
			color = Math.round(50 + expr_val*50);
			tmp_color = 'rgb('+color+','+0+','+0+')';
		} else if (expr_val > 1 && expr_val <= 10) {
			color = Math.round(100 + expr_val*155/10);
			tmp_color = 'rgb('+color+','+0+','+0+')';
		} else if (expr_val > 10 && expr_val <= 100) {
			color = Math.round(155 + expr_val*100/100);
			tmp_color = 'rgb('+color+','+Math.round(color/2)+','+0+')';
		} else if (expr_val > 100 && expr_val <= 300) {
			color = Math.round(100 + expr_val*100/300);
			tmp_color = 'rgb('+255+','+color+','+0+')';
		} else if (expr_val > 300 && expr_val <= 1000) {
			color = Math.round(200 + expr_val*55/1000);
			tmp_color = 'rgb('+color+','+color+','+0+')';
		} else if (expr_val > 1000) {
			color = Math.round(200 + expr_val*55/1000);
			tmp_color = 'rgb('+color+','+color+','+color+')';
		}
	
		return tmp_color;
	}


	function add_color_grad_legend(x_pos,y_pos,color_string,tmp_layer,stage) {
	
		var color = ['rgb(255,255,255)','rgb(255,255,0)','rgb(255,200,0)','rgb(200,100,50)','rgb(255,0,0)','rgb(50,50,50)'];
		// if (color_string == 'by') {
		// 	color = ['rgb(0,0,255)','rgb(0,0,55)','rgb(255,255,0)','rgb(55,55,0)'];
		// }
	
		var grad_legend = new Kinetic.Rect({
			x: x_pos,
			y: y_pos+30,
			width: 15,
			height: 200,
			fillLinearGradientStartPoint: {x:0, y:0},
			fillLinearGradientEndPoint: {x:0,y:200},
			fillLinearGradientColorStops: [0.2, color[0], 0.2, color[1], 0.4, color[2], 0.6, color[3], 0.8, color[4], 1, color[5]],
			// fillLinearGradientColorStops: [0, color[0], 0.5, color[1], 0.5, color[2], 1, color[3]],
			stroke: 'black',
			strokeWidth: 1,
			// id: "hm"+x+y
		});
	
		var top_text = new Kinetic.Text({
			x: x_pos-12,
			y: y_pos+10,
			text: "RPKMs",
			fontSize: 12,
			fontFamily: 'Helvetica',
			fill: "black",
			align: 'center'
		});
	
		// var max_text = new Kinetic.Text({
		// 	x: x_pos+20,
		// 	y: y_pos+25,
		// 	text: "10000",
		// 	fill: "black"
		// });
	
		var mid1_text = new Kinetic.Text({
			x: x_pos+20,
			y: y_pos+65,
			text: "1000",
			fill: "black"
		});
	
		var mid2_text = new Kinetic.Text({
			x: x_pos+20,
			y: y_pos+125,
			text: "100",
			fill: "black"
		});
	
		var mid3_text = new Kinetic.Text({
			x: x_pos+20,
			y: y_pos+160,
			text: "10",
			fill: "black"
		});
	
		var min2_text = new Kinetic.Text({
			x: x_pos+20,
			y: y_pos+195,
			text: "1",
			fill: "black"
		});
	
		var min_text = new Kinetic.Text({
			x: x_pos+20,
			y: y_pos+225,
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
		// tmp_layer.add(max_text);
		stage.add(tmp_layer);
	
	}


	function add_color_switch(y,x_array,sw_msg,color_array,tmp_layer,stage,params,c_code) {
	
		var color_code = c_code;
		// alert("color code in: "+color_code);
	
		//print square
		var rg_group = new Kinetic.Group({
			id: "sw_"+color_code
		});
	
		var r_sq = new Kinetic.Rect({
			x: x_array[0],
			y: y,
			width: 10,
			height: 10,
			fill: color_array[0],
			stroke: 'black',
			strokeWidth: 1,
			// id: "hm"+x+y
		});
	
		var g_sq = new Kinetic.Rect({
			x: x_array[1],
			y: y,
			width: 10,
			height: 10,
			fill: color_array[1],
			stroke: 'black',
			strokeWidth: 1,
			// id: "hm"+x+y
		});
	
		rg_group.add(r_sq);
		rg_group.add(g_sq);
	
	    rg_group.on('mouseover', function() {
			this.opacity(0.5);
			tmp_layer.draw();
			// writeMessage(sw_msg);
	    });

	    rg_group.on('mouseout', function() {
			this.opacity(1);
			tmp_layer.draw();
	    });
	
		tmp_layer.add(rg_group);
		stage.add(tmp_layer);
	
		rg_group.on('mousedown', function() {
			$("#color_code").val(color_code);
		
			draw_cube(params[0],params[1],params[2],params[3],params[4],params[5],params[6],params[7],params[8],params[9],params[10]);
		});

	}


	function draw_cube(genes,stages,tissues,expr_val,tmp_layer,tmp_canvas,x_margin,last_y_margin,top_x_start,y_margin,right_x_start) {
		tmp_layer.removeChildren();
	
		var color_code = $('#color_code').val();
	
		for (var i=genes.length; i>=1; i--) {
			add_slice(i,genes,expr_val,stages,tissues,tmp_layer,tmp_canvas,top_x_start,y_margin,color_code);
		}
	
		//draw stage names
		for (var i=0; i<stages.length; i++) {
			var x = top_x_start -75 - i*10;
			// var x = top_x_start -60 - i*15;  //change cube orientation
			var y = y_margin -18 + i*15;
			// var y = y_margin -40 + i*15;  //change cube orientation
			var x2 = top_x_start -650 + i*180;
			// var x = top_x_start -30 - i*15;
			// var y = y_margin - 20 + i*15;
			add_stage_names(x,y,stages[i],x2,tmp_layer,tmp_canvas);
		}
				
		var sw_x = right_x_start + (tissues.length*15) + 10;
		add_color_grad_legend(sw_x,y_margin-50,color_code,tmp_layer,tmp_canvas)
	}


	// -------------------------------------------------------------------------------------
	// -------------------------------------------------------------------------------------
	// -------------------------------------------------------------------------------------


	var canvas = new Kinetic.Stage({
		container: "container",
		width: 1100,
		height: 700
	});
	var tissue_layer = new Kinetic.Layer();


	var tpericarp_imgObj = new Image();
	tpericarp_imgObj.onload = function() {

		var tp = new Kinetic.Image({
			x: 0,
			y: 175,
			image: tpericarp_imgObj,
			width: 150,
			height: 150
		});
		tissue_layer.add(tp);
		canvas.add(tissue_layer);
	};

	tpericarp_imgObj.src = '/static/images/expr_viewer/tomato_pericarp.png';


	var tBg_imgObj = new Image();
	tBg_imgObj.onload = function() {

		var tissue_bg = new Kinetic.Image({
			x: 150,
			y: 100,
			image: tBg_imgObj,
			width: 190,
			height: 300
		});

		var tissue_bg2 = new Kinetic.Image({
			x: 330,
			y: 100,
			image: tBg_imgObj,
			width: 190,
			height: 300
		});

		var tissue_bg3 = new Kinetic.Image({
			x: 510,
			y: 100,
			image: tBg_imgObj,
			width: 190,
			height: 300
		});

		// add the shape to the layer
		tissue_layer.add(tissue_bg);
		tissue_layer.add(tissue_bg2);
		tissue_layer.add(tissue_bg3);

		// add the layer to the stage
		canvas.add(tissue_layer);
	};


	tBg_imgObj.src = '/static/images/expr_viewer/bg_075.png';

	// -------------------------------------------------------------------------------------

	var cube_layer = new Kinetic.Layer();

	//set variables
	var page_width = 1100;

	var x_margin = page_width -100 - tissues.length*20 - stages.length*15;
	var y_margin = 160;

	var last_x_margin = 125 + stages.length*20;
	var last_y_margin = 155 + stages.length*15;

	var right_x_start = x_margin + 5 + tissues.length*20;
	var top_x_start = x_margin + (stages.length*15);

	draw_cube(genes,stages,tissues,aoaoa,cube_layer,canvas,x_margin,last_y_margin,top_x_start,y_margin,right_x_start);


	// -------------------------------------------------------------------------------------
	jQuery('#run_tool').click(function () {
		//alert("clicking");
		// disable_ui();
		error_var = 1;
		query_gene = jQuery('#gene').val();
		
		getGeneInfo(query_gene);

		jQuery.ajax({
			url: '/Expression_viewer/result/',
			async: false,
			method: 'POST',
			data: { 'gene': query_gene },
			success: function(response) {
				// enable_ui();
				
				// alert("AoAoA:\n"+dump(response.aoaoa));
				// alert("expr:\n"+dump(response.expr)+"\ngenes:\n"+dump(response.genes)+"\nstages:\n"+dump(response.stages)+"\ntissues:\n"+dump(response.tissues));
				
				//set starting margins
				var x_margin = page_width -100 -response.tissues.length*20 -response.stages.length*15;
				var y_margin = 160;
	
				var last_x_margin = 125 + response.stages.length*20;
				var last_y_margin = 155 + response.stages.length*15;
	
				var right_x_start = x_margin + 5 + response.tissues.length*20;
				var top_x_start = x_margin + (response.stages.length*15);
				
				
				draw_cube(response.genes,response.stages,response.tissues,response.aoaoa,cube_layer,canvas,x_margin,last_y_margin,top_x_start,y_margin,right_x_start);
				
				// open_bar_graph_dialog(response.aoaoa[0]);
	
				if (response.error) { 
					alert("ERROR: "+response.error);
					error_var = 1;
				} else {
					error_var = 0;
					data_array_obj = response.all_exp_design;
				}
			},
			error: function(response) {
				alert("An error occurred. The service may not be available right now.");
				error_var = 1;
				// enable_ui();
			}
		});
	});
	// -------------------------------------------------------------------------------------
	
	
	
});


