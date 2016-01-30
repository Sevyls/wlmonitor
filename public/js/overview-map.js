$(function() {
  // Übersichtskarte
  var vienna = new google.maps.LatLng('48.208330230278', '16.373063840833');
  var overviewMapOptions = {
    center: vienna,
    zoom: 12,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  var overviewMap = new google.maps.Map($("#overview-map")[0], overviewMapOptions);

  var linien;
  var haltestellen;

  $.when(
    $.getJSON( "/linien.json", function(data) {
      linien = data;
    }),
    $.getJSON( "/haltestellen.json", function(data) {
      haltestellen = data;
    })
  ).done(function() {
    $.each(linien, function(id, linie) {
      switch (linie['verkehrsmittel']) {
        case 'ptMetro':
          switch (linie['bezeichnung']) {
            case 'U1':
              color = 'red';
              break;
            case 'U2':
              color = 'purple';
              break;
            case 'U3':
              color = 'orange';
              break;
            case 'U4':
              color = 'green';
              break;
            case 'U5':
              color = 'aqua';
              break;
            case 'U6':
              color = 'brown';
              break;
            default:
              color = 'yellow';
          }
          zeichneLinie(linie, color);
          break;
        case 'ptBusCity':
          color = 'blue';
          break;
        default:
          color = 'red';
      }


    });
  });



function zeichneLinie(linie, color) {

  var haltestellenIds = linie['haltestellen'];
  var lineCoordinates = new Array();
  $.each(haltestellenIds, function (index, hid) {

    //var haltestelleName = haltestellen[hid]['name'];
    lineCoordinates.push(
      {
        lat: parseFloat(haltestellen[hid]['lat']),
        lng: parseFloat(haltestellen[hid]['lon'])
      }
    );


  });

  var line = new google.maps.Polyline({
    path: lineCoordinates,
    geodesic: true,
    strokeColor: color,
    strokeOpacity: 1.0,
    strokeWeight: 2
  });

  line.setMap(overviewMap);
}




  /*$.getJSON( "/haltestellen.json", function( data ) {
    var haltestelleids = data['ids'];

    $.each(haltestelleids, function (index, id) {
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


  });*/



});
