$(document).ready(function () {

    var network_loaded = 0;

    $("#network_tab").click(function(){
    $("#dwl_expr_data").css("display","none");

	d3.select("svg").remove();

	d3.json("/static/data_genes.json", function(genes) {
		// console.log(data);
		
		d3.json("/static/data_edges.json", function(edges) {

		//if (!network_loaded) {
			makenetwork(genes,edges);
		//}
		return edges;
	});
		return genes;
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

		network.showLegend().filter(.08, 60).draw();
		} //end of makenetwork function

		network_loaded = 1;

	});
});
