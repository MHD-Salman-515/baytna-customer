import 'package:baytna_customer/core/geo/geo_point.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

abstract interface class LocationService {
  /// Her position if location is on and she allows it; null otherwise. Asks
  /// for permission at most once per call and never throws.
  Future<GeoPoint?> currentPosition();
}

@LazySingleton(as: LocationService)
class GeolocatorLocationService implements LocationService {
  @override
  Future<GeoPoint?> currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return null;
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: Duration(seconds: 10)),
      );
      return GeoPoint(latitude: p.latitude, longitude: p.longitude);
    } on Object catch (e) {
      debugPrint('[location] unavailable: $e');
      return null;
    }
  }
}

/// Great-circle distance in km.
double distanceKm(GeoPoint a, GeoPoint b) => const Distance().as(
  LengthUnit.Kilometer,
  LatLng(a.latitude, a.longitude),
  LatLng(b.latitude, b.longitude),
);
