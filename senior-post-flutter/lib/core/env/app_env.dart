/// 应用编译期开关。通过 `--dart-define=USE_MOCK=false` 切换至真实接口路径。
abstract final class AppEnv {
  /// 是否启用本地 Mock（默认 true）。
  /// - **通信名录 Tab**：列表 / 用户卡 / Send Letter 已固定走 `/api/directory/*` 与 `/api/mailbox/*`，
  ///   不读此项；需后端可用。
  /// - 其他模块仍可按此开关在 Mock 与远程之间切换（如明信片墙、个人中心等）。
  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  /// 是否启用调试覆盖层（如 Mock 角标）。
  static const bool showMockBadge = bool.fromEnvironment(
    'SHOW_MOCK_BADGE',
    defaultValue: true,
  );

  /// 与后端 `senior-post.oss.keyPrefix` 对齐，用于从 GET 预签名 URL 中解析 objectKey 以便过期换签。
  static const String ossKeyPrefix = String.fromEnvironment(
    'OSS_KEY_PREFIX',
    defaultValue: 'app/uploads',
  );
}
