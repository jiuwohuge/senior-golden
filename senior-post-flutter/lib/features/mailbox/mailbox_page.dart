import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/env/app_env.dart';
import '../../core/mock/mock_models.dart';
import '../../widgets/postal/postal.dart';
import 'mailbox_providers.dart';
import 'mailbox_remote.dart';

class MailboxPage extends ConsumerStatefulWidget {
  const MailboxPage({super.key});

  @override
  ConsumerState<MailboxPage> createState() => _MailboxPageState();
}

class _MailboxPageState extends ConsumerState<MailboxPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stampHeader = ref.watch(mailboxStampHeaderProvider);
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
                stampHeader.when(
                  data: (s) => PostalStampBadge(
                    balance: s.balance,
                    cap: s.cap,
                    isVip: s.isVip,
                  ),
                  loading: () => const PostalStampBadge(
                    balance: 0,
                    cap: 3,
                    isVip: false,
                  ),
                  error: (_, __) => const PostalStampBadge(
                    balance: 0,
                    cap: 3,
                    isVip: false,
                  ),
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
                  data: (letters) => _PostalInboxBody(letters: letters),
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
  const _PostalInboxBody({required this.letters});
  final List<MockLetter> letters;

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
          child: letters.isEmpty
              ? const PostalEmptyState(
                  title: 'Postal inbox is clear',
                  subtitle:
                      'No pending letters. Connections appear after you accept a delivered letter.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: letters.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _LetterTile(letter: letters[i]),
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
    if (AppEnv.useMock) {
      final async = ref.watch(mockConnectionsProvider);
      return async.when(
        loading: () => const PostalSkeletonList(itemCount: 4, itemHeight: 72),
        error: (e, _) => PostalEmptyState(
          title: 'Unable to load connections',
          subtitle: '$e',
          tone: PostalEmptyTone.error,
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(mockConnectionsProvider),
        ),
        data: (rows) {
          if (rows.isEmpty) {
            return PostalEmptyState(
              title: 'No connections yet',
              subtitle:
                  'When you accept a delivered letter from someone, they appear here for instant chat.',
              actionLabel: 'Refresh',
              onAction: () => ref.invalidate(mockConnectionsProvider),
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
                onTap: () => context.push('/chat/${r.peer.id}'),
              );
            },
          );
        },
      );
    }

    final timAsync = ref.watch(timConversationsProvider);
    return timAsync.when(
      loading: () => const PostalSkeletonList(itemCount: 4, itemHeight: 72),
      error: (e, _) => PostalEmptyState(
        title: 'IM unavailable',
        subtitle:
            '$e\nConfigure senior-post.tencent-im and ensure you are logged in.',
        tone: PostalEmptyTone.calm,
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(timConversationsProvider),
      ),
      data: (convs) {
        if (convs.isEmpty) {
          return PostalEmptyState(
            title: 'No conversations',
            subtitle:
                'Start from Postal inbox: accept a delivered letter first.',
            actionLabel: 'Refresh',
            onAction: () => ref.invalidate(timConversationsProvider),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          itemCount: convs.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final c = convs[i];
            return _TimConversationTile(conversation: c);
          },
        );
      },
    );
  }
}

class _TimConversationTile extends StatelessWidget {
  const _TimConversationTile({required this.conversation});
  final V2TimConversation conversation;

  @override
  Widget build(BuildContext context) {
    final uid = conversation.userID ?? '';
    final title =
        (conversation.showName != null && conversation.showName!.isNotEmpty)
        ? conversation.showName!
        : uid;
    final last = conversation.lastMessage;
    String subtitle = '';
    if (last != null && last.textElem != null) {
      subtitle = last.textElem!.text ?? '';
    }
    final ts = last?.timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch((last!.timestamp!) * 1000)
        : DateTime.now();
    return _ImStyleRow(
      title: title,
      subtitle: subtitle.isEmpty ? '—' : subtitle,
      time: ts,
      onTap: () => context.push('/chat/$uid'),
    );
  }
}

class _ImStyleRow extends StatelessWidget {
  const _ImStyleRow({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final DateTime time;
  final VoidCallback onTap;

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
            PostalAvatar(name: title, size: 44),
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

class _LetterTile extends StatelessWidget {
  const _LetterTile({required this.letter});
  final MockLetter letter;

  @override
  Widget build(BuildContext context) {
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
      onTap: () => context.push('/letter/${letter.id}'),
      header: Row(
        children: [
          PostalAvatar(name: letter.peer.nickname, size: 40),
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
          Text(letter.preview, maxLines: 2, overflow: TextOverflow.ellipsis),
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
