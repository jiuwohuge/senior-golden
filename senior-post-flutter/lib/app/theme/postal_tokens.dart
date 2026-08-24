import 'package:flutter/material.dart';

/// 欧美邮政视觉语言：邮筒绿、纸张米色、邮戳红、墨色与牛皮纸辅助色。
/// 对比度按浅色背景上的正文大致满足 WCAG AA（与 [PostalTheme] 字色配合使用）。
abstract final class PostalTokens {
  // ────────────────────────────────────────────────────────────────
  // Brand colors
  // ────────────────────────────────────────────────────────────────

  /// 经典邮筒 / 邮政绿
  static const Color postboxGreen = Color(0xFF1B4D3E);

  /// 略浅的绿，用于大面积背景条，避免压抑
  static const Color postboxGreenMuted = Color(0xFF2D6A58);

  /// 信纸 / 羊皮纸感背景
  static const Color paperCream = Color(0xFFF7F2E9);

  /// 略深一点的卡片纸
  static const Color paperCard = Color(0xFFEFE8DC);

  /// 信封内衬奶油白
  static const Color paperEnvelope = Color(0xFFFFFCF5);

  /// 正文墨蓝（比纯黑柔和，仍保持高对比）
  static const Color inkNavy = Color(0xFF1A2332);

  /// 次级说明文字
  static const Color inkSecondary = Color(0xFF4A5568);

  /// 三级辅助文字（标签、时间戳）
  static const Color inkTertiary = Color(0xFF718096);

  /// 邮戳等强调色
  static const Color stampVermilion = Color(0xFFC43C3C);

  /// 邮戳红的浅底，用于背景标签
  static const Color stampVermilionMuted = Color(0xFFFBE6E1);

  /// 牛皮纸信封色（装饰描边）
  static const Color kraftBrown = Color(0xFF8B7355);

  /// 牛皮纸浅
  static const Color kraftBrownMuted = Color(0xFFD9C8A8);

  /// VIP / 邮票金
  static const Color stampGold = Color(0xFFB08A57);

  /// 齿孔线 / 分割线
  static const Color perforationLine = Color(0xFFD4C4B0);

  /// 写信桌背景。独立为语义色，避免页面散落近似的米褐色。
  static const Color composeDesk = Color(0xFFEDE4D4);

  /// 账号/内容受限状态与高价值徽章。
  static const Color blockedRed = Color(0xFFB83A2A);
  static const Color badgeGold = Color(0xFFC9A227);

  // ────────────────────────────────────────────────────────────────
  // Status colors
  // ────────────────────────────────────────────────────────────────

  /// 成功
  static const Color success = Color(0xFF2D6A58);

  /// 警告
  static const Color warning = Color(0xFFB97A2A);

  /// 错误（与 stampVermilion 同源）
  static const Color error = stampVermilion;

  /// 信息提示
  static const Color info = Color(0xFF3F6B8A);

  // ────────────────────────────────────────────────────────────────
  // Spacing scale (4 / 8 倍数体系)
  // ────────────────────────────────────────────────────────────────

  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;

  // ────────────────────────────────────────────────────────────────
  // Accessibility baseline (M0)
  // ────────────────────────────────────────────────────────────────

  /// 最小可点击区域（Material / WCAG 建议 ≥48dp）
  static const double minTouchTarget = 48.0;

  /// 正文/标签最小字号（适老化基线 ≥17pt）
  static const double minBodyFontSize = 17.0;

  // ────────────────────────────────────────────────────────────────
  // Radius scale
  // ────────────────────────────────────────────────────────────────

  static const Radius radiusSm = Radius.circular(10);
  static const Radius radiusMd = Radius.circular(14);
  static const Radius radiusLg = Radius.circular(18);
  static const Radius radiusXl = Radius.circular(24);

  static const BorderRadius shapeSm = BorderRadius.all(radiusSm);
  static const BorderRadius shapeMd = BorderRadius.all(radiusMd);
  static const BorderRadius shapeLg = BorderRadius.all(radiusLg);

  // ────────────────────────────────────────────────────────────────
  // Elevation (shadow tokens)
  // ────────────────────────────────────────────────────────────────

  static List<BoxShadow> get shadowSoft => [
    BoxShadow(
      color: inkNavy.withValues(alpha: 0.05),
      offset: const Offset(0, 2),
      blurRadius: 6,
    ),
  ];

  static List<BoxShadow> get shadowCard => [
    BoxShadow(
      color: inkNavy.withValues(alpha: 0.08),
      offset: const Offset(0, 4),
      blurRadius: 14,
    ),
    BoxShadow(
      color: kraftBrown.withValues(alpha: 0.04),
      offset: const Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static List<BoxShadow> get shadowFloating => [
    BoxShadow(
      color: inkNavy.withValues(alpha: 0.12),
      offset: const Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  // ────────────────────────────────────────────────────────────────
  // Typography family — 平台原生衬线兜底
  // ────────────────────────────────────────────────────────────────
  //
  // iOS 自带 `Charter` / `Georgia`，Android 自带 `serif`（Noto Serif），
  // Windows / macOS 桌面端自带 `Cambria` / `Times New Roman`。
  // 不引入任何第三方字体包，保留复古衬线观感的同时避免运行时下载。

  /// 主标题字体（衬线，复古/编辑感）
  static const String fontFamilyDisplay = 'Charter';

  /// 主标题兜底链
  static const List<String> fontFamilyDisplayFallback = <String>[
    'Georgia',
    'Cambria',
    'Times New Roman',
    'serif',
  ];

  /// 正文字体（与显示字体一致，保证整体衬线节奏统一）
  static const String fontFamilyBody = 'Charter';

  static const List<String> fontFamilyBodyFallback = fontFamilyDisplayFallback;

  // ────────────────────────────────────────────────────────────────
  // Animation durations
  // ────────────────────────────────────────────────────────────────

  static const Duration durationFast = Duration(milliseconds: 120);
  static const Duration durationMedium = Duration(milliseconds: 220);
  static const Duration durationSlow = Duration(milliseconds: 360);
}
