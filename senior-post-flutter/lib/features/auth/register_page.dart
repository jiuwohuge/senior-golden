import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../core/api/api_exception.dart';
import '../../core/bootstrap/app_bootstrap.dart';
import '../../widgets/postal/postal.dart';
import '../shell/main_shell.dart';
import 'auth_repository.dart';
import 'login_routes.dart';

const int _kMaxRegisterAgeYears = 110;

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _nickname = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int? _birthYear;
  String? _countryCode;
  bool _agreed = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _nickname.dispose();
    super.dispose();
  }

  List<int> _birthYearChoices(int minRegisterAge) {
    final y = DateTime.now().year;
    final minY = y - _kMaxRegisterAgeYears;
    final maxY = y - minRegisterAge;
    if (maxY < minY) return <int>[];
    return [for (var i = maxY; i >= minY; i--) i];
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_birthYear == null) {
      PostalSnack.show(context, l10n.authBirthYearRequired, tone: PostalSnackTone.warning);
      return;
    }
    if (!_agreed) {
      PostalSnack.show(context, l10n.authAgreeRequired, tone: PostalSnackTone.warning);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).register(
            email: _email.text,
            password: _password.text,
            nickname: _nickname.text,
            birthYear: _birthYear!,
            countryCode: _countryCode,
            agreedTerms: _agreed,
          );
      if (mounted) context.go(MainShellRoute.pathPostWall);
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
    final lang = Localizations.localeOf(context).languageCode;
    final bootstrapAsync = ref.watch(appBootstrapProvider);

    return Scaffold(
      body: PaperTextureBackground(
        child: SafeArea(
          child: bootstrapAsync.when(
            loading: () => const PostalSkeletonList(itemCount: 3),
            error: (error, _) => PostalEmptyState(
              title: l10n.authBootstrapLoadFailed,
              subtitle: bootstrapDebugErrorHint(error),
              actionLabel: l10n.authRetry,
              onAction: () => ref.invalidate(appBootstrapProvider),
              tone: PostalEmptyTone.error,
            ),
            data: (bootstrap) {
              final years = _birthYearChoices(bootstrap.minRegisterAge);
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PostalBrandHeader(
                          title: l10n.authRegisterTitle,
                          tagline: l10n.authRegisterSubtitle,
                        ),
                        const SizedBox(height: 20),
                        PostalCardEnvelope(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  prefixIcon: Icons.lock_outline,
                                  obscure: true,
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
                                const SizedBox(height: 14),
                                PostalTextField(
                                  controller: _confirmPassword,
                                  label: l10n.authConfirmPasswordLabel,
                                  prefixIcon: Icons.lock_reset_outlined,
                                  obscure: true,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return l10n.authFieldRequired;
                                    }
                                    if (v != _password.text) {
                                      return l10n.authPasswordNotMatch;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                PostalTextField(
                                  controller: _nickname,
                                  label: l10n.authNicknameLabel,
                                  prefixIcon: Icons.person_outline,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return l10n.authFieldRequired;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                if (years.isEmpty)
                                  Text(
                                    l10n.authBirthYearRangeError,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                  )
                                else
                                  DropdownButtonFormField<int>(
                                    // ignore: deprecated_member_use
                                    value: _birthYear,
                                    decoration: InputDecoration(
                                      labelText: l10n.authBirthYearLabel,
                                    ),
                                    items: years
                                        .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                                        .toList(),
                                    onChanged: _busy ? null : (v) => setState(() => _birthYear = v),
                                  ),
                                const SizedBox(height: 14),
                                DropdownButtonFormField<String?>(
                                  // ignore: deprecated_member_use
                                  value: _countryCode,
                                  decoration: InputDecoration(
                                    labelText: l10n.authCountryCodeLabel,
                                  ),
                                  items: [
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(l10n.authCountrySkip),
                                    ),
                                    ...bootstrap.countries.map(
                                      (c) => DropdownMenuItem<String?>(
                                        value: c.code,
                                        child: Text(c.displayName(lang)),
                                      ),
                                    ),
                                  ],
                                  onChanged: _busy ? null : (v) => setState(() => _countryCode = v),
                                ),
                                const SizedBox(height: 8),
                                PostalCheckboxField(
                                  value: _agreed,
                                  onChanged: _busy ? null : (v) => setState(() => _agreed = v),
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
                                      onTap: () => context.go(LoginRoutes.legalPrivacy),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                PostalButton(
                                  label: l10n.authRegisterSubmit,
                                  onPressed: (_busy || years.isEmpty) ? null : _submit,
                                  busy: _busy,
                                ),
                                const SizedBox(height: 10),
                                PostalButton(
                                  label: l10n.authGoLogin,
                                  onPressed: _busy ? null : () => context.go(LoginRoutes.login),
                                  variant: PostalButtonVariant.secondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
