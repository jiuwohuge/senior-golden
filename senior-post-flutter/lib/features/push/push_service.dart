import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/device/device_ids.dart';
import '../../core/network/dio_provider.dart';

/// 推送打开回调：由路由层注入，避免本文件强依赖 go_router。
typedef PushOpenHandler = void Function(PushOpenTarget target);

/// 从 FCM data 解析出的打开目标（无信件正文 / 无 PII）。
class PushOpenTarget {
  const PushOpenTarget({this.route, this.letterId, this.screen});

  /// 如 `app://letter/123`
  final String? route;

  final int? letterId;

  /// `in_transit` | `arrived`
  final String? screen;
}

/// FCM 推送注册 + 打开深链最小处理。
/// 登录后上报 token；Firebase 未配置时静默跳过。
/// Web 不注册推送（上线渠道为 Android；浏览器联调跳过）。
class PushService {
  PushService(this._dio, {PushOpenHandler? onOpened}) : _onOpened = onOpened;

  final Dio _dio;
  final PushOpenHandler? _onOpened;
  bool _initialized = false;
  bool _openHandlersBound = false;

  /// 尝试初始化 Firebase 并注册推送 Token（幂等、容错）。
  Future<void> registerIfPossible({bool enabled = true}) async {
    if (kIsWeb) return;
    try {
      if (!_initialized) {
        await Firebase.initializeApp();
        _initialized = true;
      }
      await _ensureOpenHandlers();
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

  /// 绑定冷启动 / 后台点击打开处理器（幂等）。
  Future<void> _ensureOpenHandlers() async {
    if (_openHandlersBound || kIsWeb) return;
    _openHandlersBound = true;
    final messaging = FirebaseMessaging.instance;

    // 冷启动：点通知进入 App
    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      _handleOpenedMessage(initial, source: 'getInitialMessage');
    }

    // 后台：点通知回到前台
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleOpenedMessage(message, source: 'onMessageOpenedApp');
    });
  }

  void _handleOpenedMessage(RemoteMessage message, {required String source}) {
    final target = parsePushOpenTarget(message.data);
    debugPrint(
      'PushService: opened via $source '
      'letterId=${target.letterId} screen=${target.screen} '
      'route=${target.route != null}',
    );
    final handler = _onOpened;
    if (handler == null) {
      // TODO: 在 app 启动处注入 go_router 导航（如 /letter/:id）
      return;
    }
    handler(target);
  }
}

/// 解析 FCM data：优先 `route`，其次 `letterId`；不读正文。
PushOpenTarget parsePushOpenTarget(Map<String, dynamic> data) {
  final route = data['route']?.toString();
  int? letterId;
  final rawId = data['letterId'];
  if (rawId is int) {
    letterId = rawId;
  } else if (rawId != null) {
    letterId = int.tryParse(rawId.toString());
  }
  if (letterId == null && route != null) {
    // app://letter/{id}
    final m = RegExp(r'letter/(\d+)').firstMatch(route);
    if (m != null) {
      letterId = int.tryParse(m.group(1)!);
    }
  }
  final screen = data['screen']?.toString();
  return PushOpenTarget(route: route, letterId: letterId, screen: screen);
}

String _platformBody() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return 'ios';
    case TargetPlatform.android:
      return 'android';
    default:
      final h = platformDeviceHeader().toLowerCase();
      if (h == 'ios') return 'ios';
      return 'android';
  }
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
