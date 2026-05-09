import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/session/app_session.dart';
import '../../widgets/postal/postal.dart';
import 'post_providers.dart';
import 'post_wall_report_sheet.dart';
import 'post_wall_remote.dart';

void _showContentReport(
  BuildContext context, {
  required String targetType,
  required String objectId,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => PostWallReportSheet(targetType: targetType, objectId: objectId),
  );
}

class PostDetailPage extends ConsumerStatefulWidget {
  const PostDetailPage({super.key, required this.postId});
  final String postId;

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ref.invalidate(postDetailProvider(widget.postId));
        ref.invalidate(postCommentsProvider(widget.postId));
      });
    }
  }

  Future<void> _onRefresh() async {
    ref.invalidate(postDetailProvider(widget.postId));
    ref.invalidate(postCommentsProvider(widget.postId));
    await Future.wait([
      ref.read(postDetailProvider(widget.postId).future),
      ref.read(postCommentsProvider(widget.postId).future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final postId = widget.postId;
    final postAsync = ref.watch(postDetailProvider(postId));
    final commentsAsync = ref.watch(postCommentsProvider(postId));
    final l10n = AppLocalizations.of(context)!;

    final meId = ref.watch(appSessionProvider).user.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.postDetailTitle),
        actions: [
          if (postAsync.valueOrNull != null && meId != postAsync.valueOrNull!.author.id)
            IconButton(
              tooltip: 'Report',
              icon: const Icon(Icons.flag_outlined),
              onPressed: () => _showContentReport(
                context,
                targetType: 'postcard',
                objectId: postId,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: postAsync.when(
          loading: () => const PostalSkeletonList(itemCount: 1, itemHeight: 220),
          error: (e, _) => PostalEmptyState(
            title: 'Unable to load postcard',
            subtitle: '$e',
            tone: PostalEmptyTone.error,
          ),
          data: (post) {
            if (post == null) {
              return const PostalEmptyState(
                title: 'Postcard not found',
                subtitle: 'This postcard may have been removed.',
              );
            }
            final review = post.reviewStatus;
            final String? reviewLabel = review == null
                ? null
                : switch (review) {
                    0 => l10n.postcardReviewPendingBanner,
                    2 => l10n.postcardReviewRejectedBanner,
                    _ => null,
                  };
            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    children: [
                      if (reviewLabel != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: PostalTokens.stampVermilionMuted,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: PostalTokens.stampVermilion.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: PostalTokens.stampVermilion, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      reviewLabel,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      PostalCardEnvelope(
                        header: Row(
                          children: [
                            PostalAvatar(
                              name: post.author.nickname,
                              size: 42,
                              imageUrl: post.author.avatarUrl,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                post.author.nickname,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Text(DateFormat('MM-dd HH:mm').format(post.createdAt)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final u in post.resolvedImageUrls) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: PostalOssNetworkImage(
                                    imageUrl: u,
                                    fit: BoxFit.cover,
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
                      ),
                      const SizedBox(height: 16),
                      PostalSectionTitle(title: 'Comments'),
                      const SizedBox(height: 10),
                      commentsAsync.when(
                        loading: () => const PostalSkeletonList(
                          itemCount: 3,
                          itemHeight: 86,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                        ),
                        error: (e, _) => PostalEmptyState(
                          title: 'Failed to load comments',
                          subtitle: '$e',
                          tone: PostalEmptyTone.error,
                        ),
                        data: (items) {
                          if (items.isEmpty) {
                            return const PostalEmptyState(
                              title: 'No comments yet',
                              subtitle: 'Start the first kind reply.',
                            );
                          }
                          return Column(
                            children: items
                                .map(
                                  (c) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: PostalCardEnvelope(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              PostalAvatar(
                                                name: c.author.nickname,
                                                size: 34,
                                                imageUrl: c.author.avatarUrl,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(child: Text(c.author.nickname)),
                                              Text(DateFormat('MM-dd HH:mm').format(c.createdAt)),
                                              if (meId != c.author.id)
                                                IconButton(
                                                  tooltip: 'Report comment',
                                                  icon: const Icon(Icons.flag_outlined, size: 20),
                                                  onPressed: () => _showContentReport(
                                                    context,
                                                    targetType: 'comment',
                                                    objectId: c.id,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(c.content),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
                _CommentComposer(postId: postId),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CommentComposer extends ConsumerStatefulWidget {
  const _CommentComposer({required this.postId});
  final String postId;

  @override
  ConsumerState<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends ConsumerState<_CommentComposer> {
  final _commentCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) {
      PostalSnack.show(context, 'Please enter a comment.', tone: PostalSnackTone.warning);
      return;
    }
    setState(() => _sending = true);
    try {
      await ref.read(postWallRemoteProvider).createComment(
            postcardId: widget.postId,
            content: text,
          );
      if (!mounted) return;
      _commentCtrl.clear();
      ref.invalidate(postCommentsProvider(widget.postId));
      ref.invalidate(postDetailProvider(widget.postId));
      PostalSnack.show(
        context,
        'Comment posted',
        tone: PostalSnackTone.success,
      );
    } on ApiBusinessException catch (e) {
      if (mounted) PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: PostalTextField(
              controller: _commentCtrl,
              label: 'Write a comment',
              showClearButton: true,
            ),
          ),
          const SizedBox(width: 8),
          // PostalButton expand needs bounded width inside Row.
          SizedBox(
            width: 96,
            child: PostalButton(
              label: 'Send',
              onPressed: _sending ? null : _send,
              busy: _sending,
              expand: true,
              minHeight: 52,
            ),
          ),
        ],
      ),
    );
  }
}
