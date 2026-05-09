import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../core/api/api_exception.dart';
import '../../widgets/postal/postal.dart';
import '../social/social_remote.dart';

class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _body = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final text = _body.text.trim();
    if (text.isEmpty) {
      PostalSnack.show(
        context,
        l10n.feedbackNeedContent,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(socialRemoteProvider).submitFeedback(content: text);
      if (!mounted) return;
      PostalSnack.show(
        context,
        l10n.feedbackSuccess,
        tone: PostalSnackTone.success,
      );
      context.pop();
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
      appBar: AppBar(title: Text(l10n.feedbackTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            PostalCardEnvelope(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PostalTextField(
                    controller: _body,
                    label: l10n.feedbackBodyLabel,
                    hint: l10n.feedbackBodyHint,
                    maxLines: 10,
                    minLines: 6,
                    maxLength: 4000,
                    showClearButton: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PostalButton(
              label: _busy ? l10n.feedbackSubmitting : l10n.feedbackSubmit,
              onPressed: _busy ? null : _submit,
              busy: _busy,
            ),
          ],
        ),
      ),
    );
  }
}
