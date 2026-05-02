import 'dart:math' as math;

import '../api/api_exception.dart';

/// 模拟网络延迟与错误率，让 UI 能呈现真实的 loading / 错误反馈。
class MockDelay {
  MockDelay._();

  static final _rng = math.Random();

  /// 随机 300~900ms 延迟。
  static Future<void> network() async {
    final ms = 300 + _rng.nextInt(600);
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  /// 短延迟（150~300ms），用于本地状态切换感。
  static Future<void> instant() async {
    final ms = 150 + _rng.nextInt(150);
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  /// 1% 概率抛业务错误，模拟后端兜底。仅用于"读取列表"等读操作。
  /// 写操作请显式判定，避免数据丢失感太强。
  static void maybeThrow({double rate = 0.01, String? message}) {
    if (_rng.nextDouble() < rate) {
      throw ApiBusinessException(
        500,
        message ?? 'Mock: Postal carrier got lost. Please try again.',
      );
    }
  }
}
