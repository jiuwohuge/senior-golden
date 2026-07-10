import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../core/api/api_exception.dart';
import '../../widgets/postal/postal.dart';
import '../mailbox/mailbox_remote.dart';

/// 往来信件导出（MVP）：选择日期范围并请求下载链接。
class LetterExportPage extends ConsumerStatefulWidget {
  const LetterExportPage({super.key});

  @override
  ConsumerState<LetterExportPage> createState() => _LetterExportPageState();
}

class _LetterExportPageState extends ConsumerState<LetterExportPage> {
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _busy = false;
  String? _downloadUrl;

  Future<void> _pickFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _fromDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _fromDate = picked);
  }

  Future<void> _pickTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _toDate = picked);
  }

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _downloadUrl = null;
    });
    try {
      final result = await ref
          .read(mailboxRemoteRepositoryProvider)
          .exportLetters(fromDate: _fromDate, toDate: _toDate);
      if (!mounted) return;
      setState(() => _downloadUrl = result.downloadUrl);
      PostalSnack.show(
        context,
        result.downloadUrl != null && result.downloadUrl!.isNotEmpty
            ? l10n.letterExportSuccess
            : l10n.letterExportPending,
        tone: PostalSnackTone.success,
      );
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.letterExportTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            PostalCardEnvelope(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.letterExportFromDate),
                    subtitle: Text(
                      _fromDate != null
                          ? MaterialLocalizations.of(
                              context,
                            ).formatMediumDate(_fromDate!)
                          : l10n.letterExportDateOptional,
                    ),
                    trailing: const Icon(Icons.calendar_month_outlined),
                    onTap: _pickFrom,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.letterExportToDate),
                    subtitle: Text(
                      _toDate != null
                          ? MaterialLocalizations.of(
                              context,
                            ).formatMediumDate(_toDate!)
                          : l10n.letterExportDateOptional,
                    ),
                    trailing: const Icon(Icons.calendar_month_outlined),
                    onTap: _pickTo,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PostalButton(
              label: l10n.letterExportSubmit,
              busy: _busy,
              onPressed: _busy ? null : _export,
            ),
            if (_downloadUrl != null && _downloadUrl!.isNotEmpty) ...[
              const SizedBox(height: 16),
              PostalCardEnvelope(
                child: SelectableText(
                  _downloadUrl!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
