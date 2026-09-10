import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/i18n/postal_format.dart';
import '../../widgets/postal/postal.dart';
import '../billing/billing_remote.dart';
import '../billing/play_billing_service.dart';

/// Plus 付费墙：展示订阅状态、AI 剩余额度，并提供年订/月订/恢复购买。
/// Web / Debug 另提供 test-override，便于无 Play Store 时测云端门禁。
class VipCenterPage extends ConsumerStatefulWidget {
  const VipCenterPage({super.key, this.hint});

  /// 业务错误跳转时的可选说明文案。
  final String? hint;

  @override
  ConsumerState<VipCenterPage> createState() => _VipCenterPageState();
}

class _VipCenterPageState extends ConsumerState<VipCenterPage> {
  bool _busy = false;
  List<ProductDetails> _products = const [];
  String? _localMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapStore());
  }

  Future<void> _bootstrapStore() async {
    final billing = ref.read(playBillingServiceProvider);
    billing.ensurePurchaseListener(
      onVerified: (_) {
        ref.invalidate(subscriptionStatusProvider);
        if (!mounted) return;
        setState(() => _localMessage = null);
        PostalSnack.show(
          context,
          AppLocalizations.of(context)!.vipPurchaseSuccess,
          tone: PostalSnackTone.success,
        );
      },
      onError: (e) {
        debugPrint('vip center purchase listener error: $e');
        if (!mounted) return;
        PostalSnack.show(
          context,
          AppLocalizations.of(context)!.vipPurchaseFailed,
          tone: PostalSnackTone.error,
        );
      },
    );
    if (!billing.supportsStorePurchase) return;
    final products = await billing.queryPlusProducts();
    if (mounted) setState(() => _products = products);
  }

  ProductDetails? _product(String id) {
    for (final p in _products) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> _refresh() async {
    ref.invalidate(subscriptionStatusProvider);
    await ref.read(subscriptionStatusProvider.future);
  }

  Future<void> _runBusy(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _localMessage = null;
    });
    try {
      await action();
      await _refresh();
    } catch (e, st) {
      debugPrint('vip center action failed: $e\n$st');
      if (mounted) {
        setState(() {
          _localMessage = AppLocalizations.of(context)!.commonActionFailed;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _buy(String productId) async {
    final billing = ref.read(playBillingServiceProvider);
    final l10n = AppLocalizations.of(context)!;
    if (!billing.supportsStorePurchase) {
      // Web/iOS：无商店时用测试覆盖模拟年订试用/月订开通，避免按钮空转。
      if (billing.showTestHarness) {
        await _runBusy(() async {
          await billing.applyTestOverride(
            state: productId == PlusProductIds.yearly ? 'trial' : 'active',
            productId: productId,
          );
          if (mounted) {
            PostalSnack.show(
              context,
              l10n.vipTestOverrideApplied,
              tone: PostalSnackTone.success,
            );
          }
        });
      } else {
        PostalSnack.show(context, l10n.vipStoreUnavailable, tone: PostalSnackTone.warning);
      }
      return;
    }
    final details = _product(productId);
    if (details == null) {
      PostalSnack.show(context, l10n.vipProductNotFound, tone: PostalSnackTone.warning);
      return;
    }
    await _runBusy(() async {
      final started = await billing.buyProduct(details);
      if (!started && mounted) {
        PostalSnack.show(context, l10n.vipPurchaseFailed, tone: PostalSnackTone.error);
      }
    });
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context)!;
    await _runBusy(() async {
      await ref.read(playBillingServiceProvider).restorePurchases();
      if (mounted) {
        PostalSnack.show(context, l10n.vipRestoreDone, tone: PostalSnackTone.success);
      }
    });
  }

  Future<void> _testOverride(String state) async {
    final l10n = AppLocalizations.of(context)!;
    await _runBusy(() async {
      await ref.read(playBillingServiceProvider).applyTestOverride(
            state: state,
            productId: PlusProductIds.yearly,
          );
      if (mounted) {
        PostalSnack.show(
          context,
          l10n.vipTestOverrideApplied,
          tone: PostalSnackTone.success,
        );
      }
    });
  }

  String _stateLabel(AppLocalizations l10n, SubscriptionStatus s) {
    return switch (s.state) {
      'trial' => l10n.vipStateTrial,
      'active' => l10n.vipStateActive,
      'expired' => l10n.vipStateExpired,
      _ => l10n.vipStateNone,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(subscriptionStatusProvider);
    final billing = ref.watch(playBillingServiceProvider);
    final hint = widget.hint?.trim();

    return Scaffold(
      backgroundColor: PostalTokens.paperCream,
      appBar: AppBar(
        backgroundColor: PostalTokens.postboxGreen,
        foregroundColor: Colors.white,
        title: Text(l10n.profileVipCenter),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) {
            debugPrint('vip center load failed: $e');
            return PostalEmptyState(
              title: l10n.commonLoadFailed,
              subtitle: l10n.commonLoadFailedHint,
              tone: PostalEmptyTone.error,
              actionLabel: l10n.commonRetry,
              onAction: () => ref.invalidate(subscriptionStatusProvider),
            );
          },
          data: (status) {
            final yearlyPrice = _product(PlusProductIds.yearly)?.price;
            final monthlyPrice = _product(PlusProductIds.monthly)?.price;
            return RefreshIndicator(
              color: PostalTokens.postboxGreen,
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                children: [
                  if (hint != null && hint.isNotEmpty) ...[
                    Material(
                      color: PostalTokens.stampVermilionMuted,
                      borderRadius: PostalTokens.shapeMd,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Text(
                          hint,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: PostalTokens.inkNavy,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  PostalCardEnvelope(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.vipPlusHeadline,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: PostalTokens.postboxGreen,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.vipPlusTagline,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: PostalTokens.inkSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          l10n.vipCurrentState(_stateLabel(l10n, status)),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: PostalTokens.inkNavy,
                          ),
                        ),
                        if (status.expiryAt != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            l10n.vipExpiryLine(
                              PostalFormat.dateTime(context, status.expiryAt!),
                            ),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: PostalTokens.inkSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Text(
                          l10n.vipAiQuotaRemaining(status.aiQuotaRemaining),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: PostalTokens.stampGold,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  PostalButton(
                    label: yearlyPrice == null
                        ? l10n.vipBuyYearly
                        : l10n.vipBuyYearlyPriced(yearlyPrice),
                    variant: PostalButtonVariant.primaryLarge,
                    busy: _busy,
                    onPressed: _busy ? null : () => _buy(PlusProductIds.yearly),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.vipYearlyPreferredHint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: PostalTokens.inkSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  PostalButton(
                    label: monthlyPrice == null
                        ? l10n.vipBuyMonthly
                        : l10n.vipBuyMonthlyPriced(monthlyPrice),
                    variant: PostalButtonVariant.secondary,
                    busy: _busy,
                    onPressed: _busy
                        ? null
                        : () => _buy(PlusProductIds.monthly),
                  ),
                  const SizedBox(height: 14),
                  PostalButton(
                    label: l10n.vipRestorePurchases,
                    variant: PostalButtonVariant.ghost,
                    busy: _busy,
                    onPressed: _busy ? null : _restore,
                  ),
                  if (_localMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _localMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: PostalTokens.error,
                      ),
                    ),
                  ],
                  if (billing.showTestHarness) ...[
                    const SizedBox(height: 28),
                    Text(
                      l10n.vipTestHarnessTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PostalTokens.kraftBrown,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.vipTestHarnessHint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: PostalTokens.inkSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _TestChip(
                          label: l10n.vipTestTrial,
                          onTap: _busy ? null : () => _testOverride('trial'),
                        ),
                        _TestChip(
                          label: l10n.vipTestActive,
                          onTap: _busy ? null : () => _testOverride('active'),
                        ),
                        _TestChip(
                          label: l10n.vipTestExpired,
                          onTap: _busy ? null : () => _testOverride('expired'),
                        ),
                        _TestChip(
                          label: l10n.vipTestNone,
                          onTap: _busy ? null : () => _testOverride('none'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TestChip extends StatelessWidget {
  const _TestChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PostalTokens.paperCard,
      borderRadius: PostalTokens.shapeMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: PostalTokens.shapeMd,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52, minWidth: 120),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: PostalTokens.postboxGreen,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
