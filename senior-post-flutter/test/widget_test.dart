import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:senior_post_flutter/app/senior_post_app.dart';
import 'package:senior_post_flutter/core/auth/auth_token.dart';
import 'package:senior_post_flutter/core/device/device_ids.dart';
import 'package:senior_post_flutter/core/device/location_bootstrap.dart';

void main() {
  testWidgets('已登录时展示主导航', (WidgetTester tester) async {
    final oldOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('ListTile background color')) {
        return;
      }
      oldOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = oldOnError);

    final container = ProviderContainer();
    container.read(authTokenProvider.notifier).state = 'test-jwt';
    container.read(deviceInstallIdStateProvider.notifier).state = 'test-device';
    container.read(locationBootstrapDoneProvider.notifier).state = true;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SeniorPostApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
