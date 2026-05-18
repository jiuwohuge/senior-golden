import 'dart:convert';

import 'package:encrypt/encrypt.dart' as enc;

/// 与 commons-security `wj.security.key`（32 位 hex → 16 字节 AES-128）及
/// AES/ECB/PKCS5(PKCS7) 约定对齐；可通过 `--dart-define=JH_AES_KEY=...` 覆盖。
class JhApiCrypto {
  JhApiCrypto._();

  /// 与当前后端 `application*.yml` 中 `jh.security.key` 默认配置保持一致。
  static const String _defaultKeyHex = '8e32de3646dc4c02ae2507511202c7ca';

  static String get _keyHex =>
      const String.fromEnvironment('JH_AES_KEY', defaultValue: _defaultKeyHex);

  /// 默认开启，与 `commons-security` 生产链路对齐；若本地需要明文联调可手动关闭。
  static const bool _aesEnabled = bool.fromEnvironment(
    'API_AES_ENABLED',
    defaultValue: true,
  );

  static final enc.Encrypter _encrypter = enc.Encrypter(
    enc.AES(
      enc.Key.fromBase16(_keyHex),
      mode: enc.AESMode.ecb,
      padding: 'PKCS7',
    ),
  );

  /// 与后端 `resIgnoreEncryptUris` / `reqIgnoreDecryptUris` 明文列表保持一致。
  /// 当前仅 `/webapi/**` 明文，App `/api/**` 默认全量走 AES。
  static bool isPlaintextApiPath(String path) {
    final normalizedPath = _normalizeGatewayPath(path);
    return normalizedPath.startsWith('/webapi/');
  }

  // WHY: Docker/Nginx 场景下常启用 `/backend` context-path，客户端看到的请求路径会变成
  // `/backend/api/...`；若不去掉该前缀，明文白名单匹配失效，注册/登录会被误加密。
  static String _normalizeGatewayPath(String path) {
    if (path.startsWith('/backend/')) {
      return path.substring('/backend'.length);
    }
    return path;
  }

  static String encryptUtf8ToDataField(String plainUtf8) {
    final encrypted = _encrypter.encrypt(plainUtf8, iv: enc.IV.fromLength(16));
    return encrypted.base64;
  }

  static String decryptDataFieldToUtf8(String base64Cipher) {
    return _encrypter.decrypt64(base64Cipher, iv: enc.IV.fromLength(16));
  }

  static String? tryDecryptResponseDataField(String path, Object? dataField) {
    if (!_aesEnabled) {
      return null;
    }
    if (isPlaintextApiPath(path)) {
      return null;
    }
    if (dataField is! String || dataField.isEmpty) {
      return null;
    }
    try {
      return decryptDataFieldToUtf8(dataField);
    } catch (_) {
      return null;
    }
  }

  static String? wrapJsonBodyIfNeeded(String path, Object? body) {
    if (!_aesEnabled) {
      return null;
    }
    if (isPlaintextApiPath(path)) {
      return null;
    }
    if (body is! Map) {
      return null;
    }
    final inner = jsonEncode(body);
    // commons-security 的请求解密入口直接对整个请求体做 Base64 AES 解密，
    // 因此请求体需为“纯密文字符串”，不能再包一层 {"data": "..."}。
    return encryptUtf8ToDataField(inner);
  }
}
