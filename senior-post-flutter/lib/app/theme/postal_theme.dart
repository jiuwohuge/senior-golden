import 'package:flutter/material.dart';

import 'postal_tokens.dart';

/// 面向中老年用户：较大基准字号、清晰字重、Material 3 组件主题与邮政配色统一。
abstract final class PostalTheme {
  static ThemeData light() {
    final baseScheme = ColorScheme.light(
      primary: PostalTokens.postboxGreen,
      onPrimary: Colors.white,
      primaryContainer: PostalTokens.paperCard,
      onPrimaryContainer: PostalTokens.inkNavy,
      secondary: PostalTokens.kraftBrown,
      onSecondary: Colors.white,
      tertiary: PostalTokens.stampVermilion,
      onTertiary: Colors.white,
      surface: PostalTokens.paperCream,
      onSurface: PostalTokens.inkNavy,
      onSurfaceVariant: PostalTokens.inkSecondary,
      outline: PostalTokens.perforationLine,
      outlineVariant: PostalTokens.perforationLine.withValues(alpha: 0.6),
      error: PostalTokens.stampVermilion,
      onError: Colors.white,
    );

    final textTheme = _textTheme(baseScheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseScheme,
      scaffoldBackgroundColor: PostalTokens.paperCream,
      visualDensity: VisualDensity.standard,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: PostalTokens.postboxGreen,
        foregroundColor: Colors.white,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white, size: 26),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        elevation: 3,
        shadowColor: PostalTokens.inkNavy.withValues(alpha: 0.12),
        backgroundColor: PostalTokens.paperCard,
        indicatorColor: PostalTokens.postboxGreen.withValues(alpha: 0.18),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 28,
            color: selected
                ? PostalTokens.postboxGreen
                : PostalTokens.inkSecondary,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: 0.2,
            color: selected
                ? PostalTokens.postboxGreen
                : PostalTokens.inkSecondary,
          );
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: PostalTokens.perforationLine.withValues(alpha: 0.85),
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: PostalTokens.perforationLine.withValues(alpha: 0.9),
        thickness: 1,
      ),
    );
  }

  /// 适老化：基准字号上浮；行高略增，便于长时间阅读。
  static TextTheme _textTheme(ColorScheme scheme) {
    const letterTight = 0.15;

    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 28,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
        letterSpacing: letterTight,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
        letterSpacing: letterTight,
      ),
      titleMedium: TextStyle(
        fontSize: 19,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
        letterSpacing: letterTight,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        height: 1.45,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
        letterSpacing: 0.1,
      ),
      bodyMedium: TextStyle(
        fontSize: 17,
        height: 1.45,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      labelLarge: TextStyle(
        fontSize: 17,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: scheme.onPrimary,
        letterSpacing: 0.3,
      ),
    );
  }
}
