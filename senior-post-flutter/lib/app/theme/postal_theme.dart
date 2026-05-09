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
      fontFamily: PostalTokens.fontFamilyBody,
      fontFamilyFallback: PostalTokens.fontFamilyBodyFallback,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: PostalTokens.inkNavy.withValues(alpha: 0.18),
        surfaceTintColor: Colors.transparent,
        backgroundColor: PostalTokens.postboxGreen,
        foregroundColor: Colors.white,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
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
        shape: const RoundedRectangleBorder(
          borderRadius: PostalTokens.shapeMd,
          side: BorderSide(color: PostalTokens.perforationLine),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: PostalTokens.perforationLine.withValues(alpha: 0.9),
        thickness: 1,
      ),
      inputDecorationTheme: _inputDecorationTheme(textTheme),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: PostalTokens.shapeMd),
          ),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return PostalTokens.postboxGreen.withValues(alpha: 0.4);
            }
            if (states.contains(WidgetState.pressed)) {
              return PostalTokens.postboxGreenMuted;
            }
            return PostalTokens.postboxGreen;
          }),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          overlayColor: WidgetStatePropertyAll(
            Colors.white.withValues(alpha: 0.08),
          ),
          elevation: const WidgetStatePropertyAll(0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: PostalTokens.shapeMd),
          ),
          textStyle: WidgetStatePropertyAll(
            textTheme.labelLarge?.copyWith(
              color: PostalTokens.postboxGreen,
            ),
          ),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(
                color: PostalTokens.postboxGreen.withValues(alpha: 0.3),
              );
            }
            return const BorderSide(
              color: PostalTokens.postboxGreen,
              width: 1.4,
            );
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return PostalTokens.postboxGreen.withValues(alpha: 0.5);
            }
            return PostalTokens.postboxGreen;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return PostalTokens.postboxGreen.withValues(alpha: 0.05);
            }
            return Colors.transparent;
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          textStyle: WidgetStatePropertyAll(
            textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return PostalTokens.inkSecondary.withValues(alpha: 0.5);
            }
            return PostalTokens.postboxGreen;
          }),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        side: const BorderSide(color: PostalTokens.kraftBrown, width: 1.4),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PostalTokens.postboxGreen;
          }
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: PostalTokens.inkNavy,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: const RoundedRectangleBorder(borderRadius: PostalTokens.shapeMd),
        elevation: 4,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: PostalTokens.paperEnvelope,
        elevation: 6,
        shape: const RoundedRectangleBorder(borderRadius: PostalTokens.shapeLg),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: PostalTokens.inkSecondary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: PostalTokens.paperEnvelope,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: PostalTokens.radiusXl),
        ),
        showDragHandle: true,
        dragHandleColor: PostalTokens.kraftBrown,
        dragHandleSize: Size(40, 4),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: PostalTokens.paperCard,
        selectedColor: PostalTokens.postboxGreen.withValues(alpha: 0.18),
        secondarySelectedColor: PostalTokens.postboxGreen,
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: PostalTokens.inkNavy,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: textTheme.bodyMedium?.copyWith(
          color: PostalTokens.postboxGreen,
          fontWeight: FontWeight.w700,
        ),
        side: const BorderSide(color: PostalTokens.perforationLine),
        shape: const RoundedRectangleBorder(borderRadius: PostalTokens.shapeSm),
        padding: const EdgeInsets.symmetric(
          horizontal: PostalTokens.s12,
          vertical: PostalTokens.s4,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: PostalTokens.postboxGreen,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: PostalTokens.postboxGreen,
        unselectedLabelColor: PostalTokens.inkSecondary,
        indicatorColor: PostalTokens.stampVermilion,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: textTheme.titleMedium,
        unselectedLabelStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      // M3 Slider 默认未激活轨易与 paperCream 背景融在一起；显式对比色与邮筒绿拇指。
      sliderTheme: SliderThemeData(
        trackHeight: 5,
        activeTrackColor: PostalTokens.postboxGreen,
        inactiveTrackColor: PostalTokens.perforationLine,
        secondaryActiveTrackColor: PostalTokens.postboxGreen.withValues(alpha: 0.55),
        thumbColor: PostalTokens.postboxGreen,
        overlayColor: PostalTokens.postboxGreen.withValues(alpha: 0.14),
        valueIndicatorColor: PostalTokens.postboxGreen,
      ),
    );
  }

  /// 输入框：纸感底 + 牛皮纸描边 + focus 邮筒绿强化。
  static InputDecorationTheme _inputDecorationTheme(TextTheme textTheme) {
    OutlineInputBorder makeBorder(Color color, {double width = 1.2}) {
      return OutlineInputBorder(
        borderRadius: PostalTokens.shapeMd,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecorationTheme(
      filled: true,
      fillColor: PostalTokens.paperEnvelope,
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: PostalTokens.s16,
        vertical: PostalTokens.s16,
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: PostalTokens.inkTertiary,
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: PostalTokens.inkSecondary,
        fontWeight: FontWeight.w600,
      ),
      floatingLabelStyle: textTheme.bodyMedium?.copyWith(
        color: PostalTokens.postboxGreen,
        fontWeight: FontWeight.w700,
      ),
      helperStyle: textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        color: PostalTokens.inkTertiary,
      ),
      errorStyle: textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        color: PostalTokens.stampVermilion,
        fontWeight: FontWeight.w600,
      ),
      border: makeBorder(PostalTokens.perforationLine),
      enabledBorder: makeBorder(PostalTokens.perforationLine),
      focusedBorder: makeBorder(PostalTokens.postboxGreen, width: 1.6),
      errorBorder: makeBorder(PostalTokens.stampVermilion),
      focusedErrorBorder:
          makeBorder(PostalTokens.stampVermilion, width: 1.6),
      disabledBorder: makeBorder(
        PostalTokens.perforationLine.withValues(alpha: 0.4),
      ),
    );
  }

  /// 适老化：基准字号上浮；行高略增，便于长时间阅读。
  static TextTheme _textTheme(ColorScheme scheme) {
    const letterTight = 0.1;

    TextStyle make({
      required double size,
      required double height,
      required FontWeight weight,
      Color? color,
      double letter = letterTight,
      bool display = false,
    }) {
      return TextStyle(
        fontFamily:
            display ? PostalTokens.fontFamilyDisplay : PostalTokens.fontFamilyBody,
        fontFamilyFallback: display
            ? PostalTokens.fontFamilyDisplayFallback
            : PostalTokens.fontFamilyBodyFallback,
        fontSize: size,
        height: height,
        fontWeight: weight,
        color: color ?? scheme.onSurface,
        letterSpacing: letter,
      );
    }

    return TextTheme(
      displayLarge: make(
        size: 34,
        height: 1.2,
        weight: FontWeight.w800,
        letter: 0,
        display: true,
      ),
      displayMedium: make(
        size: 30,
        height: 1.22,
        weight: FontWeight.w700,
        letter: 0,
        display: true,
      ),
      displaySmall: make(
        size: 26,
        height: 1.25,
        weight: FontWeight.w700,
        letter: 0.05,
        display: true,
      ),
      headlineMedium: make(
        size: 24,
        height: 1.3,
        weight: FontWeight.w700,
        display: true,
      ),
      headlineSmall: make(
        size: 21,
        height: 1.32,
        weight: FontWeight.w700,
        display: true,
      ),
      titleLarge: make(
        size: 22,
        height: 1.3,
        weight: FontWeight.w700,
      ),
      titleMedium: make(
        size: 19,
        height: 1.35,
        weight: FontWeight.w600,
      ),
      titleSmall: make(
        size: 17,
        height: 1.35,
        weight: FontWeight.w600,
        color: PostalTokens.inkSecondary,
      ),
      bodyLarge: make(
        size: 18,
        height: 1.5,
        weight: FontWeight.w500,
      ),
      bodyMedium: make(
        size: 16,
        height: 1.5,
        weight: FontWeight.w500,
      ),
      bodySmall: make(
        size: 14,
        height: 1.45,
        weight: FontWeight.w500,
        color: PostalTokens.inkTertiary,
      ),
      labelLarge: make(
        size: 17,
        height: 1.25,
        weight: FontWeight.w700,
        color: Colors.white,
        letter: 0.3,
      ),
      labelMedium: make(
        size: 14,
        height: 1.25,
        weight: FontWeight.w600,
        color: PostalTokens.inkSecondary,
        letter: 0.3,
      ),
      labelSmall: make(
        size: 12,
        height: 1.2,
        weight: FontWeight.w600,
        color: PostalTokens.inkTertiary,
        letter: 0.4,
      ),
    );
  }
}
