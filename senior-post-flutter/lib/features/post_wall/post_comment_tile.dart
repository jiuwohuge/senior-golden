import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/models/domain_models.dart';
import '../../widgets/postal/postal.dart';
import '../../widgets/postal/postal_gender_icon.dart';

typedef CommentAction = void Function(WallComment comment);

/// 点赞数紧凑展示（中文万/亿，英文 K/M），供固定宽度槽位使用。
String formatCommentLikeCount(int count, {required bool chineseLocale}) {
  if (count <= 0) return '';
  if (chineseLocale) {
    if (count < 10_000) return '$count';
    if (count < 100_000_000) {
      return '${_compactDecimal(count / 10_000)}万';
    }
    return '${_compactDecimal(count / 100_000_000)}亿';
  }
  if (count < 1_000) return '$count';
  if (count < 1_000_000) {
    return '${_compactDecimal(count / 1_000)}K';
  }
  return '${_compactDecimal(count / 1_000_000)}M';
}

String _compactDecimal(double value) {
  if (value >= 100) return value.floor().toString();
  final fixed = value.toStringAsFixed(1);
  return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
}

/// 右侧点赞列固定宽度，避免点赞后挤压正文。
const double _kCommentLikeColumnWidth = 48;

/// 评论区：信纸边注式排版，点击正文回复，右侧固定列点赞。
class PostCommentThread extends StatelessWidget {
  const PostCommentThread({
    super.key,
    required this.comments,
    required this.meId,
    required this.onReply,
    required this.onLike,
    required this.onReport,
  });

  final List<WallComment> comments;
  final String meId;
  final CommentAction onReply;
  final CommentAction onLike;
  final CommentAction onReport;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < comments.length; i++) ...[
          PostCommentRootTile(
            comment: comments[i],
            meId: meId,
            isLast: i == comments.length - 1,
            onReply: onReply,
            onLike: onLike,
            onReport: onReport,
          ),
        ],
      ],
    );
  }
}

class PostCommentRootTile extends StatelessWidget {
  const PostCommentRootTile({
    super.key,
    required this.comment,
    required this.meId,
    required this.isLast,
    required this.onReply,
    required this.onLike,
    required this.onReport,
  });

