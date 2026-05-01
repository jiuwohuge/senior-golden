import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../core/api/api_exception.dart';
import '../../core/bootstrap/app_bootstrap.dart';
import '../shell/main_shell.dart';
import 'auth_repository.dart';
import 'login_routes.dart';

/// 与产品约定一致：年龄上限 110 岁（出生年最老为 当前年−110）。
const int _kMaxRegisterAgeYears = 110;

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
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
    _nickname.dispose();
    super.dispose();
  }

  List<int> _birthYearChoices(int minRegisterAge) {
    final y = DateTime.now().year;
    final minY = y - _kMaxRegisterAgeYears;
    final maxY = y - minRegisterAge;
    if (maxY < minY) {
      return <int>[];
    }
    return [for (var i = maxY; i >= minY; i--) i];
  }

  Future<void> _submit(AppBootstrapData bootstrap) async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_birthYear == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authFieldRequired)));
      return;
    }
    if (!_agreed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authAgreeRequired)));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .register(
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final bootstrapAsync = ref.watch(appBootstrapProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authRegisterTitle)),
      body: SafeArea(
        child: bootstrapAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.authBootstrapLoadFailed,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(appBootstrapProvider),
                    child: Text(l10n.authRetry),
                  ),
                ],
              ),
            ),
          ),
          data: (bootstrap) {
            final years = _birthYearChoices(bootstrap.minRegisterAge);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: l10n.authEmailLabel,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return l10n.authFieldRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.authPasswordLabel,
                        border: const OutlineInputBorder(),
                      ),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nickname,
                      decoration: InputDecoration(
                        labelText: l10n.authNicknameLabel,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return l10n.authFieldRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (years.isEmpty)
                      Text(
                        l10n.authBirthYearRangeError,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      )
                    else
                      DropdownButtonFormField<int>(
                        // ignore: deprecated_member_use
                        value: _birthYear,
                        decoration: InputDecoration(
                          labelText: l10n.authBirthYearLabel,
                          border: const OutlineInputBorder(),
                        ),
                        items: years
                            .map(
                              (y) =>
                                  DropdownMenuItem(value: y, child: Text('$y')),
                            )
                            .toList(),
                        onChanged: _busy
                            ? null
                            : (v) => setState(() => _birthYear = v),
                      ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      // ignore: deprecated_member_use
                      value: _countryCode,
                      decoration: InputDecoration(
                        labelText: l10n.authCountryCodeLabel,
                        border: const OutlineInputBorder(),
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
                      onChanged: _busy
                          ? null
                          : (v) => setState(() => _countryCode = v),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: _agreed,
                      onChanged: _busy
                          ? null
                          : (v) => setState(() => _agreed = v ?? false),
                      title: Text(l10n.authAgreeTerms),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: (_busy || years.isEmpty)
                          ? null
                          : () => _submit(bootstrap),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _busy
                          ? SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : Text(l10n.authRegisterSubmit),
                    ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => context.go(LoginRoutes.login),
                      child: Text(l10n.authGoLogin),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
