import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

/// 国家邮戳样式标签：圆形邮戳 + 国家代码 + 国名。
class PostalCountrySeal extends StatelessWidget {
  const PostalCountrySeal({
    super.key,
    required this.countryCode,
    this.countryName,
    this.compact = false,
    this.color,
  });

  final String countryCode;
  final String? countryName;
  final bool compact;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? PostalTokens.stampVermilion;
    final ringSize = compact ? 26.0 : 32.0;
    final normalizedCode = countryCode.trim().toUpperCase();
    final normalizedName = (countryName ?? '').trim();
    final showCountryName =
        normalizedName.isNotEmpty &&
        normalizedName.toUpperCase() != normalizedCode;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: ringSize,
          height: ringSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: c, width: 1.4),
            color: c.withValues(alpha: 0.06),
          ),
          alignment: Alignment.center,
          child: Text(
            normalizedCode,
            style: theme.textTheme.bodySmall?.copyWith(
              color: c,
              fontWeight: FontWeight.w800,
              fontSize: compact ? 10 : 11,
              letterSpacing: 0.6,
              height: 1,
            ),
          ),
        ),
        if (showCountryName) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              normalizedName,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: PostalTokens.inkSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
