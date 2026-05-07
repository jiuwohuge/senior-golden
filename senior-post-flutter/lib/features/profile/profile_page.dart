import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_token.dart';
import '../../core/env/app_env.dart';
import '../../core/mock/mock_repository.dart';
import '../../widgets/postal/postal.dart';
import '../auth/auth_repository.dart';
import '../auth/login_routes.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    if (!AppEnv.useMock) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await ref.read(authRepositoryProvider).refreshSessionFromServer();
        } catch (_) {
          // 静默：无网或 token 失效时仍展示上次缓存的 mockSession
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(mockSessionProvider);
    final user = session.user;
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          PostalCardEnvelope(
            child: Column(
              children: [
                PostalAvatar(name: user.nickname, size: 80),
                const SizedBox(height: 10),
                Text(
                  user.nickname,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                PostalCountrySeal(
                  countryCode: user.countryCode,
                  countryName: user.countryName,
                ),
                const SizedBox(height: 10),
                Text(user.bio, textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PostalStampBadge(
                  balance: session.stampBalance,
                  cap: session.dailyStampCap,
                  isVip: session.isVip,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PostalCardEnvelope(
            child: Column(
              children: [
                _ProfileItem(
                  icon: Icons.edit_note,
                  title: 'Edit Profile',
                  onTap: () => context.push('/profile/edit'),
                ),
                _ProfileItem(
                  icon: Icons.interests_outlined,
                  title: 'Interest tags',
                  onTap: () => context.push('/profile/interests'),
                ),
                _ProfileItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Stamps ledger',
                  onTap: () => context.push('/profile/stamps'),
                ),
                _ProfileItem(
                  icon: Icons.workspace_premium_outlined,
                  title: 'VIP center',
                  onTap: () => context.push('/profile/vip'),
                ),
                _ProfileItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () => context.push('/settings'),
                ),
                _ProfileItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () => context.push('/about'),
                ),
                _ProfileItem(
                  icon: Icons.policy_outlined,
                  title: 'User Agreement',
                  onTap: () => context.push(LoginRoutes.legalTerms),
                ),
                _ProfileItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => context.push(LoginRoutes.legalPrivacy),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PostalButton(
            label: 'Logout',
            variant: PostalButtonVariant.secondary,
            onPressed: () async {
              await ref.read(authRepositoryProvider).logout();
              ref.read(authTokenProvider.notifier).state = null;
              if (context.mounted) {
                context.go(LoginRoutes.login);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
