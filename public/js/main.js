// Haltestellen Filter
$(function() {
	$("#haltestelle-filter").bindWithDelay("change paste keyup", function() {

		var keyword = $("#haltestelle-filter").val();
		console.log(keyword);
		$("#haltestellen-liste > a").hide();
		$("#haltestellen-liste > a:contains('" + keyword + "')").show();
	}, 200);
});