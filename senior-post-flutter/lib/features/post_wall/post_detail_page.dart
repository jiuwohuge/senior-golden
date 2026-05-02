import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/mock/mock_models.dart';
import '../../core/mock/mock_repository.dart';
import '../../widgets/postal/postal.dart';

final postDetailProvider = FutureProvider.family<MockPost?, String>((ref, id) async {
  return ref.read(mockPostsRepositoryProvider).findById(id);
});

final postCommentsProvider = FutureProvider.family<List<MockComment>, String>((ref, id) async {
  return ref.read(mockPostsRepositoryProvider).comments(id);
});

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.postId});
  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postDetailProvider(postId));
    final commentsAsync = ref.watch(postCommentsProvider(postId));

    return Scaffold(
      appBar: AppBar(title: const Text('Postcard')),
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
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    children: [
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
                        child: Text(
                          post.content,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PostalSectionTitle(title: 'Comments'),
                      const SizedBox(height: 10),
                      commentsAsync.when(
                        loading: () => const PostalSkeletonList(itemCount: 3, itemHeight: 86),
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
                const _CommentComposer(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CommentComposer extends StatefulWidget {
  const _CommentComposer();

  @override
  State<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<_CommentComposer> {
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
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
        children: [
          Expanded(
            child: PostalTextField(
              controller: _commentCtrl,
              label: 'Write a comment',
              showClearButton: true,
            ),
          ),
          const SizedBox(width: 8),
          PostalButton(
            label: 'Send',
            onPressed: () {
              PostalSnack.show(
                context,
                'Mock: comment submitted successfully',
                tone: PostalSnackTone.success,
              );
              _commentCtrl.clear();
            },
            expand: false,
            minHeight: 52,
          ),
        ],
      ),
    );
  }
}
