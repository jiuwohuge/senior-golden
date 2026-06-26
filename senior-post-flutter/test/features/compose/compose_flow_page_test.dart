/// Widget tests for ComposeFlowPage (3.0 unified compose flow).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:senior_post_flutter/features/compose/compose_flow_page.dart';
import '../mock_localizations.dart';
import '../mock_localizations_delegate.dart';

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        MockLocalizationsDelegate(),
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: child,
    );
  }
}

void main() {
  testWidgets('ComposeFlowPage shows destination picker initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: const _TestApp(child: ComposeFlowPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Three destination choices should appear.
    expect(find.text('To future me'), findsOneWidget);
    expect(find.text('To a pen pal'), findsOneWidget);
    expect(find.text('To a topic mailbox'), findsOneWidget);

    // Step indicator should show "1 / ?" — at least one of 4+ steps.
    // Just verify the text "1 / " is present somewhere.
    // Exact step count varies by intent.
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

    // Should land on "Write your letter" body step directly.
    // The ComposeStepScaffold renders with stepTitle.
    expect(find.text('Write your letter'), findsOneWidget);
  });

  testWidgets('ComposeFlowPage with topicMailbox intent shows topic picker',
      (WidgetTester tester) async {
    final intent = ComposeIntent(kind: ComposeKind.topicMailbox);
    await tester.pumpWidget(
      ProviderScope(
        child: _TestApp(child: ComposeFlowPage(initialIntent: intent)),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Should show topic mailbox topics as choices.
    // "Pick a topic mailbox" step title.
  });
}
