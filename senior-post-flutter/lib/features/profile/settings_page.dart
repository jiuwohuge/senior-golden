import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/postal/postal.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notify = true;
  bool _mailBadge = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
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
                    title: const Text('Push notifications'),
                  ),
                  SwitchListTile(
                    value: _mailBadge,
                    onChanged: (v) => setState(() => _mailBadge = v),
                    title: const Text('Show unread badges'),
                  ),
                  ListTile(
                    title: const Text('Language'),
                    subtitle: const Text('English / 中文'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      PostalSnack.show(
                        context,
                        'Language switch placeholder (will bind locale provider)',
                        tone: PostalSnackTone.info,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PostalButton(
              label: 'About',
              variant: PostalButtonVariant.secondary,
              onPressed: () => context.push('/about'),
            ),
            const SizedBox(height: 8),
            PostalButton(
              label: 'Delete account',
              variant: PostalButtonVariant.danger,
              onPressed: () => context.push('/account/delete'),
            ),
          ],
        ),
      ),
    );
  }
}
