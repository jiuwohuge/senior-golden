import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

/// 邮票余额徽标：`Stamps: x/3` 或 `VIP · Unlimited`。带齿边圆角，复古邮票质感。
class PostalStampBadge extends StatelessWidget {
  const PostalStampBadge({
    super.key,
    this.balance,
    this.cap,
    this.isVip = false,
    this.compact = false,
    this.onTap,
  });

  final int? balance;
  final int? cap;
  final bool isVip;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = isVip ? PostalTokens.stampGold : PostalTokens.postboxGreen;
    final bg = isVip
        ? PostalTokens.stampGold.withValues(alpha: 0.1)
        : PostalTokens.postboxGreen.withValues(alpha: 0.08);

    final label = isVip
        ? 'VIP · Unlimited'
        : 'Stamps: ${balance ?? 0}${cap != null ? '/$cap' : ''}';

    final icon = Icon(
      isVip ? Icons.workspace_premium : Icons.local_post_office,
      color: fg,
      size: compact ? 16 : 18,
    );

    final textStyle = (compact ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)
        ?.copyWith(
      color: fg,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.4,
    );

    final pad = compact
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 14, vertical: 8);

    final body = Container(
      padding: pad,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: fg.withValues(alpha: 0.6), width: 1),
        borderRadius: PostalTokens.shapeSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Text(label, style: textStyle),
        ],
      ),
    );

    if (onTap == null) return body;
    return InkWell(
      onTap: onTap,
      borderRadius: PostalTokens.shapeSm,
      child: body,
    );
  }
}
