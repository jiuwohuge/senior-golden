/// 应用编译期开关。当前阶段以"完整 UI 框架 + Mock 数据"为主，待后端联调阶段
/// 通过 `--dart-define=USE_MOCK=false` 切换至真实接口路径。
abstract final class AppEnv {
  /// 是否启用全量本地 Mock。
  /// - true（默认）：所有 Repository 走 Mock，即使后端未启动也能完整体验
  /// - false：使用真实 `/api/...` 接口
  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  /// 是否启用调试覆盖层（如 Mock 角标）。
  static const bool showMockBadge = bool.fromEnvironment(
    'SHOW_MOCK_BADGE',
    defaultValue: true,
  );
}
