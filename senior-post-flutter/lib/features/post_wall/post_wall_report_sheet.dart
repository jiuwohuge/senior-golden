import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/postal/postal.dart';
import 'post_wall_remote.dart';

/// 举报明信片或评论。
class PostWallReportSheet extends ConsumerStatefulWidget {
  const PostWallReportSheet({
    super.key,
    required this.targetType,
    required this.objectId,
  });

  /// `postcard` 或 `comment`
  final String targetType;
  /// 数字 ID 字符串，解析为 `int` 提交后端。
  final String objectId;

  @override
  ConsumerState<PostWallReportSheet> createState() => _PostWallReportSheetState();
}

class _PostWallReportSheetState extends ConsumerState<PostWallReportSheet> {
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
      final id = int.tryParse(widget.objectId);
      if (id == null) {
        throw ApiBusinessException(0, l10n.errorInvalidContentId);
      }
      await ref.read(postWallRemoteProvider).submitReport(
            targetType: widget.targetType,
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
              widget.targetType == 'comment' ? '举报评论' : '举报明信片',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            PostalTextField(
              controller: _reason,
              label: '原因',
              hint: '请简要说明（最多 255 字）',
              maxLines: 4,
              maxLength: 255,
              showClearButton: true,
            ),
            const SizedBox(height: 14),
            PostalButton(
              label: '提交',
              busy: _busy,
              onPressed: _busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
