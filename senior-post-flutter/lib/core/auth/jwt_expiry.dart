import 'dart:convert';

/// 解析 JWT `exp`，启动时剔除已过期 Token，避免带着失效凭证进主页。
bool isAuthTokenExpired(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) {
      return false;
    }
    var segment = parts[1];
    final pad = segment.length % 4;
    if (pad > 0) {
      segment += '=' * (4 - pad);
    }
    final json = utf8.decode(base64Url.decode(segment));
    final map = jsonDecode(json) as Map<String, dynamic>;
    final exp = map['exp'];
    if (exp is! num) {
      return false;
    }
    final expiry = DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
    return DateTime.now().isAfter(expiry);
  } catch (_) {
    return false;
  }
}
