$(function() {
	// Haltestellen Filter
	$("#haltestelle-filter").bindWithDelay("change paste keyup", function() {

		var keyword = $("#haltestelle-filter").val();

		$("#haltestellen-liste > a").hide();
		var gefundeneHaltestellen = $("#haltestellen-liste > a:Contains('" + keyword + "')");
		gefundeneHaltestellen.show();
		$('#haltestellen-anzahl').text(gefundeneHaltestellen.length);

	}, 200);

});
