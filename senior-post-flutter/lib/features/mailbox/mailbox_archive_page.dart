import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../widgets/postal/postal.dart';
import 'mailbox_providers.dart';

class MailboxArchivePage extends ConsumerWidget {
  const MailboxArchivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mailboxArchiveProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Letter archive')),
      body: async.when(
        loading: () => const PostalSkeletonList(itemCount: 6, itemHeight: 96),
        error: (e, _) => PostalEmptyState(
          title: 'Unable to load archive',
          subtitle: '$e',
          tone: PostalEmptyTone.error,
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(mailboxArchiveProvider),
        ),
        data: (letters) {
          if (letters.isEmpty) {
            return const PostalEmptyState(
              title: 'No letters yet',
              subtitle: 'Sent and received letters will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: letters.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final l = letters[i];
              return PostalCardEnvelope(
                onTap: () => context.push('/letter/${l.id}'),
                header: Row(
                  children: [
                    PostalAvatar(
                    name: l.peer.nickname,
                    size: 36,
                    imageUrl: l.peer.avatarUrl,
                  ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.peer.nickname,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      l.outgoing ? 'Sent' : 'Received',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(l.sentAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
