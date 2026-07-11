import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/session/app_session.dart';
import '../../widgets/postal/postal_button.dart';
import '../../widgets/postal/postal_card_envelope.dart';
import '../../widgets/postal/postal_snack.dart';
import '../compose/compose_intent.dart';
import 'post_office_remote.dart';

/// 邮局首页：一屏一主张 + 写信主 CTA + 两张摘要卡（§11）。
class PostOfficeHomePage extends ConsumerStatefulWidget {
  const PostOfficeHomePage({super.key});

  @override
  ConsumerState<PostOfficeHomePage> createState() => _PostOfficeHomePageState();
}

class _PostOfficeHomePageState extends ConsumerState<PostOfficeHomePage> {
  bool _claimDialogScheduled = false;
  bool _claimDialogVisible = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final homeAsync = ref.watch(postOfficeHomeProvider);
    final firstLetterDone =
        ref.watch(appSessionProvider).user.firstLetterDone == true;

    // 仅首封信完成后弹额度领取；避免挡住引导页 / 造成灰屏。
    homeAsync.whenData((h) {
      final sessionDone =
          firstLetterDone || h.firstLetterDone;
      if (sessionDone &&
          !h.quotaClaimedToday &&
          !_claimDialogScheduled &&
          !_claimDialogVisible) {
        _claimDialogScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showQuotaClaimDialog(h);
        });
      }
    });

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
          onPressed: () => _showWriteDestinationSheet(context),
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
          onTap: () => context.push('/post-office/messages'),
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          icon: Icons.local_shipping_outlined,
          title: l10n.postOfficeInTransitSummary(inTransit),
          onTap: () => context.push('/post-office/in-transit'),
        ),
      ],
    );
  }

  /// §11.5 首页写信分流：寄给有缘人 / 寄给未来的自己（不含 DIRECT）。
  Future<void> _showWriteDestinationSheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: PostalTokens.paperEnvelope,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.writeDestinationTitle,
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                PostalCardEnvelope(
                  onTap: () {
                    Navigator.of(ctx).pop();
                    context.push(
                      '/compose',
                      extra: const ComposeIntent(kind: ComposeKind.postOffice),
                    );
                  },
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 22,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_post_office_outlined,
                        size: 32,
                        color: PostalTokens.postboxGreen,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.writeDestinationPostOffice,
                              style: Theme.of(ctx).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.writeDestinationPostOfficeSub,
                              style: Theme.of(ctx).textTheme.bodySmall
                                  ?.copyWith(color: PostalTokens.inkSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                PostalCardEnvelope(
                  onTap: () {
                    Navigator.of(ctx).pop();
                    context.push(
                      '/compose',
                      extra: const ComposeIntent(
                        kind: ComposeKind.selfTimeLetter,
                      ),
                    );
                  },
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 22,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_send_outlined,
                        size: 32,
                        color: PostalTokens.stampVermilion,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.writeDestinationSelfTime,
                              style: Theme.of(ctx).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.writeDestinationSelfTimeSub,
                              style: Theme.of(ctx).textTheme.bodySmall
                                  ?.copyWith(color: PostalTokens.inkSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showQuotaClaimDialog(PostOfficeHomeData home) async {
    if (!mounted || _claimDialogVisible) return;
    _claimDialogVisible = true;
    final l10n = AppLocalizations.of(context)!;
    var claiming = false;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dlgCtx) {
          return StatefulBuilder(
            builder: (ctx, setLocal) {
              return PopScope(
                canPop: false,
                child: AlertDialog(
                  icon: Icon(
                    Icons.card_giftcard_outlined,
                    color: PostalTokens.postboxGreen,
                    size: 48,
                  ),
                  title: Text(l10n.quotaClaimTitle),
                  content: Text(l10n.quotaClaimMessage(home.dailyLetterQuota)),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    // expand:false 避免 Dialog actions 零尺寸 hit-test 灰屏。
                    SizedBox(
                      width: 260,
                      child: PostalButton(
                        label: l10n.quotaClaimButton,
                        expand: false,
                        busy: claiming,
                        onPressed: claiming
                            ? null
                            : () async {
                                setLocal(() => claiming = true);
                                try {
                                  if (!mounted) return;
                                  await ref
                                      .read(postOfficeRemoteRepositoryProvider)
                                      .claimDailyQuota();
                                  if (!mounted) return;
                                  ref.invalidate(postOfficeHomeProvider);
                                  if (dlgCtx.mounted) {
                                    Navigator.of(dlgCtx).pop();
                                  }
                                } catch (e) {
                                  final biz = apiBusinessExceptionFrom(e);
                                  if (ctx.mounted) {
                                    PostalSnack.show(
                                      ctx,
                                      biz?.message ?? e.toString(),
                                      tone: PostalSnackTone.error,
                                    );
                                  }
                                  setLocal(() => claiming = false);
                                }
                              },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } finally {
      _claimDialogVisible = false;
    }
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
