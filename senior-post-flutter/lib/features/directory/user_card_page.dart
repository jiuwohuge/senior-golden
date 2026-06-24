import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/models/domain_models.dart';
import '../../core/session/app_session.dart';
import '../../widgets/postal/postal.dart';
import '../../widgets/postal/postal_gender_icon.dart';
import '../post_wall/post_wall_compact_tile.dart';
import '../post_wall/post_wall_remote.dart';
import '../social/social_remote.dart';
import '../compose/compose_intent.dart';
import 'directory_remote.dart';
import 'user_report_sheet.dart';

final directoryUserProvider = FutureProvider.family<AppUser?, String>((
  ref,
  userId,
) async {
  return ref.read(directoryRemoteProvider).getDirectoryUser(userId);
});

class UserCardPage extends ConsumerStatefulWidget {
  const UserCardPage({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<UserCardPage> createState() => _UserCardPageState();
}

class _UserCardPageState extends ConsumerState<UserCardPage> {
  final List<WallPost> _friendPosts = [];
  int _friendPage = 0;
  bool _friendLoading = false;
  bool _friendHasMore = true;
  bool _friendSectionInit = false;

  String get userId => widget.userId;

  Future<void> _loadFriendPostcards({required bool append}) async {
    if (_friendLoading) return;
    if (append && !_friendHasMore) return;
    setState(() => _friendLoading = true);
    try {
      final nextPage = append ? _friendPage + 1 : 1;
      final size = append ? 10 : 1;
      final batch = await ref
          .read(postWallRemoteProvider)
          .listUserPostcards(userId: userId, page: nextPage, size: size);
      if (!mounted) return;
      setState(() {
        if (append) {
          _friendPosts.addAll(batch);
        } else {
          _friendPosts
            ..clear()
            ..addAll(batch);
        }
        _friendPage = nextPage;
        _friendHasMore = batch.length >= size;
        _friendSectionInit = true;
      });
    } finally {
      if (mounted) setState(() => _friendLoading = false);
    }
  }

  bool _onScrollLoadMore(ScrollNotification n) {
    if (!_friendHasMore || _friendLoading) return false;
    if (n.metrics.extentAfter > 160) return false;
    if (n is ScrollEndNotification || n is ScrollUpdateNotification) {
      _loadFriendPostcards(append: true);
    }
    return false;
  }

  Future<void> _onBlockUser(BuildContext context, AppUser user) async {
    final l10n = AppLocalizations.of(context)!;
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
      await ref.read(socialRemoteProvider).blockUser(blockedUserId: user.id);
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
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    }
  }

  Future<void> _onReportUser(BuildContext context, AppUser user) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PostalTokens.paperEnvelope,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: PostalTokens.radiusXl),
      ),
      showDragHandle: true,
      builder: (_) => UserReportSheet(targetUserId: user.id),
    );
  }

  PreferredSizeWidget _appBar(
    BuildContext context,
    AppLocalizations l10n,
    bool showActions,
    AppUser user,
  ) {
    return AppBar(
      backgroundColor: PostalTokens.postboxGreen,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: PostalTokens.inkNavy.withValues(alpha: 0.2),
      iconTheme: const IconThemeData(color: Colors.white, size: 26),
      title: Text(
        l10n.userCardTitle,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      actions: [
        if (showActions)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            elevation: 8,
            color: PostalTokens.paperEnvelope,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: PostalTokens.perforationLine.withValues(alpha: 0.9),
              ),
            ),
            onSelected: (value) async {
              if (value == 'time_letter') {
                context.push(
                  '/compose',
                  extra: ComposeIntent(
                    kind: ComposeKind.penPalTimeLetter,
                    peerId: user.id,
                    peerNickname: user.nickname,
                  ),
                );
              } else if (value == 'block') {
                await _onBlockUser(context, user);
              } else if (value == 'report') {
                await _onReportUser(context, user);
              }
            },
            itemBuilder: (ctx) => [
              if (user.postalFriend)
                PopupMenuItem<String>(
                  value: 'time_letter',
                  child: Text(
                    l10n.timeLetterSendToFriend,
                    style: const TextStyle(
                      color: PostalTokens.inkNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              PopupMenuItem<String>(
                value: 'block',
                child: Text(
                  l10n.socialBlockUser,
                  style: TextStyle(
                    color: PostalTokens.inkNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'report',
                child: Text(
                  l10n.userCardReportUser,
                  style: TextStyle(
                    color: PostalTokens.inkNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(directoryUserProvider(userId));
    final session = ref.watch(appSessionProvider);
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final fabPad = 88.0;

    return async.when(
      loading: () => Scaffold(
        backgroundColor: PostalTokens.paperCream,
        appBar: AppBar(
          backgroundColor: PostalTokens.postboxGreen,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text(l10n.userCardTitle),
        ),
        body: const SafeArea(
          child: PostalSkeletonList(itemCount: 1, itemHeight: 240),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: PostalTokens.paperCream,
        appBar: AppBar(
          backgroundColor: PostalTokens.postboxGreen,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text(l10n.userCardTitle),
        ),
        body: SafeArea(
          child: PostalEmptyState(
            title: l10n.userCardErrorTitle,
            subtitle: '$e',
            tone: PostalEmptyTone.error,
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            backgroundColor: PostalTokens.paperCream,
            appBar: AppBar(
              backgroundColor: PostalTokens.postboxGreen,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              title: Text(l10n.userCardTitle),
            ),
            body: SafeArea(
              child: PostalEmptyState(
                title: l10n.userCardNotFoundTitle,
                subtitle: l10n.userCardNotFoundSubtitle,
              ),
            ),
          );
        }
        final theme = Theme.of(context);
        final isSelf = session.user.id.isNotEmpty && session.user.id == user.id;
        final showFab = !isSelf;
        final showFriendFeed = !isSelf && user.postalFriend;
        if (showFriendFeed && !_friendSectionInit && !_friendLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadFriendPostcards(append: false);
          });
        }

        return Scaffold(
          backgroundColor: PostalTokens.paperCream,
          appBar: _appBar(context, l10n, showFab, user),
          floatingActionButton: showFab
              ? FloatingActionButton.extended(
                  heroTag: 'user_card_send_letter',
                  elevation: 5,
                  highlightElevation: 10,
                  backgroundColor: PostalTokens.postboxGreen,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.mail_outline_rounded, size: 22),
                  label: Text(
                    l10n.userCardSendLetter,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.25,
                    ),
                  ),
                  onPressed: () {
                    context.push(
                      '/compose',
                      extra: ComposeIntent(
                        kind: ComposeKind.penPalMail,
                        peerId: user.id,
                        peerNickname: user.nickname,
                        peerCountryLabel: user.countryName,
                      ),
                    );
                  },
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: SafeArea(
            child: NotificationListener<ScrollNotification>(
              onNotification: showFriendFeed ? _onScrollLoadMore : null,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  24 + (showFab ? fabPad : 0) + bottomSafe,
                ),
                children: [
                  PostalCardEnvelope(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: PostalAvatar(
                            name: user.nickname,
                            size: 72,
                            imageUrl: user.avatarUrl,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                user.nickname,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                  height: 1.15,
                                  color: PostalTokens.inkNavy,
                                ),
                              ),
                            ),
                            if (user.gender >= 1) ...[
                              const SizedBox(width: 6),
                              PostalGenderIcon(gender: user.gender, size: 18),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: PostalCountrySeal(
                            countryCode: user.countryCode,
                            countryName: user.countryName,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.directoryAgeYears('${user.age}'),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          l10n.userCardBioSection,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: PostalTokens.postboxGreen,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.bio.trim().isEmpty
                              ? l10n.userCardBioEmpty
                              : user.bio,
                          textAlign: TextAlign.start,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                            color: user.bio.trim().isEmpty
                                ? PostalTokens.inkTertiary
                                : PostalTokens.inkNavy.withValues(alpha: 0.92),
                            fontStyle: user.bio.trim().isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                        if (user.interests.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: user.interests
                                .map(
                                  (t) => Chip(
                                    label: Text(t),
                                    backgroundColor: PostalTokens.paperCard
                                        .withValues(alpha: 0.95),
                                    side: BorderSide(
                                      color: PostalTokens.perforationLine,
                                    ),
                                    labelStyle: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: PostalTokens.inkNavy,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (showFriendFeed) ...[
                    const SizedBox(height: 22),
                    Divider(
                      height: 1,
                      color: PostalTokens.perforationLine.withValues(
                        alpha: 0.75,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PostalSectionTitle(
                      title: l10n.userCardFriendPostcardsTitle,
                      subtitle: l10n.userCardFriendPostcardsSubtitle,
                    ),
                    const SizedBox(height: 12),
                    if (_friendLoading && _friendPosts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_friendPosts.isEmpty && _friendSectionInit)
                      Text(
                        l10n.userCardFriendPostcardsEmpty,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: PostalTokens.inkSecondary,
                        ),
                      )
                    else ...[
                      for (final post in _friendPosts) ...[
                        PostWallCompactTile(post: post),
                        const SizedBox(height: 10),
                      ],
                      if (_friendHasMore)
                        Center(
                          child: TextButton(
                            onPressed: _friendLoading
                                ? null
                                : () => _loadFriendPostcards(append: true),
                            child: _friendLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(l10n.userCardLoadMorePostcards),
                          ),
                        ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
