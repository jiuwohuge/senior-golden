/// 腾讯 IM UserID 与业务用户 ID 对齐：纯数字字符串，与后端 `String.valueOf(uid)` 一致。
String? normalizeImUserId(String? raw) {
  if (raw == null) {
    return null;
  }
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  final n = int.tryParse(trimmed);
  if (n == null || n <= 0) {
    return null;
  }
  return '$n';
}

bool isImUserIdError(String? message) {
  if (message == null || message.isEmpty) {
    return false;
  }
  final lower = message.toLowerCase();
  return lower.contains('tinyid') ||
      lower.contains('invalid receiver') ||
      lower.contains('invalid userid') ||
      lower.contains('user not exist');
}

/// 腾讯 IM UserSig 失效 / 未登录等，需重新拉取 `/api/im/usersig` 后重试。
bool isTimCredentialError(int code, String? message) {
  if (code == 6206 ||
      code == 6205 ||
      code == 6014 ||
      code == 70001 ||
      code == 70003 ||
      code == 70009) {
    return true;
  }
  if (message == null || message.isEmpty) {
    return false;
  }
  final lower = message.toLowerCase();
  return lower.contains('usersig') ||
      lower.contains('user sig') ||
      lower.contains('sig expire') ||
      lower.contains('not login') ||
      lower.contains('not logged');
}
