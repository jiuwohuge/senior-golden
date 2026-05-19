import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

/// 邮政风内联操作链：邮戳红条 + 图标 + 下划线字，用于「忘记密码」等次要跳转。
class PostalInlineLink extends StatefulWidget {
  const PostalInlineLink({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.mark_email_unread_outlined,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool enabled;

  @override
  State<PostalInlineLink> createState() => _PostalInlineLinkState();
}

class _PostalInlineLinkState extends State<PostalInlineLink> {
  bool _pressed = false;

  bool get _canTap => widget.enabled && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = _canTap
        ? PostalTokens.postboxGreen
        : PostalTokens.postboxGreen.withValues(alpha: 0.38);
    final vermilion = _canTap
        ? PostalTokens.stampVermilion
        : PostalTokens.stampVermilion.withValues(alpha: 0.35);

    return Semantics(
      button: true,
      enabled: _canTap,
      label: widget.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _canTap ? widget.onPressed : null,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: PostalTokens.shapeLg,
          splashColor: PostalTokens.postboxGreen.withValues(alpha: 0.08),
          highlightColor: PostalTokens.stampVermilionMuted.withValues(alpha: 0.45),
          child: AnimatedScale(
            scale: _pressed && _canTap ? 0.97 : 1,
            duration: PostalTokens.durationFast,
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: PostalTokens.durationFast,
              padding: const EdgeInsets.fromLTRB(10, 7, 14, 7),
              decoration: BoxDecoration(
                borderRadius: PostalTokens.shapeLg,
                color: _pressed && _canTap
                    ? PostalTokens.stampVermilionMuted.withValues(alpha: 0.55)
                    : PostalTokens.paperEnvelope,
                border: Border.all(
                  color: PostalTokens.kraftBrownMuted.withValues(
                    alpha: _canTap ? 0.85 : 0.45,
                  ),
                  width: 1,
                ),
                boxShadow: _canTap ? PostalTokens.shadowSoft : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: vermilion,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  Icon(widget.icon, size: 17, color: vermilion),
                  const SizedBox(width: 6),
                  Text(
                    widget.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: ink,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.25,
                      height: 1.1,
                      decoration: TextDecoration.underline,
                      decorationColor: vermilion.withValues(alpha: 0.55),
                      decorationThickness: 1.4,
                      decorationStyle: TextDecorationStyle.dotted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
