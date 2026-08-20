import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// 静默进入时尽量带上坐标：已授权则读定位，未授权不弹窗打断冷启动。
Future<({double? latitude, double? longitude})> readGuestCoordinates() async {
  if (kIsWeb) {
    return (latitude: null, longitude: null);
  }
  try {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return (latitude: null, longitude: null);
    }
    final last = await Geolocator.getLastKnownPosition();
    if (last != null) {
      return (latitude: last.latitude, longitude: last.longitude);
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 4),
      ),
    );
    return (latitude: pos.latitude, longitude: pos.longitude);
  } catch (e) {
    debugPrint('guest geo skipped: $e');
    return (latitude: null, longitude: null);
  }
}
