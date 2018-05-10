$(document).ready(function () {
    $.jqplot.config.enablePlugins = true;
    var plot_tissues;
    var plot_stages;
    
    var scatterplot_loaded = 0;
    $("#scatterplots_tab").click(function(){
        var scatterplot_img_loaded = 0;
	plot_tissues = tissues;
	plot_stages = stages;
	for (i in plot_stages) {
      plot_stages[i] = plot_stages[i].replace(/ /g,"_");
    }
    for (i in plot_tissues) {
      plot_tissues[i] = plot_tissues[i].replace(/ /g,"_");
    }
	$("#dwl_expr_data").css("display","none");

    function add_squares() {
        var expr_val = aoaoa[0][x-1][y-1];
        
        if (expr_val == 0.000001) {
          expr_val = "ND";
        }
        
        var sqr_color = 'rgb(210,210,210)';

        if (expr_val != "ND") {
            var rgb_array = get_expr_color(expr_val,expression_min_scale,expression_max_scale);
          sqr_color = 'rgb('+rgb_array[0]+','+rgb_array[1]+','+rgb_array[2]+')';
        }
	
	stored_color[selectorCounter] = sqr_color;

	
			
					var front_tile = new Kinetic.Rect({
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
					
					selectorArraySwitch[selectorCounter] = 0;
					
					selectorArray[selectorCounter] = front_tile;
					
					selectorArray[selectorCounter].on('mouseover', function() {
					  	if ((this.name() != "selected")) {
					  	this.fill("#529dfb");
					  	this.draw();
					  	}
					
					});
				
					selectorArray[selectorCounter].on('mouseout', function() {
					    if ((this.name() != "selected")) {
					  	this.fill(sqr_color);
						this.draw();
						}
					});
					

					layer.add(front_tile);
					stage.add(layer);
			}


	$("#get_scatterplot_btn").click(function(){

	    

 	if (samples_chosen.length == 2) {
//           if (!scatterplot_img_loaded) {

	    
	    document.getElementById("ExpCorrChart").innerHTML = "";

	    document.getElementById("NewPlot").style.display="block";
	    document.getElementById("GetPlot").style.display="none";
	    document.getElementById("ExpCorrChart").style.display="block";
	    document.getElementById("selector").style.display="none";
	    document.getElementById("new_plot_btn").style.display="block";
	    document.getElementById("get_scatterplot_btn").style.display="none";
	    document.getElementById("Scatter_Instruction").style.display="none";
//	    setTimeout($("#scatterplot_loading_modal").modal("show"), 1);
//	    $("#scatterplot_loading_modal").style.display="";

		makeplot(samples_chosen);
//		scatterplot_img_loaded = 1;
//	    setTimeout($("#scatterplot_loading_modal").modal("hide"), 5000);
//	    	    $("#scatterplot_loading_modal").style.display="none";
//	    $("#scatterplot_loading_modal").modal('hide');	    

		samples_chosen = [];
//	    }	
	}
				else if (samples_chosen.length < 2) {
				    document.getElementById("Scatter_error_modal").style.display="block";
				    if (samples_chosen.length == 1) {
				    var id_rect1 = temp_id[0];
				    
				    var temp_rect1 = stage.find("#"+id_rect1);
			            temp_rect1.fill(stored_color[id_rect1]);
				    temp_rect1.name("notselected");
					temp_rect1.draw();}
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
	temp_rect1.fill(stored_color[id_rect1]);
	temp_rect1.name("notselected");
	temp_rect1.draw();
	temp_rect2.fill(stored_color[id_rect2]);
	temp_rect2.name("notselected");
	temp_rect2.draw();
	temp_id = [];
				
				function makeplot(lists_to_get){

				    var sample1tissuetempindex = lists_to_get[0][0];
				    var sample1stagetempindex = lists_to_get[0][1];
				    var sample2tissuetempindex = lists_to_get[1][0];
				    var sample2stagetempindex = lists_to_get[1][1];
				    var sample1stageindex = ((sample1stagetempindex - 150)/20) - 1;
				    var sample2stageindex = ((sample2stagetempindex - 150)/20) - 1;
				    var sample1tissueindex = ((sample1tissuetempindex - adjustable_y_val)/20) - 1;
				    var sample2tissueindex = ((sample2tissuetempindex - adjustable_y_val)/20) - 1;
				    var sample1stage = plot_stages[sample1stageindex];
				    var sample1tissue = plot_tissues[sample1tissueindex];
				    var sample2stage = plot_stages[sample2stageindex];
				    var sample2tissue = plot_tissues[sample2tissueindex];
				    var ret;
 			 	    $.ajax({
					url: '/expression_viewer/scatterplot/',
					beforeSend: function() {
					    $("#scatterplot_loading_modal").modal("show");
					},
					
					
 					async: false,					
					method: 'POST',					
 					dataType: "json",					
 					data: { 'projectid': project_id, 'st_array': plot_stages, 'ti_array': plot_tissues, 'st_s1_index': sample1stageindex, 'st_s2_index': sample2stageindex, 'ti_s1_index': sample1tissueindex, 'ti_s2_index': sample2tissueindex, 'genes_to_plot': genes, 'corr_filter_to_set_genes': correlation_filter, 'gene_set_request': all_gene_selector},		
				    success: function(response) {
					ret = response.expression_to_plot3;
//	    				$("#scatterplot_loading_modal").style.display="none";
	    $("#scatterplot_loading_modal").modal('hide');
 				}
 				    });
				    var JSONobject = JSON.parse(ret);
				    var sample1_data = [];
				    var sample2_data = [];
				    var geneids = [];
			       var test_line2 = [];	       
				    for (var i=0; i<JSONobject.length; i++) {
					
					sample1_data[i] = eval(JSONobject[i]["sample1_exp"]);
					sample2_data[i] = eval(JSONobject[i]["sample2_exp"]);
					geneids[i] = JSONobject[i]["geneid"];
					test_line2[i] = [sample1_data[i],sample2_data[i],geneids[i]];
					
				    }
				    var sampleaxislabel1 = sample1tissue + "<br>" + sample1stage;
				    var sampleaxislabel2 = sample2tissue + "<br>" + sample2stage;

				    var plot2 = $.jqplot('ExpCorrChart', [test_line2], {
					captureRightClick: true,
					title: {
					    text: "",
					    textColor: 'black',
					    fontSize: '20',
						fontFamily: 'Helvetica'
					},
					gridPadding: {top:50, bottom:200, left:30, right:30},
					seriesDefaults: {
						color: "#17BDB8",
					        showLine: false,
					        pointLabels: {show:false},
						shadow: false
					},
					axes:{
						xaxis:{
						    label: sampleaxislabel1,
						    min:0,
						    tickOptions: {
						angle: 0,
						formatString: "%#.0f  ",
						fontSize: '10pt',
						textColor: 'black',
						fontFamily: 'Arial'
					}

						},
						yaxis:{
						    label: sampleaxislabel2,
						    min:0,
						    tickOptions: {
						angle: 0,
						formatString: "%#.0f  ",
						fontSize: '10pt',
						textColor: 'black',
						fontFamily: 'Arial'
					}
						},
					},
								grid: {
				background: "white",
				borderColor: "black",
        shadow: false,
			},
	    highlighter: {
		show: true,
		yvalues: 2,
		formatString:'<table id="current_ExpCorr_highlight" class="jqplot-highlighter"><tr><td>%s</td></tr><tr><td>%s</td></tr><tr><td>%s</td></tr></table>',
		sizeAdjust: 7.5
					},
					cursor: {
					    show: true,
					    zoom: true,
					    showTooltip: false,
					    clickReset: true
					}
				    });
				    $('#ExpCorrChart').bind('jqplotDataRightClick',
							    function (ev, seriesIndex, pointIndex, data) {
								$('#clipboard').val(data[2]);
							    }
							    
				    );
				    


    
				};

	});
   
    
			function handleClick() {       			
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
         		    }else{
			    }
			}

	if (!scatterplot_loaded) {
	    document.getElementById("NewPlot").style.display="none";
	    document.getElementById("GetPlot").style.display="block";
	    document.getElementById("selector").style.display="block";
	    document.getElementById("ExpCorrChart").style.display="none";	    
	    document.getElementById("new_plot_btn").style.display="none";
	    document.getElementById("Scatter_error_modal").style.display="none";
	    document.getElementById("new_plot_btn").style.position="relative";
	    document.getElementById("new_plot_btn").style.margin="-20 px";
	    document.getElementById("new_plot_btn").style.top="50%";
	    document.getElementById("get_scatterplot_btn").style.margin="-20 px";
	    document.getElementById("get_scatterplot_btn").style.top="0%";
	    document.getElementById("get_scatterplot_btn").style.display="block";    
	    document.getElementById("get_scatterplot_btn").style.position="relative";
	    document.getElementById("NewPlot").style.height="50px";
	    document.getElementById("NewPlot").style.width="550px";
	    document.getElementById("NewPlot").style.styleFloat="left";
	    document.getElementById("GetPlot").style.height="50px";
	    document.getElementById("GetPlot").style.width="550px";
	    document.getElementById("GetPlot").style.styleFloat="left";
	    var text_instruction_scatterplot = document.createTextNode("Please select two samples from the " + "\n" + "grid, then click \'Get scatterplot\'\.");
	    document.getElementById("Scatter_Instruction").appendChild(text_instruction_scatterplot);
	    document.getElementById("Scatter_Instruction").style.position="relative";
	    document.getElementById("Scatter_Instruction").style.styleFloat="right";
	    document.getElementById("Scatter_Instruction").style.width="250px";
//	    document.getElementById("Scatter_Instruction").style.height="50px";
	    document.getElementById("Scatter_Instruction").style.right="270px";
	    document.getElementById("Scatter_Instruction").style.top="40px";	    
	    document.getElementById("selector").style.height="1000";
	    document.getElementById("selector").style.width="850";
//	    document.getElementById("selector").style.top="200px";	    
	    //	    document.getElementById("selector").style.styleFloat = 'left';
	    	    document.getElementById("selector").style.position ="relative";
	    
	    var modal = document.getElementById('Scatter_error_modal');

	    // Get the <span> element that closes the modal
	    var close_btn = document.getElementById("scatter_close_btn");

	    document.getElementById("ExpCorrChart").style.height="550px";
	    document.getElementById("ExpCorrChart").style.width="550px";
	    document.getElementById("ExpCorrChart").style.styleFloat = 'right';

    
	    var selectioncounter = 0
	    var selectorArraySwitch = []
	    var samples_chosen = []
	    var temp_id = []
    var stored_color = []
   			var layer = new Kinetic.Layer();

    var selectorArray = [];
    var selectorCounter = 0;
    var stage_text = [];
    var tissue_text = [];
	var expr_val = 0;
	var max_tissue_length = 0;


	var all_gene_selector = 1;


	    
      var stage = new Kinetic.Stage({
		  		container: "selector",
		  		width: 600,
		  		height: 1000
			});

	for (var y=1; y<=plot_tissues.length; y++) {
	    if (plot_tissues[y-1].length >= max_tissue_length) {
		max_tissue_length = plot_tissues[y-1].length
	    }else{
	    }
	}

	    var adjustable_y_val = max_tissue_length + 20
	    var stage_lengths = [];
			
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
//					selectorCounter++;					
//					add_squares(x,y,selectorCounter);
					if (x==1) {
						tissue_text[y] = new Kinetic.Text({
						    x: 1,
						    y: y*20+adjustable_y_val+4,
						    text: plot_tissues[y-1],
						    width: 160,
						    align: 'right',
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
//		    alert(stages[x-1].length());

		if (stage_text[x].width() >= max_stage_length) {
		    max_stage_length = stage_text[x].width();
//		if (stages[x-1].length() >= max_stage_length) {
//		    max_stage_length = stages[x-1].length();
	    }else{
	    }
	    }
	    adjustable_y_val = max_stage_length + 20;
	    
	    // add selector squares and adjust y positions/values
	    for (var x=1; x<=plot_stages.length; x++) {
		stage_text[x].y(adjustable_y_val+5);
		for (var y=1; y<=plot_tissues.length; y++) {
		    tissue_text[y].y(y*20+adjustable_y_val+4);
		selectorCounter++;		
		add_squares(x,y,selectorCounter);
	    }
			}
	    
//	    document.getElementById("selector").style.top="200px";

/*	    // trigonometry to calculate height of rotated text - max_stage_length is hypotenuse
	  
//	    var rad = 30 * Math.PI/180;
//	    max_stage_length = 90;
	    alert(max_stage_length);
//	    var adjacent_side_height = (Math.cos(rad))*max_stage_length;
	    var pseudo_new_height = 60;
//	    var new_height = adjacent_side_height - 20;
	    var new_height = max_stage_length + 50;
	    var pseudo_new_height_string = pseudo_new_height + "px";
	    var new_height_string = new_height + "px";
	    alert(pseudo_new_height_string);
	    document.getElementById("GetPlot").style.height = new_height_string;
//	    document.getElementById("GetPlot").style.height = pseudo_new_height_string; */
	    scatterplot_loaded = 1;
	}

	var temp_array_length = selectorArray.length - 1;
			for (var y=1; y<=temp_array_length; y++) {
				selectorArray[y].on("click",handleClick);
			}

	$("#new_plot_btn").click(function(){
	    scatterplot_img_loaded = 0;
	    document.getElementById("selector").style.display="block";
	    document.getElementById("ExpCorrChart").style.display="none";
	    document.getElementById("NewPlot").style.display="none";
	    document.getElementById("new_plot_btn").style.display="none";
	    document.getElementById("GetPlot").style.display="block";
	    document.getElementById("get_scatterplot_btn").style.display="block";
	    document.getElementById("Scatter_Instruction").style.display="block";
	});

	close_btn.onclick = function() {
    modal.style.display = "none";
}
	
	
window.onclick = function(event) {
    if (event.target == modal) {
        modal.style.display = "none";
    }
}
	
  });

});
