import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../core/api/api_exception.dart';
import '../../core/i18n/app_locale_provider.dart';
import '../../core/session/app_session.dart';
import '../../widgets/postal/postal.dart';
import '../auth/auth_repository.dart';
import '../push/push_service.dart';
import 'preferences_remote.dart';

/// 设置页：通知开关、语言覆盖、邮箱验证绑定、注销入口。
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _prefsLoaded = false;
  bool _notify = true;
  bool _mailBadge = true;
  bool _prefsBusy = false;
  bool _verifyBusy = false;
  final _verifyCode = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPreferences());
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await ref.read(preferencesRemoteProvider).fetch();
      if (!mounted) return;
      setState(() {
        _notify = prefs.pushEnabled;
        _mailBadge = prefs.unreadBadges;
        _prefsLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _prefsLoaded = true);
    }
  }

  Future<void> _saveNotificationPrefs() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _prefsBusy = true);
    try {
      final current = await ref.read(preferencesRemoteProvider).fetch();
      final next = current.copyWith(
        pushEnabled: _notify,
        unreadBadges: _mailBadge,
      );
      await ref.read(preferencesRemoteProvider).patch(next);
      ref.invalidate(userPreferencesProvider);
      await ensurePushTokenRegistered(ref, enabled: _notify);
      if (!mounted) return;
      PostalSnack.show(
        context,
        l10n.settingsPreferencesSaved,
        tone: PostalSnackTone.success,
      );
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _prefsBusy = false);
    }
  }

  @override
  void dispose() {
    _verifyCode.dispose();
    super.dispose();
  }

  Future<void> _pickLanguage() async {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.read(appLocaleProvider);
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.settingsLanguageSystem),
                trailing: current == null ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(ctx, 'system'),
              ),
              ListTile(
                title: Text(l10n.settingsLanguageEnglish),
                trailing: current?.languageCode == 'en'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(ctx, 'en'),
              ),
              ListTile(
                title: Text(l10n.settingsLanguageChinese),
                trailing: current?.languageCode == 'zh'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(ctx, 'zh'),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || choice == null) return;
    final notifier = ref.read(appLocaleProvider.notifier);
    if (choice == 'system') {
      await notifier.setLocale(null);
    } else if (choice == 'en') {
      await notifier.setLocale(const Locale('en'));
    } else if (choice == 'zh') {
      await notifier.setLocale(const Locale('zh'));
    }
  }

  Future<void> _sendVerifyCode() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _verifyBusy = true);
    try {
      await ref.read(authRepositoryProvider).sendEmailVerifyCode();
      if (!mounted) return;
      PostalSnack.show(
        context,
        l10n.settingsEmailVerifyCodeSent,
        tone: PostalSnackTone.success,
      );
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _verifyBusy = false);
    }
  }

  Future<void> _confirmVerify() async {
    final l10n = AppLocalizations.of(context)!;
    final code = _verifyCode.text.trim();
    if (code.isEmpty) {
      PostalSnack.show(
        context,
        l10n.settingsEmailVerifyCodeRequired,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    setState(() => _verifyBusy = true);
    try {
      await ref.read(authRepositoryProvider).confirmEmailVerify(code: code);
      if (!mounted) return;
      _verifyCode.clear();
      PostalSnack.show(
        context,
        l10n.settingsEmailVerifySuccess,
        tone: PostalSnackTone.success,
      );
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _verifyBusy = false);
    }
  }

  Future<void> _openEmailVerifySheet() async {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.read(appSessionProvider).user;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.settingsEmailVerifyTitle,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.settingsEmailVerifyHint(user.email),
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _verifyCode,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.settingsEmailVerifyCodeLabel,
                ),
              ),
              const SizedBox(height: 16),
              PostalButton(
                label: l10n.settingsEmailVerifySendCode,
                variant: PostalButtonVariant.secondary,
                onPressed: _verifyBusy ? null : _sendVerifyCode,
              ),
              const SizedBox(height: 10),
              PostalButton(
                label: l10n.settingsEmailVerifyConfirm,
                onPressed: _verifyBusy ? null : _confirmVerify,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(appSessionProvider).user;
    final emailVerified = user.emailVerified;
    final hasEmail = user.email.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            PostalCardEnvelope(
              child: Column(
                children: [
                  if (!_prefsLoaded)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: LinearProgressIndicator(),
                    )
                  else ...[
                    SwitchListTile(
                      value: _notify,
                      onChanged: _prefsBusy
                          ? null
                          : (v) async {
                              setState(() => _notify = v);
                              await _saveNotificationPrefs();
                            },
                      title: Text(l10n.settingsPushNotifications),
                    ),
                    SwitchListTile(
                      value: _mailBadge,
                      onChanged: _prefsBusy
                          ? null
                          : (v) async {
                              setState(() => _mailBadge = v);
                              await _saveNotificationPrefs();
                            },
                      title: Text(l10n.settingsUnreadBadges),
                    ),
                  ],
                  ListTile(
                    title: Text(l10n.settingsLanguage),
                    subtitle: Text(l10n.settingsLanguageSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _pickLanguage,
                  ),
                  if (hasEmail)
                    ListTile(
                      title: Text(l10n.settingsEmailVerify),
                      subtitle: Text(
                        emailVerified
                            ? l10n.settingsEmailVerifyDone
                            : l10n.settingsEmailVerifyPending,
                      ),
                      trailing: emailVerified
                          ? const Icon(Icons.verified_outlined)
                          : const Icon(Icons.chevron_right),
                      onTap: emailVerified ? null : _openEmailVerifySheet,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PostalButton(
              label: l10n.settingsDeleteAccount,
              variant: PostalButtonVariant.danger,
              onPressed: () => context.push('/account/delete'),
            ),
          ],
        ),
      ),
    );
  }
}
