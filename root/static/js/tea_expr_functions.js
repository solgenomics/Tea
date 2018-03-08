
  //draw the expression bar graph on dialog
  function print_bar_chart(tis_names,stg_names,sxt_values,gene_name,corr_val,expr_units,sem_AoAoh,sem_AoA_text) {

    var s_names = new Array();
    var t_names = new Array();

    for (i in stg_names) {
      s_names[i] = stg_names[i];
      s_names[i].replace(/_/g," ");
    }
    for (i in tis_names) {
      t_names[i] = tis_names[i];
      t_names[i].replace(/_/g," ");
    }

    var div_gene_name = gene_name.replace(/[-,]+/g,"");
    div_gene_name = div_gene_name.replace(/\:/g,"");
    div_gene_name = div_gene_name.replace(/\|/g,"");
    div_gene_name = div_gene_name.replace(/\+/g,"");

    // alert("div_gene_name1: "+div_gene_name);

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

  }

  function get_error_bars(gene, stage_array, tissue_array, is_transposed) {

    var sem_AoAoh = new Array();
    var sem_AoA_text = new Array();

    if (is_transposed) {

      for (t in tissue_array) {
        var t_sem_a = new Array();
        var t_sem_a_text = new Array();

        for (s in stage_array) {
          var my_key = gene+"_"+stage_array[s].replace(/ /g,"_")+"_"+tissue_array[t].replace(/ /g,"_");

          if (gst_sem_hohoh[my_key]) {
          // if (stage_array[s] && tissue_array[t] && gst_sem_hohoh[gene] && gst_sem_hohoh[gene][stage_array[s]] && gst_sem_hohoh[gene][stage_array[s]][tissue_array[t]]) {
            // var sem_value = gst_sem_hohoh[gene][stage_array[s]][tissue_array[t]];

            var sem_value = gst_sem_hohoh[my_key];
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
      for (s in stage_array) {

        var t_sem_a = new Array();
        var t_sem_a_text = new Array();

        for (t in tissue_array) {
          var my_key = gene+"_"+stage_array[s].replace(/ /g,"_")+"_"+tissue_array[t].replace(/ /g,"_");

          if (gst_sem_hohoh[my_key]) {
          // if (stage_array[s] && tissue_array[t] && gst_sem_hohoh[gene] && gst_sem_hohoh[gene][stage_array[s]] && gst_sem_hohoh[gene][stage_array[s]][tissue_array[t]]) {
            // var sem_value = gst_sem_hohoh[gene][stage_array[s]][tissue_array[t]];

            var sem_value = gst_sem_hohoh[my_key];
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
  function open_bar_graph_dialog(stage_tissue_values, gene_name, corr_val, description, gene_id, stage_names, tissue_names, expr_unit) {

    var panel_width = 1200;
    var panel_max = 1200;
    var panel_min = 600;

    gene_name = gene_name.replace(/\./g,"_o0o_");
    // var div_gene_name = gene_name;
    gene_name2 = gene_name.replace(/_o0o_/g,".");

    var div_gene_name = gene_name.replace(/[-,]+/g,"");
    div_gene_name = div_gene_name.replace(/\:/g,"");
    div_gene_name = div_gene_name.replace(/\|/g,"");
    div_gene_name = div_gene_name.replace(/\+/g,"");

    // alert("div_gene_name2: "+div_gene_name);

    if (stage_names.length*tissue_names.length > 90) {
      panel_width = stage_names.length*tissue_names.length*6 + 300;
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

    if (panel_width < panel_min) {
      panel_width = panel_min;
    }

    var transpose_switch = $('#'+div_gene_name+'_dialog');

    var dialog_null = document.getElementById(div_gene_name+"_dialog");

    if (dialog_null != null) {

      transpose_switch.val = "on";
      $("#"+div_gene_name+"_bar_graph").empty();

      var openDialog = $("#"+div_gene_name+"_dialog").dialog( "isOpen" );

      if (openDialog) {
        $("#"+div_gene_name+"_dialog").dialog({ position: { my: "center", at: "center", of: window },});
        $("#"+div_gene_name+"_bar_graph").empty();
      } else {
        $("#"+div_gene_name+"_dialog").dialog( "open" );
      }

      [sem_AoAoh,sem_AoA_text] = get_error_bars(gene_name2,stage_names,tissue_names,0)

      print_bar_chart(tissue_names,stage_names,stage_tissue_values,gene_name,corr_val,expr_unit,sem_AoAoh,sem_AoA_text);
    } else {
      transpose_switch.val = "on";

      //TO DO: paste gene on input box on click

      var dynamicDialog = $('<div id="'+div_gene_name+'_dialog" value="off">\
        <center>\
          <table width="90%"><tr id="dialog_top_info">\
            <td><a href="http://solgenomics.net/locus/'+gene_id+'/view" target="blank"><b>'+gene_name2+'</b></a></td>\
            <td><b> Correlation val: </b>'+corr_val+'</td>\
            <td><span id="tr_barplot'+div_gene_name+'" class="blue_link">transpose</span></td>\
          </tr></table>\
          <span>'+description+'</span><br>\
        </center>\
        <div id="'+div_gene_name+'_bar_graph"></div>\
      </div>');

      $(function() {
        dynamicDialog.dialog({
          title: gene_name2,
          minWidth: panel_width,
          draggable: true,
          resizable: false,
        });
        $('.ui-dialog :button').blur();
        $('.sgn_logo_link').blur();

        [sem_AoAoh,sem_AoA_text] = get_error_bars(gene_name2,stage_names,tissue_names,0)
        print_bar_chart(tissue_names,stage_names,stage_tissue_values,gene_name,corr_val,expr_unit,sem_AoAoh,sem_AoA_text);
      });
    } //end else

    //clicking on transpose button
    $('#tr_barplot'+div_gene_name).click(function () {
        var new_array = stage_tissue_values[0].map(function(col, i) {
          return stage_tissue_values.map(function(row) {
            return row[i]
          })
        });

        $("#"+div_gene_name+"_bar_graph").empty();

        if (transpose_switch.val == "off") {
          transpose_switch.val = "on";
          [sem_AoAoh,sem_AoA_text] = get_error_bars(gene_name2,stage_names,tissue_names,0)
          print_bar_chart(tissue_names,stage_names,stage_tissue_values,gene_name,corr_val,expr_unit,sem_AoAoh,sem_AoA_text);
        } else {
          transpose_switch.val = "off";
          [sem_AoAoh,sem_AoA_text] = get_error_bars(gene_name2,stage_names,tissue_names,1)
          print_bar_chart(stage_names,tissue_names,new_array,gene_name,corr_val,expr_unit,sem_AoAoh,sem_AoA_text);
        }
    }); //end clicking on transpose

  }

  //get color for expression values for cube and tissue imgs
  function get_expr_color(expr_val,min_expr,max_expr) {

    var r_color = 255;
    var g_color = 255;
    var b_color = 255;

    var top_val = max_expr * 1;
    var bottom_val = min_expr * 1;

    var section_length = Math.round((top_val-bottom_val)/5);

    if (min_expr == "default" || max_expr == "default") {

      if (expr_val == 0) {
        r_color = 255;
        g_color = 255;
        b_color = 255;
      } else if (expr_val == 0.000001) {
        r_color = 210;
        g_color = 210;
        b_color = 210;
      } else if (expr_val <= 1) {
        r_color = 255;
        g_color = 255;
        b_color = Math.round(130*(1-expr_val)+100);
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

    } else {

      // if (bottom_val == 0) {
      //   bottom_val = section_length/2;
      // }

      if (expr_val <= bottom_val) {
        r_color = 255;
        g_color = 255;
        b_color = 255;
      } else if (expr_val == 0.000001) {
        r_color = 210;
        g_color = 210;
        b_color = 210;
      } else if (expr_val > bottom_val && expr_val <= bottom_val+section_length) {

        var myval = Math.round((expr_val-bottom_val)/section_length); //0-1

        r_color = 255;
        g_color = 255;
        b_color = Math.round(90 + 130*(1-myval));
      } else if (expr_val > bottom_val+section_length && expr_val <= bottom_val+section_length*2) {

        var myval = Math.round((expr_val-(bottom_val+section_length))/section_length); //0-1

        r_color = 255;
        g_color = Math.round(185 + 54*(1-myval));
        b_color = Math.round(115 + 94*(1-myval));

      } else if (expr_val > bottom_val+section_length*2 && expr_val <= bottom_val+section_length*3) {

        var myval = Math.round((expr_val-(bottom_val+section_length*2))/section_length); //0-1

        r_color = 255;
        g_color = Math.round(130 + 60*(1-myval));
        b_color = Math.round(0 + 117*(1-myval));
      } else if (expr_val > bottom_val+section_length*3 && expr_val <= bottom_val+section_length*4) {

        var myval = Math.round((expr_val-(bottom_val+section_length*3))/section_length); //0-1

        r_color = 255
        g_color = Math.round(130*(1-myval));
        b_color = 0;
      } else if (expr_val > bottom_val+section_length*4 && expr_val <= top_val) {

        var myval = Math.round((expr_val-(bottom_val+section_length*4))/section_length); //0-1

        r_color = Math.round(90 + 165*(1-myval));
        g_color = 0;
        b_color = 0;
      } else if (expr_val > top_val) {
        r_color = 60;
        g_color = 0;
        b_color = 0;
      }

    }

    return [r_color,g_color,b_color];
  }




  // function get_expr_color(expr_val) {
  //
  //   var r_color = 255;
  //   var g_color = 255;
  //   var b_color = 255;
  //
  //   if (expr_val == 0) {
  //     r_color = 255;
  //     g_color = 255;
  //     b_color = 255;
  //
  //   }
  //   else if (expr_val == 0.000001) {
  //     r_color = 210;
  //     g_color = 210;
  //     b_color = 210;
  //   }
  //   else if (expr_val <= 1) {
  //     r_color = 255;
  //     g_color = 255;
  //     b_color = Math.round(130*(1-expr_val)+100);
  //   } else if (expr_val > 1 && expr_val <= 10) {
  //     r_color = 255;
  //     g_color = Math.round(245 - 60*expr_val/10);
  //     b_color = Math.round(220 - 105*expr_val/10);
  //   } else if (expr_val > 10 && expr_val <= 100) {
  //     r_color = 255;
  //     g_color = Math.round(197 - 67*(expr_val/100));
  //     b_color = Math.round(130 - 130*(expr_val/100));
  //   } else if (expr_val > 100 && expr_val <= 300) {
  //     r_color = 255
  //     g_color = Math.round(130 - 130*(expr_val-100)/200);
  //     b_color = 0;
  //   } else if (expr_val > 300 && expr_val <= 500) {
  //     r_color = Math.round(255 - 175*(expr_val-300)/200);
  //     g_color = 0;
  //     b_color = 0;
  //   } else if (expr_val > 500) {
  //     r_color = 80;
  //     g_color = 0;
  //     b_color = 0;
  //   }
  //
  //   return [r_color,g_color,b_color];
  // }
  //
  //
  //
  //
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
