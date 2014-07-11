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


	// function getGeneInfo(gene) {
	//
	// 	$.ajax({
	// 		url: 'http://192.168.1.166:3000/api/tea',
	// 		dataType: 'jsonp', // Notice! JSONP <-- P (lowercase)
	// 		timeout: 600000,
	// 		data: { 'gene_name': gene},
	// 		success: function(response) {
	// 			document.getElementById("gene_name").innerHTML = "<a href='http://solgenomics.net/feature/"+response.gene_id+"/details' target='_blank'>"+response.gene_name+" <img src='/static/images/sgn_logo.png' height='16' title='Connect to SGN for metadata associated with this gene'/></a>";
	// 			document.getElementById("gene_desc").innerHTML = response.description;
	// 		},
	// 		error: function(response) {
	// 			alert("An error occurred. The service may not be available right now.");
	// 		}
	// 	});
	// }


	function print_bar_chart(t_names,s_names,sxt_values,gene_name,corr_val) {
		// alert("data: "+sxt_values);
		
		// var plot1 = $.jqplot('bar_graph', sxt_values, {
		var plot1 = $.jqplot(gene_name+'_bar_graph', sxt_values, {
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
			seriesColors: ['#20608E', '#008800', '#CC0000', '#60208E', '#008888'],
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
				document.getElementById(gene_name+"_gene_dialog").innerHTML = "<a href='http://solgenomics.net/feature/"+response.gene_id+"/details' target='_blank'><img src='/static/images/sgn_logo.png' height='25' title='Connect to SGN for metadata associated with this gene'/> "+response.gene_name+"</a>";
				if (corr_val != null) {
					document.getElementById(gene_name+"_desc_dialog").innerHTML = response.description+"<br/>Correlation Value: "+corr_val;
				} else {
					document.getElementById(gene_name+"_desc_dialog").innerHTML = response.description;
				}
			},
			error: function(response) {
				alert("An error occurred. The service may not be available right now.");
			}
		});
		
	}


	function open_bar_graph_dialog(stage_tissue_values, gene_name, corr_val) {

		var tissue_names = ["Inner epidermis","Parenchyma","Vascular tissue","Collenchyma","Outer epidermis"];
		var stage_names = ["10DPA", "Mature green", "Pink"];
		// var stage_tissue_values = [[146.25, 180.23, 20.12, 221.16, 60.12],[133.53, 284.63, 38.37, 169.95, 264.21],[12.35, 31.26, 3.18, 10.38, 37.21]];
		
		var dialog_null = document.getElementById(gene_name+"_dialog");
		
		if (dialog_null != null) {
			
			var openDialog = $("#"+gene_name+"_dialog").dialog( "isOpen" );
			
			if (openDialog) {
				$("#"+gene_name+"_dialog").dialog({ position: { my: "center", at: "center", of: window } });
				$("#"+gene_name+"_bar_graph").empty();
				print_bar_chart(tissue_names,stage_names,stage_tissue_values,gene_name,corr_val);
			} else {
				$("#"+gene_name+"_dialog").dialog( "open" );
				print_bar_chart(tissue_names,stage_names,stage_tissue_values,gene_name,corr_val);
			}
			
		} else {
		
			var dynamicDialog = $('<div id="'+gene_name+'_dialog">\
			<center>\
				<span id="'+gene_name+'_gene_dialog" class="gene_name_dialog"></span>\
				<br/>\
				<span id="'+gene_name+'_desc_dialog" class="gene_desc_dialog"></span>\
			</center>\
			<div id="'+gene_name+'_bar_graph"></div>\
			</div>');
	
			$(function() {
				dynamicDialog.dialog({
					title: gene_name,
					minWidth: 600,
					draggable: true,
					resizable: false,
				});
				$('.ui-dialog :button').blur();
				// dynamicDialog.css('background-color','transparent');
				print_bar_chart(tissue_names,stage_names,stage_tissue_values,gene_name,corr_val);
			});
		}
	}


	// function add_slice(n,gene_names_array,aoa,tissue_names,stage_names,tmp_layer,stage,x_margin,y_margin,color_code) {
	function add_slice(n,gene_names_array,aoa,stage_names,tissue_names,tmp_layer,stage,x_margin,y_margin,color_code,correlation) {
		var sq_size = 20;
		y_margin = y_margin +n*sq_size;
		x_margin = x_margin + 20;
		
		var slice_group = new Kinetic.Group({
			id: "slice_"+n,
		});
		
		var gene_text = new Kinetic.Text({
			// x: x_margin -175,
			// y: y_margin +93,
			x: x_margin -155,  //change cube stages by tissues
			y: y_margin +63,  //change cube stages by tissues
			id: "slice_name_"+n,
			// text: "Solyc00g0000009",
			text: gene_names_array[n-1],
			fontSize: 16,
			fontFamily: 'Helvetica',
			fill: "black"
		});
		
		var gene_popup_layer = new Kinetic.Layer();
		stage.add(gene_popup_layer);
		
		gene_text.on('mouseover', function() {
			var x_pos = this.getAbsolutePosition().x-510;
			var y_pos = this.getAbsolutePosition().y-10;
			
			var gene_desc = "gene description from SGN";
			
			var gene_popup = new Kinetic.Rect({
		        x: x_pos-50,
		        y: y_pos,
		        fill: '#000000',
				opacity: 0.5,
		        width: 500,
		        height: 30,
		        cornerRadius: 10
			});
			
			var desc_txt = new Kinetic.Text({
				x: x_pos+5,
				y: y_pos+8,
				text: gene_desc,
				fontSize: 16,
				fontFamily: 'Helvetica',
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
			gene_popup_layer.removeChildren();
			gene_popup_layer.draw();
		});
		
		
		var circle = new Kinetic.Circle({
		        // x: x_margin -180,
		        // y: y_margin +100,
		        x: x_margin -160, //change cube stages by tissues
		        y: y_margin +70, //change cube stages by tissues
		        radius: 3,
		        fill: 'white',
		        stroke: 'black',
		        strokeWidth: 1,
				id: "circle_"+n,
				name: "gene_circle"
		});

		if (n>1) {
			var moving_slice_group = new Kinetic.Group({
				id: "full_slice_"+n,
				name: 'slice_up',
				// draggable: true,
		        // dragBoundFunc: function(pos) {
		        //   return {
		        //     x: this.getAbsolutePosition().x,
		        //     y: pos.y
		        //   }
		        // }
			});
		} else {
			gene_text.fill("blue");
			var moving_slice_group = new Kinetic.Group({
				id: "full_slice_"+n,
			});
		}
	
		moving_slice_group.add(circle);
		// if (n<=1) {
		// 	circle.fill("red");
		// }


		
		// for (var j=stage_names.length; j>=1; j--) {
		for (var j=1; j<=stage_names.length; j++) {  //change cube stages by tissues
			for (var i=tissue_names.length; i>=1; i--) {
				var x_start = x_margin - j*15;
				var nx = i*sq_size + x_start;
				var ny = y_margin + j*15;
			
				// var sqr_color = get_expr_color(color_code, aoa[n-1][i-1][j-1]); //change cube stages by tissues
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
						// x: nx+10, //change cube stages by tissues
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
						fontSize: 18,
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
			// var all_circles = stage.find(".gene_circle");
			// all_circles.fill("white");
			open_bar_graph_dialog(aoa[n-1],gene_names_array[n-1],correlation[n-2]);
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
			fontSize: 16,
			fontFamily: 'Helvetica',
			fill: 'black',
			rotation: 30
			// rotation: 45 //change cube orientation
		});
	
		// stages for tissue images
		var stage_text_pict = new Kinetic.Text({
			x: x_margin2 -30,
			y: 70,
			text: stage_name,
			fontSize: 20,
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
		
		// var color = ['rgb(100,0,0)','rgb(255,0,0)','rgb(255,130,0)','rgb(255,205,155)','rgb(255,255,0)','rgb(255,255,205)'];
		
		//get a color from expression value
		var tmp_color;
		// alert(expr_val);
		// var color = Math.round(200 + expr_val/155);
		
		if (expr_val == 0) {
			tmp_color = 'rgb('+255+','+255+','+255+')';
		} else if (expr_val <= 1) {
			// b_color = Math.round(205*expr_val);
			b_color = Math.round(205*(1-expr_val));
			tmp_color = 'rgb('+255+','+255+','+b_color+')';
			
		} else if (expr_val > 1 && expr_val <= 10) {
			g_color = Math.round(255 - 125*expr_val/10);
			b_color = Math.round(205 - 205*expr_val/10);
			tmp_color = 'rgb('+255+','+g_color+','+b_color+')';
			
		} else if (expr_val > 10 && expr_val <= 100) {
			g_color = Math.round(205 - 75*(1 - expr_val/100));
			b_color = Math.round(155 - 155*(1 - expr_val/100));
			
			tmp_color = 'rgb('+255+','+g_color+','+b_color+')';
		} else if (expr_val > 100 && expr_val <= 300) {
			r_color = Math.round(255 - 105*(expr_val-100)/200);
			g_color = Math.round(130 - 130*(expr_val-100)/200);
			tmp_color = 'rgb('+r_color+','+g_color+','+0+')';
		} else if (expr_val > 300) {
			color = Math.round(150 + 105*expr_val/300);
			tmp_color = 'rgb('+color+','+0+','+0+')';
		}
	
		// if (expr_val <= 1) {
		// 	color = Math.round(50 + expr_val*50);
		// 	tmp_color = 'rgb('+color+','+0+','+0+')';
		// } else if (expr_val > 1 && expr_val <= 10) {
		// 	color = Math.round(100 + expr_val*155/10);
		// 	tmp_color = 'rgb('+color+','+0+','+0+')';
		// } else if (expr_val > 10 && expr_val <= 100) {
		// 	color = Math.round(155 + expr_val*100/100);
		// 	tmp_color = 'rgb('+color+','+Math.round(color/2)+','+0+')';
		// } else if (expr_val > 100 && expr_val <= 300) {
		// 	color = Math.round(100 + expr_val*100/300);
		// 	tmp_color = 'rgb('+255+','+color+','+0+')';
		// } else if (expr_val > 300 && expr_val <= 1000) {
		// 	color = Math.round(200 + expr_val*55/1000);
		// 	tmp_color = 'rgb('+color+','+color+','+0+')';
		// } else if (expr_val > 1000) {
		// 	color = Math.round(200 + expr_val*55/1000);
		// 	tmp_color = 'rgb('+color+','+color+','+color+')';
		// }
		//
		return tmp_color;
	}


	function add_color_grad_legend(x_pos,y_pos,color_string,tmp_layer,stage) {
	
		var color = ['rgb(100,0,0)','rgb(255,0,0)','rgb(255,130,0)','rgb(255,205,155)','rgb(255,255,0)','rgb(255,255,205)'];
		// var color = ['rgb(255,0,0)','rgb(150,0,0)','rgb(255,130,0)','rgb(255,205,155)','rgb(255,255,205)','rgb(255,255,0)'];
		// var color = ['rgb(255,0,0)','rgb(150,0,0)','rgb(255,205,155)','rgb(255,130,0)','rgb(255,255,205)','rgb(255,255,0)'];
		// var color = ['rgb(255,255,255)','rgb(255,255,0)','rgb(255,200,0)','rgb(200,100,50)','rgb(255,0,0)','rgb(50,50,50)'];
		// if (color_string == 'by') {
		// 	color = ['rgb(0,0,255)','rgb(0,0,55)','rgb(255,255,0)','rgb(55,55,0)'];
		// }
	
		var grad_legend = new Kinetic.Rect({
			x: x_pos,
			y: y_pos+105,
			width: 15,
			height: 400,
			fillLinearGradientStartPoint: {x:0, y:0},
			fillLinearGradientEndPoint: {x:0,y:400},
			fillLinearGradientColorStops: [0, color[0], 0.2, color[1], 0.4, color[2], 0.6, color[3], 0.9, color[4], 0.99, color[5], 1, 'rgb(255,255,255)'],
			// fillLinearGradientColorStops: [0.2, color[0], 0.2, color[1], 0.4, color[2], 0.6, color[3], 0.8, color[4], 1, color[5]],
			// fillLinearGradientColorStops: [0, color[0], 0.5, color[1], 0.5, color[2], 1, color[3]],
			stroke: 'black',
			strokeWidth: 1,
			// id: "hm"+x+y
		});
	
		var top_text = new Kinetic.Text({
			x: x_pos-12,
			y: y_pos+85,
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
			y: y_pos+180,
			text: "300",
			// text: "1000",
			fill: "black"
		});
	
		var mid2_text = new Kinetic.Text({
			x: x_pos+20,
			y: y_pos+260,
			text: "100",
			fill: "black"
		});
	
		var mid3_text = new Kinetic.Text({
			x: x_pos+20,
			y: y_pos+340,
			text: "10",
			fill: "black"
		});
	
		var min2_text = new Kinetic.Text({
			x: x_pos+20,
			y: y_pos+420,
			text: "1",
			fill: "black"
		});
	
		var min_text = new Kinetic.Text({
			x: x_pos+20,
			y: y_pos+500,
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
			add_slice(i,genes,expr_val,stages,tissues,tmp_layer,tmp_canvas,top_x_start,y_margin,color_code,corr_values);
		}
	
		//draw stage names
		// for (var i=0; i<tissues.length; i++) { //change cube stages by tissues
		// for (var i=tissues.length-1; i>=0; i--) { //change cube stages by tissues
			// alert("i: "+i+" tissues[i]: "+tissues[i])
		for (var i=0; i<stages.length; i++) {
			var x = top_x_start -75 - i*10;
			// var x = top_x_start -60 - i*15;  //change cube orientation
			var y = y_margin -18 + i*15;
			// var y = y_margin -40 + i*15;  //change cube orientation
			var x2 = top_x_start -650 + i*180;
			// var x = top_x_start -30 - i*15;
			// var y = y_margin - 20 + i*15;
			// add_stage_names(x,y,tissues[i],x2,tmp_layer,tmp_canvas); //change cube stages by tissues
			add_stage_names(x,y,stages[i],x2,tmp_layer,tmp_canvas);
		}
				
		// var sw_x = right_x_start + (stages.length*15) + 10; //change cube stages by tissues
		var sw_x = right_x_start + (tissues.length*15) + 10;
		add_color_grad_legend(sw_x,y_margin-50,color_code,tmp_layer,tmp_canvas)
	}


	// -------------------------------------------------------------------------------------
	// -------------------------------------------------------------------------------------
	// -------------------------------------------------------------------------------------


	var canvas = new Kinetic.Stage({
		container: "container",
		width: 1100,
		height: 1700
	});
	var tissue_layer = new Kinetic.Layer();


	var tpericarp_imgObj = new Image();
	tpericarp_imgObj.onload = function() {

		var tp = new Kinetic.Image({
			x: 0,
			y: 160,
			image: tpericarp_imgObj,
			width: 180,
			height: 180
		});
		tissue_layer.add(tp);
		canvas.add(tissue_layer);
	};

	tpericarp_imgObj.src = '/static/images/expr_viewer/RR_pericarp.png';


	var tBg_imgObj = new Image();
	tBg_imgObj.onload = function() {

		var tissue_bg = new Kinetic.Image({
			x: 170,
			y: 100,
			image: tBg_imgObj,
			width: 190,
			height: 300
		});

		var tissue_bg2 = new Kinetic.Image({
			x: 350,
			y: 100,
			image: tBg_imgObj,
			width: 190,
			height: 300
		});

		var tissue_bg3 = new Kinetic.Image({
			x: 530,
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
	
	function loadImage(x_offset,r_color,g_color,b_color,tissue_layer,canvas) {
		var tmp_imgObj = new Image();
		tmp_imgObj.onload = function() {

			var tmp_tissue = new Kinetic.Image({
				id: "t_layer"+i+"_s"+j,
				x: x_offset,
				y: 100,
				image: tmp_imgObj,
				width: 190,
				height: 300
			});
			tissue_layer.add(tmp_tissue);
			canvas.add(tissue_layer);
			
			tmp_tissue.cache();
			tmp_tissue.filters([Kinetic.Filters.RGB]);
			tmp_tissue.red(r_color).green(g_color).blue(b_color);
			tmp_tissue.draw();
			
		};
		tmp_imgObj.src = '/static/images/expr_viewer/'+tissues[i]+'.png';
	}
		
		// http://www.html5canvastutorials.com/tutorials/html5-canvas-image-loader/
		
	
	for (var j = 0; j < stages.length; j++) {
		var x_offset = 170 + 180*j;

		for (var i = 0; i<tissues.length; i++) {
			
			var expr_val = aoaoa[0][j][i];
			var r = 255;
			var g = 255;
			var b = 255;
			
			// var color = ['rgb(255,0,0)','rgb(150,0,0)','rgb(255,128,0)','rgb(255,205,155)','rgb(255,255,0)','rgb(255,255,205)'];
			
			if (expr_val == 0) {
				r = 255;
				g = 255;
				b = 255;
			} else if (expr_val <= 1) {
				color = Math.round(205*(1-expr_val));
				r = 255;
				g = 255;
				b = color;
			} else if (expr_val > 1 && expr_val <= 10) {
				g_color = Math.round(255 - 125*expr_val/10);
				b_color = Math.round(205 - 205*expr_val/10);
				r = 255;
				g = g_color;
				b = b_color;
			} else if (expr_val > 10 && expr_val <= 100) {
				g_color = Math.round(205 - 75*(1 - expr_val/100));
				b_color = Math.round(155 - 155*(1 - expr_val/100));
				r = 255;
				g = g_color;
				b = b_color;
				
				// alert("r: "+r+" g: "+g+" b: "+b);
				
			} else if (expr_val > 100 && expr_val <= 300) {
				r_color = Math.round(255 - 105*(expr_val-100)/200);
				g_color = Math.round(130 - 130*(expr_val-100)/200);
				r = r_color;
				g = g_color;
				b = 0;
			} else if (expr_val > 300 ) {
				color = Math.round(150 + 105*expr_val/300);
				r = color;
				g = 0;
				b = 0;
			}
			
			
			// if (expr_val <= 1) {
			// 	color = Math.round(50 + expr_val*50);
			// 	r = color;
			// 	g = 0;
			// 	b = 0;
			// } else if (expr_val > 1 && expr_val <= 10) {
			// 	color = Math.round(100 + expr_val*155/10);
			// 	r = color;
			// 	g = 0;
			// 	b = 0;
			// } else if (expr_val > 10 && expr_val <= 100) {
			// 	color = Math.round(155 + expr_val*100/100);
			// 	r = color;
			// 	g = Math.round(color/2);
			// 	b = 0;
			// } else if (expr_val > 100 && expr_val <= 300) {
			// 	color = Math.round(100 + expr_val*100/300);
			// 	r = 255;
			// 	g = color;
			// 	b = 0;
			// } else if (expr_val > 300 && expr_val <= 1000) {
			// 	color = Math.round(200 + expr_val*55/1000);
			// 	r = color;
			// 	g = color;
			// 	b = 0;
			// } else if (expr_val > 1000) {
			// 	color = Math.round(200 + expr_val*55/1000);
			// 	r = color;
			// 	g = color;
			// 	b = color;
			// }
			
			// alert("tissue: "+tissues[i]);
	        loadImage(x_offset,r,g,b,tissue_layer,canvas);
		}
	}
	// -------------------------------------------------------------------------------------

	var cube_layer = new Kinetic.Layer();

	//set variables
	var page_width = 1100;

	var x_margin = page_width -100 - tissues.length*20 - stages.length*15;
	var y_margin = 100;
	// var y_margin = 160;

	var last_x_margin = 125 + stages.length*20;
	var last_y_margin = 155 + stages.length*15;

	var right_x_start = x_margin + 5 + tissues.length*20;
	var top_x_start = x_margin + (stages.length*15);

	draw_cube(genes,stages,tissues,aoaoa,cube_layer,canvas,x_margin,last_y_margin,top_x_start,y_margin,right_x_start);
	
});


