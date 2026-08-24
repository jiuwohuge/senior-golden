import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/models/domain_models.dart';
import '../../widgets/postal/postal.dart';
import 'commerce_remote.dart';

/// 我的装扮/权益列表。
class MyEntitlementsPage extends ConsumerWidget {
  const MyEntitlementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(commerceEntitlementsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.entitlementsTitle)),
      body: SafeArea(
        child: async.when(
          loading: () => const PostalSkeletonList(itemCount: 4, itemHeight: 72),
          error: (e, _) => PostalEmptyState(
            title: l10n.commonLoadFailed,
            subtitle: l10n.commonLoadFailedHint,
            tone: PostalEmptyTone.error,
          ),
          data: (items) {
            if (items.isEmpty) {
              return PostalEmptyState(
                title: l10n.entitlementsEmptyTitle,
                subtitle: l10n.entitlementsEmptySubtitle,
                actionLabel: l10n.shopTitleStampsVip,
                onAction: () => Navigator.of(context).pop(),
              );
            }
            final grouped = <String, List<CommerceEntitlement>>{};
            for (final e in items) {
              grouped.putIfAbsent(e.productType, () => []).add(e);
            }
            final types = grouped.keys.toList()..sort();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                for (final type in types) ...[
                  Text(
                    commerceTypeLabel(l10n, type),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...grouped[type]!.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _EntitlementCard(entitlement: e),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EntitlementCard extends StatelessWidget {
  const _EntitlementCard({required this.entitlement});

  final CommerceEntitlement entitlement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final granted = entitlement.grantedAt;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PostalTokens.paperCard,
        borderRadius: PostalTokens.shapeMd,
        border: Border.all(color: PostalTokens.perforationLine),
      ),
      child: ListTile(
        leading: Icon(
          Icons.verified_outlined,
          color: PostalTokens.postboxGreen,
          size: 28,
        ),
        title: Text(
          commerceProductTitle(l10n, entitlement.titleKey),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          granted != null
              ? l10n.entitlementsGrantedAt(DateFormat.yMMMd().format(granted))
              : entitlement.productCode,
        ),
      ),
    );
  }
}
