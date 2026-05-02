import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

/// 协议勾选 + 内联富文本：支持点击多个链接（用户协议、隐私政策）。
class PostalCheckboxField extends StatelessWidget {
  const PostalCheckboxField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.linkSegments = const [],
    this.error,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  /// 主体文本，使用 `{terms}` `{privacy}` 等占位插入链接段。
  /// 例如：`'I agree to {terms} and {privacy}.'`
  final String label;

  /// 链接段（按 key 替换 `{key}`）。
  final List<PostalLinkSegment> linkSegments;

  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = onChanged == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: disabled ? null : () => onChanged!(!value),
          borderRadius: PostalTokens.shapeSm,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: PostalTokens.s8,
              horizontal: PostalTokens.s4,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: value,
                    onChanged: disabled
                        ? null
                        : (v) => onChanged!(v ?? false),
                    materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: PostalTokens.s12),
                Expanded(
                  child: _buildRichText(theme, disabled),
                ),
              ],
            ),
          ),
        ),
        if (error != null && error!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 2),
            child: Text(
              error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: PostalTokens.stampVermilion,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRichText(ThemeData theme, bool disabled) {
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(
      color: disabled
          ? PostalTokens.inkSecondary.withValues(alpha: 0.5)
          : PostalTokens.inkNavy,
      fontSize: 15,
      height: 1.5,
    );
    final linkStyle = baseStyle?.copyWith(
      color: PostalTokens.postboxGreen,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationColor: PostalTokens.postboxGreen,
    );

    final spans = <InlineSpan>[];
    final regex = RegExp(r'\{([a-zA-Z_]+)\}');
    int lastEnd = 0;
    for (final m in regex.allMatches(label)) {
      if (m.start > lastEnd) {
        spans.add(TextSpan(text: label.substring(lastEnd, m.start)));
      }
      final key = m.group(1)!;
      PostalLinkSegment? seg;
      for (final item in linkSegments) {
        if (item.key == key) {
          seg = item;
          break;
        }
      }
      if (seg != null) {
        spans.add(
          TextSpan(
            text: seg.text,
            style: linkStyle,
            recognizer: TapGestureRecognizer()..onTap = seg.onTap,
          ),
        );
      } else {
        spans.add(TextSpan(text: m.group(0)));
      }
      lastEnd = m.end;
    }
    if (lastEnd < label.length) {
      spans.add(TextSpan(text: label.substring(lastEnd)));
    }

    return Text.rich(
      TextSpan(style: baseStyle, children: spans),
    );
  }
}

class PostalLinkSegment {
  PostalLinkSegment({
    required this.key,
    required this.text,
    required this.onTap,
  });

  final String key;
  final String text;
  final VoidCallback onTap;
}
