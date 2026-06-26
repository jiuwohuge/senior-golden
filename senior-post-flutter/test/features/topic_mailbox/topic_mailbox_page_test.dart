/// Widget tests for TopicMailboxPage — the 3.0 first tab.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:senior_post_flutter/features/topic_mailbox/topic_mailbox_page.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';
import '../../mock_localizations.dart';
import '../../mock_localizations_delegate.dart';

void main() {
  testWidgets('TopicMailboxPage renders greeting and safety notice',
      (WidgetTester tester) async {
    final l10n = MockAppLocalizations();
    when(() => l10n.topicSafetyTitle).thenReturn('Safer pen pal');
    when(() => l10n.topicSafetyBody).thenReturn('Avoid scams.');
    when(() => l10n.topicFriendFallback).thenReturn('friend');
    when(() => l10n.topicTodayGreeting(any())).thenReturn('Good to see you');
    when(() => l10n.topicTodayIntro).thenReturn('No rush.');
    when(() => l10n.topicTodayLetters).thenReturn('Letters');
    when(() => l10n.topicTodayLoading).thenReturn('Loading');
    when(() => l10n.topicTodayTime).thenReturn('Time letters');
    when(() => l10n.topicTodayTimeLettersLoading).thenReturn('Checking');
    when(() => l10n.topicWriteLetter).thenReturn('Write');
    when(() => l10n.topicOpenMailbox).thenReturn('Mailbox');
    when(() => l10n.topicOfficialLetterTitle).thenReturn('Official');
    when(() => l10n.topicOfficialIdentity).thenReturn('Post');
    when(() => l10n.topicOfficialLetterBody).thenReturn('Write.');
    when(() => l10n.topicOfficialCta).thenReturn('Write');
    when(() => l10n.topicDailyTitle).thenReturn('Daily');
    when(() => l10n.topicDailySubtitle).thenReturn('Pick one.');
    when(() => l10n.topicWriteToTopic).thenReturn('Write');
    when(() => l10n.topicHometownTitle).thenReturn('Hometown');
    when(() => l10n.topicHometownPrompt).thenReturn('Describe.');
    when(() => l10n.topicRetirementTitle).thenReturn('Retirement');
    when(() => l10n.topicRetirementPrompt).thenReturn('Write.');
    when(() => l10n.topicOldPhotoTitle).thenReturn('Old photo');
    when(() => l10n.topicOldPhotoPrompt).thenReturn('Pick.');
    when(() => l10n.topicOfficialExample).thenReturn('Example');
    when(() => l10n.topicTodayTopic).thenReturn('Today');

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            MockLocalizationsDelegate(l10n),
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: const TopicMailboxPage(),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text('Safer pen pal'), findsOneWidget,
        reason: 'Safety notice title should render.');
    expect(find.byType(ListView), findsOneWidget,
        reason: 'A scrollable list should be present.');
  });
}
