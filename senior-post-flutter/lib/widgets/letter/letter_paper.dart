import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';
import 'letter_document.dart';

/// 写信 / 预览 / 读信三态共用的信纸渲染器（写读像素级一致）。
enum LetterPaperMode { compose, preview, read }

/// 一张信纸：纸色 + 字体字号 + 正文；compose 态内嵌可编辑 TextField。
class LetterPaper extends StatelessWidget {
  const LetterPaper({
    super.key,
    required this.mode,
    required this.document,
    this.controller,
    this.focusNode,
    this.onBodyChanged,
    this.placeholder,
    this.minHeight = 280,
    this.readOnlyOverlay,
    this.header,
    this.footer,
  });

  final LetterPaperMode mode;
  final LetterDocument document;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onBodyChanged;
  final String? placeholder;
  final double minHeight;

  /// 读信隐藏正文时叠在纸上的遮罩（由调用方提供）。
  final Widget? readOnlyOverlay;

  /// 写信桌：邮票条贴在信纸上沿。
  final Widget? header;

  /// 写信桌：字数/撤销/信纸/助手贴在纸脚。
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final tokens = LetterPaperTokens.forSkin(document.skinId);
    final style = letterBodyTextStyle(
      fontId: document.fontId,
      tier: document.fontSizeTier,
      ink: tokens.ink,
    );

    // compose 态填满父级；preview/read 仍按内容 + minHeight 伸展。
    final paper = AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: tokens.background,
        borderRadius: PostalTokens.shapeLg,
        border: Border.all(color: PostalTokens.kraftBrownMuted, width: 1.2),
        boxShadow: PostalTokens.shadowCard,
      ),
      child: ClipRRect(
        borderRadius: PostalTokens.shapeLg,
        child: Stack(
          children: [
            // 左侧装订线，强化「真信纸」而非卡片表单。
            Positioned(
              left: 18,
              top: 16,
              bottom: 16,
              child: Container(
                width: 1.5,
                color: PostalTokens.kraftBrown.withValues(alpha: 0.28),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                32,
                mode == LetterPaperMode.compose ? 8 : 22,
                20,
                mode == LetterPaperMode.compose ? 8 : 22,
              ),
              child: mode == LetterPaperMode.compose
                  ? Column(
                      children: [
                        if (header != null) header!,
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 4),
                            child: _ComposeField(
                              controller: controller!,
                              focusNode: focusNode,
                              style: style,
                              placeholder: placeholder,
                              onChanged: onBodyChanged,
                            ),
                          ),
                        ),
                        if (footer != null) footer!,
                      ],
                    )
                  : _ReadBody(
                      body: document.body,
                      style: style,
                      overlay: readOnlyOverlay,
                    ),
            ),
          ],
        ),
      ),
    );

    if (mode == LetterPaperMode.compose) {
      return SizedBox.expand(child: paper);
    }
    return paper;
  }
}

class _ComposeField extends StatelessWidget {
  const _ComposeField({
    required this.controller,
    required this.style,
    this.focusNode,
    this.placeholder,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextStyle style;
  final String? placeholder;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    // 显式关掉主题 OutlineInputBorder，避免聚焦绿框只包住 minLines 高度。
    const none = InputBorder.none;
    return SizedBox.expand(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        expands: true,
        maxLines: null,
        minLines: null,
        keyboardType: TextInputType.multiline,
        textAlignVertical: TextAlignVertical.top,
        style: style,
        cursorColor: PostalTokens.postboxGreen,
        decoration: InputDecoration(
          isCollapsed: true,
          border: none,
          enabledBorder: none,
          focusedBorder: none,
          disabledBorder: none,
          errorBorder: none,
          focusedErrorBorder: none,
          filled: false,
          contentPadding: EdgeInsets.zero,
          hintText: placeholder,
          hintStyle: style.copyWith(
            color: PostalTokens.inkTertiary.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}

class _ReadBody extends StatelessWidget {
  const _ReadBody({
    required this.body,
    required this.style,
    this.overlay,
  });

  final String body;
  final TextStyle style;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      body.isEmpty ? ' ' : body,
      style: style,
    );
    if (overlay == null) return text;
    return Stack(
      children: [
        text,
        Positioned.fill(child: overlay!),
      ],
    );
  }
}
