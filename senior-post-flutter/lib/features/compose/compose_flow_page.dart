import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/models/domain_models.dart';
import '../../core/network/router_refresh.dart';
import '../../core/session/app_session.dart';
import '../../widgets/letter/letter_document.dart';
import '../../widgets/letter/letter_paper.dart';
import '../../widgets/postal/postal.dart';
import '../auth/auth_repository.dart';
import '../commerce/commerce_remote.dart';
import '../letter_drafts/letter_drafts_remote.dart';
import '../mailbox/mailbox_providers.dart';
import '../mailbox/mailbox_remote.dart';
import '../post_office/post_office_remote.dart';
import '../ritual/delivery_sent_overlay.dart';
import '../shell/main_shell.dart';
import '../time_letter/time_letter_providers.dart';
import '../time_letter/time_letter_remote.dart';
import '../time_letter/time_letter_seal_slider.dart';
import 'compose_editor_toolbar.dart';
import 'compose_first_preview_gate.dart';
import 'compose_intent.dart';
import 'letter_assistant_sheet.dart';

/// 单页写信桌：整屏正文 + 信纸设置 + 预览门闩（替代多步向导）。
class ComposeFlowPage extends ConsumerStatefulWidget {
  const ComposeFlowPage({
    super.key,
    this.initialIntent = const ComposeIntent(),
  });

  final ComposeIntent initialIntent;

  @override
  ConsumerState<ComposeFlowPage> createState() => _ComposeFlowPageState();
}

class _ComposeFlowPageState extends ConsumerState<ComposeFlowPage> {
  late ComposeKind? _kind;
  String? _peerId;
  String? _peerNickname;

  late final TextEditingController _bodyController;
  final FocusNode _bodyFocus = FocusNode();

