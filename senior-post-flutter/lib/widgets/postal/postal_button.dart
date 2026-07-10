import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

/// 邮政风格按钮。所有变体均为实色或描边，禁止透明主按钮。
enum PostalButtonVariant { primary, primaryLarge, secondary, ghost, danger }

/// 按钮内容排布：并排主操作区用 [stacked] 保留适老化字号。
enum PostalButtonLayout { inline, stacked }

class PostalButton extends StatelessWidget {
  const PostalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PostalButtonVariant.primary,
    this.icon,
    this.busy = false,
    this.expand = true,
    this.minHeight = 52,
    this.pill = false,
    this.layout = PostalButtonLayout.inline,
  });

  final String label;
  final VoidCallback? onPressed;
  final PostalButtonVariant variant;
  final IconData? icon;
  final bool busy;
  final bool expand;
  final double minHeight;

  /// 胶囊圆角（欢迎页等），否则使用 [PostalTokens.shapeMd]。
  final bool pill;

  /// [stacked]：图标在上、文案在下，适合首页并排双主按钮。
  final PostalButtonLayout layout;

  bool get _disabled => onPressed == null || busy;

  bool get _stacked => layout == PostalButtonLayout.stacked;

  double get _effectiveMinHeight {
    if (variant == PostalButtonVariant.primaryLarge) {
      return minHeight < 64 ? 64 : minHeight;
    }
    if (_stacked) {
      return minHeight < PostalTokens.minTouchTarget
          ? PostalTokens.minTouchTarget
          : minHeight;
    }
    return minHeight < PostalTokens.minTouchTarget
        ? PostalTokens.minTouchTarget
        : minHeight;
  }

  BorderRadius get _shape =>
      pill ? BorderRadius.circular(minHeight / 2) : PostalTokens.shapeMd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = busy
        ? _busyIndicator()
        : _stacked
        ? _stackedLabel(theme.textTheme)
        : _labelRow(theme.textTheme.labelLarge);

    final shell = switch (variant) {
      PostalButtonVariant.primary ||
      PostalButtonVariant.primaryLarge => _primary(child),
      PostalButtonVariant.secondary => _secondary(child),
      PostalButtonVariant.ghost => _ghost(child),
      PostalButtonVariant.danger => _danger(child),
    };

    final fixedHeight = SizedBox(height: _effectiveMinHeight, child: shell);

    // 避免 `SizedBox(width: double.infinity)`：与部分父级（如 Row / Flexible）合并约束时会得到
    // 非法的无限宽度。有界时用 LayoutBuilder 的 maxWidth 铺满；无界或非 expand 用 IntrinsicWidth。
    if (!expand) {
      return IntrinsicWidth(child: fixedHeight);
    }

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        if (w.isFinite && w > 0) {
          return SizedBox(width: w, height: _effectiveMinHeight, child: shell);
        }
        return IntrinsicWidth(child: fixedHeight);
      },
    );
  }

  Widget _busyIndicator() {
    final color = switch (variant) {
      PostalButtonVariant.primary ||
      PostalButtonVariant.primaryLarge ||
      PostalButtonVariant.danger => Colors.white,
      _ => PostalTokens.postboxGreen,
    };
    return SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    );
  }

  Widget _stackedLabel(TextTheme textTheme) {
    final color = switch (variant) {
      PostalButtonVariant.primary ||
      PostalButtonVariant.primaryLarge ||
      PostalButtonVariant.danger => Colors.white,
      _ => PostalTokens.postboxGreen,
    };
    final style = textTheme.labelLarge?.copyWith(
      color: color,
      fontSize: 15,
      height: 1.15,
      letterSpacing: 0.15,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
          ],
          Text(label, maxLines: 2, textAlign: TextAlign.center, style: style),
        ],
      ),
    );
  }

  Widget _labelRow(TextStyle? base) {
    final color = switch (variant) {
      PostalButtonVariant.primary ||
      PostalButtonVariant.primaryLarge ||
      PostalButtonVariant.danger => Colors.white,
      _ => PostalTokens.postboxGreen,
    };
    final style = base?.copyWith(color: color, letterSpacing: 0.4);
    if (icon == null) {
      return Center(
        child: Text(
          label,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: style,
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: style,
          ),
        ),
      ],
    );
  }

  Widget _primary(Widget child) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: _shape,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _disabled
              ? [
                  PostalTokens.postboxGreen.withValues(alpha: 0.45),
                  PostalTokens.postboxGreenMuted.withValues(alpha: 0.45),
                ]
              : const [
                  PostalTokens.postboxGreen,
                  PostalTokens.postboxGreenMuted,
                ],
        ),
        boxShadow: _disabled
            ? null
            : [
                BoxShadow(
                  color: PostalTokens.postboxGreen.withValues(alpha: 0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: FilledButton(
        onPressed: _disabled ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: _shape),
          padding: EdgeInsets.symmetric(horizontal: _stacked ? 10 : 20),
        ),
        child: child,
      ),
    );
  }

  Widget _secondary(Widget child) {
    return OutlinedButton(
      onPressed: _disabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: PostalTokens.paperEnvelope,
        side: BorderSide(
          color: _disabled
              ? PostalTokens.postboxGreen.withValues(alpha: 0.3)
              : PostalTokens.postboxGreen,
          width: 1.4,
        ),
        shape: RoundedRectangleBorder(borderRadius: _shape),
        padding: EdgeInsets.zero,
      ),
      child: child,
    );
  }

  Widget _ghost(Widget child) {
    return TextButton(
      onPressed: _disabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: PostalTokens.postboxGreen,
        backgroundColor: PostalTokens.paperCard.withValues(alpha: 0.92),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: _shape),
      ),
      child: child,
    );
  }

  Widget _danger(Widget child) {
    return FilledButton(
      onPressed: _disabled ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: PostalTokens.stampVermilion,
        disabledBackgroundColor: PostalTokens.stampVermilion.withValues(
          alpha: 0.4,
        ),
        shape: RoundedRectangleBorder(borderRadius: _shape),
        padding: EdgeInsets.zero,
      ),
      child: child,
    );
  }
}
