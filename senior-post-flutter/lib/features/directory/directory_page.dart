import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/models/domain_models.dart';
import '../../core/session/app_session.dart';
import '../../widgets/postal/postal.dart';
import '../../widgets/postal/postal_gender_icon.dart';
import '../compose/compose_intent.dart';
import 'directory_filter_sheet.dart';
import 'directory_providers.dart';

class DirectoryPage extends ConsumerStatefulWidget {
  const DirectoryPage({super.key});

  @override
  ConsumerState<DirectoryPage> createState() => _DirectoryPageState();
}

class _DirectoryPageState extends ConsumerState<DirectoryPage>
    with SingleTickerProviderStateMixin {
  bool _refreshing = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh(int tab) async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      switch (tab) {
        case 0:
          ref.invalidate(dailyRecommendationsProvider);
          await ref.read(dailyRecommendationsProvider.future);
        case 1:
          ref.invalidate(directoryUsersProvider);
          await ref.read(directoryUsersProvider.future);
        case 2:
          ref.invalidate(myPenpalsProvider);
          await ref.read(myPenpalsProvider.future);
      }
    } finally {
      if (mounted) _refreshing = false;
    }
  }

  Future<void> _openFilter() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const DirectoryFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Column(
        children: [
          const PostalPerforationStrip(),
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: PostalTokens.postboxGreen,
              unselectedLabelColor: PostalTokens.inkTertiary,
              indicatorColor: PostalTokens.postboxGreen,
              tabs: [
                Tab(text: l10n.directoryTabRecommend),
                Tab(text: l10n.directoryTabFind),
                Tab(text: l10n.directoryTabMyPenpals),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _RecommendTab(onRefresh: () => _onRefresh(0)),
                _FindTab(onFilter: _openFilter, onRefresh: () => _onRefresh(1)),
                _MyPenpalsTab(onRefresh: () => _onRefresh(2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendTab extends ConsumerWidget {
  const _RecommendTab({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(dailyRecommendationsProvider);
    final selfId = ref.watch(appSessionProvider).user.id;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: async.when(
        loading: () => const PostalSkeletonList(itemCount: 3, itemHeight: 176),
        error: (e, _) => ListView(
          children: [
            PostalEmptyState(
              title: l10n.directoryLoadFailed,
              subtitle: '$e',
              tone: PostalEmptyTone.error,
            ),
          ],
        ),
        data: (users) {
          // 客户端兜底：过滤掉当前登录用户自己。
          final filtered = selfId.isEmpty
              ? users
              : users.where((u) => u.id != selfId).toList();
          if (filtered.isEmpty) {
            return ListView(
              children: [
                PostalEmptyState(
                  title: l10n.directoryRecommendEmpty,
                  subtitle: l10n.directoryRecommendEmptyHint,
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              for (final user in filtered) ...[
                _PenPalCard(user: user, showRecommendReason: true),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _FindTab extends ConsumerWidget {
  const _FindTab({required this.onFilter, required this.onRefresh});

  final VoidCallback onFilter;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final usersAsync = ref.watch(directoryUsersProvider);
    final selfId = ref.watch(appSessionProvider).user.id;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          _DirectoryIntroCard(onFilter: onFilter),
          const SizedBox(height: 12),
          usersAsync.when(
            loading: () => const PostalSkeletonList(
              itemCount: 4,
              itemHeight: 176,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
            ),
            error: (e, _) => PostalEmptyState(
              title: l10n.directoryLoadFailed,
              subtitle: '$e',
              tone: PostalEmptyTone.error,
            ),
            data: (users) {
              final filtered = selfId.isEmpty
                  ? users
                  : users.where((u) => u.id != selfId).toList();
              if (filtered.isEmpty) {
                return PostalEmptyState(
                  title: l10n.directoryEmptyTitle,
                  subtitle: l10n.directoryEmptySubtitle,
                );
              }
              return Column(
                children: [
                  for (final user in filtered.take(30)) ...[
                    _PenPalCard(user: user),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MyPenpalsTab extends ConsumerWidget {
  const _MyPenpalsTab({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(myPenpalsProvider);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: async.when(
        loading: () => const PostalSkeletonList(itemCount: 4, itemHeight: 88),
        error: (e, _) => ListView(
          children: [
            PostalEmptyState(title: l10n.directoryLoadFailed, subtitle: '$e'),
          ],
        ),
        data: (rows) {
          if (rows.isEmpty) {
            return ListView(
              children: [
                PostalEmptyState(
                  title: l10n.directoryPenpalsEmpty,
                  subtitle: l10n.directoryPenpalsEmptyHint,
                ),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            itemCount: rows.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _MyPenpalRow(item: rows[i]),
          );
        },
      ),
    );
  }
}

class _MyPenpalRow extends StatelessWidget {
  const _MyPenpalRow({required this.item});

  final PenpalListItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PostalCardEnvelope(
      child: Row(
        children: [
          PostalAvatar(name: item.nickname, imageUrl: item.avatarUrl, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nickname,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(l10n.penpalListMeta(item.penpalDays, item.letterCount)),
              ],
            ),
          ),
          PostalButton(
            label: l10n.directoryWriteLetter,
            variant: PostalButtonVariant.secondary,
            onPressed: () => context.push(
              '/compose',
              extra: ComposeIntent(
                kind: ComposeKind.penPalMail,
                peerId: item.peerUserId,
                peerNickname: item.nickname,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectoryIntroCard extends StatelessWidget {
  const _DirectoryIntroCard({required this.onFilter});

  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return PostalCardEnvelope(
      accent: PostalTokens.postboxGreen,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: PostalTokens.postboxGreen.withValues(alpha: 0.1),
                  borderRadius: PostalTokens.shapeSm,
                  border: Border.all(
                    color: PostalTokens.postboxGreen.withValues(alpha: 0.22),
                  ),
                ),
                child: const Icon(
                  Icons.diversity_3_outlined,
                  color: PostalTokens.postboxGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.directoryTitle,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.directorySubtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: PostalTokens.inkSecondary,
                        height: 1.48,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PostalButton(
            label: l10n.directoryFilterCta,
            icon: Icons.tune,
            variant: PostalButtonVariant.secondary,
            onPressed: onFilter,
          ),
        ],
      ),
    );
  }
}

class _PenPalCard extends StatelessWidget {
  const _PenPalCard({required this.user, this.showRecommendReason = false});

  final AppUser user;
  final bool showRecommendReason;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bio = user.bio.trim().isEmpty ? l10n.directoryBioFallback : user.bio;
    final isPenpal =
        user.relationDisplayState == RelationDisplayState.penpal ||
        user.postalFriend;
    return PostalCardEnvelope(
      accent: isPenpal ? PostalTokens.postboxGreen : PostalTokens.stampGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostalAvatar(
                name: user.nickname,
                size: 58,
                imageUrl: user.avatarUrl,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.nickname,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (user.gender >= 1) ...[
                          const SizedBox(width: 5),
                          PostalGenderIcon(gender: user.gender, size: 15),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        PostalCountrySeal(
                          countryCode: user.countryCode,
                          countryName: user.countryName,
                          compact: true,
                        ),
                        _SoftChip(
                          icon: Icons.cake_outlined,
                          label: l10n.directoryAgeYears('${user.age}'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PostalStatusChip.draft(label: l10n.directoryLetterFirstBadge),
            ],
          ),
          const SizedBox(height: 14),
          if (showRecommendReason &&
              (user.recommendReason?.trim().isNotEmpty ?? false)) ...[
            Text(
              user.recommendReason!.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                color: PostalTokens.postboxGreen,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            bio,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: PostalTokens.inkSecondary,
              height: 1.48,
            ),
          ),
          const SizedBox(height: 12),
          _InterestWrap(user: user),
          const SizedBox(height: 14),
          PostalButton(
            label: l10n.directoryViewProfile,
            icon: Icons.badge_outlined,
            variant: PostalButtonVariant.ghost,
            onPressed: () => context.push('/user/${user.id}'),
          ),
          if (!isPenpal) ...[
            const SizedBox(height: 8),
            PostalButton(
              label: l10n.directoryWriteLetter,
              icon: Icons.mail_outline,
              onPressed: () => context.push(
                '/compose',
                extra: ComposeIntent(
                  kind: ComposeKind.penPalMail,
                  peerId: user.id,
                  peerNickname: user.nickname,
                  peerCountryLabel: user.countryName,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InterestWrap extends StatelessWidget {
  const _InterestWrap({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final interests = user.interests
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (interests.isEmpty) {
      return _SoftChip(
        icon: Icons.interests_outlined,
        label: l10n.directoryInterestEmpty,
      );
    }
    final visible = interests.take(3).toList();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final interest in visible)
          _SoftChip(icon: Icons.local_florist_outlined, label: interest),
        if (interests.length > visible.length)
          _SoftChip(
            icon: Icons.more_horiz,
            label: l10n.directoryMoreInterests(
              '${interests.length - visible.length}',
            ),
          ),
      ],
    );
  }
}

class _SoftChip extends StatelessWidget {
  const _SoftChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: PostalTokens.paperCard.withValues(alpha: 0.72),
        borderRadius: PostalTokens.shapeSm,
        border: Border.all(color: PostalTokens.perforationLine),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: PostalTokens.kraftBrown),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: PostalTokens.inkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
