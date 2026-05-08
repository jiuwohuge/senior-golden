import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../core/api/api_exception.dart';
import '../../core/env/app_env.dart';
import '../../widgets/postal/postal.dart';
import '../shell/main_shell.dart';
import 'auth_repository.dart';
import 'login_routes.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController(text: 'edith@example.com');
  final _password = TextEditingController(text: '12345678');
  final _formKey = GlobalKey<FormState>();
  bool _agreed = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
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
      await ref
          .read(authRepositoryProvider)
          .login(email: _email.text, password: _password.text);
      if (mounted) {
        context.go(MainShellRoute.pathPostWall);
      }
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
      body: PaperTextureBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppEnv.useMock
                          ? PostalStampBadge(
                              isVip: true,
                              compact: true,
                              onTap: () {},
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 8),
                    PostalBrandHeader(
                      title: l10n.appTitle,
                      tagline: l10n.appTagline,
                      year: '2026',
                    ),
                    const SizedBox(height: 24),
                    PostalCardEnvelope(
                      header: PostalSectionTitle(
                        title: l10n.authLoginTitle,
                        subtitle: AppEnv.useMock
                            ? l10n.authMockTip
                            : l10n.authWelcomeBack,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                if (value.isEmpty) return l10n.authFieldRequired;
                                if (!value.contains('@') || !value.contains('.')) {
                                  return l10n.authEmailInvalid;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
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
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: PostalButton(
                                label: l10n.authForgotPassword,
                                onPressed: _busy
                                    ? null
                                    : () => context.go(LoginRoutes.forgotPassword),
                                variant: PostalButtonVariant.ghost,
                                expand: false,
                                minHeight: 40,
                              ),
                            ),
                            PostalCheckboxField(
                              value: _agreed,
                              onChanged: _busy
                                  ? null
                                  : (v) => setState(() => _agreed = v),
                              label: l10n.authAgreeTpl('{terms}', '{privacy}'),
                              linkSegments: [
                                PostalLinkSegment(
                                  key: 'terms',
                                  text: l10n.authTermsTitle,
                                  onTap: () => context.go(LoginRoutes.legalTerms),
                                ),
                                PostalLinkSegment(
                                  key: 'privacy',
                                  text: l10n.authPrivacyTitle,
                                  onTap: () =>
                                      context.go(LoginRoutes.legalPrivacy),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            PostalButton(
                              label: l10n.authLoginSubmit,
                              onPressed: _busy ? null : _submit,
                              busy: _busy,
                            ),
                            const SizedBox(height: 12),
                            PostalButton(
                              label: l10n.authGoRegister,
                              onPressed: _busy
                                  ? null
                                  : () => context.go(LoginRoutes.register),
                              variant: PostalButtonVariant.secondary,
                            ),
                            const SizedBox(height: 8),
                            PostalButton(
                              label: l10n.authOnboardingAgain,
                              onPressed: _busy
                                  ? null
                                  : () => context.go(LoginRoutes.onboarding),
                              variant: PostalButtonVariant.ghost,
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
