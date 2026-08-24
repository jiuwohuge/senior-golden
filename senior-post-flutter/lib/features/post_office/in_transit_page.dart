import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../widgets/postal/postal.dart';
import '../../core/models/letter_peer_label.dart';
import 'post_office_remote.dart';

/// 在途页不画系统滚动条：Material 指示条容易被看成卡片底边的横向滚动条。
class _NoBarScrollBehavior extends MaterialScrollBehavior {
  const _NoBarScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

/// §11.4 在途明细：发出未达 / 收到未达 / 未读，含相对 ETA 与投递轨迹。
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
      body: ScrollConfiguration(
        behavior: const _NoBarScrollBehavior(),
        child: async.when(
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
            return RefreshIndicator(
              color: PostalTokens.postboxGreen,
              onRefresh: () async {
                ref.invalidate(postOfficeInTransitProvider);
                ref.invalidate(postOfficeHomeProvider);
                await ref.read(postOfficeInTransitProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
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
              ),
            );
          },
        ),
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

  /// 收到未达：收件人侧正文密封，列表只给占位句。
  bool get _inboundSealed => item.itemType == 2;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final progress = (item.progressRatio ?? 0).clamp(0.0, 1.0);
    final hours = item.etaRelativeHours;
    final peerName = letterPeerDisplayTitle(l10n: l10n, peer: item.peer);
    final bodyText = _inboundSealed
        ? l10n.letterContentHiddenHint
        : item.preview.trim();

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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (hours != null && hours > 0) ...[
                const SizedBox(width: 8),
                Text(
                  l10n.inTransitEtaHours(hours.round()),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: PostalTokens.postboxGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          if (bodyText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              bodyText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _inboundSealed
                    ? PostalTokens.inkTertiary
                    : PostalTokens.inkSecondary,
                fontStyle: _inboundSealed ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
          if (item.itemType != 3) ...[
            const SizedBox(height: 14),
            PostalDeliveryProgress(progress: progress),
          ],
        ],
      ),
    );
  }
}

