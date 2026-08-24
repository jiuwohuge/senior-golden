import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/device/location_access.dart';
import '../../core/i18n/postal_format.dart';
import '../../core/models/domain_models.dart';
import '../../core/session/app_session.dart';
import '../../widgets/postal/postal.dart';
import '../auth/auth_repository.dart';
import '../auth/login_routes.dart';
import '../relation/relation_remote.dart';
import 'preferences_remote.dart';

/// 我的：资料与设置。商店/VIP、信件导出入口暂时隐藏，路由仍保留。
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
    final overviewAsync = ref.watch(profileOverviewProvider);
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
                  l10n.profileAccountDeletionBanner(
                    PostalFormat.dateTime(
                      context,
                      user.deletionEffectiveAt ?? user.deletionRequestedAt!,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          PostalCardEnvelope(
            child: Column(
              children: [
                _ProfileAvatarWithAudit(user: user, l10n: l10n),
                if (user.isAvatarAuditRejected) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.profileAvatarRejectedHint,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PostalTokens.blockedRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  user.nickname.isEmpty ? l10n.appTitle : user.nickname,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                PostalCountrySeal(
                  countryCode: user.countryCode,
                  countryName: user.countryName,
                ),
                const SizedBox(height: 10),
                Text(user.bio, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                overviewAsync.when(
                  loading: () => const PostalSkeletonList(
                    itemCount: 1,
                    itemHeight: 56,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                  ),
                  error: (_, _) => _ProfileOverviewRow(
                    overview: const ProfileOverview(),
                    l10n: l10n,
                  ),
                  data: (overview) =>
                      _ProfileOverviewRow(overview: overview, l10n: l10n),
                ),
              ],
            ),
          ),
          if (user.latitude == null || user.longitude == null) ...[
            const SizedBox(height: 12),
            PostalCardEnvelope(
              onTap: () => ref
                  .read(locationAccessProvider)
                  .ensureAsked(
                    context: context,
                    reason: LocationPromptReason.settings,
                  ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 28,
                    color: PostalTokens.postboxGreen,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.locationProfileBannerTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.locationProfileBannerBody,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: PostalTokens.inkSecondary,
                                height: 1.4,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          _ReturnAddressMenu(
            user: user,
            l10n: l10n,
            onTap: user.canBind
                ? () => context.push(LoginRoutes.bindEmail)
                : null,
          ),
          const SizedBox(height: 12),
          _ProfileSectionTitle(title: l10n.profileSectionMyContent),
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
                const Divider(height: 1),
                _ProfileItem(
                  icon: Icons.drafts_outlined,
                  title: l10n.profileLetterDrafts,
                  onTap: () => context.push('/profile/letter-drafts'),
                ),
                _ProfileItem(
                  icon: Icons.inventory_2_outlined,
                  title: l10n.mailboxArchiveTitle,
                  onTap: () => context.push('/mailbox/archive'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ProfileSectionTitle(title: l10n.profileSectionPrivacy),
          PostalCardEnvelope(
            child: Column(
              children: [
                _ProfileItem(
                  icon: Icons.block_outlined,
                  title: l10n.profileBlacklist,
                  onTap: () => context.push('/profile/blocks'),
                ),
                const Divider(height: 1),
                const _PrivacyPreferencesSection(),
                const Divider(height: 1),
                _ProfileItem(
                  icon: Icons.feedback_outlined,
                  title: l10n.settingsFeedback,
                  onTap: () => context.push('/settings/feedback'),
                ),
                _ProfileItem(
                  icon: Icons.settings_outlined,
                  title: l10n.profileSettings,
                  onTap: () => context.push('/settings'),
                ),
                const Divider(height: 1),
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
              await ref
                  .read(authRepositoryProvider)
                  .logout(reenterAsGuest: false);
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

/// 「我的」回邮地址：信封左上角写法。仅 guest 开户显示去绑定 / 更换。
class _ReturnAddressMenu extends StatelessWidget {
  const _ReturnAddressMenu({
    required this.user,
    required this.l10n,
    required this.onTap,
  });

  final AppUser user;
  final AppLocalizations l10n;
  final VoidCallback? onTap;

  String get _identity {
    if (!user.bound) {
      return l10n.profileReturnAddressEmpty;
    }
    final email = user.email.trim();
    if (user.bindProvider == 'google') {
      if (email.isEmpty) {
        return l10n.bindMethodGoogle;
      }
      return '${l10n.bindMethodGoogle} · $email';
    }
    if (email.isNotEmpty) {
      return email;
    }
    return l10n.profileBindAccount;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bound = user.bound;
    final canAct = user.canBind;
    final action = bound
        ? l10n.profileReturnAddressChange
        : l10n.profileReturnAddressBind;
    return Material(
      color: PostalTokens.paperEnvelope,
      borderRadius: PostalTokens.shapeMd,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: PostalTokens.shapeMd,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: PostalTokens.shapeMd,
            border: Border.all(color: PostalTokens.kraftBrown, width: 1.2),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 40,
                    decoration: BoxDecoration(
                      color: PostalTokens.kraftBrown,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.profileReturnAddressLabel,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: PostalTokens.kraftBrown,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _identity,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: bound
                                ? PostalTokens.inkNavy
                                : PostalTokens.inkSecondary,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (canAct) ...[
                    const SizedBox(width: 8),
                    Text(
                      action,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: PostalTokens.postboxGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: PostalTokens.postboxGreen,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileSectionTitle extends StatelessWidget {
  const _ProfileSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: PostalTokens.inkSecondary,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ProfileOverviewRow extends StatelessWidget {
  const _ProfileOverviewRow({required this.overview, required this.l10n});

  final ProfileOverview overview;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget cell(String label, int value) {
      return Expanded(
        child: Column(
          children: [
            Text(
              '$value',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: PostalTokens.postboxGreen,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: PostalTokens.inkSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: PostalTokens.paperCard.withValues(alpha: 0.72),
        borderRadius: PostalTokens.shapeMd,
        border: Border.all(color: PostalTokens.perforationLine),
      ),
      child: Row(
        children: [
          cell(l10n.profileOverviewPenpals, overview.penpalCount),
          cell(l10n.profileOverviewLetters, overview.letterCount),
          cell(l10n.profileOverviewTimeLetters, overview.timeLetterCount),
        ],
      ),
    );
  }
}

/// 个人中心头像：待审角标、驳回遮罩与占位。
class _ProfileAvatarWithAudit extends StatelessWidget {
  const _ProfileAvatarWithAudit({required this.user, required this.l10n});

  final AppUser user;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final rejected = user.isAvatarAuditRejected;
    final pending = user.isAvatarAuditPending;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        PostalAvatar(
          name: user.nickname,
          size: 80,
          imageUrl: rejected ? null : user.avatarUrl,
        ),
        if (rejected)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.42),
              border: Border.all(color: PostalTokens.blockedRed, width: 2),
            ),
            child: const Icon(Icons.block, color: Colors.white, size: 34),
          ),
        if (pending)
          Positioned(
            bottom: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: PostalTokens.badgeGold,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                l10n.profileAvatarAuditPending,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        if (rejected)
          Positioned(
            bottom: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: PostalTokens.blockedRed,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                l10n.profileAvatarAuditRejected,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PrivacyPreferencesSection extends ConsumerStatefulWidget {
  const _PrivacyPreferencesSection();

  @override
  ConsumerState<_PrivacyPreferencesSection> createState() =>
      _PrivacyPreferencesSectionState();
}

class _PrivacyPreferencesSectionState
    extends ConsumerState<_PrivacyPreferencesSection> {
  bool _busy = false;

  Future<void> _patch(UserPreferences next) async {
    setState(() => _busy = true);
    try {
      await ref.read(preferencesRemoteProvider).patch(next);
      ref.invalidate(userPreferencesProvider);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(userPreferencesProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(12),
        child: LinearProgressIndicator(),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (prefs) {
        return Column(
          children: [
            SwitchListTile(
              value: prefs.hideRecommendations,
              onChanged: _busy
                  ? null
                  : (v) => _patch(prefs.copyWith(hideRecommendations: v)),
              title: Text(l10n.profilePrivacyHideRecommend),
            ),
            SwitchListTile(
              value: prefs.rejectStrangerMail,
              onChanged: _busy
                  ? null
                  : (v) => _patch(prefs.copyWith(rejectStrangerMail: v)),
              title: Text(l10n.profilePrivacyRejectStranger),
            ),
          ],
        );
      },
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
