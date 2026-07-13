import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../widgets/postal/postal.dart';
import '../mailbox/mailbox_remote.dart';

/// 信件助手帮助模式（与后端 helpMode 对齐）。
enum LetterAssistantHelpMode {
  warmer,
  natural,
  expand,
  polite,
  translate,
  custom,
}

/// 半屏信件助手：选模式 → 对照预览 → 替换/保留/再改。
/// 返回建议稿（用户点「替换原文」）或 null（保留/关闭）。
Future<String?> showLetterAssistantSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String sourceText,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: PostalTokens.paperEnvelope,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return LetterAssistantSheet(
        sourceText: sourceText,
        onRequestAssist: (mode, custom, targetLang) {
          return ref.read(mailboxRemoteRepositoryProvider).letterAssistant(
                sourceText: sourceText,
                helpMode: mode.name,
                customInstruction: custom,
                targetLang: targetLang,
              );
        },
      );
    },
  );
}

/// 信件助手半屏内容（可挂写信桌 / 回信框）。
class LetterAssistantSheet extends StatefulWidget {
  const LetterAssistantSheet({
    super.key,
    required this.sourceText,
    required this.onRequestAssist,
  });

  final String sourceText;
  final Future<String> Function(
    LetterAssistantHelpMode mode,
    String? customInstruction,
    String? targetLang,
  ) onRequestAssist;

  @override
  State<LetterAssistantSheet> createState() => _LetterAssistantSheetState();
}

class _LetterAssistantSheetState extends State<LetterAssistantSheet> {
  LetterAssistantHelpMode _mode = LetterAssistantHelpMode.natural;
  final _customCtrl = TextEditingController();
  String? _suggestion;
  bool _busy = false;
  /// true=对照预览；false=模式选择
  bool _comparePhase = false;

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final l10n = AppLocalizations.of(context)!;
    if (widget.sourceText.trim().isEmpty) {
      PostalSnack.show(
        context,
        l10n.letterAssistantEmptyBody,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final suggestion = await widget.onRequestAssist(
        _mode,
        _mode == LetterAssistantHelpMode.custom
            ? _customCtrl.text.trim()
            : null,
        _mode == LetterAssistantHelpMode.translate ? 'en' : null,
      );
      if (!mounted) return;
      setState(() {
        _suggestion = suggestion;
        _comparePhase = true;
      });
    } catch (e) {
      debugPrint('letter assistant failed: $e');
      if (!mounted) return;
      final biz = apiBusinessExceptionFrom(e);
      PostalSnack.show(
        context,
        biz?.message ?? e.toString(),
        tone: PostalSnackTone.error,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _modeLabel(AppLocalizations l10n, LetterAssistantHelpMode m) {
    return switch (m) {
      LetterAssistantHelpMode.warmer => l10n.letterAssistantModeWarmer,
      LetterAssistantHelpMode.natural => l10n.letterAssistantModeNatural,
      LetterAssistantHelpMode.expand => l10n.letterAssistantModeExpand,
      LetterAssistantHelpMode.polite => l10n.letterAssistantModePolite,
      LetterAssistantHelpMode.translate => l10n.letterAssistantModeTranslate,
      LetterAssistantHelpMode.custom => l10n.letterAssistantModeCustom,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final height = MediaQuery.of(context).size.height * 0.72;
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PostalTokens.perforationLine,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.letterAssistantTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _comparePhase ? _buildCompare(l10n) : _buildModes(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModes(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            children: [
              for (final m in LetterAssistantHelpMode.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: _mode == m
                        ? PostalTokens.postboxGreen.withValues(alpha: 0.12)
                        : PostalTokens.paperCard,
                    borderRadius: PostalTokens.shapeMd,
                    child: InkWell(
                      onTap: _busy ? null : () => setState(() => _mode = m),
                      borderRadius: PostalTokens.shapeMd,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 56),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Text(
                            _modeLabel(l10n, m),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: _mode == m
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: PostalTokens.inkNavy,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_mode == LetterAssistantHelpMode.custom) ...[
                const SizedBox(height: 4),
                PostalTextField(
                  controller: _customCtrl,
                  label: l10n.letterAssistantCustomHint,
                  maxLines: 3,
                  minLines: 2,
                  showClearButton: true,
                ),
              ],
            ],
          ),
        ),
        PostalButton(
          label: _busy ? l10n.letterAssistantBusy : l10n.letterAssistantGenerate,
          busy: _busy,
          onPressed: _busy ? null : _generate,
        ),
      ],
    );
  }

  Widget _buildCompare(AppLocalizations l10n) {
    final suggestion = _suggestion ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            children: [
              Text(
                l10n.letterAssistantYourDraft,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _DraftBlock(text: widget.sourceText),
              const SizedBox(height: 20),
              Text(
                l10n.letterAssistantSuggestion,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _DraftBlock(text: suggestion, emphasize: true),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PostalButton(
          label: l10n.letterAssistantReplace,
          onPressed: () => Navigator.pop(context, suggestion),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: PostalButton(
                label: l10n.letterAssistantKeep,
                variant: PostalButtonVariant.secondary,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PostalButton(
                label: l10n.letterAssistantRetry,
                variant: PostalButtonVariant.secondary,
                onPressed: () => setState(() {
                  _comparePhase = false;
                  _suggestion = null;
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DraftBlock extends StatelessWidget {
  const _DraftBlock({required this.text, this.emphasize = false});

  final String text;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: emphasize
            ? PostalTokens.postboxGreen.withValues(alpha: 0.08)
            : PostalTokens.paperCard,
        borderRadius: PostalTokens.shapeMd,
        border: Border.all(
          color: emphasize
              ? PostalTokens.postboxGreen.withValues(alpha: 0.35)
              : PostalTokens.perforationLine,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 17,
          height: 1.45,
          color: PostalTokens.inkNavy,
          fontWeight: emphasize ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
