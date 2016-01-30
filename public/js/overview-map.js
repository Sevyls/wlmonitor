$(function() {
  // Übersichtskarte
  var vienna = new google.maps.LatLng('48.208330230278', '16.373063840833');
  var overviewMapOptions = {
    center: vienna,
    zoom: 12,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  var overviewMap = new google.maps.Map($("#overview-map")[0], overviewMapOptions);


  $.getJSON( "/haltestellen.json", function( data ) {
    var haltestelleids = [];
    $.each( data, function( key, val ) {
      if ( key == 'ids') {
        haltestelleids = val;
      }
    });

    $.each(data['ids'], function (index, id) {

      $.getJSON( "/haltestellen/" + id + ".json", function (haltestelle) {
        var haltestelleName = haltestelle['name'];
        var lon = haltestelle['lon'];
        var lat = haltestelle['lat'];

        var haltestellePosition = new google.maps.LatLng(lat, lon);

        var marker = new google.maps.Marker({
          position: haltestellePosition,
          map: overviewMap,
          title: haltestelleName
        });
      });
    });


  });



});
