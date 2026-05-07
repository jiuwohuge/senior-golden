import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/env/app_env.dart';
import '../../core/mock/mock_repository.dart';
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

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.postId});
  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postDetailProvider(postId));
    final commentsAsync = ref.watch(postCommentsProvider(postId));

    final meId = ref.watch(mockSessionProvider).user.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Postcard'),
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
            final reviewLabel = review == null
                ? null
                : switch (review) {
                    0 => '审核中：仅自己可见，通过后将上墙',
                    2 => '未通过审核',
                    _ => null,
                  };
            return Column(
              children: [
                Expanded(
                  child: ListView(
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
                            PostalAvatar(name: post.author.nickname, size: 42),
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
                                  child: Image.network(
                                    u,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const ColoredBox(
                                      color: Color(0xFFE8E4DC),
                                      child: Icon(Icons.broken_image_outlined),
                                    ),
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
                                              PostalAvatar(name: c.author.nickname, size: 34),
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
      if (AppEnv.useMock) {
        PostalSnack.show(
          context,
          'Mock: comment submitted successfully',
          tone: PostalSnackTone.success,
        );
        _commentCtrl.clear();
        return;
      }
      await ref.read(postWallRemoteProvider).createComment(
            postcardId: widget.postId,
            content: text,
          );
      if (!mounted) return;
      _commentCtrl.clear();
      ref.invalidate(postCommentsProvider(widget.postId));
      PostalSnack.show(
        context,
        '已提交审核',
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
          // Row 对非 flex 子项会先给 maxWidth=∞；expand 的 PostalButton 内部为 width:infinity，
          // 必须外包有界宽度，否则会触发 infinite width / LayoutBuilder 断言级联。
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
