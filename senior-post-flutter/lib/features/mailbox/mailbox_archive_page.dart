import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../core/models/letter_peer_label.dart';
import '../../widgets/postal/postal.dart';
import 'mailbox_providers.dart';

class MailboxArchivePage extends ConsumerWidget {
  const MailboxArchivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(mailboxArchiveProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.mailboxArchiveTitle)),
      body: async.when(
        loading: () => const PostalSkeletonList(itemCount: 6, itemHeight: 96),
        error: (e, _) => PostalEmptyState(
          title: 'Unable to load archive',
          subtitle: '$e',
          tone: PostalEmptyTone.error,
          actionLabel: l10n.commonRetry,
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
                      name: letterPeerDisplayTitle(l10n: l10n, peer: l.peer),
                      size: 36,
                      imageUrl: isUnresolvedLetterPeer(l.peer)
                          ? null
                          : l.peer.avatarUrl,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        letterPeerDisplayTitle(l10n: l10n, peer: l.peer),
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
