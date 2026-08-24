/// Widget tests for the compose desk (letter-on-a-desk skeleton).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_post_flutter/core/bootstrap/app_bootstrap.dart';
import 'package:senior_post_flutter/core/models/letter_topic_option.dart';
import 'package:senior_post_flutter/features/compose/compose_flow_page.dart';
import 'package:senior_post_flutter/features/compose/compose_intent.dart';
import 'package:senior_post_flutter/features/compose/compose_stamp_strip.dart';
import 'package:senior_post_flutter/features/post_office/post_office_remote.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

const _topics = [
  LetterTopicOption(id: 11, code: 'heart_talk', title: "What's on my mind"),
  LetterTopicOption(id: 12, code: 'life_share', title: 'Life lately'),
];

const _home = PostOfficeHomeData(
  greeting: 'Hi',
  todayHint: '',
  dailyLetterQuota: 5,
  sentToday: 0,
  relationMessageCount: 0,
  inTransitCount: 0,
  recommendedAction: 'POST_OFFICE',
);

List<Override> _composeOverrides() {
  return [
    postOfficeHomeProvider.overrideWith((ref) async => _home),
    appBootstrapProvider.overrideWith((ref, lang) async {
      return const AppBootstrapData(
        minRegisterAge: 45,
        countries: [],
        letterTopicOptions: _topics,
      );
    }),
  ];
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.viewInsets});
  final Widget child;
  final EdgeInsets? viewInsets;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      builder: viewInsets == null
          ? null
          : (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(viewInsets: viewInsets),
                child: child!,
              );
            },
      home: child,
    );
  }
}

void main() {
  testWidgets('stamp tap selects and tap again unsticks', (tester) async {
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ComposeStampStrip(
                topics: _topics,
                selectedId: selected,
                compact: false,
                compactLabel: 'No stamp yet',
                onExpandCompact: () {},
                onSelected: (id) => setState(() => selected = id),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text("What's on my mind"));
    await tester.pump();
    expect(selected, 11);

    await tester.tap(find.text("What's on my mind"));
    await tester.pump();
    expect(selected, isNull);
  });

  testWidgets('post office desk shows drop-in primary button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _composeOverrides(),
        child: const _TestApp(
          child: ComposeFlowPage(
            initialIntent: ComposeIntent(kind: ComposeKind.postOffice),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Drop in the post office'), findsOneWidget);
    expect(find.text('To future me'), findsNothing);
    expect(find.text('Mind'), findsOneWidget);
  });

  testWidgets('self time letter primary is seal and send', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _composeOverrides(),
        child: const _TestApp(
          child: ComposeFlowPage(
            initialIntent: ComposeIntent(kind: ComposeKind.selfTimeLetter),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Seal and send'), findsOneWidget);
  });

  testWidgets('locked pen pal primary is send this letter', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _composeOverrides(),
        child: const _TestApp(
          child: ComposeFlowPage(
            initialIntent: ComposeIntent(
              kind: ComposeKind.penPalMail,
              peerId: '9',
              peerNickname: 'Ada',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Send this letter'), findsOneWidget);
  });

  testWidgets('empty body primary send focuses paper without snack', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _composeOverrides(),
        child: const _TestApp(
          child: ComposeFlowPage(
            initialIntent: ComposeIntent(kind: ComposeKind.postOffice),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.byKey(const ValueKey('compose-primary-send')));
    await tester.pump();
    expect(find.textContaining('cannot be empty'), findsNothing);
    expect(find.text('Please pick a topic stamp again'), findsNothing);
  });

  testWidgets('keyboard insets still show primary send', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _composeOverrides(),
        child: const _TestApp(
          viewInsets: EdgeInsets.only(bottom: 280),
          child: ComposeFlowPage(
            initialIntent: ComposeIntent(kind: ComposeKind.postOffice),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(const ValueKey('compose-primary-send')), findsOneWidget);
    expect(find.text('No stamp yet'), findsOneWidget);
  });

  testWidgets('empty body still opens letter assistant', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _composeOverrides(),
        child: const _TestApp(
          child: ComposeFlowPage(
            initialIntent: ComposeIntent(kind: ComposeKind.postOffice),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Help'));
    await tester.pumpAndSettle();
    expect(find.text('Letter assistant'), findsWidgets);
  });
}
