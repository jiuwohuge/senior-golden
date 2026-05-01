import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 当前登录 JWT（内存 + SecureStorage 持久化在 [AuthStorage] 中同步）。
final authTokenProvider = StateProvider<String?>((ref) => null);
