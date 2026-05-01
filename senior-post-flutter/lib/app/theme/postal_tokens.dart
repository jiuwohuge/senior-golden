import 'package:flutter/material.dart';

/// 欧美邮政视觉语言：邮筒绿、纸张米色、邮戳红、墨色与牛皮纸辅助色。
/// 对比度按浅色背景上的正文大致满足 WCAG AA（与 [PostalTheme] 字色配合使用）。
abstract final class PostalTokens {
  /// 经典邮筒 / 邮政绿
  static const Color postboxGreen = Color(0xFF1B4D3E);

  /// 略浅的绿，用于大面积背景条，避免压抑
  static const Color postboxGreenMuted = Color(0xFF2D6A58);

  /// 信纸 / 羊皮纸感背景
  static const Color paperCream = Color(0xFFF7F2E9);

  /// 略深一点的卡片纸
  static const Color paperCard = Color(0xFFEFE8DC);

  /// 正文墨蓝（比纯黑柔和，仍保持高对比）
  static const Color inkNavy = Color(0xFF1A2332);

  /// 次级说明文字
  static const Color inkSecondary = Color(0xFF4A5568);

  /// 邮戳、挂号等强调色
  static const Color stampVermilion = Color(0xFFC43C3C);

  /// 牛皮纸信封色（装饰描边）
  static const Color kraftBrown = Color(0xFF8B7355);

  /// 齿孔线 / 分割线
  static const Color perforationLine = Color(0xFFD4C4B0);
}
