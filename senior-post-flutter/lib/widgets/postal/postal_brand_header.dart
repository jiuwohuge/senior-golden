import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';
import 'postal_painters.dart';

/// 认证页 / 启动页顶部的品牌头：邮戳环 + 标题 + 一句话定位。
class PostalBrandHeader extends StatelessWidget {
  const PostalBrandHeader({
    super.key,
    required this.title,
    required this.tagline,
    this.year,
  });

  final String title;
  final String tagline;
  final String? year;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PostmarkRing(
          size: 76,
          strokeWidth: 1.6,
          color: PostalTokens.postboxGreen.withValues(alpha: 0.5),
          year: year,
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(
            color: PostalTokens.inkNavy,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 56,
          height: 1.4,
          color: PostalTokens.stampVermilion,
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            tagline,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: PostalTokens.inkSecondary,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
