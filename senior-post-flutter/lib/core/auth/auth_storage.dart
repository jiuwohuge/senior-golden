import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kAuthToken = 'auth_token';

class AuthStorage {
  AuthStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> readToken() => _storage.read(key: _kAuthToken);

  static Future<void> writeToken(String token) =>
      _storage.write(key: _kAuthToken, value: token);

  static Future<void> clearToken() => _storage.delete(key: _kAuthToken);
}
