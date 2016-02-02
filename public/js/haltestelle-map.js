$(function() {
  // Haltestelle Karte
  if ($("#haltestelle-map").length) {
    var haltestelleId = $("#haltestelle").data('haltestelleid');

    $.getJSON( "/haltestellen/" + haltestelleId + ".json", function(data) {
      haltestelle = data;

      haltestellePosition = new google.maps.LatLng(haltestelle.lat, haltestelle.lon);

      var mapOptions = {
        center: haltestellePosition,
        zoom: 18,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      var map = new google.maps.Map($("#haltestelle-map")[0], mapOptions);

      var contentString = '<div id="infoHaltestelle">'+
      '<div id="siteNotice"><p>Haltestelle</p>'+
      '</div>'+
      '<h4 id="firstHeading" class="firstHeading">' + haltestelle.name + '</h4>'+
      '</div>';

      var infowindow = new google.maps.InfoWindow({
        content: contentString
      });

      var haltestelleMarker = new google.maps.Marker({
        position: haltestellePosition,
        map: map,
        title: haltestelle.name
      });


      google.maps.event.addListener(marker, 'click', function() {
        infowindow.open(map, marker);
      });

      google.maps.event.addDomListener(window, "resize", function() {
        var center = map.getCenter();
        google.maps.event.trigger(map, "resize");
        map.setCenter(center);
      });
    });
  }
});
