import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/session/app_session.dart';
import '../../widgets/postal/postal.dart';
import '../mailbox/mailbox_providers.dart';
import '../time_letter/time_letter_providers.dart';

class TopicMailboxPage extends ConsumerWidget {
  const TopicMailboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(appSessionProvider);
    final postalLetters = ref.watch(postalInboxLettersProvider);
    final timeStats = ref.watch(timeLetterStatsProvider);

    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(postalInboxLettersProvider);
          ref.invalidate(timeLetterStatsProvider);
          try {
            await ref.read(postalInboxLettersProvider.future);
          } catch (_) {}
          try {
            await ref.read(timeLetterStatsProvider.future);
          } catch (_) {}
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          children: [
            const PostalPerforationStrip(),
            const SizedBox(height: 14),
            _TodayMailboxPanel(
              name: session.user.nickname,
              postalCount: postalLetters.maybeWhen(
                data: (rows) => rows.length,
                orElse: () => null,
              ),
              timeLetterText: timeStats.maybeWhen(
                data: (s) => l10n.topicTodayTimeLetters(
                  s.inFlightCount.toString(),
                  s.deliveredUnreadCount.toString(),
                ),
                orElse: () => l10n.topicTodayTimeLettersLoading,
              ),
            ),
            const SizedBox(height: 16),
            _OfficialLetterCard(
              title: l10n.topicOfficialLetterTitle,
              body: l10n.topicOfficialLetterBody,
              onWrite: () => context.push('/time-letter/compose'),
            ),
            const SizedBox(height: 16),
            _SectionHeader(
              title: l10n.topicDailyTitle,
              subtitle: l10n.topicDailySubtitle,
            ),
            const SizedBox(height: 10),
            ..._topicSpecs(l10n).map(
              (topic) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TopicMailboxCard(
                  topic: topic,
                  onTap: () => context.push('/post/new'),
                ),
              ),
            ),
            const SizedBox(height: 6),
            _SafetyNotice(
              title: l10n.topicSafetyTitle,
              body: l10n.topicSafetyBody,
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayMailboxPanel extends StatelessWidget {
  const _TodayMailboxPanel({
    required this.name,
    required this.postalCount,
    required this.timeLetterText,
  });

  final String name;
  final int? postalCount;
  final String timeLetterText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final greetingName = name.trim().isEmpty ? l10n.topicFriendFallback : name;
    return PostalCardEnvelope(
      accent: PostalTokens.postboxGreen,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.topicTodayGreeting(greetingName),
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.topicTodayIntro,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: PostalTokens.inkSecondary,
            ),
          ),
          const SizedBox(height: 18),
          _TodayMetricRow(
            icon: Icons.mark_email_unread_outlined,
            label: l10n.topicTodayLetters,
            value: postalCount == null
                ? l10n.topicTodayLoading
                : l10n.topicTodayLettersCount(postalCount.toString()),
          ),
          const SizedBox(height: 10),
          _TodayMetricRow(
            icon: Icons.schedule_send_outlined,
            label: l10n.topicTodayTime,
            value: timeLetterText,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: PostalButton(
                  label: l10n.topicWriteLetter,
                  icon: Icons.edit_note,
                  onPressed: () => context.push('/time-letter/compose'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PostalButton(
                  label: l10n.topicOpenMailbox,
                  icon: Icons.local_post_office_outlined,
                  variant: PostalButtonVariant.secondary,
                  onPressed: () => context.go('/mailbox'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TodayMetricRow extends StatelessWidget {
  const _TodayMetricRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: PostalTokens.paperCard.withValues(alpha: 0.72),
        borderRadius: PostalTokens.shapeSm,
        border: Border.all(color: PostalTokens.perforationLine),
      ),
      child: Row(
        children: [
          Icon(icon, color: PostalTokens.postboxGreen, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: PostalTokens.inkSecondary,
              ),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.titleSmall?.copyWith(
              color: PostalTokens.inkNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfficialLetterCard extends StatelessWidget {
  const _OfficialLetterCard({
    required this.title,
    required this.body,
    required this.onWrite,
  });

  final String title;
  final String body;
  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return PostalCardEnvelope(
      accent: PostalTokens.stampVermilion,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PostalTokens.stampVermilionMuted,
                  border: Border.all(
                    color: PostalTokens.stampVermilion.withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Icons.local_post_office,
                  color: PostalTokens.stampVermilion,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      l10n.topicOfficialIdentity,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: PostalTokens.kraftBrown,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: PostalTokens.inkSecondary,
              height: 1.58,
            ),
          ),
          const SizedBox(height: 14),
          PostalButton(
            label: l10n.topicOfficialCta,
            icon: Icons.history_edu_outlined,
            onPressed: onWrite,
            variant: PostalButtonVariant.ghost,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: PostalTokens.inkSecondary,
          ),
        ),
      ],
    );
  }
}

class _TopicMailboxCard extends StatelessWidget {
  const _TopicMailboxCard({required this.topic, required this.onTap});

  final _TopicSpec topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return PostalCardEnvelope(
      accent: topic.accent,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(topic.icon, color: topic.accent, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(topic.title, style: theme.textTheme.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            topic.prompt,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: PostalTokens.inkSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              PostalStatusChip.draft(label: topic.label),
              const Spacer(),
              Text(
                l10n.topicWriteToTopic,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: PostalTokens.postboxGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                color: PostalTokens.postboxGreen,
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PostalTokens.paperCard.withValues(alpha: 0.82),
        borderRadius: PostalTokens.shapeMd,
        border: Border.all(color: PostalTokens.perforationLine),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.health_and_safety_outlined,
            color: PostalTokens.postboxGreen,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: PostalTokens.inkSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicSpec {
  const _TopicSpec({
    required this.title,
    required this.prompt,
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String prompt;
  final String label;
  final IconData icon;
  final Color accent;
}

List<_TopicSpec> _topicSpecs(AppLocalizations l10n) => [
  _TopicSpec(
    title: l10n.topicHometownTitle,
    prompt: l10n.topicHometownPrompt,
    label: l10n.topicOfficialExample,
    icon: Icons.home_work_outlined,
    accent: PostalTokens.postboxGreen,
  ),
  _TopicSpec(
    title: l10n.topicRetirementTitle,
    prompt: l10n.topicRetirementPrompt,
    label: l10n.topicTodayTopic,
    icon: Icons.local_florist_outlined,
    accent: PostalTokens.stampGold,
  ),
  _TopicSpec(
    title: l10n.topicOldPhotoTitle,
    prompt: l10n.topicOldPhotoPrompt,
    label: l10n.topicOfficialExample,
    icon: Icons.photo_camera_back_outlined,
    accent: PostalTokens.stampVermilion,
  ),
];
