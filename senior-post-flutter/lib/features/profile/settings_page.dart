import 'dart:async';

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

  Future<void> _openEmailVerifySheet() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const _EmailVerifySheet(),
    );
    if (ok == true && mounted) {
      PostalSnack.show(
        context,
        l10n.settingsEmailVerifySuccess,
        tone: PostalSnackTone.success,
      );
    }
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

/// 邮箱验证：码在输入框内，发送在右侧；sheet 内 Scaffold 才能看见提示。
class _EmailVerifySheet extends ConsumerStatefulWidget {
  const _EmailVerifySheet();

  @override
  ConsumerState<_EmailVerifySheet> createState() => _EmailVerifySheetState();
}

class _EmailVerifySheetState extends ConsumerState<_EmailVerifySheet> {
  final _code = TextEditingController();
  bool _sending = false;
  bool _confirming = false;
  int _cooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldown = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_cooldown <= 1) {
        t.cancel();
        setState(() => _cooldown = 0);
        return;
      }
      setState(() => _cooldown -= 1);
    });
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _sending = true);
    try {
      await ref.read(authRepositoryProvider).sendEmailVerifyCode();
      if (!mounted) return;
      _startCooldown();
      PostalSnack.show(
        context,
        l10n.settingsEmailVerifyCodeSent,
        tone: PostalSnackTone.success,
      );
    } on ApiBusinessException catch (e) {
      debugPrint('settings email verify send failed: $e');
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } catch (e) {
      debugPrint('settings email verify send failed: $e');
      if (mounted) {
        PostalSnack.show(context, e.toString(), tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context)!;
    final code = _code.text.trim();
    if (code.isEmpty) {
      PostalSnack.show(
        context,
        l10n.settingsEmailVerifyCodeRequired,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    setState(() => _confirming = true);
    try {
      await ref.read(authRepositoryProvider).confirmEmailVerify(code: code);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiBusinessException catch (e) {
      debugPrint('settings email verify confirm failed: $e');
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } catch (e) {
      debugPrint('settings email verify confirm failed: $e');
      if (mounted) {
        PostalSnack.show(context, e.toString(), tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final email = ref.watch(appSessionProvider).user.email;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.settingsEmailVerifyTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.settingsEmailVerifyHint(email),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              PostalVerifyCodeField(
                controller: _code,
                label: l10n.settingsEmailVerifyCodeLabel,
                sendLabel: l10n.bindSendCode,
                sending: _sending,
                cooldownSeconds: _cooldown,
                enabled: !_confirming,
                onSend: _send,
              ),
              const SizedBox(height: 20),
              PostalButton(
                label: l10n.settingsEmailVerifyConfirm,
                busy: _confirming,
                onPressed: _confirming ? null : _confirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


