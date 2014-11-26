$(document).ready(function () {
	
	function print_bar_chart(t_names,s_names,sxt_values,gene_name,corr_val) {
		
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
		
	}


	function open_bar_graph_dialog(stage_tissue_values, gene_name, corr_val, description, gene_id) {

		var tissue_names = ["Inner epidermis","Parenchyma","Vascular tissue","Collenchyma","Outer epidermis"];
		var stage_names = ["10DPA", "Mature green", "Pink"];
		
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
			//TO DO: paste gene on input box on click
			
			var dynamicDialog = $('<div id="'+gene_name+'_dialog">\
			<center>\
				<a href="http://solgenomics.net/locus/'+gene_id+'/view" target="_blank"><img src="/static/images/sgn_logo.png" height="25" title="Connect to SGN for metadata associated with this gene"/></a>\
				<a id="paste_gene"><b>'+gene_name+'</b></a> \
				&nbsp; &nbsp; &nbsp; <b> Correlation val: </b>'+corr_val+' \
				<br/>\
				<span>'+description+'</span>\
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
				print_bar_chart(tissue_names,stage_names,stage_tissue_values,gene_name,corr_val);
			});
		}
	}

	//function to draw the central page numbers for the cube pagination
	function draw_central_pages(page_index, page_x_index, y_margin, pages_group, pages_num) {
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
		
		var sq_size = 20;
		page_y = y_margin +20*sq_size +100;
		y_margin = y_margin +n*sq_size;
		x_margin = x_margin + 20;
		
		var slice_group = new Kinetic.Group({
			id: "slice_"+n,
		});
		
		var gene_text = new Kinetic.Text({
			x: x_margin -150,
			y: y_margin +62,
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
			gene_popup_layer.removeChildren();
			gene_popup_layer.draw();
		});
		
		
		var circle = new Kinetic.Circle({
			x: x_margin -155,
			y: y_margin +68,
			radius: 3,
			fill: 'white',
			stroke: 'black',
			strokeWidth: 1,
			id: "circle_"+n,
			name: "gene_circle"
		});

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
	
		moving_slice_group.add(circle);


		// add stage and tissue names to the first gene
		for (var j=1; j<=stage_names.length; j++) {
			for (var i=tissue_names.length; i>=1; i--) {
				var x_start = x_margin - j*15;
				var nx = i*sq_size + x_start;
				var ny = y_margin + j*15;
			
				var rgb_color_array = get_expr_color(aoa[n-1][j-1][i-1]);
				var sqr_color = 'rgb('+rgb_color_array[0]+','+rgb_color_array[1]+','+rgb_color_array[2]+')';
				
				nx = nx-15 + (j-1)*5;
				var top_tile = new Kinetic.Line({
					points: [(nx+15), ny, (nx+35), ny, (nx+25), ny+15, nx+5, ny+15],
					fill: sqr_color,
					stroke: 'black',
					strokeWidth: 1,
					closed: true
				});
				nx = i*sq_size + x_start;
			
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
					});
				
					slice_group.add(front_tile);
				
				}
			
				if (i == tissue_names.length) {
					nx = nx-10 + (j-1)*5;
					var right_tile = new Kinetic.Line({
						points: [nx+sq_size, ny+15, nx+30, ny, nx+30, ny+sq_size, nx+sq_size, ny+35],
						fill: sqr_color,
						stroke: 'black',
						strokeWidth: 1,
						closed: true
					});
				
					slice_group.add(right_tile);
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
		
		//------------------------------------------------------------
		// pagination code
		//------------------------------------------------------------
		if (n == genes_num) {
			
			var pages_group = new Kinetic.Group();
			
			//underline the current page
			var underline = new Kinetic.Line({
				points: [x_margin - 12, page_y+28, x_margin + 6, page_y+28],
				stroke: "#4387FD",
				strokeWidth: 2,
			});

			pages_group.add(underline);
			
			//print central page links
			var page_index = current_page - 3;
			var page_x_index = x_margin - 105;
			
			for (var i=0; i<7; i++) {
				if (page_index <= pages_num && page_index > 0) {
					draw_central_pages(page_index, page_x_index, page_y, pages_group,pages_num);
				}
				page_index++;
				page_x_index = page_x_index + 30;
			}
			
			moving_slice_group.add(pages_group);
			
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
			
			moving_slice_group.add(last_triangle_group);
			
			//text ranking
			var ranking_text = new Kinetic.Text({
				x: x_margin - 55,
				y: page_y + 40,
				text: "Ranking "+current_page+"/"+pages_num,
				fontSize: '16',
				fontVariant: 'small-caps',
				fill: "black"
			});
		    moving_slice_group.add(ranking_text);
		}
		
		
		
		gene_text.on('mousedown', function() {
			for (var i=0;i<=gene_names_array.length;i++) {
				if (i>=n) {
					var other_layer = canvas.find("#full_slice_"+i);
					
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
		});
	
		slice_group.on('mousedown', function() {
			open_bar_graph_dialog(aoa[n-1],gene_names_array[n-1],correlation[n-2], gene_descriptions[gene_names_array[n-1]], gene_ids[gene_names_array[n-1]]);
			circle.fill("red");
			tmp_layer.draw();
		});
		
		moving_slice_group.add(circle);
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


	function get_expr_color(expr_val) {
		
		var r_color = 255;
		var g_color = 255;
		var b_color = 255;
		
		if (expr_val == 0) {
			tmp_color = 'rgb('+255+','+255+','+255+')';
		} else if (expr_val <= 1) {
			r_color = 255;
			g_color = 255;
			b_color = Math.round(130*(1-expr_val)+120);
		} else if (expr_val > 1 && expr_val <= 10) {
			r_color = 255;
			g_color = Math.round(245 - 60*expr_val/10);
			b_color = Math.round(220 - 105*expr_val/10);
		} else if (expr_val > 10 && expr_val <= 100) {
			r_color = 255;
			g_color = Math.round(197 - 67*(expr_val/100));
			b_color = Math.round(130 - 130*(expr_val/100));
		} else if (expr_val > 100 && expr_val <= 300) {
			r_color = 255
			g_color = Math.round(130 - 130*(expr_val-100)/200);
			b_color = 0;
		} else if (expr_val > 300 && expr_val <= 500) {

			r_color = Math.round(255 - 175*(expr_val-300)/200);
			g_color = 0;
			b_color = 0;

		} else if (expr_val > 500) {
			r_color = 80;
			g_color = 0;
			b_color = 0;
		}
		
		return [r_color,g_color,b_color];
	}


	function add_color_grad_legend(x_pos,y_pos,color_string,tmp_layer,stage) {
	
		var color = ['rgb(80,0,0)','rgb(255,0,0)','rgb(255,130,0)','rgb(255,195,125)','rgb(255,233,199)','rgb(255,255,120)','rgb(255,255,230)'];
	
		var grad_legend = new Kinetic.Rect({
			x: x_pos,
			y: y_pos+105,
			width: 15,
			height: 400,
			fillLinearGradientStartPoint: {x:0, y:0},
			fillLinearGradientEndPoint: {x:0,y:400},
			fillLinearGradientColorStops: [0, color[0], 0.2, color[1], 0.4, color[2], 0.6, color[3], 0.75, color[4], 0.9, color[5], 0.99, color[6], 1, 'rgb(255,255,255)'],
			stroke: 'black',
			strokeWidth: 1,
		});
	
		var top_text = new Kinetic.Text({
			x: x_pos-12,
			y: y_pos+85,
			text: "RPKM",
			fontSize: 12,
			fontFamily: 'Helvetica',
			fill: "black",
			align: 'center'
		});
	
		var mid1_text = new Kinetic.Text({
			x: x_pos+20,
			y: y_pos+180,
			text: "300",
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
		
		stage.add(tmp_layer);
	}


	function draw_cube(genes,stages,tissues,expr_val,tmp_layer,tmp_canvas,x_margin,last_y_margin,top_x_start,y_margin,right_x_start, gene_ids, gene_descriptions,current_page, pages_num) {
		tmp_layer.removeChildren();
		var color_code = $('#color_code').val();
		var genes_num = genes.length;
		
		for (var i=genes_num; i>=1; i--) {
			add_slice(i,genes,expr_val,stages,tissues,tmp_layer,tmp_canvas,top_x_start,y_margin,color_code,corr_values, gene_descriptions, gene_ids, current_page, pages_num, genes_num);
		}
	
		//draw stage names
		for (var i=0; i<stages.length; i++) {
			var x = top_x_start -75 - i*10;
			var y = y_margin -18 + i*15;
			var x2 = top_x_start -650 + i*180;
			add_stage_names(x,y,stages[i],x2,tmp_layer,tmp_canvas);
		}
				
		var sw_x = right_x_start + (tissues.length*15) + 10;
		add_color_grad_legend(sw_x,y_margin-50,color_code,tmp_layer,tmp_canvas)
	}

	function loadImage(i,j,aoaoa,x_offset,r_color,g_color,b_color,one_tissue_layer,canvas,stage_name,tissue_name) {
		var tmp_imgObj = new Image();
		tmp_imgObj.onload = function() {

			var tmp_tissue = new Kinetic.Image({
				id: "t_layer"+i+"_s"+j,
				x: x_offset,
				y: 60,
				image: tmp_imgObj,
				width: 200,
				height: 360
			});
			one_tissue_layer.add(tmp_tissue);
			canvas.add(one_tissue_layer);
			
			tmp_tissue.cache();
			tmp_tissue.filters([Kinetic.Filters.RGB]);
			tmp_tissue.red(r_color).green(g_color).blue(b_color);
			tmp_tissue.draw();
			
			
			//add expression values on a tooltip
			if (i == 4) {
			
				var tissue_popup_layer = new Kinetic.Layer();
				canvas.add(tissue_popup_layer);
	
				tmp_tissue.on('mouseover', function() {
					var x_pos = this.getAbsolutePosition().x-10;
					var y_pos = this.getAbsolutePosition().y+305;
					
					for (var n=0; n<5; n++) {
						var y_offset = n*65
						if (n == 3) {
							y_offset = 240
						}
						
						var tissue_popup = new Kinetic.Rect({
							x: x_pos,
							y: y_pos - y_offset,
							fill: '#000000',
							opacity: 0.7,
							width: 185,
							height: 20,
							cornerRadius: 7,
						});
						
						var tissue_name = tissues[n].replace("_"," ");
						
						var tissue_desc_txt = new Kinetic.Text({
							x: x_pos+5,
							y: y_pos+3 - y_offset,
							text: tissue_name+": "+aoaoa[0][j][n],
							fontSize: 16,
							fontFamily: 'Arial',
							fill: "white"
						});
						tissue_popup_layer.add(tissue_popup);
						tissue_popup_layer.moveToTop();
						tissue_popup_layer.add(tissue_desc_txt);
						tissue_popup_layer.draw();
					}
				});
	
				tissue_layer.on('mouseout', function() {
					tissue_popup_layer.removeChildren();
					tissue_popup_layer.draw();
				});
			
			}
			
		};
		tmp_imgObj.src = '/static/images/expr_viewer/'+stage_name+'_'+tissue_name+'.png';
	}
	
	
	function disable_ui() {
		$('#working').dialog( {
			height: 140,
			width: 50,
			modal: true,
			autoOpen: false,
			closeOnEscape: false,
			open: function(event, ui) { $(".ui-dialog-titlebar-close", ui.dialog).hide(); $('.ui-dialog-titlebar-close').blur();},
			title: 'Loading...'
		});
		$('#working').dialog("open");
	}
	
	function enable_ui() {
		$('#working').dialog("close");
	}
	
	// -------------------------------------------------------------------------------------
	// -------------------------------------------------------------------------------------
	// -------------------------------------------------------------------------------------
	disable_ui();

	var canvas = new Kinetic.Stage({
		container: "container",
		width: 1100,
		height: 1200
	});
	var tissue_layer = new Kinetic.Layer();


	var tpericarp_imgObj = new Image();
	tpericarp_imgObj.onload = function() {

		var tp = new Kinetic.Image({
			x: 0,
			y: 60,
			image: tpericarp_imgObj,
			width: 200,
			height: 360
		});
		tissue_layer.add(tp);
		canvas.add(tissue_layer);
	};

	tpericarp_imgObj.src = '/static/images/expr_viewer/RR_pericarp.png';


	var dpa_bg_imgObj = new Image();
	dpa_bg_imgObj.onload = function() {

		var tissue_bg = new Kinetic.Image({
			x: 200,
			y: 60,
			image: dpa_bg_imgObj,
			width: 200,
			height: 360
		});
		tissue_layer.add(tissue_bg);
		canvas.add(tissue_layer);
	};
	
	var mg_bg_imgObj = new Image();
	mg_bg_imgObj.onload = function() {

		var tissue_bg2 = new Kinetic.Image({
			x: 390,
			y: 60,
			image: mg_bg_imgObj,
			width: 200,
			height: 360
		});
		tissue_layer.add(tissue_bg2);
		canvas.add(tissue_layer);
	};
	
	var pink_bg_imgObj = new Image();
	pink_bg_imgObj.onload = function() {

		var tissue_bg3 = new Kinetic.Image({
			x: 580,
			y: 60,
			image: pink_bg_imgObj,
			width: 200,
			height: 360
		});
		tissue_layer.add(tissue_bg3);
		canvas.add(tissue_layer);
	};

	dpa_bg_imgObj.src = '/static/images/expr_viewer/dpa_bg.png';
	mg_bg_imgObj.src = '/static/images/expr_viewer/mg_bg.png';
	pink_bg_imgObj.src = '/static/images/expr_viewer/pink_bg.png';

	// -------------------------------------------------------------------------------------
	// http://www.html5canvastutorials.com/tutorials/html5-canvas-image-loader/
		
	
	for (var j = 0; j < stages.length; j++) {
		
		var x_offset = 200 + 190*j;

		for (var i = 0; i<tissues.length; i++) {
			
			var expr_val = aoaoa[0][j][i];
			var rgb_color_array = get_expr_color(expr_val);
			
			var r = rgb_color_array[0];
			var g = rgb_color_array[1];
			var b = rgb_color_array[2];
			
			loadImage(i,j,aoaoa,x_offset,r,g,b,tissue_layer,canvas,stages[j],tissues[i]);
		}
	}
	// -------------------------------------------------------------------------------------

	var cube_layer = new Kinetic.Layer();

	//set variables
	var page_width = 1100;

	var x_margin = page_width -100 - tissues.length*20 - stages.length*15;
	var y_margin = 100;

	var last_x_margin = 125 + stages.length*20;
	var last_y_margin = 155 + stages.length*15;

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
	
	draw_cube(genes,stages,tissues,aoaoa,cube_layer,canvas,x_margin,last_y_margin,top_x_start,y_margin,right_x_start, gene_locus_id, gene_descriptions, current_page, pages_num);
	
	//remove loading wheel
	enable_ui();
	
});


