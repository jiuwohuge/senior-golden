/// Android 模拟器访问宿主机后端的默认地址（经 nginx `/backend` 反代）。
const String kDefaultApiBaseUrl = 'http://10.0.2.2/backend';

/// 后端 Base URL，构建时覆盖：
/// `flutter run --dart-define=API_BASE_URL=https://api.example.com/backend`
/// Debug 下还可在登录页长按「查看功能引导」临时覆盖并持久化。
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: kDefaultApiBaseUrl,
);
