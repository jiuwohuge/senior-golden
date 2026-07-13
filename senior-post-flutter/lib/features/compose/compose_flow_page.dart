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
import '../../widgets/letter/letter_compose_editor.dart';
import '../../widgets/postal/postal.dart';
import '../auth/auth_repository.dart';
import '../mailbox/mailbox_providers.dart';
import '../mailbox/mailbox_remote.dart';
import '../post_office/post_office_remote.dart';
import '../commerce/commerce_remote.dart';
import '../ritual/delivery_sent_overlay.dart';
import '../shell/main_shell.dart';
import '../time_letter/time_letter_providers.dart';
import '../time_letter/time_letter_remote.dart';
import '../time_letter/time_letter_seal_slider.dart';
import 'compose_intent.dart';
import 'compose_step_scaffold.dart';

enum _ComposeStep {
  destination,
  pickPenPal,
  mailOptions,
  body,
  deliveryDate,
  preview,
  seal,
  send,
}

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
  String? _peerCountryLabel;

  int _stepIndex = 0;
  String _bodyText = '';
  int _editorEpoch = 0;
  List<String> _seedParagraphs = const [''];
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 7));
  String? _daysHint;
  String? _selectedSkinId;
  String? _selectedTemplateId;
  bool _busy = false;

  List<_ComposeStep> _steps = const [];

  @override
  void initState() {
    super.initState();
    _kind = widget.initialIntent.kind;
    _peerId = widget.initialIntent.peerId;
    _peerNickname = widget.initialIntent.peerNickname;
    _peerCountryLabel = widget.initialIntent.peerCountryLabel;
    _selectedTemplateId = widget.initialIntent.templateId;
    if (widget.initialIntent.initialParagraphs?.isNotEmpty == true) {
      _seedParagraphs = List<String>.from(
        widget.initialIntent.initialParagraphs!,
      );
      _bodyText = LetterComposeEditor.joinParagraphs(_seedParagraphs);
    }
    _rebuildSteps();
    if (_currentStep == _ComposeStep.deliveryDate ||
        _currentStep == _ComposeStep.seal) {
      _refreshDaysHint();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  _ComposeStep get _currentStep => _steps[_stepIndex];

  static String _offsetTimezoneId() {
    final offset = DateTime.now().timeZoneOffset;
    final totalMinutes = offset.inMinutes;
    final sign = totalMinutes >= 0 ? '+' : '-';
    final abs = totalMinutes.abs();
    final h = abs ~/ 60;
    final m = abs % 60;
    return '$sign${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  void _rebuildSteps() {
    final steps = <_ComposeStep>[];
    if (_kind == null) {
      steps.add(_ComposeStep.destination);
    }
    if (_needsPenPalPicker) {
      steps.add(_ComposeStep.pickPenPal);
    }
    switch (_kind) {
      case ComposeKind.selfTimeLetter:
      case ComposeKind.penPalTimeLetter:
        // 模板信纸 → 正文 → 送达 → 预览 → 封缄
        steps.add(_ComposeStep.mailOptions);
        steps.add(_ComposeStep.body);
        steps.add(_ComposeStep.deliveryDate);
        steps.add(_ComposeStep.preview);
        steps.add(_ComposeStep.seal);
      case ComposeKind.penPalMail:
      case ComposeKind.postOffice:
        // 模板信纸 → 正文 → 预览 → 发送
        steps.add(_ComposeStep.mailOptions);
        steps.add(_ComposeStep.body);
        steps.add(_ComposeStep.preview);
        steps.add(_ComposeStep.send);
      case null:
        break;
    }
    setState(() {
      _steps = steps;
      if (_stepIndex >= _steps.length) {
        _stepIndex = _steps.length - 1;
      }
    });
  }

  bool get _needsPenPalPicker {
    if (_peerId != null && _peerId!.isNotEmpty) return false;
    return _kind == ComposeKind.penPalMail ||
        _kind == ComposeKind.penPalTimeLetter;
  }

  void _onBack() {
    if (_stepIndex > 0) {
      setState(() => _stepIndex -= 1);
      return;
    }
    context.pop();
  }

  void _onNext() {
    final l10n = AppLocalizations.of(context)!;
    switch (_currentStep) {
      case _ComposeStep.destination:
        if (_kind == null) {
          PostalSnack.show(
            context,
            l10n.composePickDestinationRequired,
            tone: PostalSnackTone.warning,
          );
          return;
        }
      case _ComposeStep.pickPenPal:
        if (_peerId == null || _peerId!.isEmpty) {
          PostalSnack.show(
            context,
            l10n.composePickPenPalRequired,
            tone: PostalSnackTone.warning,
          );
          return;
        }
      case _ComposeStep.body:
        if (_bodyText.trim().isEmpty) {
          PostalSnack.show(
            context,
            l10n.composeBodyRequired,
            tone: PostalSnackTone.warning,
          );
          return;
        }
      case _ComposeStep.deliveryDate:
      case _ComposeStep.mailOptions:
      case _ComposeStep.preview:
      case _ComposeStep.seal:
      case _ComposeStep.send:
        break;
    }
    if (_stepIndex < _steps.length - 1) {
      final nextStep = _steps[_stepIndex + 1];
      setState(() => _stepIndex += 1);
      if (nextStep == _ComposeStep.deliveryDate) {
        _refreshDaysHint();
      }
    }
  }

  Future<void> _refreshDaysHint() async {
    try {
      final days = await ref
          .read(timeLetterRemoteProvider)
          .previewDaysUntil(_deliveryDate, _offsetTimezoneId());
      if (mounted) setState(() => _daysHint = '$days');
    } catch (_) {}
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _deliveryDate = picked);
      await _refreshDaysHint();
    }
  }

  Future<void> _submitTimeLetter() async {
    final l10n = AppLocalizations.of(context)!;
    final body = _bodyText.trim();
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
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: Icon(
            Icons.mark_email_read_outlined,
            color: PostalTokens.success,
            size: 48,
          ),
          title: Text(l10n.timeLetterSealSuccessTitle),
          content: Text(l10n.timeLetterSealSuccessMessage),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.dialogConfirm),
            ),
          ],
        ),
      );
      if (mounted) context.pop();
    } catch (e) {
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
    final body = _bodyText.trim();
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
            mode: isPostOffice ? 1 : 2,
            skinId: _selectedSkinId,
            templateId: _selectedTemplateId,
          );
      await ref.read(authRepositoryProvider).refreshSessionFromServer();
      // 首封信：本地兜底标记，避免 /me 滞后时 redirect 又打回引导页。
      if (widget.initialIntent.fromFirstLetterGuide) {
        ref.read(appSessionProvider.notifier).markFirstLetterDoneLocally();
        ref.read(routerRefreshProvider).value++;
      }
      ref.invalidate(mailboxLettersProvider);
      ref.invalidate(postalInboxLettersProvider);
      ref.invalidate(mailboxArchiveProvider);
      // 邮局发信消耗今日额度；刷新首页 remainingQuota。
      if (isPostOffice) {
        ref.invalidate(postOfficeHomeProvider);
      }
      if (!mounted) return;
      final dest = _kind == ComposeKind.postOffice
          ? l10n.composePostOfficeSendHint
          : (_peerNickname ?? l10n.topicFriendFallback);
      await showDeliverySentOverlay(context, destinationLabel: dest);
      if (!mounted) return;
      // 首封信引导是 go 进来的根页，pop 只会回到无返回键的引导页；
      // 须显式进邮局，并刷新 redirect（firstLetterDone 已变）。
      if (widget.initialIntent.fromFirstLetterGuide) {
        ref.read(routerRefreshProvider).value++;
        context.go(MainShellRoute.pathPostOffice);
      } else {
        context.pop();
      }
    } catch (e) {
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

  bool get _nextEnabled {
    switch (_currentStep) {
      case _ComposeStep.destination:
        return _kind != null;
      case _ComposeStep.pickPenPal:
        return _peerId != null && _peerId!.isNotEmpty;
      case _ComposeStep.body:
        return _bodyText.trim().isNotEmpty;
      default:
        return true;
    }
  }

  bool get _isLastInteractiveStep {
    return _stepIndex == _steps.length - 1 &&
        (_currentStep == _ComposeStep.seal ||
            _currentStep == _ComposeStep.send);
  }

  ({String title, String subtitle, String? footer}) _stepCopy(
    AppLocalizations l10n,
  ) {
    switch (_currentStep) {
      case _ComposeStep.destination:
        return (
          title: l10n.composeStepDestinationTitle,
          subtitle: l10n.composeStepDestinationSubtitle,
          footer: l10n.composeStepFooter,
        );
      case _ComposeStep.pickPenPal:
        return (
          title: l10n.composeStepPenPalTitle,
          subtitle: l10n.composeStepPenPalSubtitle,
          footer: null,
        );
      case _ComposeStep.body:
        return (
          title: l10n.composeStepBodyTitle,
          subtitle: _bodySubtitle(l10n),
          footer: l10n.composeBodyFooter,
        );
      case _ComposeStep.deliveryDate:
        return (
          title: l10n.composeStepDeliveryTitle,
          subtitle: l10n.composeStepDeliverySubtitle,
          footer: null,
        );
      case _ComposeStep.mailOptions:
        return (
          title: l10n.composeStepMailTitle,
          subtitle: l10n.composeStepMailSubtitleSkins,
          footer: null,
        );
      case _ComposeStep.preview:
        return (
          title: l10n.composeStepPreviewTitle,
          subtitle: l10n.composeStepPreviewSubtitle,
          footer: null,
        );
      case _ComposeStep.seal:
        return (
          title: l10n.composeStepSealTitle,
          subtitle: l10n.composeStepSealSubtitle,
          footer: null,
        );
      case _ComposeStep.send:
        return (
          title: l10n.composeStepSendTitle,
          subtitle: l10n.composeStepSendSubtitle,
          footer: null,
        );
    }
  }

  String _bodySubtitle(AppLocalizations l10n) {
    return switch (_kind) {
      ComposeKind.selfTimeLetter => l10n.composeBodySubtitleSelf,
      ComposeKind.penPalMail => l10n.composeBodySubtitlePenPal(
        _peerNickname ?? l10n.topicFriendFallback,
      ),
      ComposeKind.penPalTimeLetter => l10n.composeBodySubtitleTimePenPal(
        _peerNickname ?? l10n.topicFriendFallback,
      ),
      ComposeKind.postOffice => l10n.composeBodySubtitlePostOffice,
      null => l10n.composeStepDestinationSubtitle,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_steps.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final copy = _stepCopy(l10n);
    final showFab = !_isLastInteractiveStep;

    return Scaffold(
      backgroundColor: PostalTokens.paperCream,
      appBar: AppBar(
        backgroundColor: PostalTokens.postboxGreen,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.composeTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: ComposeStepScaffold(
            stepIndex: _stepIndex,
            stepCount: _steps.length,
            title: copy.title,
            subtitle: copy.subtitle,
            footerHint: copy.footer,
            onBack: _onBack,
            onNext: showFab ? _onNext : null,
            nextEnabled: _nextEnabled,
            nextBusy: _busy,
            isLastStep: _stepIndex == _steps.length - 1 && showFab,
            bottomAction: _buildBottomAction(l10n),
            child: _buildStepBody(l10n),
          ),
        ),
      ),
    );
  }

  Widget? _buildBottomAction(AppLocalizations l10n) {
    switch (_currentStep) {
      case _ComposeStep.seal:
        return TimeLetterSealSlider(
          label: l10n.timeLetterSealSlide,
          enabled: !_busy,
          onSealed: _submitTimeLetter,
        );
      case _ComposeStep.send:
        return PostalButton(
          label: l10n.composeSendNow,
          icon: Icons.send_outlined,
          onPressed: _busy ? null : _submitPenPalMail,
          busy: _busy,
        );
      default:
        return null;
    }
  }

  Widget _buildStepBody(AppLocalizations l10n) {
    switch (_currentStep) {
      case _ComposeStep.destination:
        return _DestinationStep(
          kind: _kind,
          onPick: (kind) {
            setState(() => _kind = kind);
            _rebuildSteps();
          },
        );
      case _ComposeStep.pickPenPal:
        return _PickPenPalStep(
          selectedId: _peerId,
          onPick: (friend) {
            setState(() {
              _peerId = friend.peer.id;
              _peerNickname = friend.peer.nickname;
              _peerCountryLabel = friend.peer.countryName;
            });
          },
        );
      case _ComposeStep.body:
        return ListView(
          physics: const ClampingScrollPhysics(),
          children: [
            if (widget.initialIntent.fromFirstLetterGuide) ...[
              PostalCardEnvelope(
                padding: const EdgeInsets.all(14),
                child: Text(
                  l10n.firstLetterComposeHint,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    color: PostalTokens.inkSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            LetterComposeEditor(
              key: ValueKey('compose-body-$_editorEpoch'),
              initialParagraphs: _seedParagraphs,
              onChanged: (text) => setState(() => _bodyText = text),
            ),
          ],
        );
      case _ComposeStep.deliveryDate:
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.timeLetterDeliveryDate),
          subtitle: Text(
            '${DateFormat.yMMMd().format(_deliveryDate)}'
            '${_daysHint != null ? ' · ${l10n.timeLetterDaysUntil(_daysHint!)}' : ''}',
          ),
          trailing: const Icon(Icons.calendar_month_outlined),
          onTap: _pickDate,
        );
      case _ComposeStep.mailOptions:
        return _MailOptionsStep(
          selectedSkinId: _selectedSkinId,
          selectedTemplateId: _selectedTemplateId,
          busy: _busy,
          onSkinChanged: (skinId) => setState(() => _selectedSkinId = skinId),
          onTemplateApplied: (product) {
            final paragraphs = product.paragraphs;
            setState(() {
              _selectedTemplateId =
                  product.templateId ??
                  product.productCode.replaceFirst('template.', '');
              _seedParagraphs = paragraphs.isEmpty ? [''] : paragraphs;
              _bodyText = LetterComposeEditor.joinParagraphs(_seedParagraphs);
              _editorEpoch += 1;
            });
            // 选模板后进入正文步继续编辑。
            final bodyIdx = _steps.indexOf(_ComposeStep.body);
            if (bodyIdx >= 0) {
              setState(() => _stepIndex = bodyIdx);
            }
          },
        );
      case _ComposeStep.preview:
        return _LetterPreviewStep(
          skinId: _selectedSkinId,
          bodyText: _bodyText,
        );
      case _ComposeStep.seal:
        return Align(
          alignment: Alignment.topCenter,
          child: Text(
            _kind == ComposeKind.selfTimeLetter
                ? l10n.timeLetterComposeToSelf
                : l10n.timeLetterComposeToFriend(
                    _peerNickname ?? l10n.topicFriendFallback,
                  ),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        );
      case _ComposeStep.send:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _kind == ComposeKind.postOffice
                  ? l10n.composePostOfficeSendHint
                  : l10n.sendLetterSheetTitle(
                      _peerNickname ?? l10n.topicFriendFallback,
                    ),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (_kind != ComposeKind.postOffice &&
                _peerCountryLabel != null &&
                _peerCountryLabel!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _peerCountryLabel!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PostalTokens.inkSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );
    }
  }
}

class _MailOptionsStep extends ConsumerWidget {
  const _MailOptionsStep({
    required this.selectedSkinId,
    required this.selectedTemplateId,
    required this.busy,
    required this.onSkinChanged,
    required this.onTemplateApplied,
  });

  final String? selectedSkinId;
  final String? selectedTemplateId;
  final bool busy;
  final ValueChanged<String?> onSkinChanged;
  final ValueChanged<CommerceProduct> onTemplateApplied;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final catalogAsync = ref.watch(commerceCatalogProvider);
    final ownedAsync = ref.watch(ownedSkinEntitlementsProvider);
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        Text(
          l10n.composeTemplatePickerTitle,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        catalogAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => const SizedBox.shrink(),
          data: (catalog) {
            // 免费或已拥有的写信模板。
            final templates = catalog
                .where(
                  (p) =>
                      p.productType == 'template' &&
                      (p.priceCents <= 0 || p.owned),
                )
                .toList();
            if (templates.isEmpty) {
              return Text(
                l10n.composeTemplateEmpty,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PostalTokens.inkTertiary,
                ),
              );
            }
            return Column(
              children: templates.map((t) {
                final tid =
                    t.templateId ?? t.productCode.replaceFirst('template.', '');
                final selected = selectedTemplateId == tid;
                return RadioListTile<String>(
                  // ignore: deprecated_member_use
                  value: tid,
                  // ignore: deprecated_member_use
                  groupValue: selectedTemplateId,
                  // ignore: deprecated_member_use
                  onChanged: busy
                      ? null
                      : (_) => onTemplateApplied(t),
                  title: Text(commerceProductTitle(l10n, t.titleKey)),
                  subtitle: selected
                      ? Text(l10n.composeTemplateApplied)
                      : null,
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          l10n.composeSkinPickerTitle,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        catalogAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => ownedAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const SizedBox.shrink(),
            data: (skins) => _skinRadios(
              context,
              l10n,
              [
                (id: 'default', label: l10n.commerceProductSkinDefault),
                ...skins.map(
                  (e) => (
                    id: e.productCode.replaceFirst('skin.', ''),
                    label: commerceProductTitle(l10n, e.titleKey),
                  ),
                ),
              ],
            ),
          ),
          data: (catalog) {
            final freeSkins = catalog.where(
              (p) =>
                  p.productType == 'skin' && (p.priceCents <= 0 || p.owned),
            );
            final options = <({String id, String label})>[
              (id: 'default', label: l10n.commerceProductSkinDefault),
            ];
            final seen = {'default'};
            for (final p in freeSkins) {
              final id = p.skinId ?? p.productCode.replaceFirst('skin.', '');
              if (seen.add(id)) {
                options.add((
                  id: id,
                  label: commerceProductTitle(l10n, p.titleKey),
                ));
              }
            }
            return _skinRadios(context, l10n, options);
          },
        ),
      ],
    );
  }

  Widget _skinRadios(
    BuildContext context,
    AppLocalizations l10n,
    List<({String id, String label})> options,
  ) {
    final selected = selectedSkinId ?? 'default';
    return Column(
      children: options.map((opt) {
        return RadioListTile<String>(
          // ignore: deprecated_member_use
          value: opt.id,
          // ignore: deprecated_member_use
          groupValue: selected,
          // ignore: deprecated_member_use
          onChanged: busy ? null : (v) => onSkinChanged(v),
          title: Text(opt.label),
          secondary: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: letterSkinBackground(opt.id),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: PostalTokens.perforationLine),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DestinationStep extends StatelessWidget {
  const _DestinationStep({required this.kind, required this.onPick});

  final ComposeKind? kind;
  final ValueChanged<ComposeKind> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        ComposeChoiceTile(
          label: l10n.composeChooseSelf,
          subtitle: l10n.composeChooseSelfSub,
          icon: Icons.schedule_send_outlined,
          selected: kind == ComposeKind.selfTimeLetter,
          onTap: () => onPick(ComposeKind.selfTimeLetter),
        ),
        const SizedBox(height: 12),
        ComposeChoiceTile(
          label: l10n.composeChoosePenPal,
          subtitle: l10n.composeChoosePenPalSub,
          icon: Icons.mail_outline_rounded,
          selected: kind == ComposeKind.penPalMail,
          onTap: () => onPick(ComposeKind.penPalMail),
        ),
        const SizedBox(height: 12),
        ComposeChoiceTile(
          label: l10n.composeChoosePostOffice,
          subtitle: l10n.composeChoosePostOfficeSub,
          icon: Icons.local_post_office_outlined,
          selected: kind == ComposeKind.postOffice,
          onTap: () => onPick(ComposeKind.postOffice),
        ),
      ],
    );
  }
}

class _PickPenPalStep extends ConsumerWidget {
  const _PickPenPalStep({required this.selectedId, required this.onPick});

  final String? selectedId;
  final ValueChanged<FriendListRow> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final friendsAsync = ref.watch(mailboxFriendsProvider);
    return friendsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => PostalEmptyState(
        title: l10n.composePenPalLoadFailed,
        subtitle: '$e',
        tone: PostalEmptyTone.error,
      ),
      data: (friends) {
        if (friends.isEmpty) {
          return PostalEmptyState(
            title: l10n.composePenPalEmptyTitle,
            subtitle: l10n.composePenPalEmptySubtitle,
            actionLabel: l10n.composeGoDirectory,
            onAction: () => context.go('/directory'),
          );
        }
        return ListView.separated(
          physics: const ClampingScrollPhysics(),
          itemCount: friends.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final friend = friends[index];
            final selected = friend.peer.id == selectedId;
            return ComposeChoiceTile(
              label: friend.peer.nickname,
              subtitle: friend.peer.countryName,
              icon: Icons.person_outline_rounded,
              selected: selected,
              onTap: () => onPick(friend),
            );
          },
        );
      },
    );
  }
}

/// 写信预览：信纸底色 + 分段正文。
class _LetterPreviewStep extends StatelessWidget {
  const _LetterPreviewStep({
    required this.skinId,
    required this.bodyText,
  });

  final String? skinId;
  final String bodyText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paragraphs = bodyText
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          decoration: BoxDecoration(
            color: letterSkinBackground(skinId),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: PostalTokens.kraftBrownMuted.withValues(alpha: 0.55),
            ),
          ),
          child: paragraphs.isEmpty
              ? Text(
                  '—',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: PostalTokens.inkSecondary,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < paragraphs.length; i++) ...[
                      if (i > 0) const SizedBox(height: 16),
                      Text(
                        paragraphs[i],
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.55,
                          color: PostalTokens.inkNavy,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
