$(document).ready(function () {

    var network_loaded = 0;

    $("#network_tab").click(function(){
	    $("#dwl_expr_data").css("display","none");
	    $("#dwl_cube").css("display","none");

		d3.select("svg").remove();
		var max_genes = $( "#max_genes" ).val();

		var data =  getnetwork(max_genes);

		makenetwork(data.genes,data.edges);
		network_loaded = 1;

	});

	$("#update_network_btn").click(function(){
	    // $("#dwl_expr_data").css("display","none");

		d3.select("svg").remove();
		var max_genes = $( "#max_genes" ).val();
		var new_corr = $( "#amount_network" ).val();

		var data =  getnetwork(max_genes,new_corr);

		makenetwork(data.genes,data.edges);
		network_loaded = 1;

	});

	$( "#correlation_slider_network" ).slider({
	      range: "min",
	      min: 65,
	      max: 99,
	      value: 70,
	      slide: function( event, ui ) {
	        $( ".corr_filter" ).val( ui.value );
	        $( "#amount_network" ).val( ui.value );
	      }
	    });
	    $( "#amount_network" ).val( $( "#correlation_slider_network" ).slider( "value" ) );
	    $( ".corr_filter" ).val( $( "#correlation_slider_network" ).slider( "value" ) );
	  // });

	function getnetwork(max_genes,new_corr){
		var genes;
		var edges;

		if(new_corr){
			correlation_filter = new_corr;
		}

		jQuery.ajax({
		    url: '/expression_viewer/get_network/',
 		    async: false,
		    method: 'GET',
		    dataType: "json",
		    data: { 'projectid': project_id, 'corrfiltervalue' : correlation_filter/100, 'inputgene' : input_gene, 'maxgenes' : max_genes } ,
		    success: function(response) {
				genes = JSON.parse(response.genes);
				edges = JSON.parse(response.edges);
 		    },
 		    error: function(response) {
                alert(response);
           }
		});

		return {
			genes: genes,
			edges: edges
	    };
	}

	function makenetwork(genes_in,edges_in){

			var network = d3.network()
			            .genes(genes_in)
			            .edges(edges_in)
			            .geneText(function(d) { return d.name; });

			d3.select("#container_network_graph")
			.append("svg")
			.attr("width", 1080)
			.attr("height", 850)
			.call(network);

			// network.showLegend().filter(.1, 5).draw();
			network.showLegend().draw();
		} //end of makenetwork function
});
