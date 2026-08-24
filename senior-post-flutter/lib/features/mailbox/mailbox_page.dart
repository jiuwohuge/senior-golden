import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';
import '../../app/theme/postal_tokens.dart';
import '../../core/i18n/postal_format.dart';
import '../../core/models/domain_models.dart';
import '../../core/models/letter_peer_label.dart';
import '../../core/models/letter_transit_progress.dart';
import '../auth/auth_repository.dart';
import '../../widgets/postal/postal.dart';
import 'mailbox_providers.dart';
import '../time_letter/time_letter_list_tab.dart';
import '../time_letter/time_letter_providers.dart';
import '../relation/relation_display_label.dart';
import '../relation/relation_remote.dart';
import '../directory/my_penpals_page.dart';

class MailboxPage extends ConsumerStatefulWidget {
  const MailboxPage({super.key});

  @override
  ConsumerState<MailboxPage> createState() => _MailboxPageState();
}

class _MailboxPageState extends ConsumerState<MailboxPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabSelected);
  }

  void _onTabSelected() {
    if (_tabController.indexIsChanging) {
      return;
    }
    _reloadTab(_tabController.index);
  }

  void _reloadTab(int index) {
    switch (index) {
      case 0:
        ref.invalidate(mailboxReceivedProvider);
      case 1:
        ref.invalidate(mailboxSentProvider);
      case 2:
        invalidateTimeLetterLists(ref);
    }
  }

  Future<void> _refreshReceived() async {
    ref.invalidate(mailboxReceivedProvider);
    await ref.read(mailboxReceivedProvider.future);
  }

  Future<void> _refreshSent() async {
    ref.invalidate(mailboxSentProvider);
    await ref.read(mailboxSentProvider.future);
  }

  Future<void> _refreshTimeLetters() async {
    invalidateTimeLetterLists(ref);
    await ref.read(timeLetterStatsProvider.future);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabSelected);
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _reloadTab(_tabController.index);
        ref.invalidate(mailboxArchiveProvider);
        ref.invalidate(mailboxLettersProvider);
        ref.read(authRepositoryProvider).refreshSessionFromServer();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              children: [
                _MailboxNavRow(
                  icon: Icons.people_outline,
                  title: l10n.mailboxMyPenpals,
                  onTap: () => context.push(MyPenpalsPage.path),
                ),
                const _MailboxPenpalRequestsRow(),
              ],
            ),
          ),
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: PostalTokens.postboxGreen,
              unselectedLabelColor: PostalTokens.inkTertiary,
              indicatorColor: PostalTokens.postboxGreen,
              tabs: [
                Tab(text: l10n.mailboxTabReceived),
                Tab(text: l10n.mailboxTabSent),
                Tab(text: l10n.mailboxTabTimeLetter),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ReceivedTab(onRefresh: _refreshReceived),
                _SentTab(onRefresh: _refreshSent),
                TimeLetterListTab(onRefresh: _refreshTimeLetters),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 可下拉刷新的滚动容器（空态 / 错误态占满 Tab 高度）。
class _MailboxRefreshBody extends StatelessWidget {
  const _MailboxRefreshBody({required this.onRefresh, required this.child});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _ReceivedTab extends ConsumerWidget {
  const _ReceivedTab({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lettersAsync = ref.watch(mailboxReceivedProvider);
    return lettersAsync.when(
      loading: () => const PostalSkeletonList(itemCount: 5, itemHeight: 120),
      error: (e, _) => _MailboxRefreshBody(
        onRefresh: onRefresh,
        child: PostalEmptyState(
          title: AppLocalizations.of(context)!.commonLoadFailed,
          subtitle: '$e',
          tone: PostalEmptyTone.error,
        ),
      ),
      data: (letters) => _MailboxLettersBody(
        letters: letters,
        onRefresh: onRefresh,
        emptyTitle: AppLocalizations.of(context)!.mailboxReceivedEmptyTitle,
        emptySubtitle: AppLocalizations.of(
          context,
        )!.mailboxReceivedEmptySubtitle,
        showInTransitBanner: true,
      ),
    );
  }
}

class _SentTab extends ConsumerWidget {
  const _SentTab({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lettersAsync = ref.watch(mailboxSentProvider);
    return lettersAsync.when(
      loading: () => const PostalSkeletonList(itemCount: 5, itemHeight: 120),
      error: (e, _) => _MailboxRefreshBody(
        onRefresh: onRefresh,
        child: PostalEmptyState(
          title: AppLocalizations.of(context)!.commonLoadFailed,
          subtitle: '$e',
          tone: PostalEmptyTone.error,
        ),
      ),
      data: (letters) => _MailboxLettersBody(
        letters: letters,
        onRefresh: onRefresh,
        emptyTitle: AppLocalizations.of(context)!.mailboxSentEmptyTitle,
        emptySubtitle: AppLocalizations.of(context)!.mailboxSentEmptySubtitle,
        showInTransitBanner: false,
      ),
    );
  }
}

class _MailboxLettersBody extends ConsumerWidget {
  const _MailboxLettersBody({
    required this.letters,
    required this.onRefresh,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.showInTransitBanner,
  });

  final List<MailboxLetter> letters;
  final Future<void> Function() onRefresh;
  final String emptyTitle;
  final String emptySubtitle;
  final bool showInTransitBanner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final delivering = showInTransitBanner
        ? letters.where(letterIsInTransit).toList()
        : const <MailboxLetter>[];
    final matching = showInTransitBanner
        ? letters.where(letterIsWaitingForMatch).toList()
        : const <MailboxLetter>[];
    return Column(
      children: [
        if (matching.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: PostalTokens.kraftBrown.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.hourglass_top_outlined),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.letterStatusWaitingMatch)),
              ],
            ),
          ),
        if (delivering.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_outlined),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.mailboxPostOnTheWay)),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: letters.isEmpty
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: PostalEmptyState(
                            title: emptyTitle,
                            subtitle: emptySubtitle,
                          ),
                        ),
                      );
                    },
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: letters.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _LetterTile(letter: letters[i]),
                  ),
          ),
        ),
      ],
    );
  }
}

