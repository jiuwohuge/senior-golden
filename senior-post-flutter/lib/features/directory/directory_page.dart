import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../core/models/domain_models.dart';
import '../../widgets/postal/postal.dart';
import '../../widgets/postal/postal_gender_icon.dart';
import 'directory_filter_sheet.dart';
import 'directory_providers.dart';

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
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          children: [
                            SizedBox(
                              height: constraints.maxHeight,
                              child: PostalEmptyState(
                                title: l10n.directoryEmptyTitle,
                                subtitle: l10n.directoryEmptySubtitle,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return PostalCardEnvelope(
      onTap: () => context.push('/user/${user.id}'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PostalAvatar(name: user.nickname, size: 54, imageUrl: user.avatarUrl),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  user.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              if (user.gender >= 1) ...[
                const SizedBox(width: 4),
                PostalGenderIcon(gender: user.gender, size: 14),
              ],
            ],
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
