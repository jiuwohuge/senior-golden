import 'package:go_router/go_router.dart';

import 'app_navigator_key.dart';

/// Plus 付费墙入口（VipCenter）。
///
/// 个人中心菜单可见；也可由业务错误码（VIP / AI 额度）通过 [pushFromRoot] 跳转。
abstract final class VipRoutes {
  static const String path = '/profile/vip';

  /// 无 [BuildContext] 时使用（如全局 Dio 拦截器）。
  static void pushFromRoot({String? message}) {
    final ctx = appRootNavigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    final uri = Uri(
      path: path,
      queryParameters: {
        if (message != null && message.isNotEmpty) 'hint': message,
      },
    );
    GoRouter.of(ctx).push(uri.toString());
  }
}
