import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

/// 信件文档：正文 + 纸面/字体元数据（与后端 `LetterContentMeta` 对齐；插图后置）。
class LetterDocument {
  const LetterDocument({
    this.body = '',
    this.skinId = defaultSkinId,
    this.fontId = defaultFontId,
    this.fontSizeTier = FontSizeTier.large,
    this.templateId,
  });

  static const String defaultSkinId = 'default';
  static const String defaultFontId = 'default';

  final String body;
  final String skinId;
  final String fontId;
  final FontSizeTier fontSizeTier;
  final String? templateId;

  LetterDocument copyWith({
    String? body,
    String? skinId,
    String? fontId,
    FontSizeTier? fontSizeTier,
    String? templateId,
  }) {
    return LetterDocument(
      body: body ?? this.body,
      skinId: skinId ?? this.skinId,
      fontId: fontId ?? this.fontId,
      fontSizeTier: fontSizeTier ?? this.fontSizeTier,
      templateId: templateId ?? this.templateId,
    );
  }

  /// 模板段落列表合并为整屏正文。
  static String joinParagraphs(List<String> paragraphs) {
    return paragraphs
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .join('\n\n');
  }
}

/// 适老字号档：默认 [large]，可选 [xlarge]。
enum FontSizeTier {
  large,
  xlarge;

  static const String apiLarge = 'large';
  static const String apiXlarge = 'xlarge';

  String get apiValue => switch (this) {
    FontSizeTier.large => apiLarge,
    FontSizeTier.xlarge => apiXlarge,
  };

  static FontSizeTier fromApi(String? raw) {
    if (raw == null || raw.trim().isEmpty) return FontSizeTier.large;
    final t = raw.trim().toLowerCase();
    if (t == apiXlarge || t == '更大') return FontSizeTier.xlarge;
    return FontSizeTier.large;
  }

  /// 正文基准字号（pt），满足 45+ 下限并略高于日记类 App。
  double get bodyFontSize => switch (this) {
    FontSizeTier.large => 19,
    FontSizeTier.xlarge => 23,
  };

  double get lineHeight => 1.65;
}

/// 信纸视觉 token：底色 + 正文色（禁止低对比组合）。
class LetterPaperTokens {
  const LetterPaperTokens({
    required this.background,
    required this.ink,
  });

  final Color background;
  final Color ink;

  static LetterPaperTokens forSkin(String? skinId) {
    return switch (skinId) {
      'vintage' => const LetterPaperTokens(
        background: Color(0xFFF3E6C8),
        ink: PostalTokens.inkNavy,
      ),
      'linen' => const LetterPaperTokens(
        background: Color(0xFFF7F1E3),
        ink: PostalTokens.inkNavy,
      ),
      _ => const LetterPaperTokens(
        background: PostalTokens.paperCream,
        ink: PostalTokens.inkNavy,
      ),
    };
  }
}

/// 读信页信纸背景色（兼容旧调用）。
Color letterSkinBackground(String? skinId) =>
    LetterPaperTokens.forSkin(skinId).background;

/// 字体族映射：仅高可读选项；花式手写体不当默认。
TextStyle letterBodyTextStyle({
  required String? fontId,
  required FontSizeTier tier,
  required Color ink,
}) {
  final base = TextStyle(
    color: ink,
    fontSize: tier.bodyFontSize,
    height: tier.lineHeight,
    fontWeight: FontWeight.w400,
  );
  // handwriting 商品若存在，用略柔的衬线但保持可读，而非花哨手写体。
  if (fontId == 'handwriting') {
    return base.copyWith(
      fontFamily: PostalTokens.fontFamilyBody,
      fontFamilyFallback: PostalTokens.fontFamilyBodyFallback,
      fontStyle: FontStyle.italic,
    );
  }
  return base.copyWith(
    fontFamily: PostalTokens.fontFamilyBody,
    fontFamilyFallback: PostalTokens.fontFamilyBodyFallback,
  );
}
