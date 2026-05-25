import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/models/domain_models.dart';
import '../../widgets/postal/postal.dart';
import '../../widgets/postal/postal_gender_icon.dart';

/// 资料页等场景的紧凑明信片行。
class PostWallCompactTile extends StatelessWidget {
  const PostWallCompactTile({super.key, required this.post});

  final WallPost post;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final urls = post.resolvedImageUrls;
    final preview = post.content.trim();
    final excerpt = preview.length > 120 ? '${preview.substring(0, 120)}…' : preview;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/post/${post.id}'),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PostalTokens.perforationLine.withValues(alpha: 0.85)),
            color: PostalTokens.paperEnvelope,
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  PostalAvatar(
                    name: post.author.nickname,
                    size: 36,
                    imageUrl: post.author.avatarUrl,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                post.author.nickname,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: PostalTokens.inkNavy,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (post.author.gender >= 1) ...[
                              const SizedBox(width: 4),
                              PostalGenderIcon(gender: post.author.gender, size: 14),
                            ],
                          ],
                        ),
                        Text(
                          DateFormat.yMMMd().format(post.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: PostalTokens.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (excerpt.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  excerpt,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                    color: PostalTokens.inkNavy,
                  ),
                ),
              ],
              if (urls.isNotEmpty) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: PostalOssNetworkImage(
                      imageUrl: urls.first,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                l10n.postWallCommentsCount('${post.commentCount}'),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: PostalTokens.postboxGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
