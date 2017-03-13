	
  //draw the expression bar graph on dialog
	function print_bar_chart(t_names,s_names,sxt_values,gene_name,corr_val,expr_units,sem_AoAoh,sem_AoA_text) {
    
    
    for (i in s_names) {
      s_names[i] = s_names[i].replace(/_/g," ");
    }
    for (i in t_names) {
      t_names[i] = t_names[i].replace(/_/g," ");
    }

    // gene_name = gene_name.replace(/\./g,"");
    var div_gene_name = gene_name.replace(/[-,]/g,"");
    
    // alert("s_names: "+s_names+", t_names: "+t_names+", gene_name: "+gene_name+", sxt_values: "+sxt_values);
    
    var bar_width = null;
    var bar_padding = 0;
    var bar_margin = 1;
    
    
    if (s_names.length*t_names.length > 90) {
      bar_width = 6;
    }
    else if (s_names.length*t_names.length > 42 && s_names.length*t_names.length <= 90) {
      bar_width = 10;
    }
    else if (s_names.length*t_names.length > 8 && s_names.length*t_names.length <= 42) {
      bar_width = 20;
    }
    else if (s_names.length*t_names.length <= 8) {
      bar_width = 40;
    }
    
    
    var color_array = ['#2e5989','#5f954c','#bb2c32','#6e3f78','#e79f44','#7d807f','#008888','#880088','#5e89b9','#8fc57c','#eb5c62','#9e6fa8','#fccf74','#adb0af','#adb0ff','#0aaeea'];
    
    // var kk = $('#'+gene_name+'_bar_graph');
    
		var plot1 = $.jqplot(div_gene_name+'_bar_graph', sxt_values, {
			title: '',
			animate: true,
			seriesDefaults:{
				shadow: false,
				renderer:$.jqplot.BarRenderer,
				rendererOptions: {
					barWidth: bar_width,
					barPadding: bar_padding,
					barMargin: bar_margin,
					fillToZero: true,
          errorBarWidth: 1,
          errorBarColor: "#606060",
          errorBarTextFont: "bold 16px Arial",
          errorData: sem_AoAoh,
          errorTextData: sem_AoA_text,
          
					barDirection: 'vertical',
					animation: {
						speed: 1000
					},
				},
			},
      series: [
        {label: s_names},
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
						fontFamily: 'Arial',
            markSize: 15,
					}
				},
				yaxis: {
					pad: 1.5,
          label: expr_units,
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
        shadow: false,
			},
			seriesColors: color_array,
			legend: {
				labels: s_names,
				show: true,
				showSwatches: true,
				location: 'ne',
				placement: 'outsideGrid'
			}
		});
		
    
    for (i in s_names) {
      s_names[i] = s_names[i].replace(/ /g,"_");
    }
    for (i in t_names) {
      t_names[i] = t_names[i].replace(/ /g,"_");
    }
    
	}
  
  function get_error_bars(gene_name, stage_names, tissue_names, gst_sem_hohoh, transposed) {
  
    var sem_AoAoh = new Array();
    var sem_AoA_text = new Array();
    
    if (transposed) {
      for (t in tissue_names) {
        var t_sem_a = new Array();
        var t_sem_a_text = new Array();
      
        for (s in stage_names) {
        
          if (stage_names[s] && tissue_names[t] && gst_sem_hohoh[gene_name] && gst_sem_hohoh[gene_name][stage_names[s]] && gst_sem_hohoh[gene_name][stage_names[s]][tissue_names[t]]) {
            var sem_value = gst_sem_hohoh[gene_name][stage_names[s]][tissue_names[t]];
            var sem_s_hash = {min: sem_value, max: sem_value};
            t_sem_a.push(sem_s_hash);
            t_sem_a_text.push("");
          }
        }
        sem_AoAoh.push(t_sem_a);
        sem_AoA_text.push(t_sem_a_text);
      }
    } 
    else {
      for (s in stage_names) {
        
        var t_sem_a = new Array();
        var t_sem_a_text = new Array();
      
        for (t in tissue_names) {
        
          if (stage_names[s] && tissue_names[t] && gst_sem_hohoh[gene_name] && gst_sem_hohoh[gene_name][stage_names[s]] && gst_sem_hohoh[gene_name][stage_names[s]][tissue_names[t]]) {

            var sem_value = gst_sem_hohoh[gene_name][stage_names[s]][tissue_names[t]];
            
            
            var sem_s_hash = {min: sem_value, max: sem_value};
            t_sem_a.push(sem_s_hash);
            t_sem_a_text.push("");
          }
        }
        sem_AoAoh.push(t_sem_a);
        sem_AoA_text.push(t_sem_a_text);
      }
    }
    
    return [sem_AoAoh,sem_AoA_text];
  }
  
  
  
  //open dialog for expression bar graph
	function open_bar_graph_dialog(stage_tissue_values, gene_name, corr_val, description, gene_id, stage_names, tissue_names, expr_unit,gst_sem_hohoh) {
    
    var panel_width = 1200;
    var panel_max = 1200;
    var panel_min = 600;
    
    gene_name = gene_name.replace(/\./g,"");
    var div_gene_name = gene_name.replace(/[-,]/g,"");
    
    if (stage_names.length*tissue_names.length > 90) {
      panel_width = stage_names.length*tissue_names.length*6 + 300;
      // panel_width = panel_max;
    }
    else if (stage_names.length*tissue_names.length > 42 && stage_names.length*tissue_names.length <= 90) {
      panel_width = stage_names.length*tissue_names.length*10+300;
    }
    else if (stage_names.length*tissue_names.length > 8 && stage_names.length*tissue_names.length <= 42) {
      panel_width = stage_names.length*tissue_names.length*20+300;
    }
    else if (stage_names.length*tissue_names.length <= 8) {
      panel_width = panel_min;
    }
    
    // if (panel_width > panel_max) {
    //   panel_width = panel_max;
    // }
    if (panel_width < panel_min) {
      panel_width = panel_min;
    }
    
    // var tissue_names = ["Inner epidermis","Parenchyma","Vascular tissue","Collenchyma","Outer epidermis"];
    // var stage_names = ["10DPA", "Mature green", "Pink"];
		
		var dialog_null = document.getElementById(div_gene_name+"_dialog");
		
		if (dialog_null != null) {

			var openDialog = $("#"+div_gene_name+"_dialog").dialog( "isOpen" );
			
			if (openDialog) {
				$("#"+div_gene_name+"_dialog").dialog({ position: { my: "center", at: "center", of: window },});
				$("#"+div_gene_name+"_bar_graph").empty();
			} else {
				$("#"+div_gene_name+"_dialog").dialog( "open" );
			}
      [sem_AoAoh,sem_AoA_text] = get_error_bars(gene_name, stage_names, tissue_names, gst_sem_hohoh)
      
			print_bar_chart(tissue_names,stage_names,stage_tissue_values,gene_name,corr_val,expr_unit,sem_AoAoh,sem_AoA_text,0);
			
		} else {
      
			//TO DO: paste gene on input box on click
      
			var dynamicDialog = $('<div id="'+div_gene_name+'_dialog" value="off">\
			<center>\
      <table width="90%"><tr id="dialog_top_info">\
				<td><a href="http://solgenomics.net/locus/'+gene_id+'/view" target="blank"><b>'+gene_name+'</b></a></td>\
				<td><b> Correlation val: </b>'+corr_val+'</td>\
        <td><span id="tr_barplot'+div_gene_name+'" class="blue_link">transpose</span></td>\
				</tr></table>\
				<span>'+description+'</span><br>\
			</center>\
			<div id="'+div_gene_name+'_bar_graph"></div>\
			</div>');
			
			$(function() {
				dynamicDialog.dialog({
					title: gene_name,
					minWidth: panel_width,
					draggable: true,
					resizable: false,
				});
				$('.ui-dialog :button').blur();
        $('.sgn_logo_link').blur();
        [sem_AoAoh,sem_AoA_text] = get_error_bars(gene_name, stage_names, tissue_names, gst_sem_hohoh,0)
				print_bar_chart(tissue_names,stage_names,stage_tissue_values,gene_name,corr_val,expr_unit,sem_AoAoh,sem_AoA_text);
			});
      
      var switch_status = $('#'+div_gene_name+'_dialog');
      var transpose_switch = $('#tr_barplot'+gene_name);
      
      $('#tr_barplot'+div_gene_name).click(function () {
        // alert("HI");
        var new_array = stage_tissue_values[0].map(function(col, i) {
          return stage_tissue_values.map(function(row) {
            return row[i]
          })
        });
        
        $("#"+div_gene_name+"_bar_graph").empty();
          
        if (switch_status.val == "on") {
          switch_status.val = "off";
          [sem_AoAoh,sem_AoA_text] = get_error_bars(gene_name, stage_names, tissue_names, gst_sem_hohoh,0)
    			print_bar_chart(tissue_names,stage_names,stage_tissue_values,gene_name,corr_val,expr_unit,sem_AoAoh,sem_AoA_text);
        } else {
          switch_status.val = "on";
          [sem_AoAoh,sem_AoA_text] = get_error_bars(gene_name, stage_names, tissue_names, gst_sem_hohoh,1)
          print_bar_chart(stage_names,tissue_names,new_array,gene_name,corr_val,expr_unit,sem_AoAoh,sem_AoA_text);
        }
      });
		}
	}

  //get color for expression values for cube and tissue imgs
	function get_expr_color(expr_val) {
		
		var r_color = 255;
		var g_color = 255;
		var b_color = 255;
		
		if (expr_val == 0) {
			r_color = 255;
			g_color = 255;
			b_color = 255;
      
    } 
    else if (expr_val == 0.000001) {
      r_color = 210;
      g_color = 210;
      b_color = 210;
    }
    else if (expr_val <= 1) {
			r_color = 255;
			g_color = 255;
			b_color = Math.round(130*(1-expr_val)+100);
      // b_color = Math.round(130*(1-expr_val)+120);
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


  //load the img for each one of the tissue layers
  function load_tissue_image(x_offset,y_offset,r_color,g_color,b_color,one_tissue_layer,canvas,img_width,img_height,imgs_group,image_name) {
      
    // alert("image_name: "+image_name);
      
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
        // tmp_stage.cache();
        // tmp_stage.moveToTop();
        tmp_stage.draw();
        // one_tissue_layer.draw();
  
        // tmp_stage.draw();
        // tissue_popup_layer.draw();
      };//end of onload
  
      tmp_imgObj.src = '/static/images/expr_viewer/'+image_name;
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




  // get array with the gene names from the project for the autocomplete function
  function get_project_genes(organism_list){
    
    $.ajax({
      url: '/expression_viewer/get_genes/',
      timeout: 600000,
      method: 'POST',
      data: { 'project_id': organism_list[0]},
      success: function(response) {
        if (response.error) {
          alert("ERROR: "+response.error);
          // enable_ui();
        } else {
          project_genes = response.project_genes;
          
          $( ".gene_autocomplete" ).autocomplete({
              source: function(request, response) {
                  var results = $.ui.autocomplete.filter(project_genes, request.term);

                  response(results.slice(0, 15));
              }
          });
          
          // alert("project_genes: "+project_genes[0]);
        }
      },
      error: function(response) {
        alert("An error occurred. The service may not be available right now.");
        // enable_ui();
      }
    });
    
  }

