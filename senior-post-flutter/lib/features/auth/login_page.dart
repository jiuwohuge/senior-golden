import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../core/api/api_exception.dart';
import '../../core/auth/google_sign_in_facade.dart';
import '../../core/config/debug_api_base_url_dialog.dart';
import '../../widgets/postal/postal.dart';
import '../shell/main_shell.dart';
import 'auth_consent_provider.dart';
import 'auth_repository.dart';
import 'login_routes.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _challengeCode = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _agreed = false;
  bool _busy = false;
  bool _challengeMode = false;

  @override
  void initState() {
    super.initState();
    if (ref.read(authConsentProvider)) {
      _agreed = true;
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _challengeCode.dispose();
    super.dispose();
  }

  Future<void> _afterAuth(AuthSignInResult result) async {
    if (!mounted) return;
    if (result.requireEmailChallenge) {
      setState(() => _challengeMode = true);
      PostalSnack.show(
        context,
        AppLocalizations.of(context)!.authLoginChallengeHint,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    context.go(MainShellRoute.pathPostOffice);
  }

  Future<void> _continueAsGuest() async {
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).guest();
      if (!mounted) return;
      context.go(MainShellRoute.pathPostOffice);
    } on ApiBusinessException catch (e) {
      if (!mounted) return;
      PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreed) {
      PostalSnack.show(
        context,
        l10n.authAgreeRequired,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final result = await ref
          .read(authRepositoryProvider)
          .login(email: _email.text, password: _password.text);
      await _afterAuth(result);
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendChallengeCode() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .sendLoginChallenge(email: _email.text);
      if (!mounted) return;
      PostalSnack.show(
        context,
        l10n.authLoginChallengeCodeSent,
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

  Future<void> _confirmChallenge() async {
    final l10n = AppLocalizations.of(context)!;
    final code = _challengeCode.text.trim();
    if (code.isEmpty) {
      PostalSnack.show(
        context,
        l10n.settingsEmailVerifyCodeRequired,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final result = await ref
          .read(authRepositoryProvider)
          .confirmLoginChallenge(email: _email.text, code: code);
      await _afterAuth(result);
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_agreed) {
      PostalSnack.show(
        context,
        l10n.authAgreeRequired,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    if (!GoogleSignInFacade.isConfigured) {
      PostalSnack.show(
        context,
        l10n.authGoogleNotConfigured,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final idToken = await GoogleSignInFacade.signIn();
      if (idToken == null || idToken.isEmpty) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      final result = await ref
          .read(authRepositoryProvider)
          .signInWithGoogle(idToken: idToken);
      await _afterAuth(result);
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Google 登录仅 Android 正式渠道；Web 联调隐藏入口。
  bool get _showGoogle =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final compactLayout = MediaQuery.sizeOf(context).height < 860;
    return Scaffold(
      body: PaperTextureBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              compactLayout ? 10 : 16,
              20,
              compactLayout ? 16 : 28,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: _busy
                            ? null
                            : () => context.go(LoginRoutes.welcome),
                      ),
                    ),
                    PostalBrandHeader(
                      title: l10n.appTitle,
                      tagline: l10n.authWelcomeBack,
                      year: '2026',
                    ),
                    SizedBox(height: compactLayout ? 12 : 20),
                    PostalCardEnvelope(
                      header: PostalSectionTitle(title: l10n.authLoginTitle),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_showGoogle) ...[
                              PostalButton(
                                label: l10n.authContinueWithGoogle,
                                icon: Icons.g_mobiledata_rounded,
                                onPressed: _busy ? null : _signInWithGoogle,
                                variant: PostalButtonVariant.secondary,
                              ),
                              SizedBox(height: compactLayout ? 12 : 16),
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      l10n.authOrContinueWithEmail,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                              SizedBox(height: compactLayout ? 12 : 16),
                            ],
                            PostalTextField(
                              controller: _email,
                              label: l10n.authEmailLabel,
                              hint: l10n.authEmailHint,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icons.alternate_email,
                              autofillHints: const [AutofillHints.email],
                              validator: (v) {
                                final value = v?.trim() ?? '';
                                if (value.isEmpty) {
                                  return l10n.authFieldRequired;
                                }
                                if (!value.contains('@') ||
                                    !value.contains('.')) {
                                  return l10n.authEmailInvalid;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: compactLayout ? 10 : 14),
                            PostalTextField(
                              controller: _password,
                              label: l10n.authPasswordLabel,
                              hint: '••••••••',
                              prefixIcon: Icons.lock_outline,
                              obscure: true,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return l10n.authFieldRequired;
                                }
                                if (v.length < 8) {
                                  return l10n.authPasswordTooShort;
                                }
                                return null;
                              },
                            ),
                            if (_challengeMode) ...[
                              SizedBox(height: compactLayout ? 10 : 14),
                              Text(
                                l10n.authLoginChallengeTitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.authLoginChallengeHint,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              SizedBox(height: compactLayout ? 10 : 14),
                              PostalVerifyCodeField(
                                controller: _challengeCode,
                                label: l10n.settingsEmailVerifyCodeLabel,
                                sendLabel: l10n.bindSendCode,
                                sending: _busy,
                                enabled: !_busy,
                                onSend: _sendChallengeCode,
                              ),
                              SizedBox(height: compactLayout ? 10 : 14),
                              PostalButton(
                                label: l10n.authLoginChallengeConfirm,
                                onPressed: _busy ? null : _confirmChallenge,
                                busy: _busy,
                              ),
                            ],
                            SizedBox(height: compactLayout ? 6 : 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: PostalInlineLink(
                                label: l10n.authForgotPassword,
                                enabled: !_busy,
                                onPressed: _busy
                                    ? null
                                    : () => context.go(
                                        LoginRoutes.forgotPassword,
                                      ),
                              ),
                            ),
                            PostalCheckboxField(
                              value: _agreed,
                              onChanged: _busy
                                  ? null
                                  : (v) => setState(() => _agreed = v),
                              label: l10n.authAgreeTpl('{terms}', '{privacy}'),
                              compact: compactLayout,
                              linkSegments: [
                                PostalLinkSegment(
                                  key: 'terms',
                                  text: l10n.authTermsTitle,
                                  onTap: () =>
                                      context.go(LoginRoutes.legalTerms),
                                ),
                                PostalLinkSegment(
                                  key: 'privacy',
                                  text: l10n.authPrivacyTitle,
                                  onTap: () =>
                                      context.go(LoginRoutes.legalPrivacy),
                                ),
                              ],
                            ),
                            SizedBox(height: compactLayout ? 10 : 14),
                            if (!_challengeMode)
                              GestureDetector(
                                onLongPress: kDebugMode && !_busy
                                    ? () => showDebugApiBaseUrlDialog(
                                        context,
                                        ref,
                                      )
                                    : null,
                                child: PostalButton(
                                  label: l10n.authLoginSubmit,
                                  onPressed: _busy ? null : _submit,
                                  busy: _busy,
                                ),
                              ),
                            SizedBox(height: compactLayout ? 10 : 14),
                            PostalButton(
                              label: l10n.authContinueAsGuest,
                              variant: PostalButtonVariant.secondary,
                              onPressed: _busy ? null : _continueAsGuest,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
