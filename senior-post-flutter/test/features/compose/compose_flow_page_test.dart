/// Widget tests for ComposeFlowPage (3.0 unified compose flow).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_post_flutter/features/compose/compose_flow_page.dart';
import 'package:senior_post_flutter/features/compose/compose_intent.dart';
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
  testWidgets('ComposeFlowPage shows destination picker initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _TestApp(child: ComposeFlowPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('To future me'), findsOneWidget);
    expect(find.text('To a pen pal'), findsOneWidget);
    expect(find.text('To the post office'), findsOneWidget);
  });

  testWidgets('ComposeFlowPage with selfTimeLetter intent skips destination',
      (WidgetTester tester) async {
    final intent = ComposeIntent(kind: ComposeKind.selfTimeLetter);
    await tester.pumpWidget(
      ProviderScope(
        child: _TestApp(child: ComposeFlowPage(initialIntent: intent)),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Write your letter'), findsOneWidget);
  });

  testWidgets('ComposeFlowPage with postOffice intent shows post office step',
      (WidgetTester tester) async {
    final intent = ComposeIntent(kind: ComposeKind.postOffice);
    await tester.pumpWidget(
      ProviderScope(
        child: _TestApp(child: ComposeFlowPage(initialIntent: intent)),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Write your letter'), findsOneWidget);
  });
}
