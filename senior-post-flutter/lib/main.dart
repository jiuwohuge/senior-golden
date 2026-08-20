import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/senior_post_app.dart';
import 'core/auth/auth_storage.dart';
import 'core/auth/auth_token.dart';
import 'core/auth/jwt_expiry.dart';
import 'core/config/api_base_url_provider.dart';
import 'core/device/device_ids.dart';
import 'core/device/device_install_id.dart';
import 'features/auth/auth_repository.dart';
import 'features/push/push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  await container.read(apiBaseUrlProvider.notifier).loadFromStorage();
  final installId = await DeviceInstallId.getOrCreate();
  container.read(deviceInstallIdStateProvider.notifier).state = installId;
  var token = await AuthStorage.readToken();
  if (token != null && token.isNotEmpty) {
    if (isAuthTokenExpired(token)) {
      await AuthStorage.clearToken();
      token = null;
    } else {
      container.read(authTokenProvider.notifier).state = token;
      // WHY: 冷启动恢复 Token 后主动同步一次服务端会话，避免首页展示游客态。
      // 弱网场景不打断进入应用，后续页面仍可按需重试拉取。
      try {
        await container.read(authRepositoryProvider).refreshSessionFromServer();
        await container.read(pushServiceProvider).registerIfPossible();
      } catch (_) {}
    }
  }
  if (token == null || token.isEmpty) {
    try {
      await container.read(authRepositoryProvider).guest();
    } catch (e) {
      debugPrint('startup guest auth failed: $e');
    }
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SeniorPostApp(),
    ),
  );
}
