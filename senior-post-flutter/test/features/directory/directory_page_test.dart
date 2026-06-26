/// Widget tests for DirectoryPage (3.0 pen pal hall).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:senior_post_flutter/features/directory/directory_page.dart';
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
  testWidgets('DirectoryPage renders intro card and safety section',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: _TestApp(child: const DirectoryPage()),
      ),
    );

    // Allow async loading to settle.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    // The intro card title should be present.
    expect(
      find.text('Pen Pal Hall'),
      findsOneWidget,
      reason: 'Intro card title should render.',
    );

    // Safety title should render.
    expect(
      find.text('Letters before private chat'),
      findsOneWidget,
      reason: 'Safety notice should render.',
    );

    // Filter button should exist.
    expect(
      find.text('Filter pen pals'),
      findsOneWidget,
    );

    // "People open to letters" section title.
    expect(
      find.text('People open to letters'),
      findsOneWidget,
    );

    // A ListView should be present (the outer scroll).
    expect(find.byType(ListView), findsOneWidget);
  });
}
