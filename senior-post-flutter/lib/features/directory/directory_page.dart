import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../core/mock/mock_models.dart';
import '../../widgets/postal/postal.dart';
import 'directory_filter_sheet.dart';
import 'directory_remote.dart';

final directoryFilterProvider =
    StateProvider<DirectoryFilter>((ref) => const DirectoryFilter());

/// 名录列表仅走 `/api/directory/users/paging`（排序与筛选由服务端计算）。
final directoryUsersProvider = FutureProvider<List<MockUser>>((ref) async {
  final filter = ref.watch(directoryFilterProvider);
  return ref.read(directoryRemoteProvider).pageUsers(
        page: 1,
        size: 60,
        countryCode: filter.countryCode,
        minAge: filter.minAge,
        maxAge: filter.maxAge,
        interestNames: filter.interests.toList(),
        sort: filter.sort,
      );
});

class DirectoryPage extends ConsumerStatefulWidget {
  const DirectoryPage({super.key});

  @override
  ConsumerState<DirectoryPage> createState() => _DirectoryPageState();
}

class _DirectoryPageState extends ConsumerState<DirectoryPage> {
  bool _refreshing = false;

  Future<void> _onRefresh() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      ref.invalidate(directoryUsersProvider);
      await ref.read(directoryUsersProvider.future);
    } finally {
      if (mounted) _refreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                Expanded(
                  child: PostalSectionTitle(
                    title: l10n.directoryTitle,
                    subtitle: l10n.directorySubtitle,
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
                title: l10n.directoryLoadFailed,
                subtitle: '$e',
                tone: PostalEmptyTone.error,
                actionLabel: l10n.commonRetry,
                onAction: () => ref.invalidate(directoryUsersProvider),
              ),
              data: (users) {
                if (users.isEmpty) {
                  return PostalEmptyState(
                    title: l10n.directoryEmptyTitle,
                    subtitle: l10n.directoryEmptySubtitle,
                  );
                }
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: users.length,
                    itemBuilder: (_, i) => _DirectoryCard(user: users[i]),
                  ),
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
          PostalAvatar(name: user.nickname, size: 54, imageUrl: user.avatarUrl),
          const SizedBox(height: 10),
          Text(
            user.nickname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          PostalCountrySeal(
            countryCode: user.countryCode,
            countryName: user.countryName,
            compact: true,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.directoryAgeYears('${user.age}'),
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
    this.sort = 'DEFAULT',
  });

  final String? countryCode;
  final int minAge;
  final int maxAge;
  final Set<String> interests;
  final String sort;

  DirectoryFilter copyWith({
    String? countryCode,
    int? minAge,
    int? maxAge,
    Set<String>? interests,
    String? sort,
  }) {
    return DirectoryFilter(
      countryCode: countryCode ?? this.countryCode,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      interests: interests ?? this.interests,
      sort: sort ?? this.sort,
    );
  }
}
