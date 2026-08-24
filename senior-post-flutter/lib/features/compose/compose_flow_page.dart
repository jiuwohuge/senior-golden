import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/bootstrap/app_bootstrap.dart';
import '../../core/i18n/effective_app_locale_provider.dart';
import '../../core/models/domain_models.dart';
import '../../core/models/letter_topic_option.dart';
import '../../core/session/app_session.dart';
import '../../widgets/letter/letter_document.dart';
import '../../widgets/letter/letter_paper.dart';
import '../../widgets/postal/postal.dart';
import '../auth/auth_repository.dart';
import '../auth/bind_email_page.dart';
import '../auth/login_routes.dart';
import '../commerce/commerce_remote.dart';
import '../letter_drafts/letter_drafts_remote.dart';
import '../mailbox/mailbox_providers.dart';
import '../mailbox/mailbox_remote.dart';
import '../post_office/post_office_remote.dart';
import '../ritual/delivery_sent_overlay.dart';
import '../time_letter/time_letter_providers.dart';
import '../time_letter/time_letter_remote.dart';
import '../time_letter/time_letter_seal_slider.dart';
import 'compose_editor_toolbar.dart';
import 'compose_first_preview_gate.dart';
import 'compose_intent.dart';
import 'compose_paper_footer.dart';
import 'compose_stamp_strip.dart';
import 'letter_assistant_sheet.dart';

