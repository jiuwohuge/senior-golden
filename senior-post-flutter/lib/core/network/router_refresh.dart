import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 驱动 [GoRouter] 在登录态变化时重新执行 `redirect`。
final routerRefreshProvider = Provider<ValueNotifier<int>>((ref) {
  final n = ValueNotifier(0);
  ref.onDispose(n.dispose);
  return n;
});
