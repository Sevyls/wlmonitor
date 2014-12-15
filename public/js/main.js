$(function() {
	// Haltestellen Filter
	$("#haltestelle-filter").bindWithDelay("change paste keyup", function() {

		var keyword = $("#haltestelle-filter").val();

		$("#haltestellen-liste > a").hide();
		var gefundeneHaltestellen = $("#haltestellen-liste > a:Contains('" + keyword + "')");
		gefundeneHaltestellen.show();
		$('#haltestellen-anzahl').text(gefundeneHaltestellen.length);

	}, 200);



	// Haltestelle Karte
	if ($("#haltestelle-map").length) {
		var koords = $('#haltestelle-koordinaten');
		var lat = koords.find(".lat").text();
		var lon = koords.find(".lon").text();
		koords.find("p.koords").remove();

		var haltestellePosition = new google.maps.LatLng(lat, lon);
		var haltestelleName = $("h1").text();

		var mapOptions = {
			center: haltestellePosition,
			zoom: 18,
			mapTypeId: google.maps.MapTypeId.ROADMAP
		};
		var map = new google.maps.Map($("#haltestelle-map")[0], mapOptions);


		var contentString = '<div id="infoHaltestelle">'+
		'<div id="siteNotice"><p>Haltestelle</p>'+
		'</div>'+
		'<h4 id="firstHeading" class="firstHeading">' + haltestelleName + '</h4>'+
		'</div>';

		var infowindow = new google.maps.InfoWindow({
			content: contentString
		});

		var marker = new google.maps.Marker({
			position: haltestellePosition,
			map: map,
			title: haltestelleName
		});

		google.maps.event.addListener(marker, 'click', function() {
			infowindow.open(map,marker);
		});

		google.maps.event.addDomListener(window, "resize", function() {
			var center = map.getCenter();
			google.maps.event.trigger(map, "resize");
			map.setCenter(center);
		});
	}
});
