import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../core/api/api_exception.dart';
import '../../widgets/postal/postal.dart';
import '../social/social_remote.dart';

class BlacklistPage extends ConsumerWidget {
  const BlacklistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(blockedUsersListProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.socialBlacklistTitle)),
      body: SafeArea(
        child: async.when(
          loading: () => const PostalSkeletonList(itemCount: 4, itemHeight: 72),
          error: (e, _) => PostalEmptyState(
            title: l10n.userCardErrorTitle,
            subtitle: '$e',
            tone: PostalEmptyTone.error,
            actionLabel: l10n.commonRetry,
            onAction: () => ref.invalidate(blockedUsersListProvider),
          ),
          data: (rows) {
            if (rows.isEmpty) {
              return PostalEmptyState(
                title: l10n.socialBlacklistEmpty,
                subtitle: l10n.socialBlacklistSubtitle,
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(blockedUsersListProvider);
                await ref.read(blockedUsersListProvider.future);
              },
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                itemCount: rows.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final row = rows[i];
                  final timeLabel = row.blockedAt != null
                      ? MaterialLocalizations.of(
                          context,
                        ).formatFullDate(row.blockedAt!.toLocal())
                      : '—';
                  return PostalCardEnvelope(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: PostalAvatar(
                        name: row.peer.nickname,
                        size: 48,
                        imageUrl: row.peer.avatarUrl,
                      ),
                      title: Text(row.peer.nickname),
                      subtitle: Text(l10n.socialBlockedAt(timeLabel)),
                      trailing: TextButton(
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(l10n.socialUnblock),
                              content: Text(
                                l10n.socialUnblockConfirm(row.peer.nickname),
                              ),
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
                          if (ok != true || !context.mounted) return;
                          try {
                            await ref
                                .read(socialRemoteProvider)
                                .unblockUser(row.blockedUserId);
                            ref.invalidate(blockedUsersListProvider);
                            if (context.mounted) {
                              PostalSnack.show(
                                context,
                                l10n.socialUnblockSuccess,
                                tone: PostalSnackTone.success,
                              );
                            }
                          } on ApiBusinessException catch (e) {
                            if (context.mounted) {
                              PostalSnack.show(
                                context,
                                e.message,
                                tone: PostalSnackTone.error,
                              );
                            }
                          }
                        },
                        child: Text(l10n.socialUnblock),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
