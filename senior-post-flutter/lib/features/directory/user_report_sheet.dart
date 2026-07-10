import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/postal/postal.dart';
import '../social/social_remote.dart';

/// 举报用户（`targetType`: `user`，与后端 [AppReportServiceImpl] 对齐）。
class UserReportSheet extends ConsumerStatefulWidget {
  const UserReportSheet({super.key, required this.targetUserId});

  final String targetUserId;

  @override
  ConsumerState<UserReportSheet> createState() => _UserReportSheetState();
}

class _UserReportSheetState extends ConsumerState<UserReportSheet> {
  final _reason = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final text = _reason.text.trim();
    if (text.isEmpty) {
      PostalSnack.show(context, l10n.reportReasonRequired, tone: PostalSnackTone.warning);
      return;
    }
    setState(() => _busy = true);
    try {
      final id = int.tryParse(widget.targetUserId);
      if (id == null) {
        throw ApiBusinessException(0, l10n.errorInvalidContentId);
      }
      await ref.read(socialRemoteProvider).submitReport(
            targetType: 'user',
            targetId: id,
            reason: text,
          );
      if (!mounted) return;
      PostalSnack.show(context, l10n.reportSubmitted, tone: PostalSnackTone.success);
      Navigator.of(context).pop();
    } on ApiBusinessException catch (e) {
      if (mounted) PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.userCardReportSheetTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            PostalTextField(
              controller: _reason,
              label: l10n.feedbackBodyLabel,
              hint: l10n.feedbackBodyHint,
              maxLines: 4,
              maxLength: 255,
              showClearButton: true,
            ),
            const SizedBox(height: 14),
            PostalButton(
              label: l10n.feedbackSubmit,
              busy: _busy,
              onPressed: _busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
