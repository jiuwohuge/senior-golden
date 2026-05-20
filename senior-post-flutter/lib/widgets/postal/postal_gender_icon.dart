import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

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
    final (IconData icon, Color ring) = switch (gender) {
      1 => (Icons.male_rounded, PostalTokens.postboxGreen),
      2 => (Icons.female_rounded, PostalTokens.stampVermilion),
      _ => (Icons.wc_rounded, PostalTokens.inkSecondary),
    };
    return Semantics(
      label: semanticLabel,
      child: Container(
        width: size + 6,
        height: size + 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ring.withValues(alpha: 0.65), width: 1.2),
          color: PostalTokens.paperCard.withValues(alpha: 0.9),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: size * 0.72, color: PostalTokens.inkNavy),
      ),
    );
  }
}
