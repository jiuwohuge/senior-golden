import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 请求头 `deviceId`：框架约定为客户端类型（见后端文档）。
///
/// commons-security 仅对 `Android` / `iOS`（且 versionCode ≥ 门槛）执行
/// `/api/**` 请求解密与响应加密。Web 仅本地多开联调，复用 `Android`，
/// 否则密文体直达 Jackson 会报 JSON parse error（正式发版仍以 Android 为准）。
String platformDeviceHeader() {
  if (kIsWeb) return 'Android';
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return 'iOS';
    case TargetPlatform.android:
      return 'Android';
    default:
      return 'Android';
  }
}

final deviceInstallIdStateProvider = StateProvider<String>((ref) => '');
