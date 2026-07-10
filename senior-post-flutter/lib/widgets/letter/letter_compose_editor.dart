import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../postal/postal_text_field.dart';

/// 多段落写信控件：段间空行，提交时用 `\n\n` 拼接正文。
///
/// 更换模板时请用新 [Key] 重建本组件（传入新的 [initialParagraphs]）。
class LetterComposeEditor extends StatefulWidget {
  const LetterComposeEditor({
    super.key,
    this.initialText,
    this.initialParagraphs,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  /// 已有正文（按 `\n\n` 拆段）；优先于 [initialParagraphs]。
  final String? initialText;
  final List<String>? initialParagraphs;
  final ValueChanged<String> onChanged;
  final String? label;
  final bool enabled;

  /// 将段落列表拼为发信正文。
  static String joinParagraphs(List<String> paragraphs) {
    return paragraphs
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .join('\n\n');
  }

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
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final seed =
        widget.initialText != null && widget.initialText!.trim().isNotEmpty
        ? LetterComposeEditor.splitBody(widget.initialText!)
        : (widget.initialParagraphs?.isNotEmpty == true
              ? List<String>.from(widget.initialParagraphs!)
              : ['']);
    _controllers = seed.map((t) => TextEditingController(text: t)).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      LetterComposeEditor.joinParagraphs(
        _controllers.map((c) => c.text).toList(),
      ),
    );
  }

  void _addParagraph() {
    setState(() {
      _controllers.add(TextEditingController());
    });
    _emit();
  }

  void _removeParagraph(int index) {
    if (_controllers.length <= 1) return;
    setState(() {
      _controllers.removeAt(index).dispose();
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = widget.label ?? l10n.composeBodyLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _controllers.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PostalTextField(
                  controller: _controllers[i],
                  label: i == 0 ? label : l10n.composeParagraphLabel(i + 1),
                  maxLines: 5,
                  minLines: 3,
                  showClearButton: false,
                  enabled: widget.enabled,
                  onChanged: (_) => _emit(),
                ),
              ),
              if (_controllers.length > 1)
                IconButton(
                  tooltip: l10n.composeRemoveParagraph,
                  onPressed: widget.enabled ? () => _removeParagraph(i) : null,
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: PostalTokens.stampVermilion,
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: widget.enabled ? _addParagraph : null,
            icon: const Icon(Icons.add),
            label: Text(l10n.composeAddParagraph),
          ),
        ),
      ],
    );
  }
}

/// 读信页信纸背景色（按 skinId）。
Color letterSkinBackground(String? skinId) {
  return switch (skinId) {
    'vintage' => const Color(0xFFF3E6C8),
    'linen' => const Color(0xFFF7F1E3),
    _ => PostalTokens.paperCream,
  };
}
