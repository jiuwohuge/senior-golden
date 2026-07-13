import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'letter_document.dart';
import 'letter_paper.dart';

export 'letter_document.dart' show letterSkinBackground, LetterDocument;

/// 兼容旧调用的整屏写信控件（单正文，非多段落框）。
class LetterComposeEditor extends StatefulWidget {
  const LetterComposeEditor({
    super.key,
    this.initialText,
    this.initialParagraphs,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final String? initialText;
  final List<String>? initialParagraphs;
  final ValueChanged<String> onChanged;
  final String? label;
  final bool enabled;

  static String joinParagraphs(List<String> paragraphs) =>
      LetterDocument.joinParagraphs(paragraphs);

  static List<String> splitBody(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return [''];
    final parts = trimmed
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.isEmpty ? [''] : parts;
  }

  @override
  State<LetterComposeEditor> createState() => _LetterComposeEditorState();
}

class _LetterComposeEditorState extends State<LetterComposeEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final seed =
        widget.initialText != null && widget.initialText!.trim().isNotEmpty
        ? widget.initialText!
        : (widget.initialParagraphs?.isNotEmpty == true
              ? LetterDocument.joinParagraphs(widget.initialParagraphs!)
              : '');
    _controller = TextEditingController(text: seed);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.composeBodyLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        IgnorePointer(
          ignoring: !widget.enabled,
          child: Opacity(
            opacity: widget.enabled ? 1 : 0.55,
            child: LetterPaper(
              mode: LetterPaperMode.compose,
              document: LetterDocument(body: _controller.text),
              controller: _controller,
              placeholder: l10n.composePlaceholderBody,
              onBodyChanged: widget.onChanged,
              minHeight: 200,
            ),
          ),
        ),
      ],
    );
  }
}