  String? _selectedSkinId = LetterDocument.defaultSkinId;
  String? _selectedFontId = LetterDocument.defaultFontId;
  FontSizeTier _fontSizeTier = FontSizeTier.large;
  String? _selectedTemplateId;

  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 7));
  String? _daysHint;
  bool _busy = false;
  bool _previewGateDone = false;
  bool _sessionPreviewSeen = false;
  static const _kMaxUndoSteps = 30;

  /// 正文逐步撤销栈（助手替换/追加前压入快照）。
  final List<String> _bodyUndoStack = [];
  bool _draftBusy = false;

  /// 首封引导写信：隐藏撤销与存草稿。
  bool get _hideUndoAndDraft => widget.initialIntent.fromFirstLetterGuide;

  /// 从前置入口（用户卡/好友）带 peer 进入：锁定收件人，不可改回邮局/自己。
  bool get _recipientLocked =>
      (_kind == ComposeKind.penPalMail ||
          _kind == ComposeKind.penPalTimeLetter) &&
      _peerId != null &&
      _peerId!.isNotEmpty &&
      widget.initialIntent.peerId != null &&
      widget.initialIntent.peerId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _kind = widget.initialIntent.kind ?? ComposeKind.postOffice;
    _peerId = widget.initialIntent.peerId;
    _peerNickname = widget.initialIntent.peerNickname;
    _selectedTemplateId = widget.initialIntent.templateId;

    var initial = '';
    if (widget.initialIntent.initialParagraphs?.isNotEmpty == true) {
      initial = LetterDocument.joinParagraphs(
        widget.initialIntent.initialParagraphs!,
      );
    }
    _bodyController = TextEditingController(text: initial);
    _bodyController.addListener(() => setState(() {}));

    ComposeFirstPreviewGate.hasCompletedPreview().then((done) {
      if (mounted) setState(() => _previewGateDone = done);
    });
    if (_isTimeLetter) {
      _refreshDaysHint();
    }
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  bool get _isTimeLetter =>
      _kind == ComposeKind.selfTimeLetter ||
      _kind == ComposeKind.penPalTimeLetter;

  bool get _needsPenPal =>
      (_kind == ComposeKind.penPalMail ||
          _kind == ComposeKind.penPalTimeLetter) &&
      (_peerId == null || _peerId!.isEmpty);

  LetterDocument get _document => LetterDocument(
    body: _bodyController.text,
    skinId: _selectedSkinId ?? LetterDocument.defaultSkinId,
    fontId: _selectedFontId ?? LetterDocument.defaultFontId,
    fontSizeTier: _fontSizeTier,
    templateId: _selectedTemplateId,
  );

  String _offsetTimezoneId() {
    final offset = DateTime.now().timeZoneOffset;
    final totalMinutes = offset.inMinutes;
    final sign = totalMinutes >= 0 ? '+' : '-';
    final abs = totalMinutes.abs();
    final h = abs ~/ 60;
    final m = abs % 60;
    return '$sign${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  Future<void> _refreshDaysHint() async {
    try {
      final days = await ref
          .read(timeLetterRemoteProvider)
          .previewDaysUntil(_deliveryDate, _offsetTimezoneId());
      if (mounted) setState(() => _daysHint = '$days');
    } catch (_) {}
  }

  String _recipientLabel(AppLocalizations l10n) {
    switch (_kind) {
      case ComposeKind.postOffice:
        return l10n.composeRecipientPostOffice;
      case ComposeKind.selfTimeLetter:
        return l10n.composeRecipientSelf;
      case ComposeKind.penPalMail:
      case ComposeKind.penPalTimeLetter:
        return _peerNickname?.isNotEmpty == true
            ? '${l10n.composeRecipientPenPal} · ${_peerNickname!}'
            : l10n.composeRecipientPenPal;
      case null:
        return l10n.composeRecipientSheetTitle;
    }
  }

  Future<void> _openRecipientSheet() async {
    if (_recipientLocked) return;
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PostalTokens.paperEnvelope,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.composeRecipientSheetTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _RecipientTile(
                  title: l10n.composeRecipientPostOffice,
                  selected: _kind == ComposeKind.postOffice,
                  onTap: () {
                    setState(() {
                      _kind = ComposeKind.postOffice;
                      _peerId = null;
                      _peerNickname = null;
                    });
                    Navigator.pop(ctx);
                  },
                ),
                _RecipientTile(
                  title: l10n.composeRecipientSelf,
                  selected: _kind == ComposeKind.selfTimeLetter,
                  onTap: () {
                    setState(() {
                      _kind = ComposeKind.selfTimeLetter;
                      _peerId = null;
                      _peerNickname = null;
                    });
                    Navigator.pop(ctx);
                    _refreshDaysHint();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pushUndoSnapshot(String snapshot) {
    if (_bodyUndoStack.isNotEmpty && _bodyUndoStack.last == snapshot) {
      return;
    }
    _bodyUndoStack.add(snapshot);
    if (_bodyUndoStack.length > _kMaxUndoSteps) {
      _bodyUndoStack.removeAt(0);
    }
  }

  void _undoLastEdit() {
    if (_bodyUndoStack.isEmpty) return;
    final prev = _bodyUndoStack.removeLast();
    setState(() => _bodyController.text = prev);
  }

  Future<void> _saveDraft() async {
    final content = _bodyController.text.trim();
    if (content.isEmpty) {
      _bodyFocus.requestFocus();
      return;
    }
    setState(() => _draftBusy = true);
    try {
      final isPostOffice = _kind == ComposeKind.postOffice ||
          _kind == ComposeKind.selfTimeLetter;
      await ref.read(letterDraftsRemoteProvider).saveDraft(
            mode: isPostOffice ? 'POST_OFFICE' : 'DIRECT',
            toUserId: isPostOffice ? null : _peerId,
            content: content,
          );
    } catch (e) {
      debugPrint('compose save draft failed: $e');
      if (!mounted) return;
      final biz = apiBusinessExceptionFrom(e);
      PostalSnack.show(
        context,
        biz?.message ?? e.toString(),
        tone: PostalSnackTone.error,
      );
    } finally {
      if (mounted) setState(() => _draftBusy = false);
    }
  }

  Future<void> _openLetterAssistant() async {
    final source = _bodyController.text.trim();
    if (source.isEmpty) {
      _bodyFocus.requestFocus();
      return;
    }
    final suggestion = await showLetterAssistantSheet(
      context: context,
      ref: ref,
      sourceText: source,
    );
    if (!mounted || suggestion == null) return;
    setState(() {
      _pushUndoSnapshot(_bodyController.text);
      _bodyController.text = suggestion;
    });
  }

  Future<void> _openPaperSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final catalog = await ref.read(commerceCatalogProvider.future);
    if (!mounted) return;
    final skins = catalog
        .where(
          (p) =>
              p.productType == 'skin' && (p.priceCents <= 0 || p.owned),
        )
        .toList();
    final fonts = catalog
        .where(
          (p) =>
              p.productType == 'font' && (p.priceCents <= 0 || p.owned),
        )
        .toList();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PostalTokens.paperEnvelope,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            void apply(VoidCallback fn) {
              setModal(fn);
              setState(fn);
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.composePaperSettings,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.composeSkinSection,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final s in _skinOptions(skins, l10n))
                            _SkinSwatch(
                              label: s.label,
                              color: LetterPaperTokens.forSkin(s.id).background,
                              selected: _selectedSkinId == s.id,
                              onTap: () => apply(() => _selectedSkinId = s.id),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.composeFontSection,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      for (final f in _fontOptions(fonts, l10n))
                        _FontOptionTile(
                          label: f.label,
                          selected: _selectedFontId == f.id,
                          onTap: () => apply(() => _selectedFontId = f.id),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.composeFontSizeSection,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<FontSizeTier>(
                        segments: [
                          ButtonSegment(
                            value: FontSizeTier.large,
                            label: Text(l10n.composeFontSizeLarge),
                          ),
                          ButtonSegment(
                            value: FontSizeTier.xlarge,
                            label: Text(l10n.composeFontSizeXlarge),
                          ),
                        ],
                        selected: {_fontSizeTier},
                        onSelectionChanged: (s) {
                          apply(() => _fontSizeTier = s.first);
                        },
                      ),
                      if (_isTimeLetter) ...[
                        const SizedBox(height: 24),
                        Text(
                          l10n.composeStepDeliveryTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        PostalButton(
                          label: DateFormat.yMMMMd().format(_deliveryDate),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _deliveryDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365 * 2),
                              ),
                            );
                            if (picked != null) {
                              apply(() => _deliveryDate = picked);
                              await _refreshDaysHint();
                            }
                          },
                        ),
                        if (_daysHint != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              l10n.composeStepDeliverySubtitle,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<({String id, String label})> _skinOptions(
    List<CommerceProduct> skins,
    AppLocalizations l10n,
  ) {
    if (skins.isEmpty) {
      return [
        (id: 'default', label: l10n.commerceProductSkinDefault),
        (id: 'vintage', label: l10n.commerceProductSkinVintage),
        (id: 'linen', label: l10n.commerceProductSkinLinen),
      ];
    }
    return skins
        .map(
          (p) => (
            id: p.skinId ?? p.productCode.replaceFirst('skin.', ''),
            label: commerceProductTitle(l10n, p.titleKey),
          ),
        )
        .toList();
  }

  List<({String id, String label})> _fontOptions(
    List<CommerceProduct> fonts,
    AppLocalizations l10n,
  ) {
    if (fonts.isEmpty) {
      return [
        (id: 'default', label: l10n.commerceProductFontDefault),
      ];
    }
    return fonts
        .map(
          (p) => (
            id: p.fontId ?? p.productCode.replaceFirst('font.', ''),
            label: commerceProductTitle(l10n, p.titleKey),
          ),
        )
        .toList();
  }

  Future<void> _openPreview({required bool forSendGate}) async {
    final l10n = AppLocalizations.of(context)!;
    if (_bodyController.text.trim().isEmpty) {
      _bodyFocus.requestFocus();
      return;
    }
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'preview',
      barrierColor: PostalTokens.inkNavy.withValues(alpha: 0.45),
      pageBuilder: (ctx, anim, _) {
        return FadeTransition(
          opacity: anim,
          child: Scaffold(
            backgroundColor: PostalTokens.paperCream,
            appBar: AppBar(
              title: Text(l10n.composeSeeAsRecipient),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                LetterPaper(
                  mode: LetterPaperMode.preview,
                  document: _document,
                  minHeight: 360,
                ),
                const SizedBox(height: 24),
                PostalButton(
                  label: forSendGate
                      ? l10n.composeContinueAfterPreview
                      : l10n.dialogConfirm,
                  onPressed: () async {
                    setState(() => _sessionPreviewSeen = true);
                    if (!_previewGateDone) {
                      await ComposeFirstPreviewGate.markPreviewCompleted();
                      if (mounted) {
                        setState(() => _previewGateDone = true);
                      }
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onPrimarySend() async {
    if (_bodyController.text.trim().isEmpty) {
      _bodyFocus.requestFocus();
      return;
    }
    if (_needsPenPal) {
      return;
    }
    // 首次写信强制预览一次（无额外 Snack，直接打开预览）。
    if (!_previewGateDone && !_sessionPreviewSeen) {
      await _openPreview(forSendGate: true);
      if (!_previewGateDone && !_sessionPreviewSeen) return;
    }

    if (_isTimeLetter) {
      await _showSealSheet();
      return;
    }
    await _submitPenPalMail();
  }

  Future<void> _showSealSheet() async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PostalTokens.paperEnvelope,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.composeStepSealTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(l10n.composeSealWhenReady),
                const SizedBox(height: 12),
                PostalButton(
                  label: DateFormat.yMMMMd().format(_deliveryDate),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _deliveryDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 2),
                      ),
                    );
                    if (picked != null) {
                      setState(() => _deliveryDate = picked);
                      await _refreshDaysHint();
                      if (ctx.mounted) (ctx as Element).markNeedsBuild();
                    }
                  },
                ),
                const SizedBox(height: 20),
                TimeLetterSealSlider(
                  label: l10n.composeStepSealTitle,
                  enabled: !_busy,
                  onSealed: () async {
                    Navigator.pop(ctx);
                    await _submitTimeLetter();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitTimeLetter() async {
    final l10n = AppLocalizations.of(context)!;
    final body = _bodyController.text.trim();
    if (body.isEmpty) return;
    setState(() => _busy = true);
    try {
      final sealId =
          '${DateTime.now().millisecondsSinceEpoch}-${ref.read(appSessionProvider).user.id}';
      final toSelf = _kind == ComposeKind.selfTimeLetter;
      await ref
          .read(timeLetterRemoteProvider)
          .seal(
            recipientId: toSelf ? null : _peerId,
            body: body,
            deliveryDate: _deliveryDate,
            deliveryTz: _offsetTimezoneId(),
            sealRequestId: sealId,
          );
      await ref.read(authRepositoryProvider).refreshSessionFromServer();
      invalidateTimeLetterLists(ref);
      if (!mounted) return;
      final dest = _kind == ComposeKind.selfTimeLetter
          ? l10n.composeRecipientSelf
          : (_peerNickname ?? l10n.topicFriendFallback);
      ref.invalidate(postOfficeHomeProvider);
      ref.invalidate(postOfficeInTransitProvider);
      await showDeliverySentOverlay(context, destinationLabel: dest);
      if (mounted) context.pop();
    } catch (e) {
      debugPrint('compose seal time letter failed: $e');
      final biz = apiBusinessExceptionFrom(e);
      if (mounted) {
        PostalSnack.show(
          context,
          biz?.message ?? e.toString(),
          tone: PostalSnackTone.error,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitPenPalMail() async {
    final l10n = AppLocalizations.of(context)!;
    final body = _bodyController.text.trim();
    if (body.isEmpty) return;
    final isPostOffice = _kind == ComposeKind.postOffice;
    if (!isPostOffice && _peerId == null) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(mailboxRemoteRepositoryProvider)
          .sendLetter(
            toUserId: isPostOffice ? null : _peerId,
            content: body,
            parentLetterId: widget.initialIntent.parentLetterId,
            mode: isPostOffice ? 1 : 2,
            skinId: _selectedSkinId,
            fontId: _selectedFontId,
            fontSizeTier: _fontSizeTier.apiValue,
            templateId: _selectedTemplateId,
          );
      await ref.read(authRepositoryProvider).refreshSessionFromServer();
      if (widget.initialIntent.fromFirstLetterGuide) {
        ref.read(appSessionProvider.notifier).markFirstLetterDoneLocally();
        ref.read(routerRefreshProvider).value++;
      }
      ref.invalidate(mailboxLettersProvider);
      ref.invalidate(postalInboxLettersProvider);
      ref.invalidate(mailboxArchiveProvider);
      // 首页与在途明细同源，寄出后必须一起刷新，否则点进「信件在途」仍见旧缓存。
      ref.invalidate(postOfficeHomeProvider);
      ref.invalidate(postOfficeInTransitProvider);
      if (!mounted) return;
      final dest = _kind == ComposeKind.postOffice
          ? l10n.composePostOfficeSendHint
          : (_peerNickname ?? l10n.topicFriendFallback);
      await showDeliverySentOverlay(context, destinationLabel: dest);
      if (!mounted) return;
      if (widget.initialIntent.fromFirstLetterGuide) {
        ref.read(routerRefreshProvider).value++;
        context.go(MainShellRoute.pathPostOffice);
      } else {
        context.pop();
      }
    } catch (e) {
      debugPrint('compose send letter failed: $e');
      final biz = apiBusinessExceptionFrom(e);
      if (mounted) {
        PostalSnack.show(
          context,
          biz?.message ?? e.toString(),
          tone: PostalSnackTone.error,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFEDE4D4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: TextButton(
          onPressed: () => context.pop(),
          child: Text(
            l10n.composeCancel,
            style: const TextStyle(fontSize: 17),
          ),
        ),
        leadingWidth: 88,
        title: _recipientLocked
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  _recipientLabel(l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : InkWell(
                onTap: _openRecipientSheet,
                borderRadius: PostalTokens.shapeMd,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _recipientLabel(l10n),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      const Icon(Icons.expand_more, size: 22),
                    ],
                  ),
                ),
              ),
        actions: [
          if (!_hideUndoAndDraft)
            IconButton(
              tooltip: l10n.composeSaveDraft,
              onPressed: _draftBusy ? null : _saveDraft,
              icon: const Icon(Icons.save_outlined),
            ),
          TextButton(
            onPressed: () => _openPreview(forSendGate: false),
            child: Text(
              l10n.composeSeeAsRecipient,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: LetterPaper(
                mode: LetterPaperMode.compose,
                document: _document,
                controller: _bodyController,
                focusNode: _bodyFocus,
                placeholder: l10n.composePlaceholderBody,
                minHeight: 320,
              ),
            ),
          ),
          ComposeEditorToolbar(
            canUndo: _bodyUndoStack.isNotEmpty,
            onUndo: _undoLastEdit,
            undoTooltip: l10n.letterAssistantUndo,
            wordCountLabel: l10n.composeEditorWordCount(
              '${composeBodyWordCount(_bodyController.text)}',
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              12,
              10,
              12,
              10 + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: BoxDecoration(
              color: PostalTokens.paperEnvelope.withValues(alpha: 0.96),
              border: Border(
                top: BorderSide(color: PostalTokens.perforationLine),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: PostalButton(
                    label: l10n.composePaperSettings,
                    variant: PostalButtonVariant.secondary,
                    layout: PostalButtonLayout.stacked,
                    icon: Icons.auto_awesome_mosaic_outlined,
                    minHeight: 56,
                    onPressed: _openPaperSheet,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PostalButton(
                    label: l10n.letterAssistantTitle,
                    variant: PostalButtonVariant.secondary,
                    layout: PostalButtonLayout.stacked,
                    icon: Icons.edit_note_outlined,
                    minHeight: 56,
                    onPressed: _openLetterAssistant,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PostalButton(
                    label: _isTimeLetter
                        ? l10n.composeStepSealTitle
                        : l10n.composeSendLetterCta,
                    layout: PostalButtonLayout.stacked,
                    icon: Icons.send_outlined,
                    minHeight: 56,
                    onPressed: _busy ? null : _onPrimarySend,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipientTile extends StatelessWidget {
  const _RecipientTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected
            ? PostalTokens.postboxGreen.withValues(alpha: 0.12)
            : PostalTokens.paperCard,
        borderRadius: PostalTokens.shapeMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: PostalTokens.shapeMd,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: PostalTokens.inkNavy,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkinSwatch extends StatelessWidget {
  const _SkinSwatch({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: PostalTokens.shapeMd,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? PostalTokens.postboxGreen
                    : PostalTokens.kraftBrown,
                width: selected ? 3 : 1.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class _FontOptionTile extends StatelessWidget {
  const _FontOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? PostalTokens.postboxGreen.withValues(alpha: 0.1)
          : Colors.transparent,
      borderRadius: PostalTokens.shapeMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: PostalTokens.shapeMd,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: PostalTokens.postboxGreen,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label, style: const TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