/// 单页写信桌：书桌上的一封信；主行动只有通栏寄出。
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
  bool _busy = false;
  bool _previewGateDone = false;
  bool _sessionPreviewSeen = false;
  static const _kMaxUndoSteps = 30;
  static const _kSilentDraftDebounce = Duration(seconds: 8);

  /// 正文逐步撤销栈（助手替换/追加前压入快照）。
  final List<String> _bodyUndoStack = [];
  bool _draftBusy = false;
  String? _draftId;
  int? _topicTagId;
  Timer? _silentDraftTimer;
  bool _leaving = false;

  /// 时光信最早明天送达；默认仍约 +7 天。
  DateTime get _minDeliveryDate {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day).add(const Duration(days: 1));
  }

  Future<DateTime?> _showDeliveryDatePicker() {
    final min = _minDeliveryDate;
    final initial = _deliveryDate.isBefore(min) ? min : _deliveryDate;
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: min,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
  }

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
    _kind =
        widget.initialIntent.kind ??
        (ref
            .read(postOfficeHomeProvider)
            .maybeWhen(
              data: (h) => h.recommendedAction == 'POST_OFFICE'
                  ? ComposeKind.postOffice
                  : ComposeKind.selfTimeLetter,
              orElse: () => ComposeKind.selfTimeLetter,
            ));
    _peerId = widget.initialIntent.peerId;
    _peerNickname = widget.initialIntent.peerNickname;
    _selectedTemplateId = widget.initialIntent.templateId;
    _draftId = widget.initialIntent.draftId;
    _topicTagId = widget.initialIntent.topicTagId;
    if (widget.initialIntent.deliveryDate != null) {
      _deliveryDate = widget.initialIntent.deliveryDate!;
    }

    var initial = '';
    if (widget.initialIntent.initialParagraphs?.isNotEmpty == true) {
      initial = LetterDocument.joinParagraphs(
        widget.initialIntent.initialParagraphs!,
      );
    }
    _bodyController = TextEditingController(text: initial);
    _bodyController.addListener(_onBodyChanged);

    ComposeFirstPreviewGate.hasCompletedPreview().then((done) {
      if (mounted) setState(() => _previewGateDone = done);
    });
  }

  @override
  void dispose() {
    _silentDraftTimer?.cancel();
    _bodyController.removeListener(_onBodyChanged);
    _bodyController.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  void _onBodyChanged() {
    if (!mounted) return;
    setState(() {});
    _scheduleSilentDraft();
  }

  /// 停笔 8 秒静默存草稿；首封引导不存；失败保持沉默。
  void _scheduleSilentDraft() {
    _silentDraftTimer?.cancel();
    if (_leaving || _busy) return;
    if (_bodyController.text.trim().isEmpty) return;
    _silentDraftTimer = Timer(_kSilentDraftDebounce, () {
      unawaited(_persistDraft(showFailure: false));
    });
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
        final timeLetterFirst = ref
            .read(postOfficeHomeProvider)
            .maybeWhen(
              data: (h) => h.recommendedAction != 'POST_OFFICE',
              orElse: () => true,
            );
        final selfTile = _RecipientTile(
          title: l10n.composeRecipientSelf,
          selected: _kind == ComposeKind.selfTimeLetter,
          onTap: () {
            setState(() {
              _kind = ComposeKind.selfTimeLetter;
              _peerId = null;
              _peerNickname = null;
            });
            Navigator.pop(ctx);
          },
        );
        final postOfficeTile = _RecipientTile(
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
        );
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
                if (timeLetterFirst) ...[
                  selfTile,
                  postOfficeTile,
                ] else ...[
                  postOfficeTile,
                  selfTile,
                ],
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

  /// 写入 `/api/letter-drafts`。离开失败才 Snack；静默失败下次再试。
  Future<bool> _persistDraft({required bool showFailure}) async {
    final content = _bodyController.text.trim();
    if (content.isEmpty) {
      return true;
    }
    if (_draftBusy) return false;
    setState(() => _draftBusy = true);
    try {
      final isPostOffice =
          _kind == ComposeKind.postOffice ||
          _kind == ComposeKind.selfTimeLetter;
      final saved = await ref
          .read(letterDraftsRemoteProvider)
          .saveDraft(
            id: _draftId,
            mode: isPostOffice ? 'POST_OFFICE' : 'DIRECT',
            toUserId: isPostOffice ? null : _peerId,
            content: content,
            topicTagId: _topicTagId,
            deliveryDate: _isTimeLetter
                ? DateFormat('yyyy-MM-dd').format(_deliveryDate)
                : null,
          );
      _draftId = saved.id.isEmpty ? _draftId : saved.id;
      return true;
    } catch (e) {
      debugPrint('compose save draft failed: $e');
      if (!mounted) return false;
      if (showFailure) {
        final biz = apiBusinessExceptionFrom(e);
        PostalSnack.show(
          context,
          biz?.message ?? AppLocalizations.of(context)!.composeDraftLeaveFailed,
          tone: PostalSnackTone.error,
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _draftBusy = false);
    }
  }

  Future<void> _leaveDesk() async {
    if (_leaving) return;
    _leaving = true;
    _silentDraftTimer?.cancel();
    if (_bodyController.text.trim().isNotEmpty) {
      final ok = await _persistDraft(showFailure: true);
      if (!ok && mounted) {
        PostalSnack.show(
          context,
          AppLocalizations.of(context)!.composeDraftLeaveFailed,
          tone: PostalSnackTone.error,
        );
      }
    }
    if (mounted) context.pop();
  }

  Future<void> _openLetterAssistant() async {
    final source = _bodyController.text;
    final mode = await showLetterAssistantQuickActions(
      context,
      hasDraft: source.trim().isNotEmpty,
    );
    if (!mounted || mode == null) return;
    final suggestion = await showLetterAssistantSheet(
      context: context,
      ref: ref,
      sourceText: source,
      initialMode: mode,
    );
    if (!mounted || suggestion == null) return;
    setState(() {
      _pushUndoSnapshot(_bodyController.text);
      _bodyController.text = suggestion;
    });
  }

  Future<void> _openPaperSheet() async {
    final l10n = AppLocalizations.of(context)!;
    List<CommerceProduct> catalog;
    try {
      catalog = await ref.read(commerceCatalogProvider.future);
    } catch (e) {
      debugPrint('compose paper catalog failed: $e');
      if (mounted) {
        PostalSnack.show(
          context,
          l10n.commonActionFailed,
          tone: PostalSnackTone.error,
        );
      }
      return;
    }
    if (!mounted) return;
    final skins = catalog
        .where((p) => p.productType == 'skin' && (p.priceCents <= 0 || p.owned))
        .toList();
    final fonts = catalog
        .where((p) => p.productType == 'font' && (p.priceCents <= 0 || p.owned))
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
      return [(id: 'default', label: l10n.commerceProductFontDefault)];
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

  String _primaryLabel(AppLocalizations l10n) {
    if (_isTimeLetter) {
      return l10n.composeStepSealTitle;
    }
    if (_recipientLocked) {
      return l10n.composePrimarySendToPenPal;
    }
    return l10n.composePrimaryDropInPostOffice;
  }

  String _compactStampLabel(
    AppLocalizations l10n,
    List<LetterTopicOption> topics,
  ) {
    if (_topicTagId == null) {
      return l10n.composeStampNone;
    }
    for (final topic in topics) {
      if (topic.id == _topicTagId) {
        return l10n.composeStampStuck(composeStampShortLabel(l10n, topic));
      }
    }
    return l10n.composeStampNone;
  }

  Future<void> _showStampPicker(List<LetterTopicOption> topics) async {
    if (topics.isEmpty) return;
    _bodyFocus.unfocus();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: PostalTokens.paperEnvelope,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
            child: ComposeStampStrip(
              topics: topics,
              selectedId: _topicTagId,
              compact: false,
              compactLabel: '',
              onExpandCompact: () {},
              onSelected: (id) {
                setState(() => _topicTagId = id);
                Navigator.pop(ctx);
              },
              labelOf: (t) =>
                  composeStampShortLabel(AppLocalizations.of(ctx)!, t),
            ),
          ),
        );
      },
    );
  }

  /// 非法话题 id：揭票并提示重选；其它发信失败留在写信桌。
  void _handleSendFailure(Object e) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final biz = apiBusinessExceptionFrom(e);
    final msg = biz?.message.isNotEmpty == true
        ? biz!.message
        : AppLocalizations.of(context)!.commonActionFailed;
    final invalidTopic =
        msg.contains(l10n.composeTopicInvalid) ||
        msg.contains('Please pick a topic stamp again') ||
        msg.contains('请重新选一个话题');
    if (invalidTopic) {
      setState(() => _topicTagId = null);
      PostalSnack.show(
        context,
        l10n.composeTopicInvalid,
        tone: PostalSnackTone.error,
      );
      return;
    }
    PostalSnack.show(context, msg, tone: PostalSnackTone.error);
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
                    final picked = await _showDeliveryDatePicker();
                    if (picked != null) {
                      setState(() => _deliveryDate = picked);
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

  /// 仪式动画与会话刷新并行，避免用户先干等网络再看动画。
  Future<void> _playSendRitual(String dest) async {
    final overlay = showDeliverySentOverlay(context, destinationLabel: dest);
    try {
      await ref.read(authRepositoryProvider).refreshSessionFromServer();
    } catch (e) {
      debugPrint('refresh session after send failed: $e');
    }
    await overlay;
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
            topicTagId: _topicTagId,
          );
      invalidateTimeLetterLists(ref);
      if (!mounted) return;
      final dest = _kind == ComposeKind.selfTimeLetter
          ? l10n.composeRecipientSelf
          : (_peerNickname ?? l10n.topicFriendFallback);
      ref.invalidate(postOfficeHomeProvider);
      ref.invalidate(postOfficeInTransitProvider);
      await _playSendRitual(dest);
      if (!mounted) return;
      final goBind = await maybePromptBindAfterSend(context, ref);
      if (!mounted) return;
      if (goBind) {
        context.pushReplacement(LoginRoutes.bindEmail);
      } else {
        context.pop();
      }
    } catch (e) {
      debugPrint('compose seal time letter failed: $e');
      _handleSendFailure(e);
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
            topicTagId: _topicTagId,
          );
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
      await _playSendRitual(dest);
      if (!mounted) return;
      final goBind = await maybePromptBindAfterSend(context, ref);
      if (!mounted) return;
      if (goBind) {
        context.pushReplacement(LoginRoutes.bindEmail);
      } else {
        context.pop();
      }
    } catch (e) {
      debugPrint('compose send letter failed: $e');
      _handleSendFailure(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final keyboardUp = MediaQuery.viewInsetsOf(context).bottom > 80;
    final lang = ref.watch(effectiveAppLocaleProvider).languageCode;
    final narrowScreen = MediaQuery.sizeOf(context).width < 360;
    final topics = ref
        .watch(appBootstrapProvider(lang))
        .maybeWhen(
          data: (d) => d.letterTopicOptions,
          orElse: () => const <LetterTopicOption>[],
        );
    final dateShort = narrowScreen
        ? DateFormat.Md(lang).format(_deliveryDate)
        : DateFormat.MMMd(lang).format(_deliveryDate);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _leaveDesk();
      },
      child: Scaffold(
        backgroundColor: PostalTokens.composeDesk,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          leading: TextButton(
            onPressed: _busy ? null : _leaveDesk,
            child: Text(
              l10n.composeCancel,
              style: const TextStyle(fontSize: 17),
            ),
          ),
          leadingWidth: lang == 'en' ? 84 : 64,
          title: _ComposeRecipientHeader(
            prefix: narrowScreen ? '' : l10n.composeMailToPrefix,
            recipient: _recipientLabel(l10n),
            dateLabel: _isTimeLetter ? dateShort : null,
            locked: _recipientLocked,
            onRecipientTap: _recipientLocked ? null : _openRecipientSheet,
            onDateTap: _isTimeLetter
                ? () async {
                    final picked = await _showDeliveryDatePicker();
                    if (picked != null) {
                      setState(() => _deliveryDate = picked);
                    }
                  }
                : null,
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            if (topics.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                child: ComposeStampStrip(
                  topics: topics,
                  selectedId: _topicTagId,
                  compact: keyboardUp,
                  compactLabel: _compactStampLabel(l10n, topics),
                  onExpandCompact: () => _showStampPicker(topics),
                  onSelected: (id) => setState(() => _topicTagId = id),
                  labelOf: (t) => composeStampShortLabel(l10n, t),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: LayoutBuilder(
                  builder: (context, constraints) => LetterPaper(
                    mode: LetterPaperMode.compose,
                    document: _document,
                    controller: _bodyController,
                    focusNode: _bodyFocus,
                    placeholder:
                        ref.watch(appSessionProvider).user.firstLetterDone !=
                            true
                        ? l10n.composeOneSentenceHint
                        : l10n.composePlaceholderBody,
                    minHeight: constraints.maxHeight.clamp(180.0, 280.0),
                    footer: ComposePaperFooter(
                      wordCountLabel: l10n.composeEditorWordCount(
                        '${composeBodyWordCount(_bodyController.text)}',
                      ),
                      canUndo: _bodyUndoStack.isNotEmpty,
                      onUndo: _undoLastEdit,
                      undoLabel: l10n.letterAssistantUndo,
                      paperLabel: l10n.composePaperSettings,
                      assistantLabel: l10n.composeFooterAssistant,
                      onPaper: _openPaperSheet,
                      onAssistant: _openLetterAssistant,
                      compact: keyboardUp || narrowScreen,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                10 + MediaQuery.paddingOf(context).bottom,
              ),
              child: PostalButton(
                key: const ValueKey('compose-primary-send'),
                label: _primaryLabel(l10n),
                minHeight: 56,
                busy: _busy,
                onPressed: _busy ? null : _onPrimarySend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 顶栏：寄给 · 收件人（可点）· 时光信日期（可点）。
class _ComposeRecipientHeader extends StatelessWidget {
  const _ComposeRecipientHeader({
    required this.prefix,
    required this.recipient,
    required this.locked,
    this.dateLabel,
    this.onRecipientTap,
    this.onDateTap,
  });

  final String prefix;
  final String recipient;
  final bool locked;
  final String? dateLabel;
  final VoidCallback? onRecipientTap;
  final VoidCallback? onDateTap;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: InkWell(
            onTap: onRecipientTap,
            borderRadius: PostalTokens.shapeSm,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      prefix.isEmpty ? recipient : '$prefix · $recipient',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: style,
                    ),
                  ),
                  if (onRecipientTap != null)
                    const Icon(Icons.expand_more, size: 22),
                ],
              ),
            ),
          ),
        ),
        if (dateLabel != null)
          InkWell(
            onTap: onDateTap,
            borderRadius: PostalTokens.shapeSm,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('· $dateLabel', style: style),
                  const Icon(Icons.expand_more, size: 22),
                ],
              ),
            ),
          ),
      ],
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
          Text(label, style: const TextStyle(fontSize: 15)),
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
