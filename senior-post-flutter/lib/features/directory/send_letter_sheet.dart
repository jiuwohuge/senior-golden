import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/models/domain_models.dart';
import '../../core/session/app_session.dart';
import '../../widgets/postal/postal.dart';
import '../auth/auth_repository.dart';
import '../mailbox/mailbox_providers.dart';
import '../mailbox/mailbox_remote.dart';

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
  LetterType _type = LetterType.registered;
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
    if (_body.text.trim().isEmpty) {
      PostalSnack.show(
        sheetContext,
        'Please write letter content.',
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
        'Not enough stamps for registered mail.',
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
      PostalSnack.show(
        sheetContext,
        'Letter sent',
        tone: PostalSnackTone.success,
      );
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
    final session = ref.watch(appSessionProvider);
    return ScaffoldMessenger(
      child: Builder(
        builder: (sheetContext) {
          // SnackBar 要求本 Messenger 子树下至少有一个 Scaffold，否则会断言失败。
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                  PostalSectionTitle(
                    title: 'Send letter to ${widget.peerNickname}',
                    subtitle: widget.countryLabel,
                  ),
                  const SizedBox(height: 12),
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
                              : (v) => setState(() => _type = v!),
                          title: const Text('Registered Mail'),
                          subtitle: Text(
                            session.isVip ? 'Free for VIP' : 'Consumes 1 stamp',
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
                          value: LetterType.standard,
                          // ignore: deprecated_member_use
                          groupValue: _type,
                          // ignore: deprecated_member_use
                          onChanged: _busy
                              ? null
                              : (v) => setState(() => _type = v!),
                          title: const Text('Standard Post'),
                          subtitle: const Text('Free, delayed delivery'),
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
                    label: 'Letter content',
                    maxLines: 7,
                    minLines: 5,
                    showClearButton: false,
                  ),
                  const SizedBox(height: 14),
                  PostalButton(
                    label: 'Send now',
                    onPressed: _busy ? null : () => _send(sheetContext),
                    busy: _busy,
                  ),
                ],
              ),
            ),
          ),
          );
        },
      ),
    );
  }
}
