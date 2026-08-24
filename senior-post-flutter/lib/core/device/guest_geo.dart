import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';

bool get skipOsLocationPlugin {
  if (kIsWeb) {
    return true;
  }
  return WidgetsBinding.instance.runtimeType.toString().contains(
    'TestWidgetsFlutterBinding',
  );
}

/// 已授权则读坐标；未授权不弹窗。启动页会先弹出系统授权。
Future<({double? latitude, double? longitude})> readGuestCoordinates() async {
  if (skipOsLocationPlugin) {
    return (latitude: null, longitude: null);
  }
  try {
    final permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      return (latitude: null, longitude: null);
    }
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        return (latitude: last.latitude, longitude: last.longitude);
      }
    } catch (_) {}
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 8),
      ),
    );
    return (latitude: pos.latitude, longitude: pos.longitude);
  } catch (e) {
    debugPrint('location read skipped: $e');
    return (latitude: null, longitude: null);
  }
}
