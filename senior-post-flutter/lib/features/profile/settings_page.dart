import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../core/i18n/app_locale_provider.dart';
import '../../widgets/postal/postal.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notify = true;
  bool _mailBadge = true;

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            PostalCardEnvelope(
              child: Column(
                children: [
                  SwitchListTile(
                    value: _notify,
                    onChanged: (v) => setState(() => _notify = v),
                    title: Text(l10n.settingsPushNotifications),
                  ),
                  SwitchListTile(
                    value: _mailBadge,
                    onChanged: (v) => setState(() => _mailBadge = v),
                    title: Text(l10n.settingsUnreadBadges),
                  ),
                  ListTile(
                    title: Text(l10n.settingsLanguage),
                    subtitle: Text(l10n.settingsLanguageSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _pickLanguage,
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
