import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

/// 写信编辑器工具栏：撤销栈 + 字数（可扩展更多工具）。
class ComposeEditorToolbar extends StatelessWidget {
  const ComposeEditorToolbar({
    super.key,
    required this.canUndo,
    required this.onUndo,
    required this.wordCountLabel,
    required this.undoTooltip,
  });

  final bool canUndo;
  final VoidCallback? onUndo;
  final String wordCountLabel;
  final String undoTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: PostalTokens.paperEnvelope.withValues(alpha: 0.88),
        border: Border(
          top: BorderSide(
            color: PostalTokens.perforationLine.withValues(alpha: 0.85),
          ),
          bottom: BorderSide(
            color: PostalTokens.perforationLine.withValues(alpha: 0.55),
          ),
        ),
      ),
      child: Row(
        children: [
          Tooltip(
            message: undoTooltip,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canUndo ? onUndo : null,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🔙',
                        style: TextStyle(
                          fontSize: 18,
                          color: canUndo
                              ? PostalTokens.postboxGreen
                              : PostalTokens.inkTertiary.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        undoTooltip,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: canUndo
                              ? PostalTokens.postboxGreen
                              : PostalTokens.inkTertiary.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(
            wordCountLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: PostalTokens.inkSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

/// 正文字数：去首尾空白后统计 rune 数（中英文一致）。
int composeBodyWordCount(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return 0;
  return trimmed.runes.length;
}
