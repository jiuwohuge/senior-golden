import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../widgets/postal/postal_button.dart';
import '../../widgets/postal/postal_card_envelope.dart';
import '../compose/compose_intent.dart';
import '../shell/main_shell.dart';
import 'post_office_remote.dart';

/// 邮局首页：一屏一主张 + 写信主 CTA + 两张摘要卡（§11）。
class PostOfficeHomePage extends ConsumerWidget {
  const PostOfficeHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final homeAsync = ref.watch(postOfficeHomeProvider);

    final greeting = homeAsync.maybeWhen(
      data: (h) => h.greeting.isNotEmpty ? h.greeting : l10n.postOfficeGreeting,
      orElse: () => l10n.postOfficeGreeting,
    );
    final hint = homeAsync.maybeWhen(
      data: (h) => h.todayHint.isNotEmpty ? h.todayHint : l10n.postOfficeTodayHint,
      orElse: () => l10n.postOfficeTodayHint,
    );
    final remaining = homeAsync.maybeWhen(
      data: (h) => h.remainingQuota,
      orElse: () => 5,
    );
    final relationCount = homeAsync.maybeWhen(
      data: (h) => h.relationMessageCount,
      orElse: () => 0,
    );
    final inTransit = homeAsync.maybeWhen(
      data: (h) => h.inTransitCount,
      orElse: () => 0,
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
        const SizedBox(height: 28),
        PostalButton(
          label: l10n.postOfficeWriteLetter,
          icon: Icons.edit_outlined,
          variant: PostalButtonVariant.primaryLarge,
          // 默认进邮局模式（POST_OFFICE）
          onPressed: () => context.push(
            '/compose',
            extra: const ComposeIntent(kind: ComposeKind.postOffice),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            l10n.postOfficeFreeQuotaHint(remaining),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: PostalTokens.inkTertiary,
            ),
          ),
        ),
        const SizedBox(height: 28),
        _SummaryCard(
          icon: Icons.mail_outline,
          title: l10n.postOfficeMessagesSummary(relationCount),
          onTap: () => context.go(MainShellRoute.pathMailbox),
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          icon: Icons.local_shipping_outlined,
          title: l10n.postOfficeInTransitSummary(inTransit),
          onTap: () => context.go(MainShellRoute.pathMailbox),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PostalCardEnvelope(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Icon(icon, size: 28, semanticLabel: title),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 28,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }
}
