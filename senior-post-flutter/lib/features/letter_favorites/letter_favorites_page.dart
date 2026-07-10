import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../widgets/postal/postal.dart';
import '../mailbox/mailbox_remote.dart';

/// 收藏信件列表。
class LetterFavoritesPage extends ConsumerWidget {
  const LetterFavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(letterFavoritesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.letterFavoritesTitle)),
      body: SafeArea(
        child: async.when(
          loading: () => const PostalSkeletonList(itemCount: 4, itemHeight: 88),
          error: (e, _) => PostalEmptyState(
            title: l10n.commonLoadFailed,
            subtitle: '$e',
            tone: PostalEmptyTone.error,
            actionLabel: l10n.commonRetry,
            onAction: () => ref.invalidate(letterFavoritesProvider),
          ),
          data: (letters) {
            if (letters.isEmpty) {
              return PostalEmptyState(
                title: l10n.letterFavoritesEmptyTitle,
                subtitle: l10n.letterFavoritesEmptySubtitle,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: letters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final letter = letters[index];
                final peer = letter.peer.nickname;
                return PostalCardEnvelope(
                  onTap: () => context.push('/letter/${letter.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              peer,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          Icon(
                            Icons.star_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        letter.preview.isNotEmpty
                            ? letter.preview
                            : letter.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat.yMMMd().format(letter.sentAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
