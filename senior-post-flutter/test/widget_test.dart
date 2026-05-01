import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:senior_post_flutter/app/senior_post_app.dart';
import 'package:senior_post_flutter/core/auth/auth_token.dart';
import 'package:senior_post_flutter/core/device/device_ids.dart';

void main() {
  testWidgets('已登录时展示主导航', (WidgetTester tester) async {
    final container = ProviderContainer();
    container.read(authTokenProvider.notifier).state = 'test-jwt';
    container.read(deviceInstallIdStateProvider.notifier).state = 'test-device';

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SeniorPostApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
