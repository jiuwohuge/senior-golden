import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/mock/mock_models.dart';
import '../../core/mock/mock_repository.dart';
import '../../widgets/postal/postal.dart';
import 'send_letter_sheet.dart';

final directoryUserProvider = FutureProvider.family<MockUser?, String>((ref, userId) async {
  return ref.read(mockDirectoryRepositoryProvider).findById(userId);
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
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                PostalCardEnvelope(
                  child: Column(
                    children: [
                      PostalAvatar(name: user.nickname, size: 68),
                      const SizedBox(height: 10),
                      Text(user.nickname, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 6),
                      PostalCountrySeal(
                        countryCode: user.countryCode,
                        countryName: user.countryName,
                      ),
                      const SizedBox(height: 8),
                      Text('${user.age} years', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 12),
                      Text(user.bio, textAlign: TextAlign.center),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: user.interests
                            .map((t) => Chip(label: Text(t)))
                            .toList(),
                      ),
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
