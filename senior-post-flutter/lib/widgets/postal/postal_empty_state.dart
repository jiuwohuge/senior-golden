import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';
import 'postal_button.dart';

/// 通用空状态：信封 / 邮筒 插画 + 标题 + 副标题 + 主 CTA。
class PostalEmptyState extends StatelessWidget {
  const PostalEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.markunread_mailbox_outlined,
    this.actionLabel,
    this.onAction,
    this.tone = PostalEmptyTone.calm,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final PostalEmptyTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = switch (tone) {
      PostalEmptyTone.calm => PostalTokens.kraftBrown,
      PostalEmptyTone.error => PostalTokens.stampVermilion,
      PostalEmptyTone.success => PostalTokens.postboxGreen,
    };

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(PostalTokens.s24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.08),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.3),
                      width: 1.4,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: accent, size: 44),
                ),
                const SizedBox(height: PostalTokens.s20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: PostalTokens.s8),
                  SelectableText(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: PostalTokens.inkSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: PostalTokens.s24),
                  PostalButton(
                    label: actionLabel!,
                    onPressed: onAction,
                    variant: PostalButtonVariant.secondary,
                    expand: false,
                    minHeight: 48,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum PostalEmptyTone { calm, error, success }
