import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_token.dart';
import '../../core/network/router_refresh.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/login_routes.dart';
import '../../features/auth/register_page.dart';
import '../../features/shell/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.read(routerRefreshProvider);

  return GoRouter(
    initialLocation: MainShellRoute.pathPostWall,
    refreshListenable: refresh,
    redirect: (context, state) {
      final token = ref.read(authTokenProvider);
      final loc = state.matchedLocation;
      final authPaths = {LoginRoutes.login, LoginRoutes.register};
      final loggedIn = token != null && token.isNotEmpty;
      if (!loggedIn && !authPaths.contains(loc)) {
        return LoginRoutes.login;
      }
      if (loggedIn && authPaths.contains(loc)) {
        return MainShellRoute.pathPostWall;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: LoginRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: LoginRoutes.register,
        builder: (context, state) => const RegisterPage(),
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
    ],
  );
});