  final WallComment comment;
  final String meId;
  final bool isLast;
  final CommentAction onReply;
  final CommentAction onLike;
  final CommentAction onReport;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: PostalTokens.perforationLine.withValues(alpha: 0.65),
                ),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: PostalTokens.s16,
          top: PostalTokens.s4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostCommentTile(
              comment: comment,
              meId: meId,
              isReply: false,
              onReply: onReply,
              onLike: onLike,
              onReport: onReport,
            ),
            if (comment.replies.isNotEmpty) ...[
              const SizedBox(height: PostalTokens.s8),
              _ReplyThread(
                replies: comment.replies,
                meId: meId,
                onReply: onReply,
                onLike: onLike,
                onReport: onReport,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReplyThread extends StatelessWidget {
  const _ReplyThread({
    required this.replies,
    required this.meId,
    required this.onReply,
    required this.onLike,
    required this.onReport,
  });

  final List<WallComment> replies;
  final String meId;
  final CommentAction onReply;
  final CommentAction onLike;
  final CommentAction onReport;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: PostalTokens.s12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: PostalTokens.postboxGreen.withValues(alpha: 0.22),
              width: 2,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: PostalTokens.s12),
          child: Column(
            children: [
              for (var i = 0; i < replies.length; i++) ...[
                if (i > 0) const SizedBox(height: PostalTokens.s12),
                PostCommentTile(
                  comment: replies[i],
                  meId: meId,
                  isReply: true,
                  onReply: onReply,
                  onLike: onLike,
                  onReport: onReport,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PostCommentTile extends StatelessWidget {
  const PostCommentTile({
    super.key,
    required this.comment,
    required this.meId,
    required this.isReply,
    required this.onReply,
    required this.onLike,
    required this.onReport,
  });

  final WallComment comment;
  final String meId;
  final bool isReply;
  final CommentAction onReply;
  final CommentAction onLike;
  final CommentAction onReport;

  static TextStyle _displayNameStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall!.copyWith(
      fontFamily: PostalTokens.fontFamilyDisplay,
      fontFamilyFallback: PostalTokens.fontFamilyDisplayFallback,
      fontWeight: FontWeight.w700,
      color: PostalTokens.inkNavy,
      letterSpacing: 0.2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final avatarSize = isReply ? 30.0 : 36.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentAvatar(user: comment.author, size: avatarSize),
        const SizedBox(width: PostalTokens.s8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      comment.author.nickname,
                      style: _displayNameStyle(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: PostalTokens.s8),
                  Text(
                    DateFormat('MM-dd HH:mm').format(comment.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: PostalTokens.inkTertiary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (meId != comment.author.id)
                    _CommentMoreButton(
                      onReport: () => onReport(comment),
                      label: l10n.postDetailReportComment,
                    ),
                ],
              ),
              const SizedBox(height: PostalTokens.s8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _CommentTapBody(
                      comment: comment,
                      l10n: l10n,
                      onReply: () => onReply(comment),
                    ),
                  ),
                  SizedBox(
                    width: _kCommentLikeColumnWidth,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: _CommentLikeColumn(
                        comment: comment,
                        onLike: () => onLike(comment),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentTapBody extends StatelessWidget {
  const _CommentTapBody({
    required this.comment,
    required this.l10n,
    required this.onReply,
  });

  final WallComment comment;
  final AppLocalizations l10n;
  final VoidCallback onReply;

  /// 与详情页 [PostalTokens.paperCream] 同色系，略深一档，避免纯白块突兀。
  static Color get _bubbleFill => Color.alphaBlend(
        PostalTokens.kraftBrownMuted.withValues(alpha: 0.18),
        PostalTokens.paperCream,
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _bubbleFill,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: PostalTokens.shapeSm,
        side: BorderSide(
          color: PostalTokens.perforationLine.withValues(alpha: 0.38),
        ),
      ),
      child: InkWell(
        onTap: onReply,
        borderRadius: PostalTokens.shapeSm,
        splashColor: PostalTokens.postboxGreen.withValues(alpha: 0.05),
        highlightColor: PostalTokens.kraftBrownMuted.withValues(alpha: 0.35),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PostalTokens.s12,
            vertical: PostalTokens.s8,
          ),
          child: _CommentBody(comment: comment, l10n: l10n),
        ),
      ),
    );
  }
}

/// 抖音式：固定宽竖列，图标 + 数字槽，点赞前后正文宽度不变。
class _CommentLikeColumn extends StatelessWidget {
  const _CommentLikeColumn({required this.comment, required this.onLike});

  final WallComment comment;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final liked = comment.likedByMe;
    final countLabel = formatCommentLikeCount(
      comment.likeCount,
      chineseLocale: Localizations.localeOf(
        context,
      ).languageCode.startsWith('zh'),
    );
    final countStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontSize: 11,
      height: 1.1,
      fontWeight: FontWeight.w600,
      color: liked ? PostalTokens.postboxGreen : PostalTokens.inkTertiary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onLike,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: _kCommentLikeColumnWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                liked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                size: 20,
                color: liked
                    ? PostalTokens.postboxGreen
                    : PostalTokens.inkTertiary.withValues(alpha: 0.85),
              ),
              const SizedBox(height: 3),
              SizedBox(
                width: _kCommentLikeColumnWidth,
                height: 14,
                child: Center(
                  child: Text(
                    countLabel,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.center,
                    style: countStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentMoreButton extends StatelessWidget {
  const _CommentMoreButton({required this.onReport, required this.label});

  final VoidCallback onReport;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_horiz_rounded,
          size: 18,
          color: PostalTokens.inkTertiary.withValues(alpha: 0.85),
        ),
        padding: EdgeInsets.zero,
        splashRadius: 18,
        offset: const Offset(0, 28),
        shape: RoundedRectangleBorder(borderRadius: PostalTokens.shapeSm),
        onSelected: (v) {
          if (v == 'report') onReport();
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'report', child: Text(label)),
        ],
      ),
    );
  }
}

class _CommentBody extends StatelessWidget {
  const _CommentBody({required this.comment, required this.l10n});

  final WallComment comment;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final baseSize = Theme.of(context).textTheme.bodyMedium?.fontSize ?? 15;
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      height: 1.52,
      fontSize: baseSize,
      color: PostalTokens.inkNavy,
      fontFamily: PostalTokens.fontFamilyBody,
      fontFamilyFallback: PostalTokens.fontFamilyBodyFallback,
    );
    final metaStyle = bodyStyle?.copyWith(
      color: PostalTokens.inkSecondary,
      fontSize: baseSize * 0.93,
      fontWeight: FontWeight.w500,
    );
    final mentionStyle = bodyStyle?.copyWith(
      color: PostalTokens.postboxGreen,
      fontWeight: FontWeight.w700,
    );

    final replyTo = comment.replyTo;
    if (replyTo == null) {
      return Text(comment.content, style: bodyStyle);
    }
    return Text.rich(
      TextSpan(
        style: bodyStyle,
        children: [
          TextSpan(text: '${l10n.postDetailReplyPrefix} ', style: metaStyle),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () => context.push('/user/${replyTo.id}'),
              child: Text('@${replyTo.nickname}', style: mentionStyle),
            ),
          ),
          TextSpan(text: ' ${comment.content}'),
        ],
      ),
    );
  }
}

class _CommentAvatar extends StatelessWidget {
  const _CommentAvatar({required this.user, required this.size});

  final AppUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/user/${user.id}'),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: PostalTokens.perforationLine.withValues(alpha: 0.9),
                  width: 1.5,
                ),
                boxShadow: PostalTokens.shadowSoft,
              ),
              child: PostalAvatar(
                name: user.nickname,
                size: size,
                imageUrl: user.avatarUrl,
              ),
            ),
            if (user.gender >= 1)
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: PostalTokens.paperEnvelope,
                    shape: BoxShape.circle,
                    border: Border.all(color: PostalTokens.perforationLine),
                  ),
                  alignment: Alignment.center,
                  child: PostalGenderIcon(gender: user.gender, size: 9),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
