import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/api/biz_error_codes.dart';
import '../../core/models/domain_models.dart';
import '../../core/session/app_session.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/postal/postal.dart';
import 'commerce_remote.dart';

/// 商品页：真实目录（按类型分组）+ MVP 模拟购买。
class ShopPage extends ConsumerWidget {
  const ShopPage({super.key, this.triggerBizCode, this.hint});

  final int? triggerBizCode;
  final String? hint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(appSessionProvider);
    final catalogAsync = ref.watch(commerceCatalogProvider);
    final mq = MediaQuery.sizeOf(context);
    final maxW = mq.width >= 600 ? 560.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shopTitleStampsVip)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  children: [
                    if (triggerBizCode != null ||
                        (hint != null && hint!.isNotEmpty))
                      _ContextBanner(code: triggerBizCode, hint: hint),
                    PostalCardEnvelope(
                      accent: PostalTokens.postboxGreen,
                      header: PostalSectionTitle(
                        title: l10n.shopVipSectionTitle,
                        subtitle: session.isVip
                            ? l10n.shopVipOwnedSubtitle
                            : l10n.shopVipPromoSubtitle,
                        trailing: session.isVip
                            ? Icon(
                                Icons.verified_rounded,
                                color: PostalTokens.postboxGreen,
                                size: 28,
                              )
                            : null,
                      ),
                      child: Text(
                        l10n.shopVipBody,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: PostalTokens.inkSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    catalogAsync.when(
                      loading: () => const PostalSkeletonList(
                        itemCount: 3,
                        itemHeight: 120,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                      ),
                      error: (e, _) => PostalEmptyState(
                        title: l10n.commonLoadFailed,
                        subtitle: '$e',
                        tone: PostalEmptyTone.error,
                        actionLabel: l10n.commonRetry,
                        onAction: () => ref.invalidate(commerceCatalogProvider),
                      ),
                      data: (products) => _CatalogByType(
                        products: products,
                        onPurchased: () {
                          ref.invalidate(commerceCatalogProvider);
                          ref.invalidate(commerceEntitlementsProvider);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CatalogByType extends StatelessWidget {
  const _CatalogByType({required this.products, required this.onPurchased});

  final List<CommerceProduct> products;
  final VoidCallback onPurchased;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (products.isEmpty) {
      return PostalEmptyState(
        title: l10n.shopCatalogEmptyTitle,
        subtitle: l10n.shopCatalogEmptySubtitle,
      );
    }
    final grouped = <String, List<CommerceProduct>>{};
    for (final p in products) {
      grouped.putIfAbsent(p.productType, () => []).add(p);
    }
    for (final list in grouped.values) {
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }
    final types = grouped.keys.toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final type in types) ...[
          Text(
            commerceTypeLabel(l10n, type),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...grouped[type]!.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ProductCard(product: p, onPurchased: onPurchased),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ProductCard extends ConsumerStatefulWidget {
  const _ProductCard({required this.product, required this.onPurchased});

  final CommerceProduct product;
  final VoidCallback onPurchased;

  @override
  ConsumerState<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<_ProductCard> {
  bool _busy = false;

  Future<void> _mockPurchase() async {
    final l10n = AppLocalizations.of(context)!;
    if (widget.product.owned) return;
    setState(() => _busy = true);
    try {
      await ref.read(commerceRemoteProvider).mockPurchase(widget.product.id);
      if (!mounted) return;
      widget.onPurchased();
      PostalSnack.show(
        context,
        l10n.shopMockPurchaseSuccess,
        tone: PostalSnackTone.success,
      );
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = widget.product;
    final previewColor = p.metadata['previewColor'] as String?;
    Color? swatch;
    if (previewColor != null && previewColor.startsWith('#')) {
      final hex = previewColor.substring(1);
      if (hex.length == 6) {
        swatch = Color(int.parse('FF$hex', radix: 16));
      }
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: swatch ?? PostalTokens.paperCard,
        borderRadius: PostalTokens.shapeMd,
        border: Border.all(color: PostalTokens.perforationLine),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    commerceProductTitle(l10n, p.titleKey),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (p.owned)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: PostalTokens.postboxGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.shopOwned,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: PostalTokens.postboxGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formatPriceCents(p.priceCents, l10n),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: PostalTokens.inkSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: p.owned || _busy ? null : _mockPurchase,
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(p.owned ? l10n.shopOwned : l10n.shopMockPurchase),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextBanner extends StatelessWidget {
  const _ContextBanner({this.code, this.hint});

  final int? code;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final lines = <String>[];
    if (code == BizErrorCodes.stampInsufficient) {
      lines.add('Current action needs more stamps — browse items below.');
    } else if (code == BizErrorCodes.vipRequired) {
      lines.add('This feature needs membership — see VIP section.');
    } else if (code != null) {
      lines.add('Business hint (code $code)');
    }
    if (hint != null && hint!.isNotEmpty) {
      lines.add(hint!);
    }
    if (lines.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: PostalTokens.stampVermilionMuted,
        borderRadius: PostalTokens.shapeMd,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.local_post_office_rounded,
                color: PostalTokens.stampVermilion,
                size: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  lines.join('\n'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PostalTokens.inkNavy,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
