import 'dart:convert';

import 'package:encrypt/encrypt.dart' as enc;

/// 与后端 `jh.security.key`（32 位 hex → 16 字节 AES-128）及 ECB/PKCS7 约定对齐；若与网关实现不一致可 `--dart-define=JH_AES_KEY=...` 覆盖。
class JhApiCrypto {
  JhApiCrypto._();

  static const String _defaultKeyHex =
      '8e32de3646dc4c02ae2507511202c7ca';

  static String get _keyHex => const String.fromEnvironment(
        'JH_AES_KEY',
        defaultValue: _defaultKeyHex,
      );

  static final enc.Encrypter _encrypter = enc.Encrypter(
    enc.AES(
      enc.Key.fromBase16(_keyHex),
      mode: enc.AESMode.ecb,
      padding: 'PKCS7',
    ),
  );

  /// 与 [application.yml] 中 `resIgnoreEncryptUris` / `reqIgnoreDecryptUris` 明文列表保持一致。
  static bool isPlaintextApiPath(String path) {
    const plain = <String>[
      '/api/auth/register',
      '/api/auth/login',
      '/api/auth/forgot-password',
      '/api/auth/reset-password',
      '/api/bootstrap/init',
      '/api/bootstrap/release-note',
    ];
    for (final p in plain) {
      if (path == p || path.startsWith('$p?')) {
        return true;
      }
    }
    return false;
  }

  static String encryptUtf8ToDataField(String plainUtf8) {
    final encrypted = _encrypter.encrypt(plainUtf8, iv: enc.IV.fromLength(16));
    return encrypted.base64;
  }

  static String decryptDataFieldToUtf8(String base64Cipher) {
    return _encrypter.decrypt64(base64Cipher, iv: enc.IV.fromLength(16));
  }

  static String? tryDecryptResponseDataField(String path, Object? dataField) {
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

  static Map<String, dynamic>? wrapJsonBodyIfNeeded(String path, Object? body) {
    if (isPlaintextApiPath(path)) {
      return null;
    }
    if (body is! Map) {
      return null;
    }
    final inner = jsonEncode(body);
    return <String, dynamic>{'data': encryptUtf8ToDataField(inner)};
  }
}