class _LetterTile extends ConsumerWidget {
  const _LetterTile({required this.letter});
  final MailboxLetter letter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statusChip = switch (letter.status) {
      LetterStatus.pending => PostalStatusChip.draft(
        label: l10n.letterStatusWaitingMatch,
      ),
      LetterStatus.matched => PostalStatusChip.delivering(
        label: l10n.letterStatusMatched,
      ),
      LetterStatus.delivering => PostalStatusChip.delivering(
        label: l10n.letterStatusInTransit,
      ),
      LetterStatus.registered => PostalStatusChip.registered(
        label: l10n.letterStatusRegistered,
      ),
      LetterStatus.delivered => PostalStatusChip.delivered(
        label: l10n.letterDeliveredLabel,
      ),
    };
    final progress = letterTransitProgress(letter);
    // auditStatus: 0 待审 / 1 通过 / 2 拒绝 — 非通过时在列表露出标签。
    final auditLabel = switch (letter.auditStatus) {
      0 => l10n.letterAuditPending,
      2 => l10n.letterAuditRejected,
      _ => null,
    };
    return PostalCardEnvelope(
      onTap: () {
        ref.invalidate(letterDetailProvider(letter.id));
        context.push(
          '/letter/${letter.id}',
          extra: <String, dynamic>{
            'firstOpen':
                !letter.outgoing &&
                letter.status == LetterStatus.delivered &&
                !letter.recipientRead,
          },
        );
      },
      header: Row(
        children: [
          isUnresolvedLetterPeer(letter.peer)
              ? _MailboxRecommendingAvatar(size: 40)
              : PostalAvatar(
                  name: letterPeerDisplayTitle(
                    l10n: l10n,
                    peer: letter.peer,
                    mode: letter.mode,
                  ),
                  size: 40,
                  imageUrl: letter.peer.avatarUrl,
                ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              letterPeerDisplayTitle(
                l10n: l10n,
                peer: letter.peer,
                mode: letter.mode,
              ),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          statusChip,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            letter.contentHidden && letter.preview.isEmpty
                ? l10n.letterMailboxSealedPreview
                : letter.preview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (auditLabel != null) ...[
            const SizedBox(height: 6),
            Text(
              l10n.letterAuditLine(auditLabel),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PostalTokens.stampVermilion,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (letter.relationDisplayState != null) ...[
            const SizedBox(height: 6),
            Text(
              relationDisplayLabel(l10n, letter.relationDisplayState!),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: letter.canAddPenpal
                    ? PostalTokens.postboxGreen
                    : PostalTokens.inkSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 8),
          if (progress != null) ...[
            PostalDeliveryProgress(progress: progress),
            const SizedBox(height: 8),
          ],
          Text(
            PostalFormat.dateTime(context, letter.sentAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _MailboxNavRow extends StatelessWidget {
  const _MailboxNavRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PostalCardEnvelope(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 28, color: PostalTokens.postboxGreen),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: PostalTokens.inkSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 28),
        ],
      ),
    );
  }
}

class _MailboxPenpalRequestsRow extends ConsumerWidget {
  const _MailboxPenpalRequestsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(postOfficeRelationMessagesProvider);
    return async.maybeWhen(
      data: (rows) {
        if (rows.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _MailboxNavRow(
            icon: Icons.mark_email_unread_outlined,
            title: l10n.mailboxPenpalRequests,
            subtitle: l10n.mailboxPenpalRequestsCount(rows.length),
            onTap: () => context.push('/post-office/messages'),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

/// 信箱列表：未配对占位头像（信封），避免「?」/「U」。
class _MailboxRecommendingAvatar extends StatelessWidget {
  const _MailboxRecommendingAvatar({this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: PostalTokens.kraftBrown, width: 1.4),
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: PostalTokens.paperEnvelope,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.markunread_mailbox_outlined,
          size: size * 0.48,
          color: PostalTokens.postboxGreen,
        ),
      ),
    );
  }
}
