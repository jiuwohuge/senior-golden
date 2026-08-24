import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
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
import 'register_wizard_scaffold.dart';
import 'widgets/birth_year_picker_sheet.dart';

const int _kMaxRegisterAgeYears = 110;

/// Email → password → name + birth year + terms. Profile extras live in 我的.
const int _kRegisterSteps = 3;

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
  final _formEmailKey = GlobalKey<FormState>();
  final _formPasswordKey = GlobalKey<FormState>();
  final _formNameKey = GlobalKey<FormState>();

  int _step = 0;
  int? _birthYear;
  bool _emailChecking = false;
  String? _emailCheckedValue;
  String? _emailAvailabilityError;
  bool _agreed = false;
  bool _busy = false;
  double? _latitude;
  double? _longitude;
  bool _geoTried = false;

  @override
  void initState() {
    super.initState();
    void clearEmailAvailability() {
      if (_emailCheckedValue == null && _emailAvailabilityError == null) {
        return;
      }
      setState(() {
        _emailCheckedValue = null;
        _emailAvailabilityError = null;
      });
    }

    _email.addListener(clearEmailAvailability);
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryCaptureLocation());
  }

  /// Use coordinates if the OS already granted them at bootstrap. Do not
  /// request permission again — location is asked once on launch.
  Future<void> _tryCaptureLocation() async {
    if (_geoTried || kIsWeb) return;
    _geoTried = true;
    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        ),
      );
      if (!mounted) return;
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      });
    } catch (e) {
      debugPrint('register geo skipped: $e');
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _nickname.dispose();
    super.dispose();
  }

  List<int> _birthYearChoices(int minRegisterAge) {
    return buildBirthYearChoices(
      minRegisterAge: minRegisterAge,
      maxRegisterAgeYears: _kMaxRegisterAgeYears,
    );
  }

  void _back() {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    if (_step <= 0) {
      context.go(LoginRoutes.welcome);
    } else {
      setState(() => _step -= 1);
    }
  }

  Future<void> _next(
    AppLocalizations l10n,
    String? autoCc,
    List<int> years,
  ) async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    if (_step < _kRegisterSteps - 1) {
      if (_step == 0) {
        if (!(_formEmailKey.currentState?.validate() ?? false)) return;
        if (!await _validateRegisterEmailAvailable(showToast: true)) return;
      } else if (!_validateStep(l10n, years)) {
        return;
      }
      if (!mounted) return;
      setState(() => _step += 1);
      return;
    }
    await _submit(l10n, autoCc);
  }

  bool _validateStep(AppLocalizations l10n, List<int> years) {
    switch (_step) {
      case 1:
        return _formPasswordKey.currentState?.validate() ?? false;
      case 2:
        if (!(_formNameKey.currentState?.validate() ?? false)) return false;
        if (_birthYear == null || years.isEmpty) {
          PostalSnack.show(
            context,
            _birthYear == null
                ? l10n.authBirthYearRequired
                : l10n.authBirthYearRangeError,
            tone: PostalSnackTone.warning,
          );
          return false;
        }
        if (!_agreed) {
          PostalSnack.show(
            context,
            l10n.authAgreeRequired,
            tone: PostalSnackTone.warning,
          );
          return false;
        }
        return true;
      default:
        return false;
    }
  }

  Future<void> _pickBirthYear(List<int> years) async {
    if (years.isEmpty || _busy) return;
    final l10n = AppLocalizations.of(context)!;
    final picked = await showBirthYearPickerSheet(
      context,
      l10n: l10n,
      years: years,
    );
    if (picked != null) setState(() => _birthYear = picked);
  }

  void _ensureDefaultBirthYear(List<int> years) {
    if (!mounted || _birthYear != null || years.isEmpty) return;
    final target = DateTime.now().year - 45;
    final fallback = years.contains(target) ? target : years.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _birthYear != null) return;
      setState(() => _birthYear = fallback);
    });
  }

  Future<bool> _validateRegisterEmailAvailable({
    required bool showToast,
  }) async {
    final email = _email.text.trim().toLowerCase();
    if (email.isEmpty) {
      return false;
    }
    if (_emailCheckedValue == email && _emailAvailabilityError == null) {
      return true;
    }
    setState(() {
      _emailChecking = true;
      _emailAvailabilityError = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .validateRegisterEmail(email: email);
      if (!mounted) return true;
      setState(() {
        _emailCheckedValue = email;
        _emailAvailabilityError = null;
      });
      return true;
    } on ApiBusinessException catch (e) {
      if (!mounted) return false;
      setState(() {
        _emailCheckedValue = null;
        _emailAvailabilityError = e.message;
      });
      if (showToast) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.warning);
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _emailChecking = false);
        _formEmailKey.currentState?.validate();
      }
    }
  }

  Future<void> _submit(AppLocalizations l10n, String? autoCountryCode) async {
    if (!(_formNameKey.currentState?.validate() ?? false)) return;
    if (_birthYear == null) {
      PostalSnack.show(
        context,
        l10n.authBirthYearRequired,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    if (!_agreed) {
      PostalSnack.show(
        context,
        l10n.authAgreeRequired,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    if (!mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .register(
            email: _email.text,
            password: _password.text,
            nickname: _nickname.text,
            birthYear: _birthYear!,
            countryCode: autoCountryCode,
            latitude: _latitude,
            longitude: _longitude,
            agreedTerms: true,
          );
      if (!mounted) return;
      context.go(MainShellRoute.pathPostOffice);
    } on ApiBusinessException catch (e) {
      debugPrint('register failed: $e');
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _stepContent(
    BuildContext context,
    AppLocalizations l10n,
    List<int> years,
  ) {
    switch (_step) {
      case 0:
        return Form(
          key: _formEmailKey,
          child: Align(
            alignment: Alignment.topCenter,
            child: PostalTextField(
              controller: _email,
              label: l10n.authEmailLabel,
              hint: l10n.authEmailHint,
              prefixIcon: Icons.alternate_email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofocus: true,
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return l10n.authFieldRequired;
                if (!value.contains('@') || !value.contains('.')) {
                  return l10n.authEmailInvalid;
                }
                if (_emailAvailabilityError != null) {
                  return _emailAvailabilityError;
                }
                return null;
              },
            ),
          ),
        );
      case 1:
        return Form(
          key: _formPasswordKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PostalTextField(
                controller: _password,
                label: l10n.authPasswordLabel,
                prefixIcon: Icons.lock_outline,
                obscure: true,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.authFieldRequired;
                  if (v.length < 8) return l10n.authPasswordTooShort;
                  return null;
                },
              ),
              const SizedBox(height: 20),
              PostalTextField(
                controller: _confirmPassword,
                label: l10n.authConfirmPasswordLabel,
                prefixIcon: Icons.lock_reset_outlined,
                obscure: true,
                textInputAction: TextInputAction.done,
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.authFieldRequired;
                  if (v != _password.text) return l10n.authPasswordNotMatch;
                  return null;
                },
              ),
            ],
          ),
        );
      case 2:
        final age = _birthYear == null
            ? null
            : DateTime.now().year - _birthYear!;
        return Form(
          key: _formNameKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PostalTextField(
                controller: _nickname,
                label: l10n.authNicknameLabel,
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.done,
                autofocus: true,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.authFieldRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                l10n.authRegisterWizardAgeTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (age != null) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.authRegisterAgePreview('$age'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: PostalTokens.postboxGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Material(
                color: PostalTokens.paperCard.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: _busy || years.isEmpty
                      ? null
                      : () => _pickBirthYear(years),
                  borderRadius: BorderRadius.circular(14),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: PostalTokens.perforationLine),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _birthYear == null
                            ? l10n.authBirthYearLabel
                            : l10n.authBirthYearFormat(
                                '$_birthYear',
                                '${DateTime.now().year - _birthYear!}',
                              ),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: PostalTokens.inkNavy,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  (String title, String subtitle) _stepCopy(AppLocalizations l10n) {
    return switch (_step) {
      0 => (
        l10n.authRegisterWizardEmailTitle,
        l10n.authRegisterWizardEmailSubtitle,
      ),
      1 => (
        l10n.authRegisterWizardPasswordTitle,
        l10n.authRegisterWizardPasswordSubtitle,
      ),
      _ => (
        l10n.authRegisterWizardNameTitle,
        l10n.authRegisterWizardNameSubtitle,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode;
    final bootstrapAsync = ref.watch(appBootstrapProvider(lang));

    return Scaffold(
      body: PaperTextureBackground(
        child: SafeArea(
          child: bootstrapAsync.when(
            loading: () =>
                const PostalSkeletonList(itemCount: 3, itemHeight: 72),
            error: (error, _) => PostalEmptyState(
              title: l10n.authBootstrapLoadFailed,
              subtitle: l10n.commonLoadFailedHint,
              actionLabel: l10n.authRetry,
              onAction: () => ref.invalidate(appBootstrapProvider(lang)),
              tone: PostalEmptyTone.error,
            ),
            data: (bootstrap) {
              final years = _birthYearChoices(bootstrap.minRegisterAge);
              _ensureDefaultBirthYear(years);
              final autoCc = countryCodeForAppLocale(
                locale,
                bootstrap.countries,
              );
              final copy = _stepCopy(l10n);
              final canNext = switch (_step) {
                0 => !_emailChecking,
                2 => _agreed && _birthYear != null && years.isNotEmpty,
                _ => true,
              };

              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: RegisterWizardScaffold(
                  stepIndex: _step,
                  stepCount: _kRegisterSteps,
                  title: copy.$1,
                  subtitle: copy.$2,
                  footerHint: l10n.authRegisterProfileHint,
                  onBack: _busy ? null : _back,
                  onNext: () => _next(l10n, autoCc, years),
                  nextEnabled: canNext,
                  nextBusy: _busy,
                  isLastStep: _step == _kRegisterSteps - 1,
                  child: _stepContent(context, l10n, years),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
