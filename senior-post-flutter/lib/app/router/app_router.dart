import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_token.dart';
import '../../core/network/router_refresh.dart';
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
import '../../features/post_wall/post_compose_page.dart';
import '../../features/post_wall/post_detail_page.dart';
import '../../features/profile/account_delete_page.dart';
import '../../features/profile/blacklist_page.dart';
import '../../features/profile/feedback_page.dart';
import '../../features/profile/interests_picker_page.dart';
import '../../features/profile/my_postcards_page.dart';
import '../../features/profile/profile_edit_page.dart';
import '../../features/profile/settings_page.dart';
import '../../features/profile/stamps_ledger_page.dart';
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
        return MainShellRoute.pathPostWall;
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
        path: MainShellRoute.pathPostWall,
        builder: (context, state) => const MainShell(initialIndex: 0),
      ),
      GoRoute(
        path: MainShellRoute.pathDirectory,
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
        path: '/post/new',
        builder: (context, state) => const PostComposePage(),
      ),
      GoRoute(
        path: '/post/:id',
        builder: (context, state) =>
            PostDetailPage(postId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/user/:id',
        builder: (context, state) =>
            UserCardPage(userId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/letter/:id',
        builder: (context, state) =>
            LetterDetailPage(letterId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/mailbox/archive',
        builder: (context, state) => const MailboxArchivePage(),
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
        path: '/profile/stamps',
        builder: (context, state) => const StampsLedgerPage(),
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
        path: '/profile/my-postcards',
        builder: (context, state) => const MyPostcardsPage(),
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
