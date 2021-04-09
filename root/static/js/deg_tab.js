$(document).ready(function () {

  var plot_tissues;
  var plot_stages;
  var deg_loaded = 0;

  var samples_chosen = [];
  var adjustable_y_val = 0;
  var temp_id = [];
  var stage;
  var stored_color = [];

  function add_squares(x,y,selectorCounter,stored_color,adjustable_y_val,selectorArraySwitch,selectorArray,layer,stage) {
      var expr_val = aoaoa[0][x-1][y-1];

      if (expr_val == 0.000001) {
        expr_val = "ND";
      }

      var sqr_color = 'rgb(210,210,210)';
      var front_tile;

      if (expr_val != "ND") {
        var rgb_array = get_expr_color(expr_val,expression_min_scale,expression_max_scale);
        sqr_color = 'rgb('+rgb_array[0]+','+rgb_array[1]+','+rgb_array[2]+')';
      }
      else {

        front_tile = new Kinetic.Rect({
          x: x*20+150,
          y: y*20+adjustable_y_val,
          width: 20,
          height: 20,
          fill: sqr_color,
          name: 'ND',
          id: selectorCounter,
          strokeWidth: 1,
          stroke: 'black',
        });
      }

      stored_color[selectorCounter] = sqr_color;

      if (expr_val != "ND") {
        front_tile = new Kinetic.Rect({
          x: x*20+150,
          y: y*20+adjustable_y_val,
          width: 20,
          height: 20,
          fill: sqr_color,
          name: 'notselected',
          id: selectorCounter,
          strokeWidth: 1,
          stroke: 'black',
        });
      }

      selectorArraySwitch[selectorCounter] = 0;

      selectorArray[selectorCounter] = front_tile;

      selectorArray[selectorCounter].on('mouseover', function() {
        if ((this.name() != "selected") && (this.name() != "ND")) {
          this.fill("#529dfb");
          this.draw();
        }

      });

      selectorArray[selectorCounter].on('mouseout', function() {
        if ((this.name() != "selected") && (this.name() != "ND")) {
          this.fill(sqr_color);
          this.draw();
        }
      });


      layer.add(front_tile);
      stage.add(layer);
  } //end of add_squares function

  $("#degNewPlot").click(function(){
      $("#degSelector").css("display", "block");
      $("#deg_output_summary").css("display", "none");
      $("#degNewPlot").css("display", "none");
      // $("#deg_new_plot_btn").css("display", "none");
      $("#degGetPlot").css("display", "block");
      $("#get_deg_btn").css("display", "block");
      $("#deg_instruction").css("display", "block");
  });



  $("#get_deg_btn").click(function(){
    if (samples_chosen.length == 2) {
      $("#loading_modal").modal("show");
      setTimeout(function(){ get_degs_after_click(); }, 1000);
      setTimeout(function(){ $("#loading_modal").modal("hide"); }, 1000);
    }
  });

  function get_degs_after_click() {

    if (samples_chosen.length == 2) {

        $("#degNewPlot").css("display", "block");
        $("#degGetPlot").css("display", "none");
        $("#deg_output_summary").css("display", "block");
        $("#degSelector").css("display", "none");
        // $("#deg_new_plot_btn").css("display", "block");
        $("#get_deg_btn").css("display", "none");
        $("#deg_instruction").css("display", "none");

        var sample1tissuetempindex = samples_chosen[0][0];
        var sample1stagetempindex = samples_chosen[0][1];
        var sample2tissuetempindex = samples_chosen[1][0];
        var sample2stagetempindex = samples_chosen[1][1];

        var sample1stageindex = ((sample1stagetempindex - 150)/20) - 1;
        var sample2stageindex = ((sample2stagetempindex - 150)/20) - 1;
        var sample1tissueindex = ((sample1tissuetempindex - adjustable_y_val)/20) - 1;
        var sample2tissueindex = ((sample2tissuetempindex - adjustable_y_val)/20) - 1;

        var e = document.getElementById("deg_method");
        var deg_method = e.options[e.selectedIndex].value;

        $.ajax({
            url: '/expression_viewer/deg/',
            async: false,
            method: 'POST',
            dataType: "json",
            data: { 'projectid': project_id, 'st_array': plot_stages, 'ti_array': plot_tissues, 'st_s1_index': sample1stageindex, 'st_s2_index': sample2stageindex, 'ti_s1_index': sample1tissueindex, 'ti_s2_index': sample2tissueindex, 'deg_method': deg_method},
            success: function(res) {
               $("#deg_output_summary").css("display", "block");
               $("#form_file_name").val(res.deg_file);
               $("#degOutput").html("<span class=\"glyphicon glyphicon-download-alt\"></span> Download DEGs");
               $(".deg_number").html(res.deg_count);
               $(".up_condition").html(res.deg_up_name);
               $(".up_number").html(res.deg_up_count);
               $(".down_condition").html(res.deg_down_name);
               $(".down_number").html(res.deg_down_count);
            }

        });


        samples_chosen = [];
    }
    else if (samples_chosen.length < 2) {
        // document.getElementById("Scatter_error_modal").style.display="block";

        if (samples_chosen.length == 1) {
           var id_rect1 = temp_id[0];

           var temp_rect1 = stage.find("#"+id_rect1);

           if ( temp_rect1.name() != "ND") {
             temp_rect1.fill(stored_color[id_rect1]);
             temp_rect1.name("notselected");
             temp_rect1.draw();
           }
        }
        samples_chosen = [];
    }
    else if (samples_chosen.length > 2) {
        alert("You have selected too many samples; please select only two samples.");
        location.reload();
    }
    else {
        alert("Error");
    }

    var id_rect1 = temp_id[0];
    var id_rect2 = temp_id[1];

    var temp_rect1 = stage.find("#"+id_rect1);
    var temp_rect2 = stage.find("#"+id_rect2);

    if ( temp_rect1.name() != "ND") {
      temp_rect1.fill(stored_color[id_rect1]);
      temp_rect1.name("notselected");
      temp_rect1.draw();
    }

    if ( temp_rect2.name() != "ND") {
      temp_rect2.fill(stored_color[id_rect2]);
      temp_rect2.name("notselected");
      temp_rect2.draw();
      temp_id = [];
    }

  }


  $("#deg_tab").click(function(){

  	plot_tissues = tissues;
  	plot_stages = stages;

    for (i in plot_stages) {
      plot_stages[i] = plot_stages[i].replace(/ /g,"_");
    }
    for (i in plot_tissues) {
      plot_tissues[i] = plot_tissues[i].replace(/ /g,"_");
    }

    // $("#dwl_expr_data").css("display","none");
    // $("#dwl_cube").css("display","none");



  	function handleClick() {

      if ( this.name() != "ND") {

  	    var temp_idx = this.id();
  	    var temp_idy = temp_id[0];
  	    var temp_idz = temp_id[1];

  	    if ((temp_idx != temp_idy) && (temp_idx != temp_idz)) {
  	        if (samples_chosen.length < 2) {
        				this.name("selected");
        				this.draw;

          			samples_chosen.push([this.y(),this.x()]);
        				temp_id.push(this.id());
        				temp_col = this.fill();

  			    } else {

        				var id_rect = temp_id[0];
        				var temp_rect = stage.find("#"+id_rect);
  			        temp_rect.fill(stored_color[id_rect]);
        				temp_rect.name("notselected");
        				temp_rect.draw();
        				samples_chosen.shift();
          			samples_chosen.push([this.y(),this.x()]);
        				temp_id.shift();
        				temp_id.push(this.id());
        				this.name("selected");
        				this.draw;
  			    }
  	    } // end of temp_idx conditional

      } // end of ND conditional
  	} // function handleClick end

  	if (!deg_loaded) {
  	    $("#degNewPlot").css("display", "none");
  	    $("#degGetPlot").css("display", "block");
  	    $("#degSelector").css("display", "block");
  	    $("#deg_output_summary").css("display", "none");
  	    // $("#deg_new_plot_btn").css("display", "none");

  	    var selectioncounter = 0;
  	    var selectorArraySwitch = [];
  	    samples_chosen = [];
  	    temp_id = [];
        stored_color = [];
     		var layer = new Kinetic.Layer();

        var selectorArray = [];
        var selectorCounter = 0;
        var stage_text = [];
        var tissue_text = [];
  	    var expr_val = 0;
  	    var max_tissue_length = 0;

  	    var all_gene_selector = 1;


        for (var y=1; y<=plot_tissues.length; y++) {
  	       if (plot_tissues[y-1].length >= max_tissue_length) {
  		         max_tissue_length = plot_tissues[y-1].length
  	       }
  	    }

	    if (max_tissue_length < 10) {
		max_tissue_length = 10;
	    }
  	    adjustable_y_val = max_tissue_length * 20;
  	    var stage_lengths = [];

        var adjustable_width = (plot_stages.length * 20) + (max_tissue_length * 30);

        stage = new Kinetic.Stage({
  		  		container: "degSelector",
  		  		width: 	adjustable_width,
  //          width: 650,
  		  		height: 500
  			});


  			for (var x=1; x<=plot_stages.length; x++) {
  				stage_text[x] = new Kinetic.Text({
  					x: x*20+150,
  					y:adjustable_y_val+5,
  					text: plot_stages[x-1],
  					fontSize: 16,
  					fontFamily: 'Helvetica',
  					fill: 'black',
  					rotation: 270
  					});
  			    layer.add(stage_text[x]);
  			    stage_lengths[x] = stage_text[x].width();
  				for (var y=1; y<=plot_tissues.length; y++) {

  					if (x==1) {
  					    tissue_text[y] = new Kinetic.Text({
        						x: plot_stages.length*20+175,
        						y: y*20+adjustable_y_val+4,
        						text: plot_tissues[y-1],
        						width: adjustable_width,
        						align: 'left',
        						fontSize: 16,
        						fontFamily: 'Helvetica',
        						fill: 'black',
        						rotation: 0
  					    });
  					    layer.add(tissue_text[y]);
  					}
  				}
  			}

  	    var max_stage_length = 0;
  	    for (var x=1; x<=plot_stages.length; x++) {

      		if (stage_text[x].width() >= max_stage_length) {
      		    max_stage_length = stage_text[x].width();
    	    }
  	    }
  	    adjustable_y_val = max_stage_length + 20;

  	    // add selector squares and adjust y positions/values
  	    for (var x=1; x<=plot_stages.length; x++) {
        		stage_text[x].y(adjustable_y_val+5);
        		for (var y=1; y<=plot_tissues.length; y++) {
        		    tissue_text[y].y(y*20+adjustable_y_val+4);
            		selectorCounter++;
            		add_squares(x,y,selectorCounter,stored_color,adjustable_y_val,selectorArraySwitch,selectorArray,layer,stage);
      	    }
  			}

  	    deg_loaded = 1;
  	}

  	var temp_array_length = selectorArray.length - 1;

    for (var y=1; y<=temp_array_length; y++) {
  		selectorArray[y].on("click",handleClick);
  	}

  });

}); //end of document ready
