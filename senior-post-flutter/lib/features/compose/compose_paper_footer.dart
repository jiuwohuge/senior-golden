import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

/// 信纸纸脚：字数、撤销、信纸、助手。键盘弹起时变矮但不消失。
class ComposePaperFooter extends StatelessWidget {
  const ComposePaperFooter({
    super.key,
    required this.wordCountLabel,
    required this.canUndo,
    required this.onUndo,
    required this.undoLabel,
    required this.paperLabel,
    required this.assistantLabel,
    required this.onPaper,
    required this.onAssistant,
    required this.compact,
  });

  final String wordCountLabel;
  final bool canUndo;
  final VoidCallback onUndo;
  final String undoLabel;
  final String paperLabel;
  final String assistantLabel;
  final VoidCallback onPaper;
  final VoidCallback onAssistant;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final pad = compact ? 4.0 : 6.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(8, pad, 8, pad),
      child: Row(
        children: [
          Flexible(
            child: Text(
              wordCountLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: PostalTokens.inkSecondary,
              ),
            ),
          ),
          const SizedBox(width: 6),
          _TextTool(
            label: undoLabel,
            enabled: canUndo,
            onTap: onUndo,
            compact: compact,
          ),
          const Spacer(),
          _IconTextTool(
            icon: Icons.auto_awesome_mosaic_outlined,
            label: paperLabel,
            onTap: onPaper,
            compact: compact,
          ),
          _IconTextTool(
            icon: Icons.edit_note_outlined,
            label: assistantLabel,
            onTap: onAssistant,
            compact: compact,
          ),
        ],
      ),
    );
  }
}

class _TextTool extends StatelessWidget {
  const _TextTool({
    required this.label,
    required this.enabled,
    required this.onTap,
    required this.compact,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: PostalTokens.shapeSm,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: compact ? 40 : 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: enabled
                      ? PostalTokens.postboxGreen
                      : PostalTokens.inkTertiary.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconTextTool extends StatelessWidget {
  const _IconTextTool({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: PostalTokens.shapeSm,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: compact ? 2 : 4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: PostalTokens.postboxGreen),
                if (!compact) ...[
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: PostalTokens.postboxGreen,
                    ),
                  ),
                ] else
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: PostalTokens.postboxGreen,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
