var linien;
var haltestellen;
var vienna = new google.maps.LatLng('48.208330230278', '16.373063840833');
var overviewMap;

$(function() {
  var overviewMapOptions = {
    center: vienna,
    zoom: 12,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  overviewMap = new google.maps.Map($("#overview-map")[0], overviewMapOptions);

  $.when(
    $.getJSON( "/linien.json", function(data) {
      linien = data;
    }),
    $.getJSON( "/haltestellen.json", function(data) {
      haltestellen = data;
    })
  ).done(function() {
    drawLines()
  });
});

function drawLines() {
  $.each(linien, function(id, linie) {
    console.debug('Linie ' + linie.bezeichnung);

    switch(linie.verkehrsmittel) {
      case 'ptMetro':
        drawMetro(linie);
        break;
      case 'ptTram':
        zeichneLinie(linie, 'wine', 1.0);
        break;
      case 'ptTrainS':
        zeichneLinie(linie, 'blue', 2.5);
        break;
      case 'ptBusCity':
        zeichneLinie(linie, 'black', 1.0);
      case 'ptTramWLB':
        break;
    }
  });
}

function drawMetro(linie) {
  if (linie['verkehrsmittel'] == 'ptMetro') {
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
        color = 'none';
    }
    zeichneLinie(linie, 'white', 6.0);
    zeichneLinie(linie, color, 4.0);
  }
}


function zeichneLinie(linie, color, lineWeight) {


  if (linie != null && color != null && color != 'none') {
    var haltestellenIds = $.map(linie.haltestellen, function(value, key) {return value;});
    var lineCoordinates = new Array();

    console.debug('Haltestellen: ' + $(haltestellenIds.values).size());
    $.each(haltestellenIds, function (index, hid) {
      haltestelle = haltestellen[hid];

      //var haltestelleName = haltestelle.name;

      coords = {
        lat: parseFloat(haltestelle.lat),
        lng: parseFloat(haltestelle.lon)
      };
      lineCoordinates.push(coords);

      if ((index == 0 || index == haltestellenIds.length - 1) && color != 'white') {
        console.debug('End point ' + index + ' Linie ' + linie.bezeichnung + ': ' + haltestelle.name);
        if (haltestelle.linien.length == 1) {
          drawEndpoint(coords, color, Math.min(1 + lineWeight, 3.0));
        } else {
          drawKnot(coords);
        }
      }
    });

    var line = new google.maps.Polyline({
      path: lineCoordinates,
      geodesic: true,
      strokeColor: color,
      strokeOpacity: 1.0,
      strokeWeight: lineWeight || 2.0
    });

    line.setMap(overviewMap);
  }
}

function drawEndpoint(coords, color, lineWeight) {
  var marker = new google.maps.Marker({
    position: coords,
    icon: {
      path: google.maps.SymbolPath.CIRCLE,
      fillColor: color,
      fillOpacity: 1.0,
      strokeColor: color,
      scale: lineWeight
    },
    map: overviewMap
  });
}

function drawKnot(coords) {
  var marker = new google.maps.Marker({
    position: coords,
    icon: {
      path: google.maps.SymbolPath.CIRCLE,
      fillColor: 'white',
      fillOpacity: 1.0,
      strokeColor: 'black',
      strokeWeight: 1.0,
      scale: 4.0
    },
    map: overviewMap
  });
}
