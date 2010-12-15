$(function() {
    var fdata = search.from.get(0).onclick() || {lat: 55.751463, lng: 37.621651};
    if (typeof VEMap != 'undefined') {
        search.map = new VEMap('bingmap');
        search.map.SetCredentials('AtNWTyXWDDDWemqtCdOBchagXymI0P5Sh14O7GSlQpl2BJxBm_xn6YRUR7TPhJD0');
        search.map.SetDashboardSize(VEDashboardSize.Tiny);
        search.map.LoadMap(new VELatLong(fdata.lat, fdata.lng), 4);
        search.map.SetScaleBarDistanceUnit(VEDistanceUnit.Kilometers);
        search.updateMap(fdata);
    }
});