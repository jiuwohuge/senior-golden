import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_token.dart';
import '../../core/network/router_refresh.dart';
import '../../core/session/app_session.dart';
import '../../features/commerce/my_entitlements_page.dart';
import '../../features/commerce/shop_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/login_routes.dart';
import '../../features/auth/auth_welcome_page.dart';
import '../../features/auth/onboarding_page.dart';
import '../../features/auth/social_profile_complete_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/auth/forgot_password_page.dart';
import '../../features/auth/legal_page.dart';
import '../../features/directory/user_card_page.dart';
import '../../features/mailbox/chat_page.dart';
import '../../features/mailbox/im_user_id.dart';
import '../../features/mailbox/letter_detail_page.dart';
import '../../features/mailbox/mailbox_archive_page.dart';
import '../../features/compose/compose_flow_page.dart';
import '../../features/compose/compose_intent.dart';
import '../../features/time_letter/time_letter_open_page.dart';
import '../../features/letter_drafts/letter_drafts_page.dart';
import '../../features/letter_export/letter_export_page.dart';
import '../../features/letter_favorites/letter_favorites_page.dart';
import '../../features/onboarding/first_letter_guide_page.dart';
import '../../features/post_office/in_transit_page.dart';
import '../../features/post_office/post_office_relation_messages_page.dart';
import '../../features/profile/account_delete_page.dart';
import '../../features/profile/blacklist_page.dart';
import '../../features/profile/feedback_page.dart';
import '../../features/profile/interests_picker_page.dart';
import '../../features/profile/profile_edit_page.dart';
import '../../features/profile/settings_page.dart';
import '../../features/shell/main_shell.dart';
import 'app_navigator_key.dart';
import 'shop_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.read(routerRefreshProvider);

  return GoRouter(
    navigatorKey: appRootNavigatorKey,
    initialLocation: LoginRoutes.welcome,
    refreshListenable: refresh,
    redirect: (context, state) {
      final token = ref.read(authTokenProvider);
      final loc = state.matchedLocation;
      final authPaths = {
        LoginRoutes.welcome,
        LoginRoutes.onboarding,
        LoginRoutes.login,
        LoginRoutes.register,
        LoginRoutes.forgotPassword,
        LoginRoutes.socialComplete,
        LoginRoutes.legalTerms,
        LoginRoutes.legalPrivacy,
      };
      final loggedIn = token != null && token.isNotEmpty;
      if (!loggedIn && !authPaths.contains(loc)) {
        return LoginRoutes.welcome;
      }
      // WHY: 移动端常见体验是“冷启动自动回到首页”，
      // 仅保留资料补全页作为登录后仍可停留的例外路径。
      if (loggedIn &&
          authPaths.contains(loc) &&
          loc != LoginRoutes.socialComplete) {
        final user = ref.read(appSessionProvider).user;
        // 首封信未完成时先进引导，而不是直接进邮局。
        if (user.id.isNotEmpty && user.firstLetterDone != true) {
          return FirstLetterGuidePage.path;
        }
        return MainShellRoute.pathPostOffice;
      }
      // 已登录且未完成首封信：主壳路径强制进引导（compose / 引导页本身放行）。
      if (loggedIn) {
        final user = ref.read(appSessionProvider).user;
        final needsFirst = user.id.isNotEmpty && user.firstLetterDone != true;
        final onMainShell =
            loc == MainShellRoute.pathPostOffice ||
            loc == MainShellRoute.pathPenPals ||
            loc == MainShellRoute.pathMailbox ||
            loc == MainShellRoute.pathProfile;
        if (needsFirst && onMainShell) {
          return FirstLetterGuidePage.path;
        }
        if (!needsFirst && loc == FirstLetterGuidePage.path) {
          return MainShellRoute.pathPostOffice;
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: LoginRoutes.welcome,
        builder: (context, state) => const AuthWelcomePage(),
      ),
      GoRoute(
        path: LoginRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: LoginRoutes.socialComplete,
        builder: (context, state) => const SocialProfileCompletePage(),
      ),
      GoRoute(
        path: LoginRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: LoginRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: LoginRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: LoginRoutes.legalTerms,
        builder: (context, state) => const LegalPage(type: LegalPageType.terms),
      ),
      GoRoute(
        path: LoginRoutes.legalPrivacy,
        builder: (context, state) =>
            const LegalPage(type: LegalPageType.privacy),
      ),
      GoRoute(
        path: FirstLetterGuidePage.path,
        builder: (context, state) => const FirstLetterGuidePage(),
      ),
      GoRoute(
        path: MainShellRoute.pathPostOffice,
        builder: (context, state) => const MainShell(initialIndex: 0),
      ),
      GoRoute(
        path: MainShellRoute.pathPenPals,
        builder: (context, state) => const MainShell(initialIndex: 1),
      ),
      GoRoute(
        path: MainShellRoute.pathMailbox,
        builder: (context, state) => const MainShell(initialIndex: 2),
      ),
      GoRoute(
        path: MainShellRoute.pathProfile,
        builder: (context, state) => const MainShell(initialIndex: 3),
      ),
      GoRoute(
        path: '/user/:id',
        builder: (context, state) =>
            UserCardPage(userId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/letter/:id',
        builder: (context, state) {
          final extra = state.extra;
          var firstOpen = false;
          if (extra is Map) {
            firstOpen = extra['firstOpen'] == true;
          }
          return LetterDetailPage(
            letterId: state.pathParameters['id']!,
            firstOpen: firstOpen,
          );
        },
      ),
      GoRoute(
        path: '/post-office/messages',
        builder: (context, state) => const PostOfficeRelationMessagesPage(),
      ),
      GoRoute(
        path: InTransitPage.path,
        builder: (context, state) => const InTransitPage(),
      ),
      GoRoute(
        path: '/mailbox/archive',
        builder: (context, state) => const MailboxArchivePage(),
      ),
      GoRoute(
        path: '/compose',
        builder: (context, state) {
          final extra = state.extra;
          final intent = extra is ComposeIntent ? extra : const ComposeIntent();
          return ComposeFlowPage(initialIntent: intent);
        },
      ),
      GoRoute(
        path: '/time-letter/compose',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is ComposeIntent) {
            return ComposeFlowPage(initialIntent: extra);
          }
          if (extra is Map) {
            return ComposeFlowPage(
              initialIntent: ComposeIntent.fromLegacyTimeLetterExtra(extra),
            );
          }
          return const ComposeFlowPage();
        },
      ),
      GoRoute(
        path: '/time-letter/:id/open',
        builder: (context, state) =>
            TimeLetterOpenPage(letterId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/chat/:userId',
        builder: (context, state) {
          final extra = state.extra;
          String? displayName;
          String? peerAvatarUrl;
          var trustedFriendship = false;
          if (extra is Map) {
            displayName =
                extra['name'] as String? ?? extra['displayName'] as String?;
            peerAvatarUrl = extra['avatarUrl'] as String?;
            trustedFriendship = extra['trustedFriendship'] == true;
          } else if (extra is String) {
            displayName = extra;
          }
          final rawPeerId = state.pathParameters['userId'] ?? '';
          return ChatPage(
            peerUserId: normalizeImUserId(rawPeerId) ?? rawPeerId,
            displayName: displayName,
            peerAvatarUrl: peerAvatarUrl,
            trustedFriendship: trustedFriendship,
          );
        },
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const ProfileEditPage(),
      ),
      GoRoute(
        path: '/profile/interests',
        builder: (context, state) => const InterestsPickerPage(),
      ),
      GoRoute(
        path: ShopRoutes.path,
        builder: (context, state) {
          final q = state.uri.queryParameters;
          return ShopPage(
            triggerBizCode: int.tryParse(q['bizCode'] ?? ''),
            hint: q['hint'],
          );
        },
      ),
      GoRoute(
        path: '/shop/entitlements',
        builder: (context, state) => const MyEntitlementsPage(),
      ),
      GoRoute(
        path: '/profile/letter-drafts',
        builder: (context, state) => const LetterDraftsPage(),
      ),
      GoRoute(
        path: '/profile/letter-favorites',
        builder: (context, state) => const LetterFavoritesPage(),
      ),
      GoRoute(
        path: '/profile/letter-export',
        builder: (context, state) => const LetterExportPage(),
      ),
      GoRoute(
        path: '/profile/blocks',
        builder: (context, state) => const BlacklistPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/settings/feedback',
        builder: (context, state) => const FeedbackPage(),
      ),
      GoRoute(
        path: '/account/delete',
        builder: (context, state) => const AccountDeletePage(),
      ),
    ],
  );
});
