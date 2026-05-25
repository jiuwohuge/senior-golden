import 'package:flutter/material.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../widgets/postal/postal_painters.dart';

/// 主流 IM 风格输入栏：底部纸感底栏 + 圆角胶囊输入框 + 动态发送钮。
class ChatComposerBar extends StatefulWidget {
  const ChatComposerBar({
    super.key,
    required this.controller,
    required this.busy,
    required this.onSend,
    required this.onEmojiTap,
  });

  final TextEditingController controller;
  final bool busy;
  final VoidCallback? onSend;
  final VoidCallback? onEmojiTap;

  @override
  State<ChatComposerBar> createState() => _ChatComposerBarState();
}

class _ChatComposerBarState extends State<ChatComposerBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final next = widget.controller.text.trim().isNotEmpty;
    if (next != _hasText && mounted) {
      setState(() => _hasText = next);
    }
  }

  void _submit() {
    if (widget.busy || widget.onSend == null || !_hasText) {
      return;
    }
    widget.onSend!();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canSend = _hasText && !widget.busy && widget.onSend != null;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: PostalTokens.paperEnvelope.withValues(alpha: 0.98),
        border: Border(
          top: BorderSide(
            color: PostalTokens.kraftBrown.withValues(alpha: 0.22),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: PostalTokens.inkNavy.withValues(alpha: 0.06),
            offset: const Offset(0, -4),
            blurRadius: 18,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PostalPerforationStrip(height: 6),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _ComposerCircleButton(
                    tooltip: l10n.chatEmojiPickerTitle,
                    icon: Icons.emoji_emotions_outlined,
                    enabled: !widget.busy && widget.onEmojiTap != null,
                    onTap: widget.onEmojiTap ?? () {},
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: PostalTokens.kraftBrown.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: PostalTokens.inkNavy.withValues(alpha: 0.04),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: widget.controller,
                        enabled: !widget.busy,
                        minLines: 1,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _submit(),
                        style: textTheme.bodyLarge?.copyWith(
                          color: PostalTokens.inkNavy,
                          height: 1.35,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.chatComposerHint,
                          hintStyle: textTheme.bodyLarge?.copyWith(
                            color: PostalTokens.inkTertiary,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _SendOrbButton(
                    busy: widget.busy,
                    enabled: canSend,
                    onPressed: canSend ? _submit : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposerCircleButton extends StatelessWidget {
  const _ComposerCircleButton({
    required this.tooltip,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: PostalTokens.postboxGreen.withValues(alpha: 0.1),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              size: 22,
              color: enabled
                  ? PostalTokens.postboxGreen
                  : PostalTokens.inkTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SendOrbButton extends StatelessWidget {
  const _SendOrbButton({
    required this.busy,
    required this.enabled,
    this.onPressed,
  });

  final bool busy;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PostalTokens.durationMedium,
      curve: Curves.easeOutCubic,
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: enabled
            ? PostalTokens.postboxGreen
            : PostalTokens.inkTertiary.withValues(alpha: 0.28),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: PostalTokens.postboxGreen.withValues(alpha: 0.35),
                  offset: const Offset(0, 3),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          splashColor: Colors.white.withValues(alpha: 0.22),
          child: Center(
            child: busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    Icons.arrow_upward_rounded,
                    size: 22,
                    color: enabled ? Colors.white : Colors.white70,
                  ),
          ),
        ),
      ),
    );
  }
}
