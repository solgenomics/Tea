$(document).ready(function () {

    $("#scatterplots_tab").click(function(){
    document.getElementById("NewPlot").style.display="block";
    document.getElementById("selector").style.display="block";
	document.getElementById("ExpCorrChart").style.display="none";
	document.getElementById("new_plot_btn").style.display="none";
	document.getElementById("new_plot_btn").style.position="relative";
	document.getElementById("new_plot_btn").style.margin="-20 px";
	document.getElementById("new_plot_btn").style.top="50%";
	document.getElementById("NewPlot").style.height="50px";
	document.getElementById("NewPlot").style.width="550px";
//	document.getElementById("NewPlot").style.visibility="hidden";
	document.getElementById("NewPlot").style.styleFloat="left";
	document.getElementById("selector").style.height="550px";
    document.getElementById("selector").style.width="850px";
    document.getElementById("selector").style.styleFloat = 'left';


    document.getElementById("ExpCorrChart").style.height="550px";    
    document.getElementById("ExpCorrChart").style.width="550px";    
    document.getElementById("ExpCorrChart").style.styleFloat = 'right';
    //    document.getElementById("ExpCorrChart").style.border = "thick solid #000000"
    
    var selectioncounter = 0
    var selectorArraySwitch = []
    var samples_chosen = []
    var temp_id = []
    var temp_col
    var stored_color = []
   
// var stage2 = new Kinetic.Stage({
//		  		container: "NewPlot",
//		  		width: 300,
//		  		height: 300
//			});
//			var layer2 = new Kinetic.Layer();
  //    var new_plot_group = new Kinetic.Group();
//	  var new_plot = new Kinetic.Rect({
//	      x: 50,
//	      y: 50,
//	      id: "newplotbutton",
//	      width: 145,
//	      height: 25,
//	      strokeWidth: 0,
//	      cornerRadius : 5,
//	      fill:'white',
//	  });
//	  new_plot_group.add(new_plot);
//	  var new_plot_text = new Kinetic.Text({
//	      x: 61,
//	      y: 54,
//	      text: "New scatterplot",
//	      fontSize: '18',
//	      fill: "#fff",
//	      fontFamily: 'Helvetica',	      
//
//	  });
//	new_plot_group.add(new_plot_text);

//	new_plot.on('mousedown', function() {
//	    alert("hello!");
	    
//	});
//	new_plot_group.on('mouseover', function() {
//	   	    new_plot_group.fill("#bbb");
//	});	
//	layer2.add(new_plot_group);
//	stage2.add(layer2);



	


//    function get_expr_color(expr_val) {
			
//	var r_color = 255;
//	var g_color = 255;
//	var b_color = 255;
/*			
	if (expr_val == 0) {
	    tmp_color = 'rgb('+255+','+255+','+255+')';
	} else if (expr_val <= 1) {
	    r_color = 255;
	    g_color = 255;
	    // b_color = Math.round(200*(1-expr_val)+50);
	    b_color = Math.round(130*(1-expr_val)+120);
	} else if (expr_val > 1 && expr_val <= 10) {
	    r_color = 255;
	    g_color = Math.round(245 - 60*expr_val/10);
	    // g_color = Math.round(250 - 55*expr_val/10);
	    b_color = Math.round(220 - 105*expr_val/10);
	    // b_color = Math.round(225 - 100*expr_val/10);
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
			
	var tmp_color = 'rgb('+r_color+','+g_color+','+b_color+')';
	return [tmp_color,r_color,g_color,b_color];
    }*/
			
			
    function add_squares() {
        var expr_val = aoaoa[0][x-1][y-1];
        
        if (expr_val == 0.000001) {
          expr_val = "ND";
        }
        
        var sqr_color = 'rgb(210,210,210)';

        if (expr_val != "ND") {
          var rgb_array = get_expr_color(expr_val);
          sqr_color = 'rgb('+rgb_array[0]+','+rgb_array[1]+','+rgb_array[2]+')';
        }
	
	stored_color[selectorCounter] = sqr_color;

	
			
					var front_tile = new Kinetic.Rect({
						x: x*20+150,
						y: y*20+150,
						width: 20,
					    height: 20,
					    fill: sqr_color,
						name: 'notselected',
					    id: selectorCounter,
//					    listening: false,
//					    name: stages[x-1],
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
					
					selectorArray[selectorCounter].on('click', function() {
					    if (samples_chosen.length < 2) {
//					    selectioncounter++;
//					    this.listening(true);
						this.name("selected");
						this.draw;
//						alert(samples_chosen.length);
					    } else {
						// else case where samples_chosen has 2 items (should never have more than 2)
						this.name("selected");
						this.draw;
//						alert(samples_chosen.length);
						
					    }
									  
					});

					layer.add(front_tile);
// 					layer.add(top_text);
					stage.add(layer);
			}
			
      var stage = new Kinetic.Stage({
		  		container: "selector",
		  		width: 600,
		  		height: 600
			});
			var layer = new Kinetic.Layer();
      var get_plot_group = new Kinetic.Group();
	  var get_plot = new Kinetic.Rect({
	      x: 0,
	      y: 80,
	      width: 135,
	      height: 25,
	      strokeWidth: 0,
	      cornerRadius : 5,
	      fill:'#777',
	  });
	  get_plot_group.add(get_plot);
	  var get_plot_text = new Kinetic.Text({
	      x: 8,
	      y: 84,
	      text: "Get scatterplot",
	      fontSize: '18',
	      fill: "#fff",
	      fontFamily: 'Helvetica',	      

	  });
      get_plot_group.add(get_plot_text);
      layer.add(get_plot_group);

    var selectorArray = [];
    var selectorCounter = 0;
    var stage_text = [];
    var tissue_text = [];
    var expr_val = 0;
			
			
			for (var x=1; x<=stages.length; x++) {
				stage_text[x] = new Kinetic.Text({
					x: x*20+150,
					y: 155,
			        // text: tissue_name,
					text: stages[x-1],
					fontSize: 16, //20 for CondensedLight
					fontFamily: 'Helvetica',
					// fontFamily: 'CondensedLight',
					fill: 'black',
					rotation: 300
					});
				layer.add(stage_text[x]);
				for (var y=1; y<=tissues.length; y++) {
					selectorCounter++;					
					add_squares(x,y,selectorCounter);
					if (x==1) {
						tissue_text[y] = new Kinetic.Text({
							x: 30,
							y: y*20+150+4,
							// text: tissue_name,
						    text: tissues[y-1],
						    align: 'left',
							fontSize: 16, //20 for CondensedLight
							fontFamily: 'Helvetica',
							// fontFamily: 'CondensedLight',
							fill: 'black',
							rotation: 0
						});
						layer.add(tissue_text[y]);
					}
				}
			}






    get_plot_group.on('mousedown', function getscatterplot() {


 	if (samples_chosen.length == 2) {
	    	document.getElementById("ExpCorrChart").innerHTML = "";
//	    document.getElementbyId("NewPlot").style.visibility="visible";
	    document.getElementById("ExpCorrChart").style.display="block";
	    document.getElementById("selector").style.display="none";
	    document.getElementById("new_plot_btn").style.display="block";
	    makeplot(samples_chosen);
	    samples_chosen = [];

//	  new_plot.fill("#777");
//	  new_plot_text.fill("#fff");	    
////	    new_plot
////	    new_plot_text.draw();
////	    new_plot.draw();
////	    new_plot_group.add(new_plot_text);
//	    new_plot_group.draw();
				}
				else if (samples_chosen.length < 2) {
				    alert("You have selected too few samples; please select two samples.");
				    //
				    if (samples_chosen.length == 1) {
				    var id_rect1 = temp_id[0];
				    
				    var temp_rect1 = stage.find("#"+id_rect1);
//				var rect_col = temp_col[0]);
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
//				    alert(lists_to_get[0])
//				    alert(lists_to_get[1])

				    var sample1tissuetempindex = lists_to_get[0][0];
				    var sample1stagetempindex = lists_to_get[0][1];
				    var sample2tissuetempindex = lists_to_get[1][0];
				    var sample2stagetempindex = lists_to_get[1][1];
				    var sample1stageindex = ((sample1stagetempindex - 150)/20) - 1;
				    var sample2stageindex = ((sample2stagetempindex - 150)/20)- 1;
				    var sample1tissueindex = ((sample1tissuetempindex - 150)/20) - 1;
				    var sample2tissueindex = ((sample2tissuetempindex - 150)/20)- 1;
				    var sample1stage = stages[sample1stageindex];
				    var sample1tissue = tissues[sample1tissueindex];
				    var sample2stage = stages[sample2stageindex];
				    var sample2tissue = tissues[sample2tissueindex];
				    
				    // make ajax request; goes to subroutine in scatterplot.pm (url); send data, variables sent are obtained from the output.mas file, which sends to this .js file
				    var ret;
 			 	    $.ajax({
				url: '/expression_viewer/scatterplot/',
// 				url: url,
//				timeout: 600000,
 				async: false,					
				method: 'POST',
 				dataType: "json",
 				data: { 'projectid': project_id, 'st_array': stages, 'ti_array': tissues, 'st_s1_index': sample1stageindex, 'st_s2_index': sample2stageindex, 'ti_s1_index': sample1tissueindex, 'ti_s2_index': sample2tissueindex, 'genes_to_plot': genes},		
				    success: function(response) {
					// ret_data should be declared outside the ajax request
 					ret = response.expression_to_plot3;
//					alert("Ajax success");
 				}// end of success function
//					error: function(XMLHttpRequest, textStatus, errorThrown) {
//					alert("Ajax failure: " + errorThrown);					    
//					}
 				    });// end of ajax
//    return ret;
// }; //end ajax data renderer
//				    var test_line1 = [[295.756591482681,400,'gene1'],[300,350,'gene2'],[100,50,'gene7'],[500,550,'gene3'],[180,230,'gene4'],[300,350,'gene5']];
//				    var test_line3 = [[295.756591482681,400],[300,350],[100,50],[500,550],[180,230],[300,350]];
//  var jsonurl = '/expression_viewer/scatterplot/';
				    var JSONobject = JSON.parse(ret);
				    var sample1_data = [];
				    var sample2_data = [];
				    var geneids = [];
			       var test_line2 = [];	       
				    for (var i=0; i<JSONobject.length; i++) {
					
					sample1_data[i] = eval(JSONobject[i]["sample1_exp"]);
					sample2_data[i] = eval(JSONobject[i]["sample2_exp"]);
//					geneids[i] = genes_to_plot[i];
					geneids[i] = JSONobject[i]["geneid"];
					test_line2[i] = [sample1_data[i],sample2_data[i],geneids[i]];
					
				    }
//				    alert(test_line2[1][2]);
				    var sampleaxislabel1 = sample1tissue + "<br>" + sample1stage;
				    var sampleaxislabel2 = sample2tissue + "<br>" + sample2stage;

				    var plot2 = $.jqplot('ExpCorrChart', [test_line2], { 
					title: {
//					    text: "Expression Scatterplot",
					    text: "",
					    textColor: 'black',
					    fontSize: '20',
						fontFamily: 'Helvetica'
					},
					gridPadding: {top:50, bottom:200, left:30, right:30},
//	dataRenderer: ajaxDataRenderer,
//	dataRendererOptions: {
//	    unusedOptionalUrl: jsonurl
//	},
//					series: [
//					    {
//						highlighter: { formatString: '%s, %s'}
//					    ]
					seriesDefaults: {
						color: "#17BDB8",
						showLine: false,
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
//							formatString: "%#.0f"
						},
					},
								grid: {
				background: "white",
				borderColor: "black",
        shadow: false,
			},
	    highlighter: {
//		tooltipContentEditor: function (str, seriesIndex, pointIndex, plot) {
		    //return str;
//		    return test_line2[seriesIndex][2];
		    
		    // return geneids[pointIndex];
		    //return str + geneids[pointIndex];

//	    },
		show: true,
		yvalues: 2,
//		formatString: "%s %s %s",
//		formatString: "%s<br>%s<br>%d",
		//		formatString: "%s<br><div style='display:none'>%d</div><br>%s",
		sizeAdjust: 7.5
					},
					cursor: {
						show: false
					}
				}); // end plot2


    
				}; //end of makeplot

//      var stage2 = new Kinetic.Stage({
//		  		container: "ExpCorrChart",
//		  		width: 600,
//		  		height: 600
//			});
//			var layer2 = new Kinetic.Layer();
//	var new_plot_group = new Kinetic.Group();
//	  var new_plot = new Kinetic.Rect({
//	      x: 150,
//	      y: 380,
//	      width: 230,
//	      height: 25,
//	      strokeWidth: 0,
//	      cornerRadius : 5,
//	      fill:'#777',
//	  });
//	  new_plot_group.add(new_plot);
//	  var new_plot_text = new Kinetic.Text({
//	      x: 158,
//	      y: 384,
//	      text: "Get new scatterplot",
//	      fontSize: '18',
//	      fill: "#fff",
//	      fontFamily: 'Helvetica',	      
//
//	  });
  //    new_plot_group.add(new_plot_text);
	//  layer2.add(new_plot_group);
			    }); // end of get_scatterplot
    

    
			function handleClick() {       			
//        		    alert(this.y());
			    //			    alert(this.x());
			    var temp_idx = this.id();
			    var temp_idy = temp_id[0];
			    var temp_idz = temp_id[1];
			    
			    if ((temp_idx != temp_idy) && (temp_idx != temp_idz)) {
			    if (samples_chosen.length < 2) {
				//				for x in temp_id
				

        			samples_chosen.push([this.y(),this.x()]);
				temp_id.push(this.id());
				temp_col = this.fill();
				

//				alert(this.fill());
//				alert(samples_chosen.length);
			    } else {
				var id_rect = temp_id[0];
				var temp_rect = stage.find("#"+id_rect);
//				var rect_col = temp_col[0]);
			        temp_rect.fill(stored_color[id_rect]);
				temp_rect.name("notselected");
				temp_rect.draw();
				samples_chosen.shift();
        			samples_chosen.push([this.y(),this.x()]);
				temp_id.shift();
				temp_id.push(this.id());				
//				alert(this.y());
//				alert(samples_chosen.length);
			    }
         		    }else{
			    }
			}
         	
			var temp_array_length = selectorArray.length - 1;
			for (var y=1; y<=temp_array_length; y++) {
				selectorArray[y].on("click",handleClick);
			}


//	function newplothandle() {
//	    alert("hello!");
//	}
//	$("#NewPlot").click(function {
//	    alert("hello!");
	//	});
//	new_plot_group.on("click", function {
//	    alert("hello!");
//	});
//	$(document).on("click","#newplotbutton",newplothandle);
	$("#new_plot_btn").click(function(){
    document.getElementById("selector").style.display="block";
	    document.getElementById("ExpCorrChart").style.display="none";
	    document.getElementById("new_plot_btn").style.display="none";

	});



  });




});
