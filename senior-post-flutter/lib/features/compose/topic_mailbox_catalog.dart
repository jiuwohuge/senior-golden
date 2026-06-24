import 'package:flutter/material.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';

class TopicMailboxTopic {
  const TopicMailboxTopic({
    required this.key,
    required this.title,
    required this.prompt,
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String key;
  final String title;
  final String prompt;
  final String label;
  final IconData icon;
  final Color accent;
}

TopicMailboxTopic? findTopicMailboxTopic(AppLocalizations l10n, String? key) {
  if (key == null || key.isEmpty) return null;
  for (final topic in topicMailboxTopics(l10n)) {
    if (topic.key == key) return topic;
  }
  return null;
}

List<TopicMailboxTopic> topicMailboxTopics(AppLocalizations l10n) => [
  TopicMailboxTopic(
    key: 'hometown',
    title: l10n.topicHometownTitle,
    prompt: l10n.topicHometownPrompt,
    label: l10n.topicOfficialExample,
    icon: Icons.home_work_outlined,
    accent: PostalTokens.postboxGreen,
  ),
  TopicMailboxTopic(
    key: 'retirement',
    title: l10n.topicRetirementTitle,
    prompt: l10n.topicRetirementPrompt,
    label: l10n.topicTodayTopic,
    icon: Icons.local_florist_outlined,
    accent: PostalTokens.stampGold,
  ),
  TopicMailboxTopic(
    key: 'oldPhoto',
    title: l10n.topicOldPhotoTitle,
    prompt: l10n.topicOldPhotoPrompt,
    label: l10n.topicOfficialExample,
    icon: Icons.photo_camera_back_outlined,
    accent: PostalTokens.stampVermilion,
  ),
];
