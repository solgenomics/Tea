$(document).ready(function () {

    var network_loaded = 0;

    $("#network_tab").click(function(){
    $('#dwl_expr_data').css("display","none");
//	alert("in the javascript");
	if (!network_loaded) {
//	    alert("in the network loader");
//	    var all_gene_selector = 1;
//	    var st_s1_index = 1;
//	    var st_s2_index = 1;
//	    var ti_s1_index = 1;
//	    var ti_s2_index = 1;
	    makenetwork();

	    function makenetwork(){
/*
		//		alert("in makenetwork function");
		var ret;
		var ret2;
		$.ajax({
		    url: '/expression_viewer/get_network/',
 		    async: false,
		    method: 'POST',
//		    dataType: "json",
		    success: function(response) {
			ret = response.node_genes_to_plot;
			ret2 = response.edges_to_plot;
//			alert("Ajax success");
 		    }
		});
*/
//		var JSONobject = JSON.parse(ret);
//		alert(ret);

		/*		$.ajax({
					url: '/expression_viewer/get_network2/',
//					beforeSend: function() {
//					    $("#loading_modal").modal("show");
//					},


 					async: true,
					method: 'POST',
 					dataType: "json",
 					data: { 'projectid': project_id, 'st_array': stages, 'ti_array': tissues, 'st_s1_index': sample1stageindex, 'st_s2_index': sample2stageindex, 'ti_s1_index': sample1tissueindex, 'ti_s2_index': sample2tissueindex, 'genes_to_plot': genes, 'corr_filter_to_set_genes': correlation_filter, 'gene_set_request': all_gene_selector},
				    success: function(response) {
					ret = response.correlation_network_to_plot;
					alert("success!");

 				}
 				    });
	    var JSONobject = JSON.parse(ret);
	    alert(JSONobject);*/


/*
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
*/
     genes_in = [
         { id: 0, name: "zero" },
         { id: 1, name: "one" },
         { id: 2, name: "two"},
         { id: 3, name: "three", query:true}
     ];

/*	    edges_in = JSONobject;*/
/*		var JSONobject = JSON.parse(ret);
//		alert(JSONobject);
		genes_in = JSONobject;

		var JSONobject2 = JSON.parse(ret2);
//		alert(JSONobject2);
		edges_in = JSONobject2;
*/
     edges_in = [
         { id: 0, source: 0, target: 1, weight: 0.1 },
         { id: 1, source: 0, target: 2, weight: 0.2 },
         { id: 2, source: 0, target: 3, weight: 0.3 },
         { id: 3, source: 1, target: 2, weight: 0.4 },
         { id: 4, source: 2, target: 3, weight: 0.5 }
     ];

     var network = d3.network()
                    .genes(genes_in)
                    .edges(edges_in)
                    .geneText(function(d) { return d.name; });

     d3.select("#container_network")
        .append("svg")
        .attr("width", 500)
        .attr("height", 500)
        .call(network);

     network.showLegend().filter(.05, 5).draw();
	    } //end of makenetwork function


	    network_loaded = 1;

	}

    });
});
