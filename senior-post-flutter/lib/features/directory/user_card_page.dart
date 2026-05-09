import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../core/api/api_exception.dart';
import '../../core/models/domain_models.dart';
import '../../core/session/app_session.dart';
import '../../widgets/postal/postal.dart';
import '../social/social_remote.dart';
import 'directory_remote.dart';
import 'send_letter_sheet.dart';

final directoryUserProvider = FutureProvider.family<AppUser?, String>((
  ref,
  userId,
) async {
  return ref.read(directoryRemoteProvider).getDirectoryUser(userId);
});

class UserCardPage extends ConsumerWidget {
  const UserCardPage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(directoryUserProvider(userId));
    final session = ref.watch(appSessionProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.userCardTitle)),
      body: SafeArea(
        child: async.when(
          loading: () =>
              const PostalSkeletonList(itemCount: 1, itemHeight: 240),
          error: (e, _) => PostalEmptyState(
            title: l10n.userCardErrorTitle,
            subtitle: '$e',
            tone: PostalEmptyTone.error,
          ),
          data: (user) {
            if (user == null) {
              return PostalEmptyState(
                title: l10n.userCardNotFoundTitle,
                subtitle: l10n.userCardNotFoundSubtitle,
              );
            }
            final theme = Theme.of(context);
            final isSelf =
                session.user.id.isNotEmpty && session.user.id == user.id;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                PostalCardEnvelope(
                  child: Column(
                    children: [
                      PostalAvatar(
                        name: user.nickname,
                        size: 72,
                        imageUrl: user.avatarUrl,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user.nickname,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      PostalCountrySeal(
                        countryCode: user.countryCode,
                        countryName: user.countryName,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.directoryAgeYears('${user.age}'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (user.bio.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          user.bio,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.45,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.88,
                            ),
                          ),
                        ),
                      ],
                      if (user.interests.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: user.interests
                              .map((t) => Chip(label: Text(t)))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (!isSelf)
                  PostalButton(
                    label: l10n.userCardSendLetter,
                    onPressed: () async {
                      await showPostalSendLetterSheet(
                        context,
                        peerId: user.id,
                        peerNickname: user.nickname,
                        countryLabel: user.countryName,
                      );
                    },
                  ),
                if (!isSelf) const SizedBox(height: 8),
                if (!isSelf)
                  PostalButton(
                    label: l10n.socialBlockUser,
                    variant: PostalButtonVariant.danger,
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.socialBlockConfirmTitle),
                          content: Text(l10n.socialBlockConfirmMessage),
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
                            .blockUser(blockedUserId: user.id);
                        ref.invalidate(directoryUserProvider(userId));
                        if (context.mounted) {
                          PostalSnack.show(
                            context,
                            l10n.socialBlockSuccess,
                            tone: PostalSnackTone.success,
                          );
                          context.pop();
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
                  ),
                if (!isSelf) const SizedBox(height: 8),
                PostalButton(
                  label: l10n.userCardBack,
                  variant: PostalButtonVariant.secondary,
                  onPressed: () => context.pop(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
