import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/mock/mock_models.dart';
import '../../widgets/postal/postal.dart';
import '../directory/send_letter_sheet.dart';
import 'post_providers.dart';

class PostWallPage extends ConsumerWidget {
  const PostWallPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postWallListProvider);
    return SafeArea(
      top: false,
      child: Column(
        children: [
          const PostalPerforationStrip(),
          Expanded(
            child: postsAsync.when(
              loading: () => const PostalSkeletonList(),
              error: (error, _) => PostalEmptyState(
                title: 'Post wall is temporarily unavailable',
                subtitle: '$error',
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(postWallListProvider),
                tone: PostalEmptyTone.error,
              ),
              data: (posts) {
                if (posts.isEmpty) {
                  return PostalEmptyState(
                    title: 'No postcards yet',
                    subtitle: 'Be the first to share a postcard today.',
                    actionLabel: 'Write postcard',
                    onAction: () => context.push('/post/new'),
                  );
                }
                return Stack(
                  children: [
                    ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
                      itemCount: posts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _PostCard(post: posts[i]),
                    ),
                    Positioned(
                      right: 20,
                      bottom: 18,
                      child: FloatingActionButton.extended(
                        onPressed: () => context.push('/post/new'),
                        icon: const Icon(Icons.edit_note),
                        label: const Text('Write'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});
  final MockPost post;

  @override
  Widget build(BuildContext context) {
    final dt = DateFormat('MM-dd HH:mm').format(post.createdAt);
    return PostalCardEnvelope(
      onTap: () => context.push('/post/${post.id}'),
      header: Row(
        children: [
          PostalAvatar(name: post.author.nickname, size: 44),
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
          PostalStatusChip.draft(label: 'Comments ${post.commentCount}'),
          const Spacer(),
          IconButton(
            onPressed: () => context.push('/post/${post.id}'),
            icon: const Icon(Icons.mode_comment_outlined),
            color: PostalTokens.postboxGreen,
          ),
          IconButton(
            tooltip: 'Send letter',
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (ctx) => SendLetterSheet(
                  peerId: post.author.id,
                  peerNickname: post.author.nickname,
                  countryLabel: post.author.countryName.isNotEmpty
                      ? post.author.countryName
                      : post.author.countryCode,
                ),
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
                    Image.network(
                      post.resolvedImageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: Color(0xFFE8E4DC),
                        child: Icon(Icons.broken_image_outlined),
                      ),
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
                              '${post.resolvedImageUrls.length} photos',
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
