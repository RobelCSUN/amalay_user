import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'package:amalay_user/services/geo/geo_utils.dart';

/// Wraps geolocator: permission prompt + one-shot position fetch.
/// Returns null when the user declines or location is unavailable, so the
/// app keeps working without GPS (distance simply isn't shown).
class LocationService {
  Future<GeoPointData?> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.reduced,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return GeoPointData(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      debugPrint('[Location] unavailable: $e');
      return null;
    }
  }
}
