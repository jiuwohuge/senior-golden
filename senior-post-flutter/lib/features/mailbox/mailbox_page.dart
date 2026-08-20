import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';
import '../../app/theme/postal_tokens.dart';
import '../../core/models/domain_models.dart';
import '../../core/models/letter_peer_label.dart';
import '../auth/auth_repository.dart';
import '../../widgets/postal/postal.dart';
import 'mailbox_providers.dart';
import '../time_letter/time_letter_list_tab.dart';
import '../time_letter/time_letter_providers.dart';
import '../relation/relation_display_label.dart';
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
          const PostalPerforationStrip(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
            child: Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () => context.push(MyPenpalsPage.path),
                  child: Text(l10n.mailboxMyPenpals),
                ),
                TextButton(
                  onPressed: () => context.push('/mailbox/archive'),
                  child: Text(l10n.mailboxOpenArchive),
                ),
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
        ? letters
              .where(
                (l) =>
                    l.status == LetterStatus.delivering ||
                    l.status == LetterStatus.pending ||
                    l.status == LetterStatus.matched,
              )
              .toList()
        : const <MailboxLetter>[];
    return Column(
      children: [
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
    // MATCHED 单独展示；pending/delivering 仍用在途芯片。
    final statusChip = switch (letter.status) {
      LetterStatus.matched => PostalStatusChip.delivering(
        label: l10n.letterStatusMatched,
      ),
      LetterStatus.pending ||
      LetterStatus.delivering => PostalStatusChip.delivering(),
      LetterStatus.registered => PostalStatusChip.registered(
        label: 'Registered',
      ),
      LetterStatus.delivered =>
        letter.type == LetterType.registered
            ? PostalStatusChip.registered(label: 'Registered')
            : PostalStatusChip.delivered(),
    };
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
          Text(
            DateFormat('MM-dd HH:mm').format(letter.sentAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
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
