import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/bootstrap/app_bootstrap.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/postal/postal.dart';

class VipCenterPage extends ConsumerWidget {
  const VipCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final bootstrapAsync = ref.watch(appBootstrapProvider(lang));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileVipCenter)),
      body: SafeArea(
        child: bootstrapAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => PostalEmptyState(
            title: l10n.commonLoadFailed,
            subtitle: l10n.commonLoadFailedHint,
            tone: PostalEmptyTone.error,
            actionLabel: l10n.commonRetry,
            onAction: () => ref.invalidate(appBootstrapProvider(lang)),
          ),
          data: (bootstrap) {
            final v = bootstrap.vipProduct;
            final title = v.displayName;
            final subtitle = v.taglineForLanguage(lang);
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                PostalCardEnvelope(
                  header: PostalSectionTitle(title: title, subtitle: subtitle),
                  child: const SizedBox.shrink(),
                ),
                const SizedBox(height: 14),
                if (!v.productEnabled)
                  Text(
                    l10n.vipCenterPurchaseDisabled,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  Text(
                    l10n.vipCenterCheckoutNotWired,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
