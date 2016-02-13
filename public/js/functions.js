var linien;
var haltestellen;

function init(run) {
  $.when($.getJSON("/linien.json", function(data) {
      linien = data;
    }),
    $.getJSON("/haltestellen.json", function(data) {
      haltestellen = data;
    })).then(run);
}

function drawLines(map) {
  $.each(linien, function(id, linie) {
    drawLine(linie, map);
  });
}

function drawLine(linie, map) {
  console.debug('Linie ' + linie.bezeichnung);

  switch (linie.verkehrsmittel) {
    case 'ptMetro':
      drawMetro(linie, map);
      break;
    case 'ptTram':
      paintLine(linie, 'wine', 1.0, map);
      break;
    case 'ptTrainS':
      paintLine(linie, 'blue', 2.5, map);
      break;
    case 'ptBusCity':
      paintLine(linie, 'black', 1.0, map);
    case 'ptTramWLB':
    default:
      paintLine(linie, 'grey', 2.0, map);
      break;
  }
}

function drawMetro(linie, map) {
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
    paintLine(linie, 'white', 6.0, map);
    paintLine(linie, color, 4.0, map);
  }
}


function paintLine(linie, color, lineWeight, map) {
  if (linie != null && color != null && color != 'none') {
    var haltestellenIds = $.map(linie.haltestellen, function(value, key) {
      return value;
    });
    var lineCoordinates = new Array();

    console.debug('Haltestellen: ' + $(haltestellenIds.values).size());
    $.each(haltestellenIds, function(index, hid) {
      haltestelle = haltestellen[hid];

      //var haltestelleName = haltestelle.name;

      coords = {
        lat: parseFloat(haltestelle.lat),
        lng: parseFloat(haltestelle.lon)
      };
      lineCoordinates.push(coords);

      if ((index == 0 || index == haltestellenIds.length - 1) && color !=
        'white') {
        console.debug('End point ' + index + ' Linie ' + linie.bezeichnung +
          ': ' + haltestelle.name);
        if (haltestelle.linien.length == 1) {
          drawEndpoint(coords, color, Math.min(1 + lineWeight, 3.0), map);
        } else {
          drawKnot(coords, map);
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

    line.setMap(map);
  }
}

function drawEndpoint(coords, color, lineWeight, map) {
  var marker = new google.maps.Marker({
    position: coords,
    icon: {
      path: google.maps.SymbolPath.CIRCLE,
      fillColor: color,
      fillOpacity: 1.0,
      strokeColor: color,
      scale: lineWeight
    },
    map: map
  });
}

function drawKnot(coords, map) {
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
    map: map
  });
}
