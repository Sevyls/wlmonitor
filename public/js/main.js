// Haltestellen Filter
$(function() {
	$("#haltestelle-filter").bindWithDelay("change paste keyup", function() {

		var keyword = $("#haltestelle-filter").val();
		console.log(keyword);
		$("#haltestellen-liste > a").hide();
		$("#haltestellen-liste > a:contains('" + keyword + "')").show();
	}, 200);

	if ($("#haltestelle-map").length) {
		var koords = $('#haltestelle-koordinaten');
		var lat = koords.find(".lat").text();
		var lon = koords.find(".lon").text();
		koords.find("p.koords").remove();

		var latlng = new google.maps.LatLng(lat, lon);

		var mapOptions = {
			center: latlng,
			zoom: 18,
			mapTypeId: google.maps.MapTypeId.ROADMAP
		};
		var map = new google.maps.Map($("#haltestelle-map")[0], mapOptions);

		var marker = new google.maps.Marker({
			position: latlng,
			map: map,
		});
	}
});
