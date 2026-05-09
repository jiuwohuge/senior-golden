import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/bootstrap/app_bootstrap.dart';
import '../../core/i18n/country_from_locale.dart';
import '../../widgets/postal/postal.dart';
import '../shell/main_shell.dart';
import 'auth_repository.dart';
import 'login_routes.dart';

const int _kMaxRegisterAgeYears = 110;
const int _kRegisterSteps = 4;

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
  final _formAccountKey = GlobalKey<FormState>();
  final _formProfileKey = GlobalKey<FormState>();
  int _step = 0;
  int? _birthYear;
  bool _agreed = false;
  bool _busy = false;
  final Set<int> _interestTagIds = {};

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

  String _maskedEmail(String raw) {
    final t = raw.trim();
    final at = t.indexOf('@');
    if (at <= 0 || at >= t.length - 1) return t.isEmpty ? '—' : t;
    final local = t.substring(0, at);
    final domain = t.substring(at + 1);
    final head = local.length <= 2 ? local : '${local.substring(0, 2)}…';
    return '$head@$domain';
  }

  int _interestCount() => _interestTagIds.length;

  void _goToStep(int index) {
    if (_busy || index < 0 || index >= _kRegisterSteps || index == _step) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _step = index);
  }

  List<String> _stepTabLabels(AppLocalizations l10n) {
    return [
      l10n.authRegisterTabAccount,
      l10n.authRegisterTabProfile,
      l10n.authRegisterTabInterests,
      l10n.authRegisterTabReview,
    ];
  }

  Widget _buildClickableStepTabs(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final labels = _stepTabLabels(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_kRegisterSteps, (i) {
              final active = i == _step;
              final label = labels[i];
              return Padding(
                padding: EdgeInsets.only(right: i < _kRegisterSteps - 1 ? 8 : 0),
                child: Semantics(
                  button: true,
                  selected: active,
                  label: '$label, ${l10n.authRegisterStepProgress('${i + 1}', '$_kRegisterSteps')}',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _busy ? null : () => _goToStep(i),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        constraints: const BoxConstraints(minWidth: 76, minHeight: 48),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: active
                                ? PostalTokens.postboxGreen
                                : PostalTokens.perforationLine.withValues(alpha: 0.95),
                            width: active ? 2 : 1,
                          ),
                          color: active
                              ? PostalTokens.paperEnvelope
                              : PostalTokens.paperCard.withValues(alpha: 0.35),
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: PostalTokens.postboxGreen.withValues(alpha: 0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${i + 1}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: active ? PostalTokens.postboxGreen : PostalTokens.inkTertiary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: active ? PostalTokens.inkNavy : PostalTokens.inkSecondary,
                                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressHeader(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: PostalTokens.inkNavy,
              visualDensity: VisualDensity.compact,
              onPressed: _busy
                  ? null
                  : () {
                      if (_step <= 0) {
                        context.go(LoginRoutes.login);
                      } else {
                        FocusScope.of(context).unfocus();
                        setState(() => _step -= 1);
                      }
                    },
            ),
            Expanded(
              child: Text(
                l10n.authRegisterStepProgress('${_step + 1}', '$_kRegisterSteps'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: PostalTokens.inkNavy,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: PostalTokens.s8),
        _buildClickableStepTabs(context, l10n),
        const SizedBox(height: PostalTokens.s4),
        Text(
          l10n.authRegisterWizardHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: PostalTokens.inkTertiary,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _buildInterestChips(BuildContext context, AppBootstrapData bootstrap, AppLocalizations l10n) {
    if (bootstrap.interestTagOptions.isEmpty) {
      return Text(
        l10n.authRegisterInterestsServerEmpty,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: PostalTokens.inkSecondary,
            ),
      );
    }
    return Wrap(
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
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: PostalTokens.inkSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(color: PostalTokens.inkNavy),
            ),
          ),
        ],
      ),
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

  bool _validateCurrentStep(AppLocalizations l10n, List<int> years, AppBootstrapData bootstrap) {
    switch (_step) {
      case 0:
        return _formAccountKey.currentState?.validate() ?? false;
      case 1:
        final ok = _formProfileKey.currentState?.validate() ?? false;
        if (!ok) return false;
        if (_birthYear == null) {
          PostalSnack.show(context, l10n.authBirthYearRequired, tone: PostalSnackTone.warning);
          return false;
        }
        if (years.isEmpty) {
          PostalSnack.show(context, l10n.authBirthYearRangeError, tone: PostalSnackTone.warning);
          return false;
        }
        return true;
      case 2:
        if (_interestCount() < 3) {
          PostalSnack.show(context, l10n.authRegisterInterestsMin, tone: PostalSnackTone.warning);
          return false;
        }
        if (bootstrap.interestTagOptions.isEmpty) {
          PostalSnack.show(context, l10n.authRegisterInterestsServerEmpty, tone: PostalSnackTone.warning);
          return false;
        }
        return true;
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _onPrimaryAction(
    AppLocalizations l10n,
    String? autoCountryCode,
    List<int> years,
    AppBootstrapData bootstrap,
  ) {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    if (_step < _kRegisterSteps - 1) {
      if (!_validateCurrentStep(l10n, years, bootstrap)) return;
      setState(() => _step += 1);
      return;
    }
    _submit(l10n, autoCountryCode);
  }

  /// 仅当前步挂载了 [Form] 时 [FormState] 才非空；最后一步点「注册」时必须不依赖 [FormState]。
  bool _validateAccountFieldsForSubmit(AppLocalizations l10n) {
    final value = _email.text.trim();
    if (value.isEmpty) {
      PostalSnack.show(context, l10n.authFieldRequired, tone: PostalSnackTone.warning);
      return false;
    }
    if (!value.contains('@') || !value.contains('.')) {
      PostalSnack.show(context, l10n.authEmailInvalid, tone: PostalSnackTone.warning);
      return false;
    }
    final p = _password.text;
    if (p.isEmpty) {
      PostalSnack.show(context, l10n.authFieldRequired, tone: PostalSnackTone.warning);
      return false;
    }
    if (p.length < 8) {
      PostalSnack.show(context, l10n.authPasswordTooShort, tone: PostalSnackTone.warning);
      return false;
    }
    final c = _confirmPassword.text;
    if (c.isEmpty) {
      PostalSnack.show(context, l10n.authFieldRequired, tone: PostalSnackTone.warning);
      return false;
    }
    if (c != p) {
      PostalSnack.show(context, l10n.authPasswordNotMatch, tone: PostalSnackTone.warning);
      return false;
    }
    return true;
  }

  bool _validateProfileFieldsForSubmit(AppLocalizations l10n) {
    if (_nickname.text.trim().isEmpty) {
      PostalSnack.show(context, l10n.authFieldRequired, tone: PostalSnackTone.warning);
      return false;
    }
    return true;
  }

  void _scheduleFormValidate(GlobalKey<FormState> key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      key.currentState?.validate();
    });
  }

  Future<void> _submit(AppLocalizations l10n, String? autoCountryCode) async {
    if (!_validateAccountFieldsForSubmit(l10n)) {
      setState(() => _step = 0);
      _scheduleFormValidate(_formAccountKey);
      return;
    }
    if (!_validateProfileFieldsForSubmit(l10n) || _birthYear == null) {
      setState(() => _step = 1);
      _scheduleFormValidate(_formProfileKey);
      if (_birthYear == null) {
        PostalSnack.show(context, l10n.authBirthYearRequired, tone: PostalSnackTone.warning);
      }
      return;
    }
    if (_interestCount() < 3) {
      setState(() => _step = 2);
      PostalSnack.show(context, l10n.authRegisterInterestsMin, tone: PostalSnackTone.warning);
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
            countryCode: autoCountryCode,
            agreedTerms: _agreed,
            interestTagIds: _interestTagIds.toList(),
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
                padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + bottomInset),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PostalBrandHeader(
                          title: l10n.authRegisterTitle,
                          tagline: l10n.authRegisterSubtitle,
                        ),
                        const SizedBox(height: PostalTokens.s8),
                        _buildProgressHeader(context, l10n),
                        const SizedBox(height: PostalTokens.s12),
                        PostalCardEnvelope(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildStepBody(context, l10n, years, bootstrap, countryLabel),
                              const SizedBox(height: PostalTokens.s16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_step > 0)
                                    Expanded(
                                      child: PostalButton(
                                        label: l10n.authRegisterBack,
                                        variant: PostalButtonVariant.secondary,
                                        expand: true,
                                        onPressed: _busy
                                            ? null
                                            : () {
                                                FocusScope.of(context).unfocus();
                                                setState(() => _step -= 1);
                                              },
                                      ),
                                    ),
                                  if (_step > 0) const SizedBox(width: 12),
                                  Expanded(
                                    child: PostalButton(
                                      label: _step == _kRegisterSteps - 1
                                          ? l10n.authRegisterSubmit
                                          : l10n.authRegisterNext,
                                      busy: _busy,
                                      expand: true,
                                      onPressed: (_busy || (_step == 1 && years.isEmpty))
                                          ? null
                                          : () => _onPrimaryAction(
                                                l10n,
                                                autoCc,
                                                years,
                                                bootstrap,
                                              ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: PostalTokens.s8),
                              PostalButton(
                                label: l10n.authGoLogin,
                                onPressed: _busy ? null : () => context.go(LoginRoutes.login),
                                variant: PostalButtonVariant.ghost,
                              ),
                            ],
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

  Widget _buildStepBody(
    BuildContext context,
    AppLocalizations l10n,
    List<int> years,
    AppBootstrapData bootstrap,
    String countryLabel,
  ) {
    switch (_step) {
      case 0:
        return _stepAccount(context, l10n);
      case 1:
        return _stepProfile(context, l10n, years);
      case 2:
        return _stepInterests(context, l10n, bootstrap);
      case 3:
        return _stepReview(context, l10n, countryLabel);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _stepAccount(BuildContext context, AppLocalizations l10n) {
    return Form(
      key: _formAccountKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PostalSectionTitle(
            title: l10n.authRegisterStepAccountTitle,
            subtitle: l10n.authRegisterStepAccountSubtitle,
          ),
          const SizedBox(height: PostalTokens.s12),
          PostalTextField(
            controller: _email,
            label: l10n.authEmailLabel,
            hint: l10n.authEmailHint,
            prefixIcon: Icons.alternate_email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return l10n.authFieldRequired;
              if (!value.contains('@') || !value.contains('.')) {
                return l10n.authEmailInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          PostalTextField(
            controller: _password,
            label: l10n.authPasswordLabel,
            prefixIcon: Icons.lock_outline,
            obscure: true,
            textInputAction: TextInputAction.next,
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
          const SizedBox(height: 10),
          PostalTextField(
            controller: _confirmPassword,
            label: l10n.authConfirmPasswordLabel,
            prefixIcon: Icons.lock_reset_outlined,
            obscure: true,
            textInputAction: TextInputAction.done,
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
        ],
      ),
    );
  }

  Widget _stepProfile(BuildContext context, AppLocalizations l10n, List<int> years) {
    return Form(
      key: _formProfileKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PostalSectionTitle(
            title: l10n.authRegisterStepProfileTitle,
            subtitle: l10n.authRegisterStepProfileSubtitle,
          ),
          const SizedBox(height: PostalTokens.s12),
          PostalTextField(
            controller: _nickname,
            label: l10n.authNicknameLabel,
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return l10n.authFieldRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
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
                  errorText: null,
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
        ],
      ),
    );
  }

  Widget _stepInterests(BuildContext context, AppLocalizations l10n, AppBootstrapData bootstrap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PostalSectionTitle(
          title: l10n.authRegisterStepInterestsTitle,
          subtitle: l10n.authRegisterStepInterestsSubtitle,
        ),
        const SizedBox(height: PostalTokens.s8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: PostalTokens.stampVermilionMuted.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: PostalTokens.perforationLine.withValues(alpha: 0.9)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 20, color: PostalTokens.stampVermilion),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.authRegisterInterestsMin,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PostalTokens.inkSecondary,
                        height: 1.3,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PostalTokens.s12),
        _buildInterestChips(context, bootstrap, l10n),
      ],
    );
  }

  Widget _stepReview(BuildContext context, AppLocalizations l10n, String countryLabel) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PostalSectionTitle(
          title: l10n.authRegisterStepReviewTitle,
          subtitle: l10n.authRegisterStepReviewSubtitle,
        ),
        const SizedBox(height: PostalTokens.s12),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: PostalTokens.paperEnvelope.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: PostalTokens.kraftBrownMuted.withValues(alpha: 0.65)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _summaryRow(context, l10n.authRegisterSummaryEmail, _maskedEmail(_email.text)),
              Divider(height: 20, color: PostalTokens.perforationLine.withValues(alpha: 0.85)),
              _summaryRow(context, l10n.authRegisterSummaryNickname, _nickname.text.trim().isEmpty ? '—' : _nickname.text.trim()),
              _summaryRow(
                context,
                l10n.authRegisterSummaryBirth,
                _birthYear == null
                    ? '—'
                    : l10n.authBirthYearFormat(
                        '$_birthYear',
                        '${DateTime.now().year - _birthYear!}',
                      ),
              ),
              _summaryRow(context, l10n.authRegisterSummaryCountry, countryLabel),
              _summaryRow(
                context,
                l10n.authRegisterSummaryInterests,
                '${_interestCount()}',
              ),
            ],
          ),
        ),
        const SizedBox(height: PostalTokens.s16),
        Text(
          l10n.authRegisterStepReviewSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(color: PostalTokens.inkTertiary),
        ),
        const SizedBox(height: PostalTokens.s12),
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
      ],
    );
  }
}
