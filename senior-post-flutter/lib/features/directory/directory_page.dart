import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/env/app_env.dart';
import '../../core/mock/mock_models.dart';
import '../../core/mock/mock_repository.dart';
import '../../widgets/postal/postal.dart';
import 'directory_filter_sheet.dart';
import 'directory_remote.dart';

final directoryFilterProvider =
    StateProvider<DirectoryFilter>((ref) => const DirectoryFilter());

final directoryUsersProvider = FutureProvider<List<MockUser>>((ref) async {
  final filter = ref.watch(directoryFilterProvider);
  if (AppEnv.useMock) {
    return ref.read(mockDirectoryRepositoryProvider).list(
          countryCode: filter.countryCode,
          minAge: filter.minAge,
          maxAge: filter.maxAge,
          interests: filter.interests,
        );
  }
  return ref.read(directoryRemoteProvider).pageUsers(
        page: 1,
        size: 60,
        countryCode: filter.countryCode,
        minAge: filter.minAge,
        maxAge: filter.maxAge,
        interestNames: filter.interests.toList(),
      );
});

class DirectoryPage extends ConsumerWidget {
  const DirectoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(directoryUsersProvider);
    return SafeArea(
      top: false,
      child: Column(
        children: [
          const PostalPerforationStrip(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                const Expanded(
                  child: PostalSectionTitle(
                    title: 'Post Directory',
                    subtitle: 'Find pen pals by country and interests',
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const DirectoryFilterSheet(),
                    );
                  },
                  icon: const Icon(Icons.tune),
                ),
              ],
            ),
          ),
          Expanded(
            child: usersAsync.when(
              loading: () => const PostalSkeletonList(itemCount: 6, itemHeight: 160),
              error: (e, _) => PostalEmptyState(
                title: 'Unable to load directory',
                subtitle: '$e',
                tone: PostalEmptyTone.error,
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(directoryUsersProvider),
              ),
              data: (users) {
                if (users.isEmpty) {
                  return const PostalEmptyState(
                    title: 'No matching members',
                    subtitle: 'Try clearing filters or changing age range.',
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: users.length,
                  itemBuilder: (_, i) => _DirectoryCard(user: users[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectoryCard extends StatelessWidget {
  const _DirectoryCard({required this.user});
  final MockUser user;

  @override
  Widget build(BuildContext context) {
    return PostalCardEnvelope(
      onTap: () => context.push('/user/${user.id}'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PostalAvatar(name: user.nickname, size: 54),
          const SizedBox(height: 8),
          Text(
            user.nickname,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          PostalCountrySeal(
            countryCode: user.countryCode,
            countryName: user.countryName,
            compact: true,
          ),
          const SizedBox(height: 8),
          Text(
            '${user.age} years',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class DirectoryFilter {
  const DirectoryFilter({
    this.countryCode,
    this.minAge = 45,
    this.maxAge = 80,
    this.interests = const {},
  });

  final String? countryCode;
  final int minAge;
  final int maxAge;
  final Set<String> interests;

  DirectoryFilter copyWith({
    String? countryCode,
    int? minAge,
    int? maxAge,
    Set<String>? interests,
  }) {
    return DirectoryFilter(
      countryCode: countryCode ?? this.countryCode,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      interests: interests ?? this.interests,
    );
  }
}
