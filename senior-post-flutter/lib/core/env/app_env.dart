/// 应用编译期配置（API Base URL 等在 `dio_provider` / 启动参数中）。
abstract final class AppEnv {
  /// 与后端 `senior-post.oss.keyPrefix` 对齐，用于从 GET 预签名 URL 中解析 objectKey 以便过期换签。
  static const String ossKeyPrefix = String.fromEnvironment(
    'OSS_KEY_PREFIX',
    defaultValue: 'app/uploads',
  );
}
