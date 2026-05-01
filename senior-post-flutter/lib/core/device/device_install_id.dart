import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kInstallId = 'device_install_uuid';

/// 合规场景下可替换为 IDFV / Android ID 等；M1 使用安装级随机 UUID 持久化。
class DeviceInstallId {
  DeviceInstallId._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String> getOrCreate() async {
    final existing = await _storage.read(key: _kInstallId);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final v = _randomHex(16);
    await _storage.write(key: _kInstallId, value: v);
    return v;
  }

  static String _randomHex(int byteLength) {
    final r = Random.secure();
    final b = List<int>.generate(byteLength, (_) => r.nextInt(256));
    return b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  }
}
