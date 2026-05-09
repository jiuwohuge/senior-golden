import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';
import '../../app/theme/postal_tokens.dart';
import '../../core/models/domain_models.dart';
import '../../core/session/app_session.dart';
import '../auth/auth_repository.dart';
import '../../widgets/postal/postal.dart';
import 'mailbox_providers.dart';

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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.invalidate(postalInboxLettersProvider);
        ref.invalidate(mailboxArchiveProvider);
        ref.invalidate(mailboxLettersProvider);
        ref.invalidate(mailboxFriendsProvider);
        ref.read(authRepositoryProvider).refreshSessionFromServer();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    final lettersAsync = ref.watch(postalInboxLettersProvider);
    return SafeArea(
      top: false,
      child: Column(
        children: [
          const PostalPerforationStrip(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
            child: Row(
              children: [
                PostalStampBadge(
                  balance: session.stampBalance,
                  cap: session.dailyStampCap,
                  isVip: session.isVip,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/mailbox/archive'),
                  child: const Text('Archive'),
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
              tabs: const [
                Tab(text: 'Postal inbox'),
                Tab(text: 'Connections'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                lettersAsync.when(
                  loading: () =>
                      const PostalSkeletonList(itemCount: 5, itemHeight: 120),
                  error: (e, _) => PostalEmptyState(
                    title: 'Unable to load mailbox',
                    subtitle: '$e',
                    tone: PostalEmptyTone.error,
                    actionLabel: 'Retry',
                    onAction: () => ref.invalidate(postalInboxLettersProvider),
                  ),
                  data: (letters) => _PostalInboxBody(
                    letters: letters,
                    onSyncMailbox: () async {
                      ref.invalidate(postalInboxLettersProvider);
                      ref.invalidate(mailboxArchiveProvider);
                      ref.invalidate(mailboxLettersProvider);
                      ref.invalidate(mailboxFriendsProvider);
                      await ref.read(postalInboxLettersProvider.future);
                    },
                  ),
                ),
                const _ConnectionsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostalInboxBody extends ConsumerWidget {
  const _PostalInboxBody({required this.letters, required this.onSyncMailbox});

  final List<MailboxLetter> letters;
  final Future<void> Function() onSyncMailbox;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delivering = letters
        .where((l) => l.status == LetterStatus.delivering)
        .toList();
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
            child: const Row(
              children: [
                Icon(Icons.local_shipping_outlined),
                SizedBox(width: 8),
                Expanded(child: Text('A post is on the way')),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onSyncMailbox,
            child: letters.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    children: const [
                      SizedBox(
                        height: 280,
                        child: PostalEmptyState(
                          title: 'Postal inbox is clear',
                          subtitle:
                              'No letters need attention here. In-transit and unread items appear in this inbox.',
                        ),
                      ),
                    ],
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

class _ConnectionsTab extends ConsumerWidget {
  const _ConnectionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mailboxFriendsProvider);
    return async.when(
      loading: () => const PostalSkeletonList(itemCount: 4, itemHeight: 72),
      error: (e, _) => PostalEmptyState(
        title: 'Unable to load friends',
        subtitle: '$e',
        tone: PostalEmptyTone.error,
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(mailboxFriendsProvider),
      ),
      data: (rows) {
        if (rows.isEmpty) {
          return PostalEmptyState(
            title: 'No postal friends yet',
            subtitle:
                'Accept a delivered letter to add someone here. This list is your friend list (not recent chats).',
            actionLabel: 'Refresh',
            onAction: () => ref.invalidate(mailboxFriendsProvider),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          itemCount: rows.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final r = rows[i];
            return _ImStyleRow(
              title: r.peer.nickname,
              subtitle: r.lastMessage,
              time: r.lastTime,
              avatarUrl: r.peer.avatarUrl,
              onTap: () => context.push('/chat/${r.peer.id}'),
            );
          },
        );
      },
    );
  }
}

class _ImStyleRow extends StatelessWidget {
  const _ImStyleRow({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.onTap,
    this.avatarUrl,
  });

  final String title;
  final String subtitle;
  final DateTime time;
  final VoidCallback onTap;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostalAvatar(name: title, size: 44, imageUrl: avatarUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: PostalTokens.inkTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('MM-dd').format(time),
              style: theme.textTheme.labelSmall?.copyWith(
                color: PostalTokens.inkTertiary,
              ),
            ),
          ],
        ),
      ),
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
      LetterStatus.delivering => PostalStatusChip.delivering(),
      LetterStatus.registered => PostalStatusChip.registered(
        label: 'Registered',
      ),
      LetterStatus.delivered =>
        letter.type == LetterType.registered
            ? PostalStatusChip.registered(label: 'Registered')
            : PostalStatusChip.delivered(),
    };
    return PostalCardEnvelope(
      onTap: () {
        ref.invalidate(letterDetailProvider(letter.id));
        context.push('/letter/${letter.id}');
      },
      header: Row(
        children: [
          PostalAvatar(
            name: letter.peer.nickname,
            size: 40,
            imageUrl: letter.peer.avatarUrl,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              letter.peer.nickname,
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
