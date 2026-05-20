/// 无需携带 Token 的接口（携带过期 Token 时部分网关仍会返回 8502）。
bool isPublicApiPath(String path) {
  final normalized = path.contains('/api/')
      ? path.substring(path.indexOf('/api/'))
      : path;
  return normalized.startsWith('/api/bootstrap/') ||
      normalized == '/api/auth/login' ||
      normalized == '/api/auth/register' ||
      normalized.startsWith('/api/auth/forgot-password') ||
      normalized.startsWith('/api/auth/reset-password');
}
