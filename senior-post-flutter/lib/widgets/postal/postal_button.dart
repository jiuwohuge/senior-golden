import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

/// 邮政风格按钮。所有变体均为实色或描边，禁止透明主按钮。
enum PostalButtonVariant { primary, secondary, ghost, danger }

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
  });

  final String label;
  final VoidCallback? onPressed;
  final PostalButtonVariant variant;
  final IconData? icon;
  final bool busy;
  final bool expand;
  final double minHeight;

  bool get _disabled => onPressed == null || busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = busy
        ? _busyIndicator()
        : _labelRow(theme.textTheme.labelLarge);

    final inner = SizedBox(
      width: expand ? double.infinity : null,
      height: minHeight,
      child: switch (variant) {
        PostalButtonVariant.primary => _primary(child),
        PostalButtonVariant.secondary => _secondary(child),
        PostalButtonVariant.ghost => _ghost(child),
        PostalButtonVariant.danger => _danger(child),
      },
    );

    return inner;
  }

  Widget _busyIndicator() {
    final color = switch (variant) {
      PostalButtonVariant.primary || PostalButtonVariant.danger => Colors.white,
      _ => PostalTokens.postboxGreen,
    };
    return SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    );
  }

  Widget _labelRow(TextStyle? base) {
    final color = switch (variant) {
      PostalButtonVariant.primary => Colors.white,
      PostalButtonVariant.danger => Colors.white,
      _ => PostalTokens.postboxGreen,
    };
    final style = base?.copyWith(color: color, letterSpacing: 0.4);
    if (icon == null) {
      return Center(child: Text(label, style: style));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(label, style: style),
      ],
    );
  }

  Widget _primary(Widget child) {
    return FilledButton(
      onPressed: _disabled ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: PostalTokens.postboxGreen,
        disabledBackgroundColor:
            PostalTokens.postboxGreen.withValues(alpha: 0.4),
        shape: const RoundedRectangleBorder(
          borderRadius: PostalTokens.shapeMd,
        ),
        padding: EdgeInsets.zero,
      ),
      child: child,
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
        shape: const RoundedRectangleBorder(
          borderRadius: PostalTokens.shapeMd,
        ),
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
        shape: const RoundedRectangleBorder(
          borderRadius: PostalTokens.shapeMd,
        ),
      ),
      child: child,
    );
  }

  Widget _danger(Widget child) {
    return FilledButton(
      onPressed: _disabled ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: PostalTokens.stampVermilion,
        disabledBackgroundColor:
            PostalTokens.stampVermilion.withValues(alpha: 0.4),
        shape: const RoundedRectangleBorder(
          borderRadius: PostalTokens.shapeMd,
        ),
        padding: EdgeInsets.zero,
      ),
      child: child,
    );
  }
}
