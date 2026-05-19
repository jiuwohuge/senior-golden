import 'package:shared_preferences/shared_preferences.dart';

const _kDebugApiBaseUrlOverride = 'debug_api_base_url_override';

/// Debug 下持久化的 API Base URL 覆盖（优先于编译期 [kApiBaseUrl]）。
abstract final class ApiBaseUrlStorage {
  static Future<String?> readOverride() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kDebugApiBaseUrlOverride);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    return raw.trim();
  }

  static Future<void> writeOverride(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDebugApiBaseUrlOverride, url.trim());
  }

  static Future<void> clearOverride() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kDebugApiBaseUrlOverride);
  }
}
