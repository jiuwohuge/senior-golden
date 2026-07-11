import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../widgets/postal/postal.dart';
import '../compose/compose_intent.dart';
import '../post_office/post_office_remote.dart';
import '../post_office/quota_claim_dialog.dart';

/// §2.8 首封信引导：资料完成后强制进入；写首封前必须先领取今日免费额度。
class FirstLetterGuidePage extends ConsumerStatefulWidget {
  const FirstLetterGuidePage({super.key});

  static const path = '/onboarding/first-letter';

  @override
  ConsumerState<FirstLetterGuidePage> createState() =>
      _FirstLetterGuidePageState();
}

class _FirstLetterGuidePageState extends ConsumerState<FirstLetterGuidePage> {
  bool _claimDialogScheduled = false;
  bool _quotaReady = false;
  bool _loadingQuota = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureQuotaClaimed());
  }

  /// 注册后先进本页：未领取则强制弹窗，领取后才可写首封信。
  Future<void> _ensureQuotaClaimed() async {
    if (!mounted || _claimDialogScheduled) return;
    _claimDialogScheduled = true;
    try {
      final home =
          await ref.read(postOfficeRemoteRepositoryProvider).fetchHome();
      if (!mounted) return;
      if (home.quotaClaimedToday) {
        setState(() {
          _quotaReady = true;
          _loadingQuota = false;
        });
        return;
      }
      setState(() => _loadingQuota = false);
      final claimed = await showDailyQuotaClaimDialog(
        context: context,
        ref: ref,
        dailyLetterQuota: home.dailyLetterQuota,
      );
      if (!mounted) return;
      setState(() => _quotaReady = claimed);
    } catch (e) {
      debugPrint('first-letter quota check failed: $e');
      if (mounted) {
        setState(() => _loadingQuota = false);
        PostalSnack.show(
          context,
          e.toString(),
          tone: PostalSnackTone.error,
        );
      }
    }
  }

  Future<void> _onStartCompose() async {
    if (!_quotaReady) {
      _claimDialogScheduled = false;
      await _ensureQuotaClaimed();
      if (!_quotaReady || !mounted) return;
    }
    if (!mounted) return;
    context.push(
      '/compose',
      extra: const ComposeIntent(
        kind: ComposeKind.postOffice,
        fromFirstLetterGuide: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: PostalTokens.paperCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.local_post_office_outlined,
                size: 56,
                color: PostalTokens.postboxGreen,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.firstLetterGuideTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: PostalTokens.inkNavy,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.firstLetterGuideSubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.45,
                  color: PostalTokens.inkSecondary,
                ),
              ),
              const SizedBox(height: 28),
              PostalCardEnvelope(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.firstLetterGuideHintTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.firstLetterGuideHintBody,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (_loadingQuota)
                const Center(child: CircularProgressIndicator())
              else
                PostalButton(
                  label: _quotaReady
                      ? l10n.firstLetterGuideCta
                      : l10n.quotaClaimButton,
                  icon: _quotaReady
                      ? Icons.edit_outlined
                      : Icons.card_giftcard_outlined,
                  variant: PostalButtonVariant.primaryLarge,
                  onPressed: _onStartCompose,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
