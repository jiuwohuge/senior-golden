import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/postal_tokens.dart';
import '../../widgets/postal/postal_painters.dart';

/// 信件邮戳：寄出地 → 送达地 + 日期，用于读信/列表仪式区。
class PostmarkWidget extends StatelessWidget {
  const PostmarkWidget({
    super.key,
    this.fromCountryName,
    this.toCountryName,
    this.sentAt,
    this.label,
  });

  final String? fromCountryName;
  final String? toCountryName;
  final DateTime? sentAt;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final from = (fromCountryName ?? '').trim();
    final to = (toCountryName ?? '').trim();
    if (from.isEmpty && to.isEmpty && sentAt == null && label == null) {
      return const SizedBox.shrink();
    }
    final route = [
      if (from.isNotEmpty) from,
      if (to.isNotEmpty) to,
    ].join(' → ');
    final dateText = sentAt != null
        ? DateFormat('yyyy-MM-dd').format(sentAt!)
        : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: PostalTokens.stampVermilionMuted.withValues(alpha: 0.35),
        borderRadius: PostalTokens.shapeMd,
        border: Border.all(
          color: PostalTokens.stampVermilion.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostmarkRing(
            size: 52,
            color: PostalTokens.stampVermilion.withValues(alpha: 0.82),
            strokeWidth: 1.8,
            year: dateText?.substring(0, 4),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (route.isNotEmpty)
                  Text(
                    route,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: PostalTokens.inkNavy,
                    ),
                  ),
                if (dateText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    dateText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PostalTokens.inkSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (label != null && label!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    label!,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: PostalTokens.postboxGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
