import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/mock/mock_models.dart';
import '../../core/mock/mock_repository.dart';
import '../../widgets/postal/postal.dart';

final mailboxLettersProvider = FutureProvider<List<MockLetter>>((ref) async {
  return ref.read(mockMailboxRepositoryProvider).list();
});

class MailboxPage extends ConsumerWidget {
  const MailboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(mockSessionProvider);
    final lettersAsync = ref.watch(mailboxLettersProvider);
    return SafeArea(
      top: false,
      child: Column(
        children: [
          const PostalPerforationStrip(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
            child: Row(
              children: [
                PostalStampBadge(
                  balance: session.stampBalance,
                  cap: session.dailyStampCap,
                  isVip: session.isVip,
                ),
              ],
            ),
          ),
          Expanded(
            child: lettersAsync.when(
              loading: () => const PostalSkeletonList(itemCount: 5, itemHeight: 120),
              error: (e, _) => PostalEmptyState(
                title: 'Unable to load mailbox',
                subtitle: '$e',
                tone: PostalEmptyTone.error,
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(mailboxLettersProvider),
              ),
              data: (letters) {
                final delivering = letters.where((l) => l.status == LetterStatus.delivering).toList();
                return Column(
                  children: [
                    if (delivering.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_shipping_outlined),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('A post is on the way'),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: letters.isEmpty
                          ? const PostalEmptyState(
                              title: 'Mailbox is empty',
                              subtitle: 'Letters will appear here after delivery.',
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
              },
            ),
          ),
        ],
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
      LetterStatus.delivered => letter.type == LetterType.registered
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
