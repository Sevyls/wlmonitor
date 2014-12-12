$(function() {
	// Haltestellen Filter
	$("#haltestelle-filter").bindWithDelay("change paste keyup", function() {

		var keyword = $("#haltestelle-filter").val();

		$("#haltestellen-liste > a").hide();
		$("#haltestellen-liste > a:Contains('" + keyword + "')").show();
	}, 200);

	// Haltestelle Karte
	if ($("#haltestelle-map").length) {
		var koords = $('#haltestelle-koordinaten');
		var lat = koords.find(".lat").text();
		var lon = koords.find(".lon").text();
		koords.find("p.koords").remove();

		var haltestellePosition = new google.maps.LatLng(lat, lon);

		var mapOptions = {
			center: haltestellePosition,
			zoom: 18,
			mapTypeId: google.maps.MapTypeId.ROADMAP
		};
		var map = new google.maps.Map($("#haltestelle-map")[0], mapOptions);

		var marker = new google.maps.Marker({
			position: haltestellePosition,
			map: map,
			title: $("h1").text()
		});
	}
});
