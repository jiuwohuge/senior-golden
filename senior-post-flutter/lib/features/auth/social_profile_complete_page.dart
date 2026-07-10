import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../core/api/api_exception.dart';
import '../../core/bootstrap/app_bootstrap.dart';
import '../../core/i18n/country_from_locale.dart';
import '../../core/oss/oss_upload_service.dart';
import '../../core/session/app_session.dart';
import '../../app/theme/postal_tokens.dart';
import '../../widgets/postal/postal.dart';
import '../onboarding/first_letter_guide_page.dart';
import '../shell/main_shell.dart'; // MainShellRoute
import 'auth_repository.dart';
import 'widgets/birth_year_picker_sheet.dart';

/// Google 等新 OAuth 用户登录后补全资料（性别、出生年、兴趣等）。
class SocialProfileCompletePage extends ConsumerStatefulWidget {
  const SocialProfileCompletePage({super.key});

  @override
  ConsumerState<SocialProfileCompletePage> createState() =>
      _SocialProfileCompletePageState();
}

class _SocialProfileCompletePageState
    extends ConsumerState<SocialProfileCompletePage> {
  static const int _kMaxRegisterAgeYears = 110;

  final _nickname = TextEditingController();
  int? _gender;
  int? _birthYear;
  final Set<int> _interestTagIds = {};
  Uint8List? _avatarPendingBytes;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final session = ref.read(appSessionProvider).user;
    if (session.nickname.isNotEmpty) {
      _nickname.text = session.nickname;
    }
    if (session.gender == 1 || session.gender == 2) {
      _gender = session.gender;
    }
    if (session.birthYear > 1900) {
      _birthYear = session.birthYear;
    }
    if (session.interestTagIds.isNotEmpty) {
      _interestTagIds.addAll(session.interestTagIds);
    }
  }

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _submit(AppBootstrapData bootstrap) async {
    final l10n = AppLocalizations.of(context)!;
    if (_gender != 1 && _gender != 2 ||
        _nickname.text.trim().isEmpty ||
        _birthYear == null) {
      PostalSnack.show(
        context,
        l10n.authFieldRequired,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    if (_interestTagIds.length < 3) {
      PostalSnack.show(
        context,
        l10n.authRegisterInterestsMin,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final locale = Localizations.localeOf(context);
      final cc = countryCodeForAppLocale(locale, bootstrap.countries);
      String? avatarKey;
      if (_avatarPendingBytes != null) {
        avatarKey = await ref
            .read(ossUploadServiceProvider)
            .uploadAvatarImage(
              bytes: _avatarPendingBytes!,
              ext: 'jpg',
              contentType: 'image/jpeg',
            );
      }
      await ref
          .read(authRepositoryProvider)
          .completeGoogleProfile(
            gender: _gender!,
            birthYear: _birthYear!,
            nickname: _nickname.text,
            countryCode: cc,
            interestTagIds: _interestTagIds.toList(),
            avatarUrl: avatarKey,
          );
      if (mounted) {
        final done =
            ref.read(appSessionProvider).user.firstLetterDone == true;
        context.go(
          done ? MainShellRoute.pathPostOffice : FirstLetterGuidePage.path,
        );
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
    final lang = Localizations.localeOf(context).languageCode;
    final bootstrapAsync = ref.watch(appBootstrapProvider(lang));

    return Scaffold(
      body: PaperTextureBackground(
        child: SafeArea(
          child: bootstrapAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (bootstrap) {
              final years = buildBirthYearChoices(
                minRegisterAge: bootstrap.minRegisterAge,
                maxRegisterAgeYears: _kMaxRegisterAgeYears,
              );
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PostalSectionTitle(
                      title: l10n.authSocialCompleteTitle,
                      subtitle: l10n.authRegisterStepProfileSubtitle,
                    ),
                    const SizedBox(height: 16),
                    PostalTextField(
                      controller: _nickname,
                      label: l10n.authNicknameLabel,
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.authGenderLabel),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: Text(l10n.authGenderMale),
                          selected: _gender == 1,
                          onSelected: _busy
                              ? null
                              : (_) => setState(() => _gender = 1),
                        ),
                        FilterChip(
                          label: Text(l10n.authGenderFemale),
                          selected: _gender == 2,
                          onSelected: _busy
                              ? null
                              : (_) => setState(() => _gender = 2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Material(
                      color: PostalTokens.paperCard.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: _busy
                            ? null
                            : () async {
                                final picked = await showBirthYearPickerSheet(
                                  context,
                                  l10n: l10n,
                                  years: years,
                                );
                                if (picked != null && mounted) {
                                  setState(() => _birthYear = picked);
                                }
                              },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: PostalTokens.perforationLine,
                            ),
                          ),
                          child: Text(
                            _birthYear == null
                                ? l10n.authBirthYearLabel
                                : l10n.authBirthYearFormat(
                                    '$_birthYear',
                                    '${DateTime.now().year - _birthYear!}',
                                  ),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: PostalTokens.inkNavy,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.authRegisterStepInterestsTitle),
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
                    const SizedBox(height: 20),
                    PostalButton(
                      label: l10n.profileSave,
                      busy: _busy,
                      onPressed: _busy ? null : () => _submit(bootstrap),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
