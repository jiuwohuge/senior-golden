import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 请求头 `deviceId`：框架约定为客户端类型（见后端文档）。
String platformDeviceHeader() {
  if (Platform.isIOS) return 'iOS';
  if (Platform.isAndroid) return 'Android';
  return 'unknown';
}

final deviceInstallIdStateProvider = StateProvider<String>((ref) => '');
