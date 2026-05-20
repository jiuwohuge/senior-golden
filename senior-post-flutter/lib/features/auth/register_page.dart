import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/bootstrap/app_bootstrap.dart';
import '../../core/i18n/country_from_locale.dart';
import '../../core/oss/oss_upload_service.dart';
import '../../widgets/postal/postal.dart';
import '../profile/avatar_crop_page.dart';
import '../shell/main_shell.dart';
import 'auth_repository.dart';
import 'login_routes.dart';
import 'register_wizard_scaffold.dart';

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
  Uint8List? _avatarPendingBytes;
  String? _avatarObjectKey;
  bool _avatarUploading = false;
  bool _accountRegistered = false;
  bool _agreed = false;
  bool _busy = false;
  final Set<int> _interestTagIds = {};

  @override
  void initState() {
    super.initState();
    void invalidateRegistration() {
      if (!_accountRegistered) return;
      setState(() {
        _accountRegistered = false;
        _avatarObjectKey = null;
      });
      ref.read(authRepositoryProvider).logout();
    }
    _email.addListener(invalidateRegistration);
    _password.addListener(invalidateRegistration);
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
    final y = DateTime.now().year;
    final minY = y - _kMaxRegisterAgeYears;
    final maxY = y - minRegisterAge;
    if (maxY < minY) return <int>[];
    return [for (var i = maxY; i >= minY; i--) i];
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
      if (!_validateStep(l10n, years, bootstrap)) return;
      if (_step == 6) {
        setState(() => _busy = true);
        try {
          await _ensureAccountReady(l10n, autoCc);
        } on ApiBusinessException catch (e) {
          if (mounted) {
            PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
          }
          return;
        } finally {
          if (mounted) setState(() => _busy = false);
        }
      }
      if (!mounted) return;
      setState(() => _step += 1);
      return;
    }
    await _submit(l10n, autoCc);
  }

  bool _validateStep(AppLocalizations l10n, List<int> years, AppBootstrapData bootstrap) {
    switch (_step) {
      case 0:
        return _formEmailKey.currentState?.validate() ?? false;
      case 1:
        return _formPasswordKey.currentState?.validate() ?? false;
      case 2:
        return _formNameKey.currentState?.validate() ?? false;
      case 3:
        if (_gender == 1 || _gender == 2) return true;
        PostalSnack.show(context, l10n.authGenderLabel, tone: PostalSnackTone.warning);
        return false;
      case 4:
        if (_birthYear != null && years.isNotEmpty) return true;
        PostalSnack.show(
          context,
          _birthYear == null ? l10n.authBirthYearRequired : l10n.authBirthYearRangeError,
          tone: PostalSnackTone.warning,
        );
        return false;
      case 5:
        if (_interestTagIds.length >= 3 && bootstrap.interestTagOptions.isNotEmpty) {
          return true;
        }
        if (bootstrap.interestTagOptions.isEmpty) {
          PostalSnack.show(context, l10n.authRegisterInterestsServerEmpty, tone: PostalSnackTone.warning);
        } else {
          PostalSnack.show(context, l10n.authRegisterInterestsMin, tone: PostalSnackTone.warning);
        }
        return false;
      case 6:
        if (_agreed) return true;
        PostalSnack.show(context, l10n.authAgreeRequired, tone: PostalSnackTone.warning);
        return false;
      case 7:
        return true;
      default:
        return false;
    }
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
    if (picked != null) setState(() => _birthYear = picked);
  }

  Future<void> _pickRegisterAvatar() async {
    final l10n = AppLocalizations.of(context)!;
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
    if (_agreed) {
      final locale = Localizations.localeOf(context);
      final bootstrap = await ref.read(appBootstrapProvider(locale.languageCode).future);
      final autoCc = countryCodeForAppLocale(locale, bootstrap.countries);
      await _uploadAvatarIfPossible(l10n, autoCc);
    } else {
      PostalSnack.show(
        context,
        l10n.authRegisterAvatarAgreeFirst,
        tone: PostalSnackTone.warning,
      );
    }
  }

  Future<void> _registerIfNeeded(AppLocalizations l10n, String? autoCountryCode) async {
    if (_accountRegistered) return;
    if (!_validateRegistrationFields(l10n)) {
      throw ApiBusinessException(400, l10n.authFieldRequired);
    }
    await ref.read(authRepositoryProvider).register(
          email: _email.text,
          password: _password.text,
          nickname: _nickname.text,
          gender: _gender!,
          birthYear: _birthYear!,
          countryCode: autoCountryCode,
          agreedTerms: true,
          interestTagIds: _interestTagIds.toList(),
          avatarUrl: _avatarObjectKey,
        );
    _accountRegistered = true;
  }

  Future<void> _uploadAvatarIfPossible(AppLocalizations l10n, String? autoCountryCode) async {
    final bytes = _avatarPendingBytes;
    if (bytes == null || _avatarObjectKey != null) return;
    if (!_agreed || !_validateRegistrationFields(l10n)) return;

    setState(() => _avatarUploading = true);
    try {
      await _registerIfNeeded(l10n, autoCountryCode);
      final key = await ref.read(ossUploadServiceProvider).uploadAvatarImage(
            bytes: bytes,
            ext: 'jpg',
            contentType: 'image/jpeg',
          );
      await ref.read(authRepositoryProvider).updateProfileOnServer(avatarUrl: key);
      if (mounted) setState(() => _avatarObjectKey = key);
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
      rethrow;
    } finally {
      if (mounted) setState(() => _avatarUploading = false);
    }
  }

  Future<void> _ensureAccountReady(AppLocalizations l10n, String? autoCountryCode) async {
    if (!_agreed) {
      PostalSnack.show(context, l10n.authAgreeRequired, tone: PostalSnackTone.warning);
      throw ApiBusinessException(400, l10n.authAgreeRequired);
    }
    if (!_validateRegistrationFields(l10n)) {
      throw ApiBusinessException(400, l10n.authFieldRequired);
    }
    await _registerIfNeeded(l10n, autoCountryCode);
    if (_avatarPendingBytes != null && _avatarObjectKey == null) {
      await _uploadAvatarIfPossible(l10n, autoCountryCode);
    }
  }

  Future<void> _submit(AppLocalizations l10n, String? autoCountryCode) async {
    if (!_validateAllForSubmit(l10n)) return;
    setState(() => _busy = true);
    try {
      if (!_accountRegistered) {
        await _registerIfNeeded(l10n, autoCountryCode);
        if (_avatarPendingBytes != null && _avatarObjectKey == null) {
          await _uploadAvatarIfPossible(l10n, autoCountryCode);
        }
      }
      if (mounted) context.go(MainShellRoute.pathPostWall);
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
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) return false;
    final pwd = _password.text;
    if (pwd.isEmpty || pwd.length < 8 || _confirmPassword.text != pwd) return false;
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
      PostalSnack.show(context, l10n.authPasswordNotMatch, tone: PostalSnackTone.warning);
      return false;
    }
    if (_nickname.text.trim().isEmpty) {
      setState(() => _step = 2);
      PostalSnack.show(context, l10n.authFieldRequired, tone: PostalSnackTone.warning);
      return false;
    }
    if (_gender != 1 && _gender != 2) {
      setState(() => _step = 3);
      PostalSnack.show(context, l10n.authGenderLabel, tone: PostalSnackTone.warning);
      return false;
    }
    if (_birthYear == null) {
      setState(() => _step = 4);
      PostalSnack.show(context, l10n.authBirthYearRequired, tone: PostalSnackTone.warning);
      return false;
    }
    if (_interestTagIds.length < 3) {
      setState(() => _step = 5);
      PostalSnack.show(context, l10n.authRegisterInterestsMin, tone: PostalSnackTone.warning);
      return false;
    }
    if (!_agreed) {
      setState(() => _step = 7);
      PostalSnack.show(context, l10n.authAgreeRequired, tone: PostalSnackTone.warning);
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
                if (v == null || v.trim().isEmpty) return l10n.authFieldRequired;
                return null;
              },
            ),
          ),
        );
      case 3:
        return Column(
          children: [
            RegisterWizardChoiceTile(
              label: l10n.authGenderMale,
              selected: _gender == 1,
              enabled: !_busy,
              onTap: () => setState(() => _gender = 1),
            ),
            const SizedBox(height: 12),
            RegisterWizardChoiceTile(
              label: l10n.authGenderFemale,
              selected: _gender == 2,
              enabled: !_busy,
              onTap: () => setState(() => _gender = 2),
            ),
          ],
        );
      case 4:
        if (years.isEmpty) {
          return Text(
            l10n.authBirthYearRangeError,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PostalTokens.error),
          );
        }
        final age = _birthYear == null ? null : DateTime.now().year - _birthYear!;
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
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
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
        return _stepAvatar(context, l10n, autoCountryCode: autoCountryCode);
      case 7:
        return SingleChildScrollView(
          child: _reviewCard(context, l10n, countryLabel),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _reviewCard(BuildContext context, AppLocalizations l10n, String countryLabel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: PostalTokens.paperEnvelope.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PostalTokens.kraftBrownMuted.withValues(alpha: 0.65)),
      ),
      child: Column(
        children: [
          _summaryRow(
            context,
            l10n.authRegisterSummaryEmail,
            _email.text.trim().isEmpty ? '—' : _email.text.trim(),
            valueMaxLines: 3,
          ),
          _summaryRow(context, l10n.authRegisterSummaryNickname, _nickname.text.trim()),
          _summaryRow(context, l10n.authRegisterSummaryGender, _genderLabel(l10n)),
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
          _summaryRow(context, l10n.authRegisterSummaryInterests, '${_interestTagIds.length}'),
          _summaryRow(context, l10n.authRegisterSummaryAvatar, _avatarSummaryLabel(l10n)),
        ],
      ),
    );
  }

  Widget _stepAvatar(
    BuildContext context,
    AppLocalizations l10n, {
    required String? autoCountryCode,
  }) {
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
                  onTap: (_busy || _avatarUploading) ? null : _pickRegisterAvatar,
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
                              color: PostalTokens.inkTertiary.withValues(alpha: 0.85),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.authRegisterAvatarTapToAdd,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: PostalTokens.inkTertiary,
                                  ),
                            ),
                          ],
                        ),
                      if (pending != null && !_avatarUploading)
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: PostalTokens.inkNavy.withValues(alpha: 0.72),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.edit_outlined, color: Colors.white, size: 22),
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
                                const CircularProgressIndicator(color: Colors.white),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.authRegisterAvatarUploading,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                      ),
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
                              color: PostalTokens.postboxGreen.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(
                                l10n.authRegisterAvatarUploaded,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
        PostalCheckboxField(
          value: _agreed,
          onChanged: (_busy || _avatarUploading)
              ? null
              : (v) async {
                  setState(() => _agreed = v);
                  if (v && _avatarPendingBytes != null) {
                    await _uploadAvatarIfPossible(l10n, autoCountryCode);
                  }
                },
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

  String _avatarSummaryLabel(AppLocalizations l10n) {
    if (_avatarUploading) return l10n.authRegisterAvatarUploading;
    if (_avatarObjectKey != null) return l10n.authRegisterSummaryAvatarSet;
    if (_avatarPendingBytes != null) return l10n.authRegisterSummaryAvatarPending;
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
      0 => (l10n.authRegisterWizardEmailTitle, l10n.authRegisterWizardEmailSubtitle),
      1 => (l10n.authRegisterWizardPasswordTitle, l10n.authRegisterWizardPasswordSubtitle),
      2 => (l10n.authRegisterWizardNameTitle, l10n.authRegisterWizardNameSubtitle),
      3 => (l10n.authRegisterWizardGenderTitle, l10n.authRegisterWizardGenderSubtitle),
      4 => (l10n.authRegisterWizardAgeTitle, l10n.authRegisterWizardAgeSubtitle),
      5 => (l10n.authRegisterStepInterestsTitle, l10n.authRegisterStepInterestsSubtitle),
      6 => (l10n.authRegisterWizardAvatarTitle, l10n.authRegisterWizardAvatarSubtitle),
      7 => (l10n.authRegisterStepReviewTitle, l10n.authRegisterStepReviewSubtitle),
      _ => ('', ''),
    };
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
              final copy = _stepCopy(l10n);
              final canNext = switch (_step) {
                3 => _gender == 1 || _gender == 2,
                4 => _birthYear != null && years.isNotEmpty,
                5 => _interestTagIds.length >= 3,
                6 => _agreed && !_avatarUploading,
                _ => true,
              };
              final footerHint = switch (_step) {
                6 => l10n.authRegisterAvatarSkipHint,
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
                  onNext: () => _next(l10n, autoCc, years, bootstrap),
                  nextEnabled: canNext && !(_step == 4 && years.isEmpty),
                  nextBusy: _busy || _avatarUploading,
                  isLastStep: _step == _kRegisterSteps - 1,
                  child: _stepContent(context, l10n, years, bootstrap, countryLabel, autoCc),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
