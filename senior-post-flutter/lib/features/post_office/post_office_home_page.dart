import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../widgets/postal/postal_delivery_progress.dart';
import '../../widgets/postal/postal_button.dart';
import '../../widgets/postal/postal_card_envelope.dart';
import '../compose/compose_intent.dart';
import '../post_office/post_office_remote.dart';

/// 邮局首页：后台下发主 CTA（默认时光信）+ 次级有缘人。
class PostOfficeHomePage extends ConsumerWidget {
  const PostOfficeHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final homeAsync = ref.watch(postOfficeHomeProvider);
    final transitAsync = ref.watch(postOfficeInTransitProvider);

    final greeting = homeAsync.maybeWhen(
      data: (h) => h.greeting.isNotEmpty ? h.greeting : l10n.postOfficeGreeting,
      orElse: () => l10n.postOfficeGreeting,
    );
    final hint = homeAsync.maybeWhen(
      data: (h) =>
          h.todayHint.isNotEmpty ? h.todayHint : l10n.postOfficeTodayHint,
      orElse: () => l10n.postOfficeTodayHint,
    );
    final remaining = homeAsync.maybeWhen(
      data: (h) => h.remainingQuota,
      orElse: () => 5,
    );
    final inTransit = homeAsync.maybeWhen(
      data: (h) => h.inTransitCount,
      orElse: () => 0,
    );
    final relationMessages = homeAsync.maybeWhen(
      data: (h) => h.relationMessageCount,
      orElse: () => 0,
    );
    final transitItems = transitAsync.maybeWhen(
      data: (items) => items,
      orElse: () => const <PostOfficeInTransitItem>[],
    );
    final activeTransitItems = transitItems
        .where((item) => item.itemType != 3)
        .toList();
    final activeTransit = activeTransitItems.isEmpty
        ? null
        : activeTransitItems.first;
    final timeLetterPrimary = homeAsync.maybeWhen(
      data: (h) => h.recommendedAction != 'POST_OFFICE',
      orElse: () => true,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          greeting,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hint,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.4,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 24),
        _TransitCard(
          count: inTransit,
          item: activeTransit,
          loading: transitAsync.isLoading,
          onTap: () => context.push('/post-office/in-transit'),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.topicTodayTopic,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        _TodaySummary(remaining: remaining, relationMessages: relationMessages),
        const SizedBox(height: 28),
        PostalButton(
          label: timeLetterPrimary
              ? l10n.writeDestinationSelfTime
              : l10n.writeDestinationPostOffice,
          icon: timeLetterPrimary
              ? Icons.schedule_send_outlined
              : Icons.edit_outlined,
          variant: PostalButtonVariant.primaryLarge,
          onPressed: () => _openCompose(
            context,
            timeLetterPrimary
                ? ComposeKind.selfTimeLetter
                : ComposeKind.postOffice,
          ),
        ),
        const SizedBox(height: 12),
        PostalButton(
          label: timeLetterPrimary
              ? l10n.postOfficeWritePostOfficeWaitHint
              : l10n.writeDestinationSelfTime,
          icon: Icons.forward_to_inbox_outlined,
          variant: PostalButtonVariant.secondary,
          onPressed: () => _openCompose(
            context,
            timeLetterPrimary
                ? ComposeKind.postOffice
                : ComposeKind.selfTimeLetter,
          ),
        ),
      ],
    );
  }

  void _openCompose(BuildContext context, ComposeKind kind) {
    context.push('/compose', extra: ComposeIntent(kind: kind));
  }
}

class _TransitCard extends StatelessWidget {
  const _TransitCard({
    required this.count,
    required this.item,
    required this.loading,
    required this.onTap,
  });

  final int count;
  final PostOfficeInTransitItem? item;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final progress = item?.progressRatio?.clamp(0.0, 1.0);
    final etaHours = item?.etaRelativeHours;

    return PostalCardEnvelope(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: PostalTokens.postboxGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: PostalTokens.postboxGreen,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.postOfficeInTransitSummary(count),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      count == 0
                          ? l10n.inTransitEmptySubtitle
                          : etaHours != null && etaHours > 0
                          ? l10n.inTransitEtaHours(etaHours.round())
                          : l10n.inTransitTitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: PostalTokens.inkTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 28,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ],
          ),
          if (loading) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(minHeight: 3),
          ] else if (progress != null) ...[
            const SizedBox(height: 16),
            PostalDeliveryProgress(progress: progress),
          ],
        ],
      ),
    );
  }
}

class _TodaySummary extends StatelessWidget {
  const _TodaySummary({
    required this.remaining,
    required this.relationMessages,
  });

  final int remaining;
  final int relationMessages;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: PostalTokens.paperEnvelope.withValues(alpha: 0.62),
        borderRadius: PostalTokens.shapeMd,
        border: Border.all(color: PostalTokens.perforationLine),
      ),
      child: Column(
        children: [
          _TodayRow(
            icon: Icons.mark_email_unread_outlined,
            label: l10n.postOfficeMessagesSummary(relationMessages),
          ),
          const Divider(height: 1, color: PostalTokens.perforationLine),
          _TodayRow(
            icon: Icons.local_post_office_outlined,
            label: l10n.postOfficeFreeQuotaHint(remaining),
          ),
        ],
      ),
    );
  }
}

class _TodayRow extends StatelessWidget {
  const _TodayRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 21, color: PostalTokens.postboxGreen),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
