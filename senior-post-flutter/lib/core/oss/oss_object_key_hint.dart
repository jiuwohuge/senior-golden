import 'package:senior_post_flutter/core/env/app_env.dart';

/// 从「纯 objectKey」或 OSS 预签名 URL 的路径段解析可提交给 `/api/oss/get-sign` 的 key（与后端 [OssObjectKeyResolver] 路径规则对齐）。
String? tryParseOssObjectKey(String ref) {
  final t = ref.trim();
  if (t.isEmpty) {
    return null;
  }
  final path = _isProbablyHttpUrl(t) ? _pathFromHttpUrl(t) : t;
  if (path == null || path.isEmpty) {
    return null;
  }
  final norm = path.startsWith('/') ? path.substring(1) : path;
  if (_objectKeyPattern().hasMatch(norm)) {
    return norm;
  }
  return null;
}

bool _isProbablyHttpUrl(String s) {
  final lower = s.toLowerCase();
  return lower.startsWith('http://') || lower.startsWith('https://');
}

String? _pathFromHttpUrl(String raw) {
  final u = Uri.tryParse(raw);
  if (u == null || u.path.isEmpty) {
    return null;
  }
  final p = u.path;
  return p.startsWith('/') ? p.substring(1) : p;
}

RegExp _objectKeyPattern() {
  final p = RegExp.escape(
    AppEnv.ossKeyPrefix.replaceAll(RegExp(r'^/+|/+$'), ''),
  );
  return RegExp(
    '^$p/(postcard|avatar|letter)/\\d+/[^/]+\\.(jpg|jpeg|png|webp|gif)\$',
    caseSensitive: false,
  );
}
