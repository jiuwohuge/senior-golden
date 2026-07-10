/// Widget tests for DirectoryPage (4.0 pen pal hall).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_post_flutter/features/directory/directory_page.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    );
  }
}

void main() {
  testWidgets('DirectoryPage renders three tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _TestApp(child: DirectoryPage()),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text('For you'), findsOneWidget);
    expect(find.text('Find pen pals'), findsOneWidget);
    expect(find.text('My pen pals'), findsOneWidget);
    expect(find.byType(TabBarView), findsOneWidget);
  });
}
