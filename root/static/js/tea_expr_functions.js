	
  //draw the expression bar graph on dialog
	function print_bar_chart(t_names,s_names,sxt_values,gene_name,corr_val) {
		
    for (i in t_names) {
      t_names[i] = t_names[i].replace(/_/g," ");
    }
    for (i in s_names) {
      s_names[i] = s_names[i].replace(/_/g," ");
    }
    
    var color_array = ['#2e5989', '#5f954c', '#bb2c32', '#6e3f78', '#e79f44', '#7d807f', '#008888','#880088'];
    
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
		
	}

  //open dialog for expression bar graph
	function open_bar_graph_dialog(stage_tissue_values, gene_name, corr_val, description, gene_id, stage_names, tissue_names) {

    // var tissue_names = ["Inner epidermis","Parenchyma","Vascular tissue","Collenchyma","Outer epidermis"];
    // var stage_names = ["10DPA", "Mature green", "Pink"];
		
		var dialog_null = document.getElementById(gene_name+"_dialog");
		
		if (dialog_null != null) {
			
			var openDialog = $("#"+gene_name+"_dialog").dialog( "isOpen" );
			
			if (openDialog) {
				$("#"+gene_name+"_dialog").dialog({ position: { my: "center", at: "center", of: window },});
				$("#"+gene_name+"_bar_graph").empty();
				print_bar_chart(tissue_names,stage_names,stage_tissue_values,gene_name,corr_val);
			} else {
				$("#"+gene_name+"_dialog").dialog( "open" );
				print_bar_chart(tissue_names,stage_names,stage_tissue_values,gene_name,corr_val);
			}
			
		} else {
			//TO DO: paste gene on input box on click
			
      // var tr_function = transpose_barplot(tissue_names,stage_names,stage_tissue_values,gene_name,corr_val);
      
			var dynamicDialog = $('<div id="'+gene_name+'_dialog" value="off">\
			<center>\
      <table width="90%"><tr id="dialog_top_info">\
				<td><a href="http://solgenomics.net/locus/'+gene_id+'/view" target="_blank">\
          <img src="/static/images/sgn_logo.png" height="25" title="Connect to SGN for metadata associated with this gene"/>\
        </a></td>\
				<td><a id="paste_gene"><b>'+gene_name+'</b></a></td>\
				<td><b> Correlation val: </b>'+corr_val+'</td>\
        <td><span id="tr_barplot'+gene_name+'" class="blue_link">transpose</span></td>\
				</tr></table>\
				<span>'+description+'</span><br>\
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
        $('.sgn_logo_link').blur();
				print_bar_chart(tissue_names,stage_names,stage_tissue_values,gene_name,corr_val);
			});
      
      var switch_status = $('#'+gene_name+'_dialog');
      var transpose_switch = $('#tr_barplot'+gene_name);
      
      $('#tr_barplot'+gene_name).click(function () {
        // alert("HI");
        var new_array = stage_tissue_values[0].map(function(col, i) {
          return stage_tissue_values.map(function(row) {
            return row[i]
          })
        });
        
        $("#"+gene_name+"_bar_graph").empty();
          
        if (switch_status.val == "on") {
          switch_status.val = "off";
    			print_bar_chart(tissue_names,stage_names,stage_tissue_values,gene_name,corr_val);
        } else {
          switch_status.val = "on";
          print_bar_chart(stage_names,tissue_names,new_array,gene_name,corr_val);
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

  //load the img for each one of the tissue layers
  function load_tissue_image(i,j,aoaoa,x_offset,r_color,g_color,b_color,one_tissue_layer,canvas,stage_name,tissue_name,img_width,img_height) {
    canvas.add(one_tissue_layer);
    
    var tmp_imgObj = new Image();
    tmp_imgObj.src = '/static/images/expr_viewer/'+stage_name+'_'+tissue_name+'.png';
    
    tmp_imgObj.onload = function() {
      
      var tmp_stage = new Kinetic.Image({
        id: "t_layer"+i+"_s"+j,
        x: x_offset,
        y: 60,
        image: tmp_imgObj,
        width: img_width,
        height: img_height
      });
      one_tissue_layer.add(tmp_stage);
      canvas.add(one_tissue_layer);
      
      //fix cache bug
      tmp_stage.cache();
      tmp_stage.filters([Kinetic.Filters.RGB]);
      tmp_stage.red(r_color).green(g_color).blue(b_color);
      // tmp_stage.cache();
      // tmp_stage.moveToTop();
      tmp_stage.draw();
      // one_tissue_layer.draw();
      
      //add expression values on a tooltip
      if (i == 4) {

        var tissue_popup_layer = new Kinetic.Layer();
        canvas.add(tissue_popup_layer);

        tmp_stage.on('mouseover', function() {
          var x_pos = this.getAbsolutePosition().x;
          // var x_pos = this.getAbsolutePosition().x-10;
          var y_pos = this.getAbsolutePosition().y+305;

          for (var n=0; n<5; n++) {
            var y_offset = n*65;
            if (n == 3) {
              y_offset = 240;
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
            // tissue_popup_layer.moveToTop();
            tissue_popup_layer.add(tissue_desc_txt);
            tissue_popup_layer.cache();
            tissue_popup_layer.moveToTop();
            tissue_popup_layer.draw();
          }
        });

        one_tissue_layer.on('mouseout', function() {
          tissue_popup_layer.removeChildren();
          tissue_popup_layer.draw();
        });
      }
      // tmp_stage.draw();
      // tissue_popup_layer.draw();
    };
    // tmp_imgObj.src = '/static/images/expr_viewer/'+stage_name+'_'+tissue_name+'.png';
  }
  
  //load the bg image for each stage. This will be the bg for the tissue layers
  function load_stage_image(aoaoa,x_offset,one_tissue_layer,canvas,stage_name,img_width,img_height) {
    canvas.add(one_tissue_layer);
    
    var tmp_imgObj = new Image();
    tmp_imgObj.src = '/static/images/expr_viewer/'+stage_name+'_bg.png';
    
    tmp_imgObj.onload = function() {
      
      var tmp_stage = new Kinetic.Image({
        x: x_offset,
        y: 60,
        image: tmp_imgObj,
        width: img_width,
        height: img_height
      });
      one_tissue_layer.add(tmp_stage);
      canvas.add(one_tissue_layer);

    };
  }

