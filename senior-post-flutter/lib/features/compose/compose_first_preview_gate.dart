import 'package:shared_preferences/shared_preferences.dart';

/// 首次写信强制预览：本地门闩（与服务器 first_letter_done 解耦）。
class ComposeFirstPreviewGate {
  ComposeFirstPreviewGate._();

  static const _prefsKey = 'compose_first_preview_done_v1';

  /// 是否已完成过一次「寄出前预览」。
  static Future<bool> hasCompletedPreview() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? false;
  }

  /// 用户看过预览后调用，解除强制门闩。
  static Future<void> markPreviewCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }
}
