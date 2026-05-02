import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

/// 信件状态标签：挂号 ✅ / 平邮 ✉️ Delivering / Delivered。
class PostalStatusChip extends StatelessWidget {
  const PostalStatusChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  factory PostalStatusChip.delivered({String label = 'Delivered'}) =>
      PostalStatusChip(
        label: label,
        icon: Icons.check_circle,
        color: PostalTokens.success,
      );

  factory PostalStatusChip.delivering({String label = 'Delivering…'}) =>
      PostalStatusChip(
        label: label,
        icon: Icons.directions_run,
        color: PostalTokens.warning,
      );

  factory PostalStatusChip.registered({String label = 'Registered'}) =>
      PostalStatusChip(
        label: label,
        icon: Icons.bolt_rounded,
        color: PostalTokens.stampVermilion,
      );

  factory PostalStatusChip.draft({String label = 'Draft'}) => PostalStatusChip(
    label: label,
    icon: Icons.edit_note,
    color: PostalTokens.kraftBrown,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
