import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/mock/mock_models.dart';
import '../../widgets/postal/postal.dart';
import 'directory_remote.dart';
import 'send_letter_sheet.dart';

final directoryUserProvider = FutureProvider.family<MockUser?, String>((ref, userId) async {
  return ref.read(directoryRemoteProvider).getDirectoryUser(userId);
});

class UserCardPage extends ConsumerWidget {
  const UserCardPage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(directoryUserProvider(userId));
    return Scaffold(
      appBar: AppBar(title: const Text('Member profile')),
      body: SafeArea(
        child: async.when(
          loading: () => const PostalSkeletonList(itemCount: 1, itemHeight: 240),
          error: (e, _) => PostalEmptyState(
            title: 'Unable to load profile',
            subtitle: '$e',
            tone: PostalEmptyTone.error,
          ),
          data: (user) {
            if (user == null) {
              return const PostalEmptyState(
                title: 'Profile not found',
                subtitle: 'The member may no longer be available.',
              );
            }
            final theme = Theme.of(context);
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
                        '${user.age} years',
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
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.88),
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
                PostalButton(
                  label: 'Send letter',
                  onPressed: () async {
                    await showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => SendLetterSheet(
                        peerId: user.id,
                        peerNickname: user.nickname,
                        countryLabel: user.countryName,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                PostalButton(
                  label: 'Back',
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
