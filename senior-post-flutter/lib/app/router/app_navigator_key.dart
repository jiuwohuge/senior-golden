import 'package:flutter/material.dart';

/// 根导航键：供 Dio 等无 [BuildContext] 场景触发 [GoRouter] 跳转。
final GlobalKey<NavigatorState> appRootNavigatorKey =
    GlobalKey<NavigatorState>();
