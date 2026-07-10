import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

/// 包装可点击区域，保证最小 [PostalTokens.minTouchTarget] 点击热区。
class PostalMinTouch extends StatelessWidget {
  const PostalMinTouch({
    super.key,
    required this.onTap,
    required this.child,
    this.semanticLabel,
    this.enabled = true,
  });

  final VoidCallback? onTap;
  final Widget child;
  final String? semanticLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveOnTap = enabled ? onTap : null;
    return Semantics(
      button: effectiveOnTap != null,
      label: semanticLabel,
      enabled: enabled,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: PostalTokens.minTouchTarget,
          minHeight: PostalTokens.minTouchTarget,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: effectiveOnTap,
            borderRadius: PostalTokens.shapeSm,
            child: Align(alignment: Alignment.center, child: child),
          ),
        ),
      ),
    );
  }
}
