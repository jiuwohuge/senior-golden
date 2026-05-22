import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/models/domain_models.dart';
import '../../core/session/app_session.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/postal/postal.dart';
import '../auth/auth_repository.dart';
import '../mailbox/mailbox_providers.dart';
import '../mailbox/mailbox_remote.dart';

/// 统一发信底部弹层：透明幕布 + 圆角信纸容器；内容见 [SendLetterSheet]。
///
/// 寄信成功：模态对话框，须用户点击确认后才关闭（避免 SnackBar 随 sheet 关闭一闪而过）。
Future<void> showPostalSendLetterSuccessDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (dlgCtx) {
      return AlertDialog(
        icon: Icon(
          Icons.mark_email_read_outlined,
          color: PostalTokens.success,
          size: 48,
        ),
        title: Text(l10n.sendLetterSentSuccessTitle),
        content: Text(l10n.sendLetterSentSuccessMessage),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dlgCtx).pop(),
            child: Text(l10n.dialogConfirm),
          ),
        ],
      );
    },
  );
}

Future<void> showPostalSendLetterSheet(
  BuildContext context, {
  required String peerId,
  required String peerNickname,
  required String countryLabel,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: PostalTokens.inkNavy.withValues(alpha: 0.34),
    builder: (ctx) => SendLetterSheet(
      peerId: peerId,
      peerNickname: peerNickname,
      countryLabel: countryLabel,
    ),
  );
}

class SendLetterSheet extends ConsumerStatefulWidget {
  const SendLetterSheet({
    super.key,
    required this.peerId,
    required this.peerNickname,
    required this.countryLabel,
  });

  final String peerId;
  final String peerNickname;
  final String countryLabel;

  @override
  ConsumerState<SendLetterSheet> createState() => _SendLetterSheetState();
}

class _SendLetterSheetState extends ConsumerState<SendLetterSheet> {
  LetterType _type = LetterType.standard;
  bool _busy = false;
  final _body = TextEditingController();

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  /// [sheetContext] 须为嵌套在 [ScaffoldMessenger] 之下的子树 context，
  /// 否则 SnackBar 会挂到父页 Scaffold，在 bottom sheet 背后不可见。
  Future<void> _send(BuildContext sheetContext) async {
    final l10n = AppLocalizations.of(sheetContext)!;
    if (_body.text.trim().isEmpty) {
      PostalSnack.show(
        sheetContext,
        l10n.sendLetterBodyRequired,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    final session = ref.read(appSessionProvider);
    if (!mounted) return;
    if (_type == LetterType.registered &&
        !session.isVip &&
        session.stampBalance < 1) {
      PostalSnack.show(
        sheetContext,
        l10n.sendLetterRegisteredStampShort,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(mailboxRemoteRepositoryProvider)
          .sendLetter(
            toUserId: widget.peerId,
            content: _body.text.trim(),
            type: _type,
          );
      await ref.read(authRepositoryProvider).refreshSessionFromServer();
      if (!sheetContext.mounted) return;
      ref.invalidate(mailboxLettersProvider);
      ref.invalidate(postalInboxLettersProvider);
      ref.invalidate(mailboxArchiveProvider);
      if (!sheetContext.mounted) return;
      await showPostalSendLetterSuccessDialog(sheetContext);
      if (!sheetContext.mounted) return;
      Navigator.of(sheetContext).pop();
    } on ApiBusinessException catch (e) {
      if (sheetContext.mounted) {
        PostalSnack.show(sheetContext, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(appSessionProvider);
    final mq = MediaQuery.of(context);
    final viewH = mq.size.height;
    final kb = mq.viewInsets.bottom;
    final sheetH = ((viewH - kb) * 0.88).clamp(320.0, viewH * 0.92);

    return Padding(
      padding: EdgeInsets.only(bottom: kb),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: sheetH,
          width: double.infinity,
          child: Material(
            color: PostalTokens.paperEnvelope,
            elevation: 16,
            shadowColor: PostalTokens.inkNavy.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            clipBehavior: Clip.antiAlias,
            child: ScaffoldMessenger(
              child: Builder(
                builder: (sheetContext) {
                  return Scaffold(
                    backgroundColor: PostalTokens.paperEnvelope,
                    resizeToAvoidBottomInset: false,
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: PostalTokens.inkTertiary.withValues(
                                alpha: 0.38,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: PostalTokens.kraftBrownMuted.withValues(
                            alpha: 0.45,
                          ),
                        ),
                        Expanded(
                          child: SafeArea(
                            top: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                14,
                                20,
                                18,
                              ),
                              child: ListView(
                                physics: const ClampingScrollPhysics(),
                                children: [
                                  PostalSectionTitle(
                                    title: l10n.sendLetterSheetTitle(
                                      widget.peerNickname,
                                    ),
                                    subtitle: widget.countryLabel,
                                    trailing: IconButton(
                                      tooltip: MaterialLocalizations.of(
                                        context,
                                      ).closeButtonTooltip,
                                      icon: Icon(
                                        Icons.close,
                                        color: PostalTokens.inkTertiary,
                                      ),
                                      onPressed: _busy
                                          ? null
                                          : () => Navigator.of(
                                              sheetContext,
                                            ).pop(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: RadioListTile<LetterType>(
                                          // ignore: deprecated_member_use
                                          value: LetterType.standard,
                                          // ignore: deprecated_member_use
                                          groupValue: _type,
                                          // ignore: deprecated_member_use
                                          onChanged: _busy
                                              ? null
                                              : (v) =>
                                                    setState(() => _type = v!),
                                          title: Text(
                                            l10n.sendLetterStandardPost,
                                          ),
                                          subtitle: Text(
                                            l10n.sendLetterStandardSub,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: RadioListTile<LetterType>(
                                          // ignore: deprecated_member_use
                                          value: LetterType.registered,
                                          // ignore: deprecated_member_use
                                          groupValue: _type,
                                          // ignore: deprecated_member_use
                                          onChanged: _busy
                                              ? null
                                              : (v) =>
                                                    setState(() => _type = v!),
                                          title: Text(
                                            l10n.sendLetterRegisteredMail,
                                          ),
                                          subtitle: Text(
                                            session.isVip
                                                ? l10n.sendLetterRegisteredSubVip
                                                : l10n.sendLetterRegisteredSubPaid,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  PostalStampBadge(
                                    balance: session.stampBalance,
                                    cap: session.dailyStampCap,
                                    isVip: session.isVip,
                                  ),
                                  const SizedBox(height: 12),
                                  PostalTextField(
                                    controller: _body,
                                    label: l10n.sendLetterContentLabel,
                                    maxLines: 7,
                                    minLines: 5,
                                    showClearButton: false,
                                  ),
                                  const SizedBox(height: 14),
                                  PostalButton(
                                    label: 'Send now',
                                    onPressed: _busy
                                        ? null
                                        : () => _send(sheetContext),
                                    busy: _busy,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
