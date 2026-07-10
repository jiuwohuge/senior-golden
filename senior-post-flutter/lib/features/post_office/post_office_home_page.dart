import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/bootstrap/app_bootstrap.dart';
import '../../core/i18n/app_locale_provider.dart';
import '../../core/models/domain_models.dart';
import '../../widgets/postal/postal_button.dart';
import '../../widgets/postal/postal_card_envelope.dart';
import '../mailbox/mailbox_providers.dart';
import '../shell/main_shell.dart';

/// M0: 邮局首页 — 一屏一主张 + 摘要卡（§11 / §12.2 / §12.8）
class PostOfficeHomePage extends ConsumerWidget {
  const PostOfficeHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final lang = ref.watch(appLocaleProvider)?.languageCode ?? 'en';
    final bootstrap = ref.watch(appBootstrapProvider(lang));
    final dailyQuota = bootstrap.valueOrNull?.dailyLetterQuota ?? 5;

    final inboxAsync = ref.watch(postalInboxLettersProvider);
    final pendingCount = inboxAsync.maybeWhen(
      data: (letters) => letters.length,
      orElse: () => 0,
    );
    final inTransitCount = inboxAsync.maybeWhen(
      data: (letters) =>
          letters.where((l) => l.status == LetterStatus.delivering).length,
      orElse: () => 0,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          l10n.postOfficeGreeting,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.postOfficeTodayHint,
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
          onPressed: () => context.push('/compose'),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            l10n.postOfficeFreeQuotaHint(dailyQuota),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: PostalTokens.inkTertiary,
            ),
          ),
        ),
        const SizedBox(height: 28),
        _SummaryCard(
          icon: Icons.mail_outline,
          title: l10n.postOfficeMessagesSummary(pendingCount),
          onTap: () => context.go(MainShellRoute.pathMailbox),
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          icon: Icons.local_shipping_outlined,
          title: l10n.postOfficeInTransitSummary(inTransitCount),
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
