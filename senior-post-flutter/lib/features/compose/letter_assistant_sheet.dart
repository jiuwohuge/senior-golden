import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../widgets/postal/postal.dart';
import '../mailbox/mailbox_remote.dart';

/// 信件助手帮助模式（API helpMode：continue/shorten/inspire 等）。
enum LetterAssistantHelpMode { warmer, natural, continueChat, shorten, inspire }

extension on LetterAssistantHelpMode {
  /// 发给后端的 helpMode 字符串。
  String get apiName => switch (this) {
    LetterAssistantHelpMode.continueChat => 'continue',
    _ => name,
  };

  bool get isInspire => this == LetterAssistantHelpMode.inspire;
}

/// P0 只暴露润色 natural 与灵感 inspire，降低写信门槛。
const _p0AssistantModes = [
  LetterAssistantHelpMode.natural,
  LetterAssistantHelpMode.inspire,
];

/// 写信桌上的轻量快捷菜单：先选动作，再进入结果页，避免为了两个选项打开整页。
Future<LetterAssistantHelpMode?> showLetterAssistantQuickActions(
  BuildContext context, {
  required bool hasDraft,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showGeneralDialog<LetterAssistantHelpMode>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: PostalTokens.durationMedium,
    pageBuilder: (ctx, _, __) => SafeArea(
      child: Stack(
        children: [
          Positioned(
            right: 16,
            bottom: 78,
            width: 240,
            child: Material(
              color: PostalTokens.paperEnvelope,
              elevation: 8,
              borderRadius: PostalTokens.shapeLg,
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QuickAssistantAction(
                    icon: Icons.auto_fix_high_outlined,
                    label: l10n.letterAssistantModeNatural,
                    subtitle: hasDraft ? null : l10n.letterAssistantEmptyBody,
                    onTap: hasDraft
                        ? () => Navigator.pop(
                            ctx,
                            LetterAssistantHelpMode.natural,
                          )
                        : null,
                  ),
                  const Divider(height: 1),
                  _QuickAssistantAction(
                    icon: Icons.lightbulb_outline,
                    label: l10n.letterAssistantModeInspire,
                    onTap: () =>
                        Navigator.pop(ctx, LetterAssistantHelpMode.inspire),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    transitionBuilder: (ctx, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.94, end: 1.0).animate(curved),
          alignment: Alignment.bottomRight,
          child: child,
        ),
      );
    },
  );
}

/// 全屏信件助手：润色对照替换，或灵感选题追加。
/// 返回最终正文（替换/追加后）或 null（保留/关闭）。
/// 不可点遮罩关闭，须点顶部关闭或「保留原文」。
Future<String?> showLetterAssistantSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String sourceText,
  LetterAssistantHelpMode? initialMode,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    useSafeArea: true,
    backgroundColor: PostalTokens.paperCream,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (ctx) => SizedBox(
      height: MediaQuery.sizeOf(ctx).height * 0.9,
      child: LetterAssistantSheet(
        sourceText: sourceText,
        initialMode: initialMode,
        onRequestAssist: (mode) => ref
            .read(mailboxRemoteRepositoryProvider)
            .letterAssistant(
              sourceText: sourceText,
              helpMode: mode.apiName,
              languageCode: Localizations.localeOf(context).languageCode,
            ),
      ),
    ),
  );
}

/// 信件助手全屏页（写信桌 / 回信框共用）：信封纸感 + 对照可读长文。
class LetterAssistantSheet extends StatefulWidget {
  const LetterAssistantSheet({
    super.key,
    required this.sourceText,
    required this.onRequestAssist,
    this.initialMode,
  });

  final String sourceText;
  final LetterAssistantHelpMode? initialMode;
  final Future<LetterAssistantResult> Function(LetterAssistantHelpMode mode)
  onRequestAssist;

  @override
  State<LetterAssistantSheet> createState() => _LetterAssistantSheetState();
}

class _LetterAssistantSheetState extends State<LetterAssistantSheet> {
  late LetterAssistantHelpMode _mode;
  LetterAssistantResult? _result;
  bool _busy = false;
  String? _inlineMessage;
  bool _inlineIsError = false;

  /// true=结果页；false=模式选择
  bool _resultPhase = false;
  final Set<String> _pickedTopics = {};

  @override
  void initState() {
    super.initState();
    // 空白信纸默认灵感，避免先点到「更自然」再被拦截。
    _mode =
        widget.initialMode ??
        (widget.sourceText.trim().isEmpty
            ? LetterAssistantHelpMode.inspire
            : LetterAssistantHelpMode.natural);
    if (widget.initialMode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
    }
  }

  Future<void> _generate() async {
    final l10n = AppLocalizations.of(context)!;
    if (widget.sourceText.trim().isEmpty && !_mode.isInspire) {
      setState(() {
        _inlineMessage = l10n.letterAssistantEmptyBody;
        _inlineIsError = false;
      });
      return;
    }
    setState(() {
      _busy = true;
      _resultPhase = false;
      _result = null;
      _inlineMessage = null;
    });
    try {
      final result = await widget.onRequestAssist(_mode);
      if (!mounted) return;
      setState(() {
        _result = result;
        _resultPhase = true;
        _pickedTopics
          ..clear()
          ..addAll(result.inspireAsk)
          ..addAll(result.inspireShare);
        _inlineMessage = null;
      });
    } catch (e) {
      debugPrint('letter assistant failed: $e');
      if (!mounted) return;
      final biz = apiBusinessExceptionFrom(e);
      setState(() {
        _inlineMessage = biz?.message.isNotEmpty == true
            ? biz!.message
            : l10n.commonActionFailed;
        _inlineIsError = true;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _modeLabel(AppLocalizations l10n, LetterAssistantHelpMode m) {
    return switch (m) {
      LetterAssistantHelpMode.warmer => l10n.letterAssistantModeWarmer,
      LetterAssistantHelpMode.natural => l10n.letterAssistantModeNatural,
      LetterAssistantHelpMode.continueChat => l10n.letterAssistantModeContinue,
      LetterAssistantHelpMode.shorten => l10n.letterAssistantModeShorten,
      LetterAssistantHelpMode.inspire => l10n.letterAssistantModeInspire,
    };
  }

  /// 将勾选话题追加到原文末尾（固定衔接语）。
  String _appendInspire(AppLocalizations l10n) {
    final picked = _pickedTopics.toList();
    if (picked.isEmpty) {
      return widget.sourceText;
    }
    final buf = StringBuffer(widget.sourceText.trimRight());
    buf.writeln();
    buf.writeln();
    buf.writeln(l10n.letterAssistantInspireBridge);
    for (final t in picked) {
      buf.writeln('• $t');
    }
    return buf.toString().trimRight();
  }

  void _closeWithoutApply() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: PostalTokens.paperCream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AssistantAppBar(
              title: l10n.letterAssistantTitle,
              closeLabel: l10n.letterAssistantClose,
              onClose: _closeWithoutApply,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: _resultPhase ? _buildResult(l10n) : _buildModes(l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModes(AppLocalizations l10n) {
    // 写信页已经在快捷浮层选过模式。这里仅展示该动作的生成状态，
    // 即使请求失败也不退回模式选择，避免让用户重复选择一次。
    if (widget.initialMode != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_busy)
              const CircularProgressIndicator()
            else
              Icon(Icons.error_outline, size: 40, color: PostalTokens.error),
            const SizedBox(height: 16),
            Text(
              _busy
                  ? l10n.letterAssistantBusy
                  : (_inlineMessage ?? l10n.letterAssistantBusy),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _busy ? PostalTokens.inkNavy : PostalTokens.error,
              ),
            ),
            if (!_busy) ...[
              const SizedBox(height: 20),
              PostalButton(
                label: l10n.letterAssistantRetry,
                onPressed: _generate,
              ),
            ],
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.letterAssistantPickModeHint,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: PostalTokens.inkSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView(
            children: [
              for (final m in _p0AssistantModes)
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        constraints: const BoxConstraints(minHeight: 60),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: PostalTokens.shapeMd,
                          border: Border.all(
                            color: _mode == m
                                ? PostalTokens.postboxGreen.withValues(
                                    alpha: 0.45,
                                  )
                                : PostalTokens.perforationLine,
                          ),
                        ),
                        child: Text(
                          _modeLabel(l10n, m),
                          style: TextStyle(
                            fontSize: 19,
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
            ],
          ),
        ),
        if (_inlineMessage != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              _inlineMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _inlineIsError
                    ? PostalTokens.error
                    : PostalTokens.inkSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
        PostalButton(
          label: _busy
              ? l10n.letterAssistantBusy
              : (_mode.isInspire
                    ? l10n.letterAssistantInspireGenerate
                    : l10n.letterAssistantGenerate),
          busy: _busy,
          onPressed: _busy ? null : _generate,
        ),
      ],
    );
  }

  Widget _buildResult(AppLocalizations l10n) {
    final result = _result;
    if (result == null) {
      return const SizedBox.shrink();
    }
    if (result.isInspire) {
      return _buildInspire(l10n, result);
    }
    return _buildCompare(l10n, result.suggestion);
  }

  Widget _buildCompare(AppLocalizations l10n, String suggestion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            children: [
              Text(
                l10n.letterAssistantYourDraft,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _DraftBlock(text: widget.sourceText),
              const SizedBox(height: 22),
              Text(
                l10n.letterAssistantSuggestion,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _DraftBlock(text: suggestion, emphasize: true),
              const SizedBox(height: 8),
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
                onPressed: _closeWithoutApply,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PostalButton(
                label: l10n.letterAssistantRetry,
                variant: PostalButtonVariant.secondary,
                onPressed: _generate,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInspire(AppLocalizations l10n, LetterAssistantResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.letterAssistantInspirePickHint,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: PostalTokens.inkSecondary),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: [
              if (result.inspireAsk.isNotEmpty) ...[
                Text(
                  l10n.letterAssistantInspireAskTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                for (final t in result.inspireAsk)
                  _TopicCheckTile(
                    label: t,
                    selected: _pickedTopics.contains(t),
                    onChanged: (v) => setState(() {
                      if (v) {
                        _pickedTopics.add(t);
                      } else {
                        _pickedTopics.remove(t);
                      }
                    }),
                  ),
                const SizedBox(height: 16),
              ],
              if (result.inspireShare.isNotEmpty) ...[
                Text(
                  l10n.letterAssistantInspireShareTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                for (final t in result.inspireShare)
                  _TopicCheckTile(
                    label: t,
                    selected: _pickedTopics.contains(t),
                    onChanged: (v) => setState(() {
                      if (v) {
                        _pickedTopics.add(t);
                      } else {
                        _pickedTopics.remove(t);
                      }
                    }),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        PostalButton(
          label: l10n.letterAssistantInspireAppend,
          onPressed: _pickedTopics.isEmpty
              ? null
              : () => Navigator.pop(context, _appendInspire(l10n)),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: PostalButton(
                label: l10n.letterAssistantKeep,
                variant: PostalButtonVariant.secondary,
                onPressed: _closeWithoutApply,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PostalButton(
                label: l10n.letterAssistantRetry,
                variant: PostalButtonVariant.secondary,
                onPressed: _generate,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickAssistantAction extends StatelessWidget {
  const _QuickAssistantAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: enabled
                    ? PostalTokens.postboxGreen
                    : PostalTokens.inkTertiary,
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: enabled
                            ? PostalTokens.inkNavy
                            : PostalTokens.inkTertiary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (enabled)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: PostalTokens.inkTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 顶栏：标题左置 + 明确「关闭」文案，避免误点遮罩丢结果。
class _AssistantAppBar extends StatelessWidget {
  const _AssistantAppBar({
    required this.title,
    required this.closeLabel,
    required this.onClose,
  });

  final String title;
  final String closeLabel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: PostalTokens.inkNavy,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: onClose,
            child: Text(
              closeLabel,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: PostalTokens.postboxGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicCheckTile extends StatelessWidget {
  const _TopicCheckTile({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: selected,
      onChanged: (v) => onChanged(v ?? false),
      title: Text(label, style: const TextStyle(fontSize: 17, height: 1.35)),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: PostalTokens.postboxGreen,
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
      padding: const EdgeInsets.all(16),
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
      child: SelectableText(
        text,
        style: TextStyle(
          fontSize: 17,
          height: 1.5,
          color: PostalTokens.inkNavy,
          fontWeight: emphasize ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
