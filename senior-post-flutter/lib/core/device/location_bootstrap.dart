import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 定位授权启动页是否已结束（含拒绝）。未完成时路由停在 `/boot`，避免闪到登录页。
final locationBootstrapDoneProvider = StateProvider<bool>((ref) => false);
