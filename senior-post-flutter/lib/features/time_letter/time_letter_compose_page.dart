import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/session/app_session.dart';
import '../../widgets/postal/postal.dart';
import '../auth/auth_repository.dart';
import 'time_letter_providers.dart';
import 'time_letter_remote.dart';
import 'time_letter_seal_slider.dart';

class TimeLetterComposePage extends ConsumerStatefulWidget {
  const TimeLetterComposePage({
    super.key,
    this.recipientId,
    this.recipientNickname,
    this.toSelf = false,
  });

  final String? recipientId;
  final String? recipientNickname;
  final bool toSelf;

  @override
  ConsumerState<TimeLetterComposePage> createState() =>
      _TimeLetterComposePageState();
}

class _TimeLetterComposePageState extends ConsumerState<TimeLetterComposePage> {
  final _bodyCtrl = TextEditingController();
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 7));
  bool _sealing = false;
  String? _daysHint;

  /// IANA 偏移格式，供后端 {@code ZoneId} 解析（如 +08:00）。
  static String _offsetTimezoneId() {
    final offset = DateTime.now().timeZoneOffset;
    final totalMinutes = offset.inMinutes;
    final sign = totalMinutes >= 0 ? '+' : '-';
    final abs = totalMinutes.abs();
    final h = abs ~/ 60;
    final m = abs % 60;
    return '$sign${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  String get _deliveryTz => _offsetTimezoneId();

  @override
  void initState() {
    super.initState();
    _refreshDaysHint();
  }

  @override
  void dispose() {
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _refreshDaysHint() async {
    try {
      final days = await ref
          .read(timeLetterRemoteProvider)
          .previewDaysUntil(_deliveryDate, _deliveryTz);
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

  Future<void> _onSeal() async {
    final l10n = AppLocalizations.of(context)!;
    final body = _bodyCtrl.text.trim();
    if (body.isEmpty) {
      PostalSnack.show(
        context,
        l10n.timeLetterBodyEmpty,
        tone: PostalSnackTone.error,
      );
      return;
    }
    setState(() => _sealing = true);
    try {
      final sealId =
          '${DateTime.now().millisecondsSinceEpoch}-${ref.read(appSessionProvider).user.id}';
      final result = await ref
          .read(timeLetterRemoteProvider)
          .seal(
            recipientId: widget.toSelf ? null : widget.recipientId,
            body: body,
            deliveryDate: _deliveryDate,
            deliveryTz: _deliveryTz,
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
      if (mounted) context.pop(result.id);
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
      if (mounted) setState(() => _sealing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = widget.toSelf
        ? l10n.timeLetterComposeToSelf
        : l10n.timeLetterComposeToFriend(widget.recipientNickname ?? '');

    return Scaffold(
      backgroundColor: PostalTokens.paperCream,
      appBar: AppBar(
        backgroundColor: PostalTokens.postboxGreen,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.timeLetterComposeTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Row(
              children: [
                const Spacer(),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.timeLetterDeliveryDate),
              subtitle: Text(
                '${DateFormat.yMMMd().format(_deliveryDate)}'
                '${_daysHint != null ? ' · ${l10n.timeLetterDaysUntil(_daysHint!)}' : ''}',
              ),
              trailing: const Icon(Icons.calendar_month_outlined),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bodyCtrl,
              maxLines: 12,
              maxLength: 1500,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontSize: 20, height: 1.5),
              decoration: InputDecoration(
                hintText: l10n.timeLetterBodyHint,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TimeLetterSealSlider(
              label: l10n.timeLetterSealSlide,
              enabled: !_sealing,
              onSealed: _onSeal,
            ),
          ],
        ),
      ),
    );
  }
}
