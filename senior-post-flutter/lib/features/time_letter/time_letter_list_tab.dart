import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../widgets/postal/postal.dart';
import '../compose/compose_intent.dart';
import 'time_letter_providers.dart';
import 'time_letter_remote.dart';

class TimeLetterListTab extends ConsumerStatefulWidget {
  const TimeLetterListTab({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  ConsumerState<TimeLetterListTab> createState() => _TimeLetterListTabState();
}

class _TimeLetterListTabState extends ConsumerState<TimeLetterListTab>
    with SingleTickerProviderStateMixin {
  late TabController _inner;

  @override
  void initState() {
    super.initState();
    _inner = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _inner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(timeLetterStatsProvider);

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
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(
                    '/compose',
                    extra: const ComposeIntent(
                      kind: ComposeKind.selfTimeLetter,
                    ),
                  ),
                  icon: const Icon(Icons.edit_note_outlined),
                  label: Text(l10n.timeLetterComposeToSelf),
                ),
              ),
            ],
          ),
        ),
        TabBar(
          controller: _inner,
          labelColor: PostalTokens.postboxGreen,
          unselectedLabelColor: PostalTokens.inkTertiary,
          indicatorColor: PostalTokens.postboxGreen,
          tabs: [
            Tab(text: l10n.timeLetterTabOutbox),
            Tab(text: l10n.timeLetterTabInbox),
            Tab(text: l10n.timeLetterTabMemorial),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _inner,
            children: [
              _LetterList(
                provider: timeLetterOutboxProvider,
                onRefresh: widget.onRefresh,
                isOutbox: true,
              ),
              _LetterList(
                provider: timeLetterInboxProvider,
                onRefresh: widget.onRefresh,
                isOutbox: false,
              ),
              _LetterList(
                provider: timeLetterMemorialProvider,
                onRefresh: widget.onRefresh,
                isOutbox: null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LetterList extends ConsumerWidget {
  const _LetterList({
    required this.provider,
    required this.onRefresh,
    required this.isOutbox,
  });

  final AutoDisposeFutureProvider<List<TimeLetterItem>> provider;
  final Future<void> Function() onRefresh;
  final bool? isOutbox;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(provider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(provider);
        ref.invalidate(timeLetterStatsProvider);
        await onRefresh();
        await ref.read(provider.future);
      },
      child: async.when(
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
              subtitle: '$e',
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
              return _TimeLetterTile(item: item, isOutbox: isOutbox);
            },
          );
        },
      ),
    );
  }
}

class _TimeLetterTile extends ConsumerWidget {
  const _TimeLetterTile({required this.item, required this.isOutbox});

  final TimeLetterItem item;
  final bool? isOutbox;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final subtitle = item.bodyPreview?.isNotEmpty == true
        ? item.bodyPreview!
        : (isOutbox == true
              ? l10n.timeLetterSealedHidden
              : l10n.timeLetterTapToOpen);
    final trailing = isOutbox == true && item.daysUntilDelivery != null
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
                      item.peerNickname ?? l10n.timeLetterComposeToSelf,
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
