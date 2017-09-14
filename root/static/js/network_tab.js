$(document).ready(function () {

    var network_loaded = 0;

    $("#network_tab").click(function(){
    $("#dwl_expr_data").css("display","none");
	alert("in the javascript");
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
/*         { id: 0, name: "Solyc03g095290" },
         { id: 1, name: "Solyc03g116570" },
         { id: 2, name: "Solyc04g016470" },
         { id: 3, name: "Solyc01g102660", query:true},
	 { id: 4, name: "Solyc05g012020" },
	 { id: 5, name: "Solyc05g056620" },*/
	 { id: 0, name: "Solyc01g102660", query:true },
{ id: 1, name: "Solyc09g007270" },
{ id: 2, name: "Solyc11g010450" },
{ id: 3, name: "Solyc01g096100" },
{ id: 4, name: "Solyc01g112120" },
{ id: 5, name: "Solyc01g067660" },
{ id: 6, name: "Solyc03g095290" },
{ id: 7, name: "Solyc03g121840" },
{ id: 8, name: "Solyc07g047800" },
{ id: 9, name: "Solyc09g064720" },
{ id: 10, name: "Solyc12g007090" },
{ id: 11, name: "Solyc01g088090" },
{ id: 12, name: "Solyc02g080270" },
{ id: 13, name: "Solyc02g084870" },
{ id: 14, name: "Solyc06g084530" },
{ id: 15, name: "Solyc12g017250" },
{ id: 16, name: "Solyc12g099360" },
{ id: 17, name: "Solyc01g090550" },
{ id: 18, name: "Solyc01g099190" },
{ id: 19, name: "Solyc02g077920" },
{ id: 20, name: "Solyc03g033640" },
{ id: 21, name: "Solyc06g053710" },
{ id: 22, name: "Solyc08g065880" },
{ id: 23, name: "Solyc10g008500" },
{ id: 24, name: "Solyc10g051200" },
{ id: 25, name: "Solyc01g097540" },
{ id: 26, name: "Solyc02g063360" },
{ id: 27, name: "Solyc02g070020" },
{ id: 28, name: "Solyc02g077670" },
{ id: 29, name: "Solyc03g083910" },
{ id: 30, name: "Solyc04g071150" },
{ id: 31, name: "Solyc05g052260" },
{ id: 32, name: "Solyc07g007660" },
{ id: 33, name: "Solyc07g049530" },
{ id: 34, name: "Solyc08g075730" },
{ id: 35, name: "Solyc08g082980" },
{ id: 36, name: "Solyc09g020110" },
{ id: 37, name: "Solyc10g006650" },
{ id: 38, name: "Solyc12g005860" },
{ id: 39, name: "Solyc12g099310" },
{ id: 40, name: "Solyc01g094080" },
{ id: 41, name: "Solyc01g097810" },
{ id: 42, name: "Solyc01g099680" },
{ id: 43, name: "Solyc01g109170" },
{ id: 44, name: "Solyc01g112130" },
{ id: 45, name: "Solyc03g031860" },
{ id: 46, name: "Solyc03g113270" },
{ id: 47, name: "Solyc05g008920" },
{ id: 48, name: "Solyc06g005970" },
{ id: 49, name: "Solyc07g049200" },
{ id: 50, name: "Solyc04g074140" },
{ id: 51, name: "Solyc05g055470" },
{ id: 52, name: "Solyc06g036170" },
{ id: 53, name: "Solyc06g064900" },
{ id: 54, name: "Solyc07g007930" },
{ id: 55, name: "Solyc07g041900" },
{ id: 56, name: "Solyc07g047820" },
{ id: 57, name: "Solyc07g053830" },
{ id: 58, name: "Solyc08g005860" },
{ id: 59, name: "Solyc08g078430" },
{ id: 60, name: "Solyc09g010140" },
{ id: 61, name: "Solyc09g031700" },
{ id: 62, name: "Solyc09g074650" },
{ id: 63, name: "Solyc09g089610" },
{ id: 64, name: "Solyc09g089730" },
{ id: 65, name: "Solyc09g091470" },
{ id: 66, name: "Solyc10g007990" },
{ id: 67, name: "Solyc10g008470" },
{ id: 68, name: "Solyc10g012370" },
{ id: 69, name: "Solyc10g047040" },
{ id: 70, name: "Solyc10g084140" },
{ id: 71, name: "Solyc10g085230" },
{ id: 72, name: "Solyc11g005190" },
{ id: 73, name: "Solyc11g011990" },
{ id: 74, name: "Solyc11g013470" },
{ id: 75, name: "Solyc12g007170" },
{ id: 76, name: "Solyc12g009060" },
{ id: 77, name: "Solyc12g089000" },
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
/*         { id: 0, source: 0, target: 1, weight: 0.1 },
        { id: 1, source: 0, target: 2, weight: 0.2 },
         { id: 2, source: 0, target: 3, weight: 0.3 },
         { id: 3, source: 1, target: 2, weight: 0.4 },
         { id: 4, source: 2, target: 3, weight: 0.5 },
	 { id: 5, source: 4, target: 3, weight: 0.5 },
	 { id: 6, source: 5, target: 3, weight: 0.5 },	 */
{ id: 0, source: 55, target: 16, weight: 0.032 },
{ id: 1, source: 55, target: 25, weight: 0.065 },
{ id: 2, source: 55, target: 41, weight: 0.161 },
{ id: 3, source: 55, target: 48, weight: 0.129 },
{ id: 4, source: 56, target: 49, weight: 0.032 },
{ id: 5, source: 56, target: 55, weight: 0.032 },
{ id: 6, source: 57, target: 55, weight: 0.032 },
{ id: 7, source: 57, target: 41, weight: 0.032 },
{ id: 8, source: 57, target: 48, weight: 0.032 },
{ id: 9, source: 58, target: 55, weight: 0.226 },
{ id: 10, source: 58, target: 48, weight: 0.226 },
{ id: 11, source: 58, target: 27, weight: 0.194 },
{ id: 12, source: 58, target: 57, weight: 0.032 },
{ id: 13, source: 58, target: 0, weight: 0.329 },
{ id: 14, source: 59, target: 58, weight: 0.484 },
{ id: 15, source: 59, target: 55, weight: 0.161 },
{ id: 16, source: 59, target: 48, weight: 0.194 },
{ id: 17, source: 59, target: 57, weight: 0.265 },
{ id: 18, source: 60, target: 48, weight: 0.032 },
{ id: 19, source: 60, target: 58, weight: 0.129 },
{ id: 20, source: 60, target: 59, weight: 0.065 },
{ id: 21, source: 61, target: 48, weight: 0.265 },
{ id: 22, source: 61, target: 58, weight: 0.194 },
{ id: 23, source: 61, target: 60, weight: 0.065 },
{ id: 24, source: 61, target: 59, weight: 0.161 },
{ id: 25, source: 61, target: 57, weight: 0.032 },
{ id: 26, source: 61, target: 55, weight: 0.032 },
{ id: 27, source: 62, target: 55, weight: 0.490 },
{ id: 28, source: 62, target: 58, weight: 0.548 },
{ id: 29, source: 62, target: 59, weight: 0.419 },
{ id: 30, source: 62, target: 48, weight: 0.226 },
{ id: 31, source: 62, target: 57, weight: 0.265 },
{ id: 32, source: 62, target: 41, weight: 0.032 },
{ id: 33, source: 62, target: 61, weight: 0.194 },
{ id: 34, source: 62, target: 60, weight: 0.097 },
{ id: 35, source: 63, target: 59, weight: 0.161 },
{ id: 36, source: 63, target: 48, weight: 0.161 },
{ id: 37, source: 63, target: 62, weight: 0.194 },
{ id: 38, source: 63, target: 57, weight: 0.065 },
{ id: 39, source: 63, target: 58, weight: 0.129 },
{ id: 40, source: 63, target: 61, weight: 0.097 },
{ id: 41, source: 63, target: 60, weight: 0.265 },
{ id: 42, source: 63, target: 55, weight: 0.032 },
{ id: 43, source: 64, target: 55, weight: 0.161 },
{ id: 44, source: 64, target: 62, weight: 0.387 },
{ id: 45, source: 64, target: 48, weight: 0.161 },
{ id: 46, source: 64, target: 63, weight: 0.129 },
{ id: 47, source: 64, target: 58, weight: 0.323 },
{ id: 48, source: 64, target: 61, weight: 0.194 },
{ id: 49, source: 64, target: 60, weight: 0.065 },
{ id: 50, source: 64, target: 59, weight: 0.490 },
{ id: 51, source: 64, target: 57, weight: 0.032 },
{ id: 52, source: 64, target: 0, weight: 0.032 },
{ id: 53, source: 65, target: 63, weight: 0.161 },
{ id: 54, source: 65, target: 64, weight: 0.226 },
{ id: 55, source: 65, target: 48, weight: 0.097 },
{ id: 56, source: 65, target: 62, weight: 0.161 },
{ id: 57, source: 65, target: 58, weight: 0.161 },
{ id: 58, source: 65, target: 61, weight: 0.161 },
{ id: 59, source: 65, target: 60, weight: 0.265 },
{ id: 60, source: 65, target: 59, weight: 0.161 },
{ id: 61, source: 65, target: 57, weight: 0.032 },
{ id: 62, source: 65, target: 55, weight: 0.265 },
{ id: 63, source: 66, target: 64, weight: 0.097 },
{ id: 64, source: 66, target: 58, weight: 0.097 },
{ id: 65, source: 66, target: 59, weight: 0.032 },
{ id: 66, source: 66, target: 62, weight: 0.065 },
{ id: 67, source: 66, target: 65, weight: 0.065 },
{ id: 68, source: 66, target: 48, weight: 0.032 },
{ id: 69, source: 66, target: 63, weight: 0.032 },
{ id: 70, source: 66, target: 61, weight: 0.032 },
{ id: 71, source: 66, target: 60, weight: 0.032 },
{ id: 72, source: 67, target: 57, weight: 0.097 },
{ id: 73, source: 68, target: 25, weight: 0.161 },
{ id: 74, source: 68, target: 0, weight: 0.032 },
{ id: 75, source: 68, target: 24, weight: 0.032 },
{ id: 76, source: 68, target: 27, weight: 0.032 },
{ id: 77, source: 68, target: 48, weight: 0.032 },
{ id: 78, source: 68, target: 41, weight: 0.032 },
{ id: 79, source: 69, target: 25, weight: 0.194 },
{ id: 80, source: 69, target: 68, weight: 0.194 },
{ id: 81, source: 69, target: 0, weight: 0.032 },
{ id: 82, source: 69, target: 24, weight: 0.032 },
{ id: 83, source: 69, target: 27, weight: 0.065 },
{ id: 84, source: 69, target: 48, weight: 0.032 },
{ id: 85, source: 69, target: 41, weight: 0.032 },
{ id: 86, source: 70, target: 25, weight: 0.129 },
{ id: 87, source: 70, target: 69, weight: 0.129 },
{ id: 88, source: 70, target: 68, weight: 0.129 },
{ id: 89, source: 70, target: 0, weight: 0.032 },
{ id: 90, source: 70, target: 24, weight: 0.032 },
{ id: 91, source: 70, target: 27, weight: 0.032 },
{ id: 92, source: 70, target: 41, weight: 0.032 },
{ id: 93, source: 70, target: 58, weight: 0.032 },
{ id: 94, source: 71, target: 27, weight: 0.032 },
{ id: 95, source: 71, target: 69, weight: 0.065 },
{ id: 96, source: 71, target: 68, weight: 0.065 },
{ id: 97, source: 71, target: 70, weight: 0.065 },
{ id: 98, source: 71, target: 0, weight: 0.032 },
{ id: 99, source: 71, target: 48, weight: 0.032 },
{ id: 100, source: 71, target: 41, weight: 0.032 },
{ id: 101, source: 71, target: 25, weight: 0.032 },
{ id: 102, source: 72, target: 26, weight: 0.065 },
{ id: 103, source: 72, target: 27, weight: 0.032 },
{ id: 104, source: 72, target: 0, weight: 0.032 },
{ id: 105, source: 73, target: 48, weight: 0.065 },
{ id: 106, source: 74, target: 48, weight: 0.065 },
{ id: 107, source: 74, target: 73, weight: 0.097 },
{ id: 108, source: 75, target: 69, weight: 0.097 },
{ id: 109, source: 75, target: 68, weight: 0.097 },
{ id: 110, source: 75, target: 25, weight: 0.097 },
{ id: 111, source: 75, target: 48, weight: 0.032 },
{ id: 112, source: 75, target: 41, weight: 0.032 },
{ id: 113, source: 75, target: 70, weight: 0.032 },
{ id: 114, source: 75, target: 71, weight: 0.032 },
{ id: 115, source: 76, target: 64, weight: 0.032 },
{ id: 116, source: 76, target: 65, weight: 0.032 },
{ id: 117, source: 76, target: 66, weight: 0.032 },
{ id: 118, source: 76, target: 63, weight: 0.032 },
{ id: 119, source: 76, target: 62, weight: 0.032 },
{ id: 120, source: 76, target: 48, weight: 0.032 },
{ id: 121, source: 76, target: 58, weight: 0.032 },
{ id: 122, source: 2, target: 1, weight: 0.032 },
{ id: 123, source: 3, target: 1, weight: 0.458 },
{ id: 124, source: 4, target: 1, weight: 0.323 },
{ id: 125, source: 4, target: 3, weight: 0.194 },
{ id: 126, source: 5, target: 1, weight: 0.032 },
{ id: 127, source: 6, target: 1, weight: 0.032 },
{ id: 128, source: 7, target: 1, weight: 0.032 },
{ id: 129, source: 8, target: 1, weight: 0.032 },
{ id: 130, source: 9, target: 1, weight: 0.065 },
{ id: 131, source: 10, target: 1, weight: 0.032 },
{ id: 132, source: 0, target: 11, weight: 0.032 },
{ id: 133, source: 0, target: 4, weight: 0.097 },
{ id: 134, source: 0, target: 3, weight: 0.097 },
{ id: 135, source: 0, target: 1, weight: 0.161 },
{ id: 136, source: 12, target: 0, weight: 0.032 },
{ id: 137, source: 13, target: 0, weight: 0.032 },
{ id: 138, source: 14, target: 0, weight: 0.032 },
{ id: 139, source: 15, target: 0, weight: 0.032 },
{ id: 140, source: 17, target: 16, weight: 0.129 },
{ id: 141, source: 18, target: 16, weight: 0.129 },
{ id: 142, source: 18, target: 17, weight: 0.129 },
{ id: 143, source: 19, target: 16, weight: 0.129 },
{ id: 144, source: 19, target: 17, weight: 0.129 },
{ id: 145, source: 19, target: 18, weight: 0.129 },
{ id: 146, source: 20, target: 16, weight: 0.097 },
{ id: 147, source: 20, target: 17, weight: 0.097 },
{ id: 148, source: 20, target: 18, weight: 0.097 },
{ id: 149, source: 20, target: 19, weight: 0.129 },
{ id: 150, source: 21, target: 16, weight: 0.097 },
{ id: 151, source: 21, target: 17, weight: 0.097 },
{ id: 152, source: 21, target: 18, weight: 0.097 },
{ id: 153, source: 21, target: 19, weight: 0.097 },
{ id: 154, source: 21, target: 20, weight: 0.161 },
{ id: 155, source: 22, target: 16, weight: 0.097 },
{ id: 156, source: 22, target: 17, weight: 0.097 },
{ id: 157, source: 22, target: 18, weight: 0.097 },
{ id: 158, source: 22, target: 19, weight: 0.097 },
{ id: 159, source: 22, target: 20, weight: 0.129 },
{ id: 160, source: 22, target: 21, weight: 0.129 },
{ id: 161, source: 23, target: 16, weight: 0.097 },
{ id: 162, source: 23, target: 17, weight: 0.097 },
{ id: 163, source: 23, target: 18, weight: 0.097 },
{ id: 164, source: 23, target: 19, weight: 0.097 },
{ id: 165, source: 23, target: 20, weight: 0.129 },
{ id: 166, source: 23, target: 21, weight: 0.129 },
{ id: 167, source: 23, target: 22, weight: 0.129 },
{ id: 168, source: 23, target: 12, weight: 0.065 },
{ id: 169, source: 23, target: 0, weight:  0.490},
{ id: 170, source: 24, target: 23, weight: 0.065 },
{ id: 171, source: 24, target: 0, weight: 0.426 },
{ id: 172, source: 25, target: 24, weight: 0.419 },
{ id: 173, source: 25, target: 23, weight: 0.032 },
{ id: 174, source: 25, target: 0, weight: 0.587 },
{ id: 175, source: 26, target: 24, weight: 0.129 },
{ id: 176, source: 26, target: 0, weight: 1.000 },
{ id: 177, source: 26, target: 16, weight: 0.032 },
{ id: 178, source: 26, target: 25, weight: 0.032 },
{ id: 179, source: 27, target: 0, weight: 0.748 },
{ id: 180, source: 27, target: 23, weight: 0.161 },
{ id: 181, source: 27, target: 25, weight: 0.161 },
{ id: 182, source: 27, target: 24, weight: 0.032 },
{ id: 183, source: 27, target: 26, weight: 0.032 },
{ id: 184, source: 28, target: 0, weight: 0.458 },
{ id: 185, source: 28, target: 27, weight: 0.032 },
{ id: 186, source: 29, target: 23, weight: 0.032 },
{ id: 187, source: 29, target: 27, weight: 0.032 },
{ id: 188, source: 29, target: 0, weight: 0.065 },
{ id: 189, source: 30, target: 23, weight: 0.032 },
{ id: 190, source: 31, target: 30, weight: 0.065 },
{ id: 191, source: 31, target: 0, weight: 0.097 },
{ id: 192, source: 31, target: 23, weight: 0.065 },
{ id: 193, source: 31, target: 27, weight: 0.032 },
{ id: 194, source: 32, target: 0, weight: 0.032 },
{ id: 195, source: 33, target: 0, weight: 0.265 },
{ id: 196, source: 33, target: 27, weight: 0.032 },
{ id: 197, source: 34, target: 0, weight: 0.097 },
{ id: 198, source: 34, target: 29, weight: 0.065 },
{ id: 199, source: 35, target: 0, weight: 0.297 },
{ id: 200, source: 35, target: 34, weight: 0.097 },
{ id: 201, source: 35, target: 29, weight: 0.065 },
{ id: 202, source: 36, target: 34, weight: 0.065 },
{ id: 203, source: 36, target: 35, weight: 0.065 },
{ id: 204, source: 36, target: 0, weight: 0.265 },
{ id: 205, source: 36, target: 29, weight: 0.032 },
{ id: 206, source: 37, target: 34, weight: 0.065 },
{ id: 207, source: 37, target: 35, weight: 0.065 },
{ id: 208, source: 37, target: 36, weight: 0.065 },
{ id: 209, source: 37, target: 0, weight: 0.265 },
{ id: 210, source: 37, target: 29, weight: 0.032 },
{ id: 211, source: 38, target: 34, weight: 0.065 },
{ id: 212, source: 38, target: 35, weight: 0.065 },
{ id: 213, source: 38, target: 36, weight: 0.065 },
{ id: 214, source: 38, target: 37, weight: 0.065 },
{ id: 215, source: 38, target: 0, weight: 0.265 },
{ id: 216, source: 38, target: 29, weight: 0.032 },
{ id: 217, source: 39, target: 25, weight: 0.032 },
{ id: 218, source: 40, target: 25, weight: 0.032 },
{ id: 219, source: 41, target: 24, weight: 0.065 },
{ id: 220, source: 41, target: 25, weight: 0.097 },
{ id: 221, source: 42, target: 41, weight: 0.065 },
{ id: 222, source: 42, target: 25, weight: 0.065 },
{ id: 223, source: 42, target: 24, weight: 0.032 },
{ id: 224, source: 43, target: 0, weight: 0.297 },
{ id: 225, source: 43, target: 26, weight: 0.032 },
{ id: 226, source: 43, target: 27, weight: 0.032 },
{ id: 227, source: 44, target: 28, weight: 0.097 },
{ id: 228, source: 44, target: 0, weight: 0.032 },
{ id: 229, source: 45, target: 28, weight: 0.065 },
{ id: 230, source: 47, target: 46, weight: 0.032 },
{ id: 231, source: 48, target: 47, weight: 0.065 },
{ id: 232, source: 48, target: 25, weight: 0.032 },
{ id: 233, source: 48, target: 27, weight: 0.032 },
{ id: 234, source: 48, target: 0, weight: 0.032 },
{ id: 235, source: 49, target: 26, weight: 0.097 },
{ id: 236, source: 49, target: 0, weight: 0.265 },
{ id: 237, source: 50, target: 49, weight: 0.032 },
{ id: 238, source: 50, target: 24, weight: 0.032 },
{ id: 239, source: 51, target: 49, weight: 0.490 },
{ id: 240, source: 51, target: 26, weight: 0.065 },
{ id: 241, source: 51, target: 0, weight: 0.265 },
{ id: 242, source: 52, target: 51, weight: 0.032 },
{ id: 243, source: 52, target: 39, weight: 0.032 },
{ id: 244, source: 53, target: 51, weight: 0.032 },
{ id: 245, source: 54, target: 51, weight: 0.065 },
{ id: 246, source: 54, target: 49, weight: 0.032 },
{ id: 247, source: 54, target: 26, weight: 0.032 },
{ id: 248, source: 55, target: 51, weight: 0.194 },
{ id: 249, source: 55, target: 49, weight: 0.387 },
{ id: 250, source: 55, target: 39, weight: 0.032 },
{ id: 251, source: 55, target: 54, weight: 0.032 },
{ id: 252, source: 55, target: 26, weight: 0.677 },
{ id: 253, source: 55, target: 0, weight: 0.813 },	 
     ];

     var network = d3.network()
                    .genes(genes_in)
                    .edges(edges_in)
                    .geneText(function(d) { return d.name; });

     d3.select("#container_network")
        .append("svg")
        .attr("width", 1000)
        .attr("height", 1000)
        .call(network);

     network.showLegend().filter(.05, 60).draw();
	    } //end of makenetwork function


	    network_loaded = 1;

	}

    });
});
