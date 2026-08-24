import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../widgets/postal/postal.dart';
import '../post_office/post_office_remote.dart';
import 'time_letter_providers.dart';
import 'time_letter_remote.dart';

/// 信箱「时光信」：只展示列表，写信入口在邮局首页。
class TimeLetterListTab extends ConsumerWidget {
  const TimeLetterListTab({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(timeLetterStatsProvider);
    final listAsync = ref.watch(timeLetterAllProvider);

    return Column(
      children: [
        statsAsync.when(
          data: (s) {
            if (s.inFlightCount == 0 &&
                s.deliveredUnreadCount == 0 &&
                s.todayDeliveredCount == 0) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Material(
                color: PostalTokens.paperEnvelope,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l10n.timeLetterBanner(
                      s.inFlightCount,
                      s.deliveredUnreadCount,
                      s.todayDeliveredCount,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              invalidateTimeLetterLists(ref);
              await onRefresh();
              await ref.read(timeLetterAllProvider.future);
            },
            child: listAsync.when(
              loading: () => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
              error: (e, _) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  PostalEmptyState(
                    title: l10n.timeLetterLoadError,
                    subtitle: l10n.commonLoadFailedHint,
                    tone: PostalEmptyTone.error,
                  ),
                ],
              ),
              data: (items) {
                if (items.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      PostalEmptyState(
                        title: l10n.timeLetterEmptyTitle,
                        subtitle: l10n.timeLetterEmptySubtitle,
                      ),
                    ],
                  );
                }
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    final inFlight =
                        item.daysUntilDelivery != null || item.canCancel;
                    return _TimeLetterTile(item: item, isOutbox: inFlight);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeLetterTile extends ConsumerWidget {
  const _TimeLetterTile({required this.item, required this.isOutbox});

  final TimeLetterItem item;
  final bool isOutbox;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final subtitle = item.bodyPreview?.isNotEmpty == true
        ? item.bodyPreview!
        : (isOutbox ? l10n.timeLetterSealedHidden : l10n.timeLetterTapToOpen);
    final trailing = isOutbox && item.daysUntilDelivery != null
        ? Text(l10n.timeLetterDaysUntil('${item.daysUntilDelivery}'))
        : null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (item.status == 3 || item.status == 4) {
            context.push('/time-letter/${item.id}/open');
          }
        },
        onLongPress: item.canCancel
            ? () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.timeLetterCancelTitle),
                    content: Text(l10n.timeLetterCancelMessage),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(l10n.profileAvatarCropCancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(l10n.dialogConfirm),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await ref.read(timeLetterRemoteProvider).cancel(item.id);
                  invalidateTimeLetterLists(ref);
                  // 取消不计入当日额度，首页剩余次数一并刷新。
                  ref.invalidate(postOfficeHomeProvider);
                }
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: PostalTokens.postboxGreen.withValues(
                  alpha: 0.12,
                ),
                backgroundImage: item.peerAvatarUrl != null
                    ? NetworkImage(item.peerAvatarUrl!)
                    : null,
                child: item.peerAvatarUrl == null
                    ? Icon(
                        Icons.person_outline,
                        color: PostalTokens.postboxGreen,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.peerNickname ?? l10n.composeRecipientSelf,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
              if (item.starFlag)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.star_rounded,
                    color: PostalTokens.stampGold,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
