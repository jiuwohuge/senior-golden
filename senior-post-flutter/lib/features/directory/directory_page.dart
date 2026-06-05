import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
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
    final usersAsync = ref.watch(directoryUsersProvider);
    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            const PostalPerforationStrip(),
            const SizedBox(height: 14),
            _DirectoryIntroCard(onFilter: _openFilter),
            const SizedBox(height: 12),
            _DirectorySafetyCard(
              title: l10n.directorySafetyTitle,
              body: l10n.directorySafetyBody,
            ),
            const SizedBox(height: 16),
            PostalSectionTitle(
              title: l10n.directoryListTitle,
              subtitle: l10n.directoryListSubtitle,
              trailing: IconButton(
                tooltip: l10n.directoryFilterCta,
                onPressed: _openFilter,
                icon: const Icon(Icons.tune),
              ),
            ),
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
                actionLabel: l10n.commonRetry,
                onAction: () => ref.invalidate(directoryUsersProvider),
              ),
              data: (users) {
                if (users.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: PostalEmptyState(
                      title: l10n.directoryEmptyTitle,
                      subtitle: l10n.directoryEmptySubtitle,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final user in users.take(30)) ...[
                      _PenPalCard(user: user),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
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

class _DirectorySafetyCard extends StatelessWidget {
  const _DirectorySafetyCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PostalTokens.paperCard.withValues(alpha: 0.82),
        borderRadius: PostalTokens.shapeMd,
        border: Border.all(color: PostalTokens.perforationLine),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: PostalTokens.postboxGreen,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: PostalTokens.inkSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PenPalCard extends StatelessWidget {
  const _PenPalCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bio = user.bio.trim().isEmpty ? l10n.directoryBioFallback : user.bio;
    return PostalCardEnvelope(
      accent: user.postalFriend
          ? PostalTokens.postboxGreen
          : PostalTokens.stampGold,
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
