import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/mock/mock_models.dart';
import '../../core/mock/mock_repository.dart';
import '../../widgets/postal/postal.dart';

class SendLetterSheet extends ConsumerStatefulWidget {
  const SendLetterSheet({super.key, required this.user});
  final MockUser user;

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

  Future<void> _send() async {
    if (_body.text.trim().isEmpty) {
      PostalSnack.show(context, 'Please write letter content.', tone: PostalSnackTone.warning);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(mockMailboxRepositoryProvider).send(
            peer: widget.user,
            body: _body.text.trim(),
            type: _type,
          );
      if (!mounted) return;
      PostalSnack.show(context, 'Mock: letter sent', tone: PostalSnackTone.success);
      Navigator.of(context).pop();
    } on ApiBusinessException catch (e) {
      if (mounted) PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(mockSessionProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
        child: ListView(
          shrinkWrap: true,
          children: [
            PostalSectionTitle(
              title: 'Send letter to ${widget.user.nickname}',
              subtitle: widget.user.countryName,
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
                    onChanged: _busy ? null : (v) => setState(() => _type = v!),
                    title: const Text('Registered Mail'),
                    subtitle: Text(session.isVip ? 'Free for VIP' : 'Consumes 1 stamp'),
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
                    onChanged: _busy ? null : (v) => setState(() => _type = v!),
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
              onPressed: _busy ? null : _send,
              busy: _busy,
            ),
          ],
        ),
      ),
    );
  }
}
