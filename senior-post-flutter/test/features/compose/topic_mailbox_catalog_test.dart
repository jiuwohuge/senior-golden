/// Tests for topic mailbox catalog: topic list, findTopicMailboxTopic.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';
import 'package:senior_post_flutter/features/compose/topic_mailbox_catalog.dart';
import '../../mock_localizations.dart';

AppLocalizations _setupL10n() {
  final l10n = MockAppLocalizations();
  when(() => l10n.topicHometownTitle).thenReturn('Hometown memories');
  when(() => l10n.topicHometownPrompt).thenReturn('Describe a road');
  when(() => l10n.topicRetirementTitle).thenReturn('Retirement day');
  when(() => l10n.topicRetirementPrompt).thenReturn('Write a moment');
  when(() => l10n.topicOldPhotoTitle).thenReturn('Old photo story');
  when(() => l10n.topicOldPhotoPrompt).thenReturn('Pick a photo');
  when(() => l10n.topicOfficialExample).thenReturn('Example');
  when(() => l10n.topicTodayTopic).thenReturn('Today');
  return l10n;
}

void main() {
  group('topicMailboxTopics', () {
    test('returns three pre-defined topics', () {
      final topics = topicMailboxTopics(_setupL10n());
      expect(topics.length, 3);
    });

    test('each topic has non-empty key, title, prompt, label', () {
      for (final t in topicMailboxTopics(_setupL10n())) {
        expect(t.key.isNotEmpty, isTrue);
        expect(t.title.isNotEmpty, isTrue);
        expect(t.prompt.isNotEmpty, isTrue);
        expect(t.label.isNotEmpty, isTrue);
      }
    });

    test('topic keys are unique', () {
      final topics = topicMailboxTopics(_setupL10n());
      final keys = topics.map((t) => t.key).toSet();
      expect(keys.length, topics.length);
    });
  });

  group('findTopicMailboxTopic', () {
    test('finds known topic by key', () {
      final t = findTopicMailboxTopic(_setupL10n(), 'hometown');
      expect(t, isNotNull);
      expect(t!.key, 'hometown');
    });

    test('returns null for unknown key', () {
      expect(findTopicMailboxTopic(_setupL10n(), 'nonexistent'), isNull);
    });

    test('returns null for null key', () {
      expect(findTopicMailboxTopic(_setupL10n(), null), isNull);
    });

    test('returns null for empty key', () {
      expect(findTopicMailboxTopic(_setupL10n(), ''), isNull);
    });
  });
}
