import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/device/device_ids.dart';
import '../../core/network/dio_provider.dart';

/// FCM 推送注册：登录后上报 token；Firebase 未配置时静默跳过。
class PushService {
  PushService(this._dio);

  final Dio _dio;
  bool _initialized = false;

  /// 尝试初始化 Firebase 并注册推送 Token（幂等、容错）。
  Future<void> registerIfPossible({bool enabled = true}) async {
    if (kIsWeb) return;
    try {
      if (!_initialized) {
        await Firebase.initializeApp();
        _initialized = true;
      }
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final token = await messaging.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('PushService: FCM token unavailable, skip register');
        return;
      }
      await _dio.post<dynamic>(
        '/api/device/push-token',
        data: <String, dynamic>{
          'platform': _platformBody(),
          'token': token,
          'enabled': enabled,
        },
      );
      debugPrint('PushService: push token registered');
    } catch (e, st) {
      debugPrint('PushService: register skipped ($e)\n$st');
    }
  }
}

String _platformBody() {
  if (Platform.isIOS) return 'ios';
  if (Platform.isAndroid) return 'android';
  final h = platformDeviceHeader().toLowerCase();
  if (h == 'ios') return 'ios';
  return 'android';
}

final pushServiceProvider = Provider<PushService>(
  (ref) => PushService(ref.read(dioProvider)),
);

/// 登录态变化时尝试注册推送 Token。
final pushRegistrationProvider = Provider<void>((ref) {
  ref.listen(pushServiceProvider, (_, __) {});
});

Future<void> ensurePushTokenRegistered(WidgetRef ref, {bool enabled = true}) {
  return ref.read(pushServiceProvider).registerIfPossible(enabled: enabled);
}
