import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_post_flutter/features/post_office/post_office_home_page.dart';
import 'package:senior_post_flutter/features/post_office/post_office_remote.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

const _home = PostOfficeHomeData(
  greeting: 'Good afternoon',
  todayHint: 'A letter can make someone’s day.',
  dailyLetterQuota: 5,
  sentToday: 1,
  relationMessageCount: 0,
  inTransitCount: 0,
  recommendedAction: 'POST_OFFICE',
);

Widget _app() {
  return ProviderScope(
    overrides: [
      postOfficeHomeProvider.overrideWith((ref) async => _home),
      postOfficeInTransitProvider.overrideWith((ref) async => const []),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: IndexedStack(
          index: 0,
          children: [PostOfficeHomePage(), SizedBox(), SizedBox()],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('home renders at a mobile viewport without layout exceptions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Good afternoon'), findsOneWidget);
    expect(find.text('In transit · 0'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });
}
