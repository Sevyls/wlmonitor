var linie;
var vienna = new google.maps.LatLng('48.208330230278', '16.373063840833');

$(init(function() {

  // Karte
  if ($("#linie-map").length) {
    var linieId = $("#linie").data('linieid');

    $.getJSON("/linien/" + linieId + ".json", function(data) {
      linie = data;

      var mapOptions = {
        center: vienna,
        zoom: 12,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      var map = new google.maps.Map($("#linie-map")[0],
        mapOptions);
      drawLine(linie, map);
    });
  }
}));
