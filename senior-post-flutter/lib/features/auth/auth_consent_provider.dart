import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 欢迎页勾选协议后，登录/注册页可默认视为已同意。
final authConsentProvider = StateProvider<bool>((ref) => false);
