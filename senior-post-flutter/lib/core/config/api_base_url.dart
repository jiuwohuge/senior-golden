/// 后端 Base URL，构建时覆盖：
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:9011`（Android 模拟器访问本机）
/// `flutter run --dart-define=API_BASE_URL=http://192.168.x.x:9011`（真机与电脑同一局域网时用电脑 IP）
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2/backend',
);
