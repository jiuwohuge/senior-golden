import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../core/api/api_exception.dart';
import '../../widgets/postal/postal.dart';
import 'auth_repository.dart';
import 'login_routes.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _email = TextEditingController();
  final _code = TextEditingController(text: '2026');
  final _newPwd = TextEditingController();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  int _step = 0;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _newPwd.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey1.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).forgotPassword(email: _email.text);
      if (!mounted) return;
      setState(() => _step = 1);
      PostalSnack.show(context, l10n.authForgotMailSent, tone: PostalSnackTone.success);
    } on ApiBusinessException catch (e) {
      if (mounted) PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reset() async {
    if (!(_formKey2.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).resetPassword(
            email: _email.text,
            code: _code.text,
            newPassword: _newPwd.text,
          );
      if (!mounted) return;
      setState(() => _step = 2);
    } on ApiBusinessException catch (e) {
      if (mounted) PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.authForgotPassword)),
      body: PaperTextureBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            children: [
              _stepper(context, l10n),
              const SizedBox(height: 18),
              if (_step == 0) _stepEmail(context, l10n),
              if (_step == 1) _stepReset(context, l10n),
              if (_step == 2) _stepDone(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepper(BuildContext context, AppLocalizations l10n) {
    Widget dot(int i, String label) {
      final active = _step >= i;
      return Expanded(
        child: Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? Theme.of(context).colorScheme.primary : Colors.transparent,
                border: Border.all(
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  color: active ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }

    return Row(
      children: [
        dot(0, l10n.authForgotStepEmail),
        dot(1, l10n.authForgotStepCode),
        dot(2, l10n.authForgotStepDone),
      ],
    );
  }

  Widget _stepEmail(BuildContext context, AppLocalizations l10n) {
    return PostalCardEnvelope(
      child: Form(
        key: _formKey1,
        child: Column(
          children: [
            PostalTextField(
              controller: _email,
              label: l10n.authEmailLabel,
              hint: 'name@example.com',
              prefixIcon: Icons.alternate_email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return l10n.authFieldRequired;
                if (!value.contains('@') || !value.contains('.')) return l10n.authEmailInvalid;
                return null;
              },
            ),
            const SizedBox(height: 16),
            PostalButton(
              label: l10n.authForgotSendCode,
              onPressed: _busy ? null : _send,
              busy: _busy,
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepReset(BuildContext context, AppLocalizations l10n) {
    return PostalCardEnvelope(
      child: Form(
        key: _formKey2,
        child: Column(
          children: [
            PostalTextField(
              controller: _code,
              label: l10n.authForgotCode,
              hint: '2026',
              prefixIcon: Icons.verified_outlined,
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.authFieldRequired : null,
            ),
            const SizedBox(height: 14),
            PostalTextField(
              controller: _newPwd,
              label: l10n.authForgotNewPassword,
              obscure: true,
              prefixIcon: Icons.lock_reset_outlined,
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.authFieldRequired;
                if (v.length < 8) return l10n.authPasswordTooShort;
                return null;
              },
            ),
            const SizedBox(height: 16),
            PostalButton(
              label: l10n.authForgotResetNow,
              onPressed: _busy ? null : _reset,
              busy: _busy,
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepDone(BuildContext context, AppLocalizations l10n) {
    return PostalEmptyState(
      title: l10n.authForgotDoneTitle,
      subtitle: l10n.authForgotDoneBody,
      tone: PostalEmptyTone.success,
      actionLabel: l10n.authBackToLogin,
      onAction: () => context.go(LoginRoutes.login),
    );
  }
}
