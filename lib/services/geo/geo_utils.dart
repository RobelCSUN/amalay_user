import 'dart:math' as math;

/// A latitude/longitude pair stored on the user document.
class GeoPointData {
  final double latitude;
  final double longitude;

  const GeoPointData({required this.latitude, required this.longitude});

  Map<String, dynamic> toMap() => {'lat': latitude, 'lng': longitude};

  static GeoPointData? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    final lat = map['lat'];
    final lng = map['lng'];
    if (lat is! num || lng is! num) return null;
    return GeoPointData(latitude: lat.toDouble(), longitude: lng.toDouble());
  }
}

/// Great-circle distance between two points in kilometers (haversine).
double distanceKm(GeoPointData a, GeoPointData b) {
  const earthRadiusKm = 6371.0;
  final dLat = _degToRad(b.latitude - a.latitude);
  final dLng = _degToRad(b.longitude - a.longitude);
  final lat1 = _degToRad(a.latitude);
  final lat2 = _degToRad(b.latitude);

  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLng / 2), 2);
  return 2 * earthRadiusKm * math.asin(math.min(1, math.sqrt(h)));
}

double _degToRad(double deg) => deg * math.pi / 180.0;

/// Human-readable distance label for profile cards.
String distanceLabel(double km) {
  if (km < 1) return 'Less than 1 km away';
  if (km < 10) return '${km.toStringAsFixed(1)} km away';
  return '${km.round()} km away';
}
