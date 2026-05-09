import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../core/auth/auth_token.dart';
import '../../core/session/app_session.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(authRepositoryProvider).refreshSessionFromServer();
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(appSessionProvider);
    final user = session.user;
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          if (user.deletionRequestedAt != null) ...[
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Account deletion requested. Log in again within 7 days to cancel. '
                  'Effective: ${user.deletionEffectiveAt ?? user.deletionRequestedAt!}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          PostalCardEnvelope(
            child: Column(
              children: [
                PostalAvatar(name: user.nickname, size: 80, imageUrl: user.avatarUrl),
                const SizedBox(height: 10),
                Text(
                  user.nickname.isEmpty ? '?' : user.nickname,
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
                  title: l10n.profileEditProfile,
                  onTap: () => context.push('/profile/edit'),
                ),
                _ProfileItem(
                  icon: Icons.interests_outlined,
                  title: l10n.profileInterestTags,
                  onTap: () => context.push('/profile/interests'),
                ),
                _ProfileItem(
                  icon: Icons.receipt_long_outlined,
                  title: l10n.profileStampsLedger,
                  onTap: () => context.push('/profile/stamps'),
                ),
                _ProfileItem(
                  icon: Icons.workspace_premium_outlined,
                  title: l10n.profileVipCenter,
                  onTap: () => context.push('/profile/vip'),
                ),
                _ProfileItem(
                  icon: Icons.settings_outlined,
                  title: l10n.profileSettings,
                  onTap: () => context.push('/settings'),
                ),
                _ProfileItem(
                  icon: Icons.info_outline,
                  title: l10n.profileAbout,
                  onTap: () => context.push('/about'),
                ),
                _ProfileItem(
                  icon: Icons.policy_outlined,
                  title: l10n.profileUserAgreement,
                  onTap: () => context.push(LoginRoutes.legalTerms),
                ),
                _ProfileItem(
                  icon: Icons.privacy_tip_outlined,
                  title: l10n.profilePrivacyPolicy,
                  onTap: () => context.push(LoginRoutes.legalPrivacy),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PostalButton(
            label: l10n.profileLogout,
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
