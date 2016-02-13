var vienna = new google.maps.LatLng('48.208330230278', '16.373063840833');
var overviewMap;

$(init(function() {
  var overviewMapOptions = {
    center: vienna,
    zoom: 12,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  overviewMap = new google.maps.Map($("#overview-map")[0],
    overviewMapOptions);

  drawLines(overviewMap);
}));
