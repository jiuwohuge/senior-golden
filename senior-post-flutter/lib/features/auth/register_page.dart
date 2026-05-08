import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../core/api/api_exception.dart';
import '../../core/bootstrap/app_bootstrap.dart';
import '../../core/env/app_env.dart';
import '../../core/i18n/country_from_locale.dart';
import '../../core/mock/mock_data.dart';
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
  bool _agreed = false;
  bool _busy = false;
  final Set<int> _interestTagIds = {};
  final Set<String> _mockInterestKeys = {};

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

  Widget _interestPicker(BuildContext context, AppBootstrapData bootstrap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Interests', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (AppEnv.useMock)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MockData.interests
                .map(
                  (e) => FilterChip(
                    label: Text(e.label),
                    selected: _mockInterestKeys.contains(e.id),
                    onSelected: _busy
                        ? null
                        : (v) {
                            setState(() {
                              if (v) {
                                _mockInterestKeys.add(e.id);
                              } else {
                                _mockInterestKeys.remove(e.id);
                              }
                            });
                          },
                  ),
                )
                .toList(),
          )
        else if (bootstrap.interestTagOptions.isEmpty)
          Text(
            'No interest tags from server. Try another language or add tags in admin.',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: bootstrap.interestTagOptions
                .map(
                  (o) => FilterChip(
                    label: Text(o.tagName),
                    selected: _interestTagIds.contains(o.id),
                    onSelected: _busy
                        ? null
                        : (v) {
                            setState(() {
                              if (v) {
                                _interestTagIds.add(o.id);
                              } else {
                                _interestTagIds.remove(o.id);
                              }
                            });
                          },
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Future<void> _pickBirthYear(List<int> years) async {
    if (years.isEmpty || _busy) return;
    final l10n = AppLocalizations.of(context)!;
    final nowY = DateTime.now().year;
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Text(
                      l10n.authBirthYearSheetTitle,
                      style: Theme.of(ctx).textTheme.titleLarge,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: years.length,
                      itemBuilder: (_, i) {
                        final y = years[i];
                        final age = nowY - y;
                        return ListTile(
                          title: Text(l10n.authBirthYearFormat('$y', '$age')),
                          onTap: () => Navigator.pop(ctx, y),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (picked != null) {
      setState(() => _birthYear = picked);
    }
  }

  Future<void> _submit(String? autoCountryCode) async {
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
    if (AppEnv.useMock) {
      if (_mockInterestKeys.length < 3) {
        PostalSnack.show(
          context,
          'Please select at least 3 interests.',
          tone: PostalSnackTone.warning,
        );
        return;
      }
    } else {
      if (_interestTagIds.length < 3) {
        PostalSnack.show(
          context,
          'Please select at least 3 interests.',
          tone: PostalSnackTone.warning,
        );
        return;
      }
    }
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).register(
            email: _email.text,
            password: _password.text,
            nickname: _nickname.text,
            birthYear: _birthYear!,
            countryCode: autoCountryCode,
            agreedTerms: _agreed,
            interestTagIds: AppEnv.useMock ? const [] : _interestTagIds.toList(),
            mockInterestKeys: AppEnv.useMock ? _mockInterestKeys.toList() : null,
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
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode;
    final bootstrapAsync = ref.watch(appBootstrapProvider(lang));

    ref.listen<AsyncValue<AppBootstrapData>>(appBootstrapProvider(lang), (prev, next) {
      next.whenData((b) {
        final years = _birthYearChoices(b.minRegisterAge);
        if (!mounted || years.isEmpty || _birthYear != null) return;
        final target = DateTime.now().year - 45;
        setState(() {
          _birthYear = years.contains(target) ? target : years.first;
        });
      });
    });

    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      body: PaperTextureBackground(
        child: SafeArea(
          child: bootstrapAsync.when(
            loading: () => const PostalSkeletonList(itemCount: 3),
            error: (error, _) => PostalEmptyState(
              title: l10n.authBootstrapLoadFailed,
              subtitle: bootstrapDebugErrorHint(error),
              actionLabel: l10n.authRetry,
              onAction: () => ref.invalidate(appBootstrapProvider(lang)),
              tone: PostalEmptyTone.error,
            ),
            data: (bootstrap) {
              final years = _birthYearChoices(bootstrap.minRegisterAge);
              final autoCc = countryCodeForAppLocale(locale, bootstrap.countries);
              CountryItem? countryItem;
              for (final c in bootstrap.countries) {
                if (c.code == autoCc) {
                  countryItem = c;
                  break;
                }
              }
              final countryLabel =
                  countryItem?.displayName(locale.languageCode) ?? autoCc ?? '—';

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 28 + bottomInset),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                                  hint: l10n.authEmailHint,
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
                                  InkWell(
                                    onTap: _busy ? null : () => _pickBirthYear(years),
                                    borderRadius: BorderRadius.circular(8),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: l10n.authBirthYearLabel,
                                        suffixIcon: const Icon(Icons.expand_more),
                                      ),
                                      child: Text(
                                        _birthYear == null
                                            ? '—'
                                            : l10n.authBirthYearFormat(
                                                '$_birthYear',
                                                '${DateTime.now().year - _birthYear!}',
                                              ),
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 14),
                                InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: l10n.authCountryAutoLabel,
                                  ),
                                  child: Text(
                                    countryLabel,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _interestPicker(context, bootstrap),
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
                                  onPressed: (_busy || years.isEmpty) ? null : () => _submit(autoCc),
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
