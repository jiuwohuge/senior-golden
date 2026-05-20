import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';
import 'postal_checkbox_field.dart';

/// 页脚协议说明（无勾选框），居中小号字 + 可点链接。
class PostalLegalFootnote extends StatelessWidget {
  const PostalLegalFootnote({
    super.key,
    required this.template,
    required this.linkSegments,
  });

  final String template;
  final List<PostalLinkSegment> linkSegments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodySmall?.copyWith(
      color: PostalTokens.inkTertiary,
      fontSize: 12,
      height: 1.4,
    );
    final linkStyle = baseStyle?.copyWith(
      color: PostalTokens.postboxGreen,
      decoration: TextDecoration.underline,
      decorationColor: PostalTokens.postboxGreen,
      fontWeight: FontWeight.w600,
    );

    final spans = <InlineSpan>[];
    final regex = RegExp(r'\{([a-zA-Z_]+)\}');
    var lastEnd = 0;
    for (final m in regex.allMatches(template)) {
      if (m.start > lastEnd) {
        spans.add(TextSpan(text: template.substring(lastEnd, m.start)));
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
    if (lastEnd < template.length) {
      spans.add(TextSpan(text: template.substring(lastEnd)));
    }

    return Text.rich(
      TextSpan(style: baseStyle, children: spans),
      textAlign: TextAlign.center,
    );
  }
}
