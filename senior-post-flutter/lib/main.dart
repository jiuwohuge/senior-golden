import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/senior_post_app.dart';
import 'core/auth/auth_storage.dart';
import 'core/auth/auth_token.dart';
import 'core/auth/jwt_expiry.dart';
import 'core/config/api_base_url_provider.dart';
import 'core/device/device_ids.dart';
import 'core/device/device_install_id.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  await container.read(apiBaseUrlProvider.notifier).loadFromStorage();
  var token = await AuthStorage.readToken();
  if (token != null && token.isNotEmpty) {
    if (isAuthTokenExpired(token)) {
      await AuthStorage.clearToken();
      token = null;
    } else {
      container.read(authTokenProvider.notifier).state = token;
    }
  }
  final installId = await DeviceInstallId.getOrCreate();
  container.read(deviceInstallIdStateProvider.notifier).state = installId;

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SeniorPostApp(),
    ),
  );
}
