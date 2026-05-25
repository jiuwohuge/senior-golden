import 'package:go_router/go_router.dart';

import 'app_navigator_key.dart';

/// 统一商品 / 邮票 / 会员入口（静态页阶段）。
///
/// 不在个人中心菜单展示；由业务错误码或付费流程通过 [pushFromRoot] 弹窗跳转。
abstract final class ShopRoutes {
  static const String path = '/shop';

  /// 无 [BuildContext] 时使用（如全局异常处理）。
  static void pushFromRoot({int? bizCode, String? message}) {
    final ctx = appRootNavigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    final uri = Uri(
      path: path,
      queryParameters: {
        if (bizCode != null) 'bizCode': '$bizCode',
        if (message != null && message.isNotEmpty) 'hint': message,
      },
    );
    GoRouter.of(ctx).push(uri.toString());
  }
}
