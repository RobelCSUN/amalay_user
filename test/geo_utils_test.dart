import 'package:flutter_test/flutter_test.dart';

import 'package:amalay_user/services/geo/geo_utils.dart';

void main() {
  group('distanceKm', () {
    test('zero for identical points', () {
      const p = GeoPointData(latitude: 9.03, longitude: 38.74);
      expect(distanceKm(p, p), closeTo(0, 0.001));
    });

    test('Addis Ababa to Adama is roughly 75-85 km', () {
      const addis = GeoPointData(latitude: 9.0300, longitude: 38.7400);
      const adama = GeoPointData(latitude: 8.5400, longitude: 39.2700);
      final km = distanceKm(addis, adama);
      expect(km, greaterThan(70));
      expect(km, lessThan(90));
    });

    test('is symmetric', () {
      const a = GeoPointData(latitude: 34.05, longitude: -118.24);
      const b = GeoPointData(latitude: 37.77, longitude: -122.42);
      expect(distanceKm(a, b), closeTo(distanceKm(b, a), 0.0001));
    });
  });

  group('distanceLabel', () {
    test('formats by magnitude', () {
      expect(distanceLabel(0.4), 'Less than 1 km away');
      expect(distanceLabel(3.25), '3.3 km away');
      expect(distanceLabel(42.7), '43 km away');
    });
  });

  group('GeoPointData', () {
    test('round-trips through a map', () {
      const p = GeoPointData(latitude: 9.03, longitude: 38.74);
      final restored = GeoPointData.fromMap(p.toMap());
      expect(restored!.latitude, 9.03);
      expect(restored.longitude, 38.74);
    });

    test('rejects corrupt maps', () {
      expect(GeoPointData.fromMap(null), isNull);
      expect(GeoPointData.fromMap({'lat': 'x', 'lng': 1}), isNull);
    });
  });
}
