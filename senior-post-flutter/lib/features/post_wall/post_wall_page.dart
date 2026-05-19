import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/models/domain_models.dart';
import '../../widgets/postal/postal.dart';
import '../directory/send_letter_sheet.dart';
import 'post_providers.dart';

class PostWallPage extends ConsumerStatefulWidget {
  const PostWallPage({super.key});

  @override
  ConsumerState<PostWallPage> createState() => _PostWallPageState();
}

class _PostWallPageState extends ConsumerState<PostWallPage> {
  bool _refreshing = false;

  Future<void> _onRefresh() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      ref.invalidate(postWallListProvider);
      await ref.read(postWallListProvider.future);
    } finally {
      if (mounted) _refreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final postsAsync = ref.watch(postWallListProvider);
    return SafeArea(
      top: false,
      child: Stack(
        children: [
          Column(
            children: [
              const PostalPerforationStrip(),
              Expanded(
                child: postsAsync.when(
                  loading: () => const PostalSkeletonList(),
                  error: (error, _) => PostalEmptyState(
                    title: l10n.postWallUnavailable,
                    subtitle: '$error',
                    actionLabel: l10n.commonRetry,
                    onAction: () => ref.invalidate(postWallListProvider),
                    tone: PostalEmptyTone.error,
                  ),
                  data: (posts) {
                    if (posts.isEmpty) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
                              children: [
                                SizedBox(
                                  height: constraints.maxHeight,
                                  child: PostalEmptyState(
                                    title: l10n.postWallEmptyTitle,
                                    subtitle: l10n.postWallEmptySubtitle,
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
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
                        itemCount: posts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _PostCard(post: posts[i]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (postsAsync.hasValue)
            Positioned(
              right: 18,
              bottom: 16,
              child: _PostWallComposeFab(
                label: l10n.postWallFAB,
                onPressed: () => context.push('/post/new'),
              ),
            ),
        ],
      ),
    );
  }
}

class _PostWallComposeFab extends StatelessWidget {
  const _PostWallComposeFab({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [PostalTokens.postboxGreen, PostalTokens.postboxGreenMuted],
          ),
          boxShadow: [
            BoxShadow(
              color: PostalTokens.postboxGreen.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          heroTag: 'post-wall-compose-fab',
          onPressed: onPressed,
          icon: const Icon(Icons.edit_square, size: 19, color: Colors.white),
          label: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          elevation: 0,
          highlightElevation: 0,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});
  final WallPost post;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dt = DateFormat('MM-dd HH:mm').format(post.createdAt);
    return PostalCardEnvelope(
      onTap: () => context.push('/post/${post.id}'),
      header: Row(
        children: [
          PostalAvatar(
            name: post.author.nickname,
            size: 44,
            imageUrl: post.author.avatarUrl,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.author.nickname,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                PostalCountrySeal(
                  countryCode: post.author.countryCode,
                  countryName: post.author.countryName,
                  compact: true,
                ),
              ],
            ),
          ),
          Text(
            dt,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PostalTokens.inkSecondary,
                ),
          ),
        ],
      ),
      footer: Row(
        children: [
          PostalStatusChip.draft(
            label: l10n.postWallCommentsCount('${post.commentCount}'),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.push('/post/${post.id}'),
            icon: const Icon(Icons.mode_comment_outlined),
            color: PostalTokens.postboxGreen,
          ),
          IconButton(
            tooltip: l10n.postWallSendLetterTooltip,
            onPressed: () {
              showPostalSendLetterSheet(
                context,
                peerId: post.author.id,
                peerNickname: post.author.nickname,
                countryLabel: post.author.countryName.isNotEmpty
                    ? post.author.countryName
                    : post.author.countryCode,
              );
            },
            icon: const Icon(Icons.mail_outline),
            color: PostalTokens.stampVermilion,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (post.resolvedImageUrls.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PostalOssNetworkImage(
                      imageUrl: post.resolvedImageUrls.first,
                      fit: BoxFit.cover,
                    ),
                    if (post.resolvedImageUrls.length > 1)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(
                              l10n.postWallPhotosLabel('${post.resolvedImageUrls.length}'),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            post.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
          ),
        ],
      ),
    );
  }
}
