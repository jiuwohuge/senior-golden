import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/bootstrap/app_bootstrap.dart';
import '../../core/i18n/country_from_locale.dart';
import '../../core/models/interest_tag_option.dart';
import '../../core/oss/oss_upload_service.dart';
import '../../core/session/app_session.dart';
import '../../widgets/postal/postal.dart';
import '../profile/avatar_crop_page.dart';
import '../shell/main_shell.dart';
import 'auth_repository.dart';
import 'login_routes.dart';
import 'register_wizard_scaffold.dart';
import 'widgets/birth_year_picker_sheet.dart';

const int _kMaxRegisterAgeYears = 110;

/// 邮箱 → 密码 → 姓名 → 性别 → 年龄 → 兴趣 → 头像(可选) → 预览
const int _kRegisterSteps = 8;

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
  int? _gender;
  bool _emailChecking = false;
  String? _emailCheckedValue;
  String? _emailAvailabilityError;
  Uint8List? _avatarPendingBytes;
  String? _avatarObjectKey;
  bool _avatarUploading = false;
  bool _accountRegistered = false;
  bool _agreed = false;
  bool _busy = false;
  final Set<int> _interestTagIds = {};
  String? _manualCountryCode;
  double? _latitude;
  double? _longitude;
  /// GPS/注册后由服务端回填的城市（只读展示）。
  String? _resolvedCity;
  bool _geoTried = false;

  @override
  void initState() {
    super.initState();
    _tryCaptureLocation();
    void invalidateRegistration() {
      if (!_accountRegistered) return;
      setState(() {
        _accountRegistered = false;
        _avatarObjectKey = null;
      });
      ref.read(authRepositoryProvider).logout(reenterAsGuest: false);
    }

    void clearEmailAvailability() {
      if (_emailCheckedValue == null && _emailAvailabilityError == null) {
        return;
      }
      setState(() {
        _emailCheckedValue = null;
        _emailAvailabilityError = null;
      });
    }

    _email.addListener(invalidateRegistration);
    _email.addListener(clearEmailAvailability);
    _password.addListener(invalidateRegistration);
  }

  /// 可选 GPS：失败不阻塞注册，回落 locale / 手动国家。
  Future<void> _tryCaptureLocation() async {
    if (_geoTried || kIsWeb) return;
    _geoTried = true;
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
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

  String _genderLabel(AppLocalizations l10n) {
    return switch (_gender) {
      1 => l10n.authGenderMale,
      2 => l10n.authGenderFemale,
      _ => '—',
    };
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
    AppBootstrapData bootstrap,
  ) async {
    if (_busy || _avatarUploading) return;
    FocusScope.of(context).unfocus();
    if (_step < _kRegisterSteps - 1) {
      if (_step == 0) {
        if (!(_formEmailKey.currentState?.validate() ?? false)) return;
        if (!await _validateRegisterEmailAvailable(showToast: true)) return;
      } else if (!_validateStep(l10n, years, bootstrap)) {
        return;
      }
      if (!mounted) return;
      setState(() => _step += 1);
      return;
    }
    await _submit(l10n, _manualCountryCode ?? autoCc);
  }

  bool _validateStep(
    AppLocalizations l10n,
    List<int> years,
    AppBootstrapData bootstrap,
  ) {
    switch (_step) {
      case 0:
        return false;
      case 1:
        return _formPasswordKey.currentState?.validate() ?? false;
      case 2:
        return _formNameKey.currentState?.validate() ?? false;
      case 3:
        if (_gender == 1 || _gender == 2) return true;
        PostalSnack.show(
          context,
          l10n.authGenderLabel,
          tone: PostalSnackTone.warning,
        );
        return false;
      case 4:
        if (_birthYear != null && years.isNotEmpty) return true;
        PostalSnack.show(
          context,
          _birthYear == null
              ? l10n.authBirthYearRequired
              : l10n.authBirthYearRangeError,
          tone: PostalSnackTone.warning,
        );
        return false;
      case 5:
        if (_interestTagIds.length >= 3 &&
            bootstrap.interestTagOptions.isNotEmpty) {
          return true;
        }
        if (bootstrap.interestTagOptions.isEmpty) {
          PostalSnack.show(
            context,
            l10n.authRegisterInterestsServerEmpty,
            tone: PostalSnackTone.warning,
          );
        } else {
          PostalSnack.show(
            context,
            l10n.authRegisterInterestsMin,
            tone: PostalSnackTone.warning,
          );
        }
        return false;
      case 6:
        return true;
      case 7:
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

  Future<void> _pickRegisterAvatar() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 92,
    );
    if (x == null || !mounted) return;
    final raw = await x.readAsBytes();
    if (!mounted) return;
    final cropped = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(builder: (_) => AvatarCropPage(imageBytes: raw)),
    );
    if (cropped == null || !mounted) return;
    setState(() {
      _avatarPendingBytes = cropped;
      _avatarObjectKey = null;
    });
  }

  Future<void> _registerIfNeeded(
    AppLocalizations l10n,
    String? autoCountryCode,
  ) async {
    if (_accountRegistered) return;
    if (!_validateRegistrationFields(l10n)) {
      throw ApiBusinessException(400, l10n.authFieldRequired);
    }
    await ref
        .read(authRepositoryProvider)
        .register(
          email: _email.text,
          password: _password.text,
          nickname: _nickname.text,
          gender: _gender!,
          birthYear: _birthYear!,
          countryCode: autoCountryCode,
          latitude: _latitude,
          longitude: _longitude,
          agreedTerms: true,
          interestTagIds: _interestTagIds.toList(),
          avatarUrl: _avatarObjectKey,
        );
    _accountRegistered = true;
    if (!mounted) return;
    final city = ref.read(appSessionProvider).user.city?.trim();
    if (city != null && city.isNotEmpty) {
      _resolvedCity = city;
    }
  }

  Future<void> _uploadAvatarIfPossible(
    AppLocalizations l10n,
    String? autoCountryCode,
  ) async {
    final bytes = _avatarPendingBytes;
    if (bytes == null || _avatarObjectKey != null) return;
    if (!_validateRegistrationFields(l10n)) return;
    if (!mounted) return;

    setState(() => _avatarUploading = true);
    try {
      await _registerIfNeeded(l10n, autoCountryCode);
      if (!mounted) return;
      final key = await ref
          .read(ossUploadServiceProvider)
          .uploadAvatarImage(
            bytes: bytes,
            ext: 'jpg',
            contentType: 'image/jpeg',
          );
      if (!mounted) return;
      await ref
          .read(authRepositoryProvider)
          .updateProfileOnServer(avatarUrl: key);
      if (!mounted) return;
      setState(() => _avatarObjectKey = key);
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
      rethrow;
    } finally {
      if (mounted) setState(() => _avatarUploading = false);
    }
  }

  Future<void> _submit(AppLocalizations l10n, String? autoCountryCode) async {
    if (!_validateAllForSubmit(l10n)) return;
    if (!mounted) return;
    setState(() => _busy = true);
    try {
      // 先完成注册与头像上传，再导航，避免 dispose 后继续用 ref。
      if (!_accountRegistered) {
        await _registerIfNeeded(l10n, autoCountryCode);
        if (!mounted) return;
        if (_avatarPendingBytes != null && _avatarObjectKey == null) {
          await _uploadAvatarIfPossible(l10n, autoCountryCode);
          if (!mounted) return;
        }
      }
      if (!mounted) return;
      final city = ref.read(appSessionProvider).user.city;
      if (city != null && city.trim().isNotEmpty) {
        _resolvedCity = city.trim();
      }
      if (!mounted) return;
      context.go(MainShellRoute.pathPostOffice);
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool _validateRegistrationFields(AppLocalizations l10n) {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      return false;
    }
    final pwd = _password.text;
    if (pwd.isEmpty || pwd.length < 8 || _confirmPassword.text != pwd) {
      return false;
    }
    if (_nickname.text.trim().isEmpty) return false;
    if (_gender != 1 && _gender != 2) return false;
    if (_birthYear == null) return false;
    if (_interestTagIds.length < 3) return false;
    return true;
  }

  /// 最后一步提交时前几步 Form 已卸载，不能依赖 [FormState.validate]。
  bool _validateAllForSubmit(AppLocalizations l10n) {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      setState(() => _step = 0);
      PostalSnack.show(
        context,
        email.isEmpty ? l10n.authFieldRequired : l10n.authEmailInvalid,
        tone: PostalSnackTone.warning,
      );
      return false;
    }
    final pwd = _password.text;
    if (pwd.isEmpty || pwd.length < 8) {
      setState(() => _step = 1);
      PostalSnack.show(
        context,
        pwd.isEmpty ? l10n.authFieldRequired : l10n.authPasswordTooShort,
        tone: PostalSnackTone.warning,
      );
      return false;
    }
    if (_confirmPassword.text != pwd) {
      setState(() => _step = 1);
      PostalSnack.show(
        context,
        l10n.authPasswordNotMatch,
        tone: PostalSnackTone.warning,
      );
      return false;
    }
    if (_nickname.text.trim().isEmpty) {
      setState(() => _step = 2);
      PostalSnack.show(
        context,
        l10n.authFieldRequired,
        tone: PostalSnackTone.warning,
      );
      return false;
    }
    if (_gender != 1 && _gender != 2) {
      setState(() => _step = 3);
      PostalSnack.show(
        context,
        l10n.authGenderLabel,
        tone: PostalSnackTone.warning,
      );
      return false;
    }
    if (_birthYear == null) {
      setState(() => _step = 4);
      PostalSnack.show(
        context,
        l10n.authBirthYearRequired,
        tone: PostalSnackTone.warning,
      );
      return false;
    }
    if (_interestTagIds.length < 3) {
      setState(() => _step = 5);
      PostalSnack.show(
        context,
        l10n.authRegisterInterestsMin,
        tone: PostalSnackTone.warning,
      );
      return false;
    }
    if (!_agreed) {
      setState(() => _step = 7);
      PostalSnack.show(
        context,
        l10n.authAgreeRequired,
        tone: PostalSnackTone.warning,
      );
      return false;
    }
    return true;
  }

  Widget _stepContent(
    BuildContext context,
    AppLocalizations l10n,
    List<int> years,
    AppBootstrapData bootstrap,
    String countryLabel,
    String? autoCountryCode,
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
        return Form(
          key: _formNameKey,
          child: Align(
            alignment: Alignment.topCenter,
            child: PostalTextField(
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
          ),
        );
      case 3:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RegisterWizardChoiceTile(
                label: l10n.authGenderMale,
                selected: _gender == 1,
                enabled: !_busy,
                compact: true,
                onTap: () => setState(() => _gender = 1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RegisterWizardChoiceTile(
                label: l10n.authGenderFemale,
                selected: _gender == 2,
                enabled: !_busy,
                compact: true,
                onTap: () => setState(() => _gender = 2),
              ),
            ),
          ],
        );
      case 4:
        if (years.isEmpty) {
          return Text(
            l10n.authBirthYearRangeError,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: PostalTokens.error),
          );
        }
        final age = _birthYear == null
            ? null
            : DateTime.now().year - _birthYear!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (age != null)
              Text(
                l10n.authRegisterAgePreview('$age'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: PostalTokens.postboxGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
            const SizedBox(height: 16),
            Material(
              color: PostalTokens.paperCard.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: _busy ? null : () => _pickBirthYear(years),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: PostalTokens.perforationLine),
                  ),
                  child: Text(
                    _birthYear == null
                        ? l10n.authBirthYearLabel
                        : l10n.authBirthYearFormat(
                            '$_birthYear',
                            '${DateTime.now().year - _birthYear!}',
                          ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: PostalTokens.inkNavy,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      case 5:
        return SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: bootstrap.interestTagOptions
                .map(
                  (o) => FilterChip(
                    label: Text(o.tagName),
                    selected: _interestTagIds.contains(o.id),
                    onSelected: _busy
                        ? null
                        : (v) => setState(() {
                            if (v) {
                              _interestTagIds.add(o.id);
                            } else {
                              _interestTagIds.remove(o.id);
                            }
                          }),
                  ),
                )
                .toList(),
          ),
        );
      case 6:
        return _stepAvatar(context, l10n);
      case 7:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _reviewCard(
                context,
                l10n,
                countryLabel,
                bootstrap.countries,
                bootstrap.interestTagOptions,
                Localizations.localeOf(context).languageCode,
              ),
              const SizedBox(height: 12),
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

  Widget _reviewCard(
    BuildContext context,
    AppLocalizations l10n,
    String countryLabel,
    List<CountryItem> countries,
    List<InterestTagOption> interestOptions,
    String lang,
  ) {
    final selectedCountryCode = () {
      final codes = countries.map((c) => c.code).toSet();
      final preferred = _manualCountryCode;
      if (preferred != null && codes.contains(preferred)) {
        return preferred;
      }
      for (final c in countries) {
        if (c.displayName(lang) == countryLabel || c.code == countryLabel) {
          return c.code;
        }
      }
      return codes.isEmpty ? null : codes.first;
    }();
    final selectedCountryName = () {
      for (final c in countries) {
        if (c.code == selectedCountryCode) {
          return c.displayName(lang);
        }
      }
      return countryLabel.isNotEmpty ? countryLabel : '—';
    }();
    final interestNames = interestOptions
        .where((o) => _interestTagIds.contains(o.id))
        .map((o) => o.tagName)
        .toList();
    final interestSep = lang.toLowerCase().startsWith('zh') ? '、' : ', ';
    final interestSummary =
        interestNames.isEmpty ? '—' : interestNames.join(interestSep);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PostalTokens.paperEnvelope,
            PostalTokens.paperCream.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PostalTokens.kraftBrownMuted.withValues(alpha: 0.85),
        ),
        boxShadow: [
          BoxShadow(
            color: PostalTokens.inkNavy.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow(
            context,
            l10n.authRegisterSummaryEmail,
            _email.text.trim().isEmpty ? '—' : _email.text.trim(),
            valueMaxLines: 3,
          ),
          _summaryRow(
            context,
            l10n.authRegisterSummaryNickname,
            _nickname.text.trim(),
          ),
          _summaryRow(
            context,
            l10n.authRegisterSummaryGender,
            _genderLabel(l10n),
          ),
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
          // 国家：紧凑胶囊 + 半屏搜索；无满宽灰底「假下拉」。
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 96,
                  child: Text(
                    l10n.authRegisterSummaryCountry,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PostalTokens.inkSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: PostalCountrySelectChip(
                      countryCode: selectedCountryCode,
                      countryName: selectedCountryName,
                      enabled: !_busy,
                      onTap: () async {
                        final code = await showPostalCountryPickerSheet(
                          context: context,
                          l10n: l10n,
                          countries: countries,
                          languageCode: lang,
                          selectedCode: selectedCountryCode,
                        );
                        if (code != null && mounted) {
                          setState(() => _manualCountryCode = code);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_resolvedCity != null && _resolvedCity!.isNotEmpty)
            _summaryRow(
              context,
              l10n.authRegisterSummaryCity,
              _resolvedCity!,
            ),
          if (_latitude != null && _longitude != null)
            _summaryRow(
              context,
              l10n.authRegisterSummaryLocation,
              _resolvedCity != null && _resolvedCity!.isNotEmpty
                  ? l10n.authRegisterLocationCaptured
                  : l10n.authRegisterLocationPendingCity,
            ),
          _summaryRow(
            context,
            l10n.authRegisterSummaryInterests,
            interestSummary,
            valueMaxLines: 2,
          ),
          _summaryRow(
            context,
            l10n.authRegisterSummaryAvatar,
            _avatarSummaryLabel(l10n),
          ),
        ],
      ),
    );
  }

  Widget _stepAvatar(BuildContext context, AppLocalizations l10n) {
    final pending = _avatarPendingBytes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: AspectRatio(
              aspectRatio: 1,
              child: Material(
                color: PostalTokens.paperCard.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: (_busy || _avatarUploading)
                      ? null
                      : _pickRegisterAvatar,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (pending != null)
                        Image.memory(pending, fit: BoxFit.cover)
                      else
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              size: 56,
                              color: PostalTokens.inkTertiary.withValues(
                                alpha: 0.85,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.authRegisterAvatarTapToAdd,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: PostalTokens.inkTertiary),
                            ),
                          ],
                        ),
                      if (pending != null && !_avatarUploading)
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: PostalTokens.inkNavy.withValues(
                                alpha: 0.72,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      if (_avatarUploading)
                        ColoredBox(
                          color: PostalTokens.inkNavy.withValues(alpha: 0.35),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.authRegisterAvatarUploading,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_avatarObjectKey != null && !_avatarUploading)
                        Positioned(
                          left: 10,
                          top: 10,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: PostalTokens.postboxGreen.withValues(
                                alpha: 0.92,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Text(
                                l10n.authRegisterAvatarUploaded,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
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
        const SizedBox(height: 20),
        Text(
          l10n.authRegisterAvatarSkipHint,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: PostalTokens.inkTertiary),
        ),
      ],
    );
  }

  String _avatarSummaryLabel(AppLocalizations l10n) {
    if (_avatarUploading) return l10n.authRegisterAvatarUploading;
    if (_avatarObjectKey != null) return l10n.authRegisterSummaryAvatarSet;
    if (_avatarPendingBytes != null) {
      return l10n.authRegisterSummaryAvatarPending;
    }
    return l10n.authRegisterSummaryAvatarSkipped;
  }

  Widget _summaryRow(
    BuildContext context,
    String label,
    String value, {
    int valueMaxLines = 2,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PostalTokens.inkSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: valueMaxLines,
              softWrap: true,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PostalTokens.inkNavy,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
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
      2 => (
        l10n.authRegisterWizardNameTitle,
        l10n.authRegisterWizardNameSubtitle,
      ),
      3 => (
        l10n.authRegisterWizardGenderTitle,
        l10n.authRegisterWizardGenderSubtitle,
      ),
      4 => (
        l10n.authRegisterWizardAgeTitle,
        l10n.authRegisterWizardAgeSubtitle,
      ),
      5 => (
        l10n.authRegisterStepInterestsTitle,
        l10n.authRegisterStepInterestsSubtitle,
      ),
      6 => (
        l10n.authRegisterWizardAvatarTitle,
        l10n.authRegisterWizardAvatarSubtitle,
      ),
      7 => (
        l10n.authRegisterStepReviewTitle,
        l10n.authRegisterStepReviewSubtitle,
      ),
      _ => ('', ''),
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => PostalEmptyState(
              title: l10n.authBootstrapLoadFailed,
              subtitle: bootstrapDebugErrorHint(error),
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
              final effectiveCc = _manualCountryCode ?? autoCc;
              CountryItem? countryItem;
              for (final c in bootstrap.countries) {
                if (c.code == effectiveCc) {
                  countryItem = c;
                  break;
                }
              }
              final countryLabel =
                  countryItem?.displayName(locale.languageCode) ??
                  effectiveCc ??
                  '—';
              final copy = _stepCopy(l10n);
              final canNext = switch (_step) {
                0 => !_emailChecking,
                3 => _gender == 1 || _gender == 2,
                4 => _birthYear != null && years.isNotEmpty,
                5 => _interestTagIds.length >= 3,
                6 => !_avatarUploading,
                _ => true,
              };
              final footerHint = switch (_step) {
                6 => null,
                7 => null,
                _ => l10n.authRegisterProfileHint,
              };

              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: RegisterWizardScaffold(
                  stepIndex: _step,
                  stepCount: _kRegisterSteps,
                  title: copy.$1,
                  subtitle: copy.$2,
                  footerHint: footerHint,
                  onBack: _busy ? null : _back,
                  onNext: () => _next(l10n, effectiveCc, years, bootstrap),
                  nextEnabled: canNext && !(_step == 4 && years.isEmpty),
                  nextBusy: _busy || _avatarUploading,
                  isLastStep: _step == _kRegisterSteps - 1,
                  child: _stepContent(
                    context,
                    l10n,
                    years,
                    bootstrap,
                    countryLabel,
                    effectiveCc,
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
