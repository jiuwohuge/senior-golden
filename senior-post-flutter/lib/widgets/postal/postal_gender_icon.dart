import 'package:flutter/material.dart';

/// 邮政风性别小图标（名录/墙/用户卡展示用）。
class PostalGenderIcon extends StatelessWidget {
  const PostalGenderIcon({
    super.key,
    required this.gender,
    this.size = 18,
    this.semanticLabel,
  });

  /// 1 男，2 女，3 其他；0 或未识别不显示。
  final int gender;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (gender < 1 || gender > 3) {
      return const SizedBox.shrink();
    }
    final (IconData icon, Color bg, Color border) = switch (gender) {
      // 主流风格：高对比底色 + 白色图标，保证小尺寸下可读性。
      1 => (
        Icons.male_rounded,
        const Color(0xFF3B82F6),
        const Color(0xFF2563EB),
      ),
      2 => (
        Icons.female_rounded,
        const Color(0xFFEC4899),
        const Color(0xFFDB2777),
      ),
      _ => (
        Icons.transgender_rounded,
        const Color(0xFF64748B),
        const Color(0xFF475569),
      ),
    };
    final badgeSize = size + 8;
    return Semantics(
      label: semanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
          border: Border.all(color: border, width: 1.1),
          boxShadow: [
            BoxShadow(
              color: border.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: SizedBox(
          width: badgeSize,
          height: badgeSize,
          child: Icon(icon, size: size * 0.68, color: Colors.white),
        ),
      ),
    );
  }
}
