$(document).ready(function () {

    var network_loaded = 0;

    $("#network_tab").click(function(){
	    $("#dwl_expr_data").css("display","none");

		d3.select("svg").remove();

		var genes;
		var edges;

		jQuery.ajax({
		    url: '/expression_viewer/get_network/',
 		    async: false,
		    method: 'GET',
		    dataType: "json",
		    data: { 'projectid': project_id, 'corrfiltervalue' : correlation_filter/100, 'inputgene' : input_gene } ,
		    success: function(response) {
				genes = JSON.parse(response.genes);
				edges = JSON.parse(response.edges);
 		    },
 		    error: function(response) {
                alert(response);
           }
		});
		
		makenetwork(genes,edges);
		network_loaded = 1;

	});

	function makenetwork(genes_in,edges_in){

			var network = d3.network()
			            .genes(genes_in)
			            .edges(edges_in)
			            .geneText(function(d) { return d.name; });

			d3.select("#container_network")
			.append("svg")
			.attr("width", 1000)
			.attr("height", 1000)
			.call(network);

			// network.showLegend().filter(.1, 5).draw();
			network.showLegend().draw();
		} //end of makenetwork function
});
