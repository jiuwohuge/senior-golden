import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../widgets/postal/postal.dart';
import 'post_office_remote.dart';

/// §11.4 在途明细：发出未达 / 收到未达 / 未读，含相对 ETA 与进度条。
class InTransitPage extends ConsumerWidget {
  const InTransitPage({super.key});

  static const path = '/post-office/in-transit';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(postOfficeInTransitProvider);

    return Scaffold(
      backgroundColor: PostalTokens.paperCream,
      appBar: AppBar(
        backgroundColor: PostalTokens.postboxGreen,
        foregroundColor: Colors.white,
        title: Text(l10n.inTransitTitle),
      ),
      body: async.when(
        loading: () => const PostalSkeletonList(itemCount: 4, itemHeight: 120),
        error: (e, _) => PostalEmptyState(
          title: l10n.inTransitLoadFailed,
          subtitle: '$e',
          tone: PostalEmptyTone.error,
          actionLabel: l10n.authRetry,
          onAction: () => ref.invalidate(postOfficeInTransitProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return PostalEmptyState(
              title: l10n.inTransitEmptyTitle,
              subtitle: l10n.inTransitEmptySubtitle,
            );
          }
          final outbound = items.where((e) => e.itemType == 1).toList();
          final inbound = items.where((e) => e.itemType == 2).toList();
          final unread = items.where((e) => e.itemType == 3).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              _Section(
                title: l10n.inTransitSectionOutbound,
                items: outbound,
              ),
              _Section(
                title: l10n.inTransitSectionInbound,
                items: inbound,
              ),
              _Section(
                title: l10n.inTransitSectionUnread,
                items: unread,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items});

  final String title;
  final List<PostOfficeInTransitItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 8),
          child: Text(
            '$title · ${items.length}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              l10n.inTransitSectionEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: PostalTokens.inkTertiary,
              ),
            ),
          )
        else
          for (final item in items) ...[
            _InTransitCard(item: item),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _InTransitCard extends StatelessWidget {
  const _InTransitCard({required this.item});

  final PostOfficeInTransitItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final progress = (item.progressRatio ?? 0).clamp(0.0, 1.0);
    final hours = item.etaRelativeHours;
    final peerName = item.peer.nickname.isNotEmpty
        ? item.peer.nickname
        : l10n.letterPeerUnknown;

    return PostalCardEnvelope(
      onTap: item.letterId.isEmpty
          ? null
          : () => context.push('/letter/${item.letterId}'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  peerName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (hours != null && hours > 0)
                Text(
                  l10n.inTransitEtaHours(hours.round()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: PostalTokens.postboxGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          if (item.preview.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: PostalTokens.inkSecondary,
              ),
            ),
          ],
          if (item.itemType != 3) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: PostalTokens.perforationLine,
                color: PostalTokens.postboxGreen,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
