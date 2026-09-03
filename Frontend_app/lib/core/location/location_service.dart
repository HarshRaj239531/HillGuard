import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService extends ChangeNotifier {
  // Default Himalayan corridor coordinate (Kurseong / Tindharia, Darjeeling)
  static const double defaultLat = 26.9048;
  static const double defaultLon = 88.3375;
  static const double defaultAlt = 1450.0;

  double _currentLat = defaultLat;
  double _currentLon = defaultLon;
  double _currentAlt = defaultAlt;
  double _accuracyMeters = 5.0;
  bool _hasGpsFix = false;
  bool _isLocating = false;

  double get currentLat => _currentLat;
  double get currentLon => _currentLon;
  double get currentAlt => _currentAlt;
  double get accuracyMeters => _accuracyMeters;
  bool get hasGpsFix => _hasGpsFix;
  bool get isLocating => _isLocating;
  LatLng get currentLatLng => LatLng(_currentLat, _currentLon);

  StreamSubscription<Position>? _positionSub;

  LocationService() {
    initLocation();
  }

  Future<void> initLocation() async {
    _isLocating = true;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('LocationService: Location services are disabled on device.');
        _isLocating = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('LocationService: Location permission denied.');
          _isLocating = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('LocationService: Location permission denied forever.');
        _isLocating = false;
        notifyListeners();
        return;
      }

      // Initial fix
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      _updatePosition(position);

      // Continuous Stream
      _positionSub?.cancel();
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // update every 5 meters
        ),
      ).listen(
        (Position pos) {
          _updatePosition(pos);
        },
        onError: (e) {
          debugPrint('Position stream note: $e');
        },
      );
    } catch (e) {
      debugPrint('LocationService init error: $e');
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }

  void _updatePosition(Position pos) {
    _currentLat = pos.latitude;
    _currentLon = pos.longitude;
    _currentAlt = pos.altitude;
    _accuracyMeters = pos.accuracy;
    _hasGpsFix = true;
    notifyListeners();
  }

  Future<void> refreshLocation() async {
    await initLocation();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }
}
