import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_base_url.dart';
import 'api_base_url_storage.dart';

/// 当前生效的 API Base URL（Debug 覆盖 > `--dart-define` > 默认值）。
final apiBaseUrlProvider = StateNotifierProvider<ApiBaseUrlNotifier, String>((
  ref,
) {
  return ApiBaseUrlNotifier();
});

class ApiBaseUrlNotifier extends StateNotifier<String> {
  ApiBaseUrlNotifier() : super(kApiBaseUrl);

  /// 启动时从磁盘恢复；应在 [runApp] 前调用一次。
  Future<void> loadFromStorage() async {
    final override = await ApiBaseUrlStorage.readOverride();
    if (override != null && override.isNotEmpty && override != state) {
      state = normalizeApiBaseUrl(override);
    }
  }

  Future<void> applyOverride(String url) async {
    final normalized = normalizeApiBaseUrl(url);
    await ApiBaseUrlStorage.writeOverride(normalized);
    state = normalized;
  }

  Future<void> clearOverride() async {
    await ApiBaseUrlStorage.clearOverride();
    state = kApiBaseUrl;
  }
}

/// 去掉首尾空白与末尾 `/`，保证 Dio `baseUrl` 拼接一致。
String normalizeApiBaseUrl(String url) {
  var s = url.trim();
  while (s.endsWith('/')) {
    s = s.substring(0, s.length - 1);
  }
  return s;
}
