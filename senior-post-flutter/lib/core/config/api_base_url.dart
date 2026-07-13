import 'package:flutter/foundation.dart';

/// Android 模拟器访问宿主机后端的默认地址（经 nginx `/backend` 反代）。
const String kAndroidEmulatorApiBaseUrl = 'http://10.0.2.2/backend';

/// Flutter Web / 本机浏览器调试默认走宿主机 nginx（与 Manage 同源入口）。
/// 正式上线目标仍是 Android；Web 仅用于多开联调，不替代发版渠道。
const String kWebLocalApiBaseUrl = 'http://localhost/backend';

/// 编译期覆盖：`flutter run --dart-define=API_BASE_URL=https://api.example.com/backend`
const String _kApiBaseUrlDefine = String.fromEnvironment('API_BASE_URL');

/// 未指定 `--dart-define=API_BASE_URL` 时的平台默认值。
String get kDefaultApiBaseUrl =>
    kIsWeb ? kWebLocalApiBaseUrl : kAndroidEmulatorApiBaseUrl;

/// 后端 Base URL：编译期 define > 平台默认。
/// Debug 下还可在登录页长按「查看功能引导」临时覆盖并持久化。
String get kApiBaseUrl =>
    _kApiBaseUrlDefine.isNotEmpty ? _kApiBaseUrlDefine : kDefaultApiBaseUrl;
