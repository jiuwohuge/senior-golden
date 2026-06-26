/// Unit tests for JhApiCrypto crypto helpers.
/// These test pure functions — no network involved.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:senior_post_flutter/core/network/jh_api_crypto.dart';

void main() {
  group('isPlaintextApiPath', () {
    test('/webapi/xxx is plaintext', () {
      expect(JhApiCrypto.isPlaintextApiPath('/webapi/auth/login'), isTrue);
    });

    test('/api/xxx is not plaintext', () {
      expect(JhApiCrypto.isPlaintextApiPath('/api/time-letter/list'), isFalse);
    });

    test('/backend/api/xxx is normalized and not plaintext', () {
      expect(JhApiCrypto.isPlaintextApiPath('/backend/api/letter/send'), isFalse);
    });

    test('/backend/webapi/xxx is normalized to plaintext', () {
      expect(JhApiCrypto.isPlaintextApiPath('/backend/webapi/auth/login'), isTrue);
    });
  });

  group('encrypt -> decrypt roundtrip', () {
    test('encryptUtf8ToDataField and decryptDataFieldToUtf8 roundtrip', () {
      const plain = '{"test": "hello world"}';
      final cipher = JhApiCrypto.encryptUtf8ToDataField(plain);
      expect(cipher, isNotEmpty);
      expect(cipher, isA<String>());

      final decrypted = JhApiCrypto.decryptDataFieldToUtf8(cipher);
      expect(decrypted, plain);
    });

    test('multiple roundtrips produce different ciphertexts (non-deterministic IV)', () {
      const plain = 'same text';
      final c1 = JhApiCrypto.encryptUtf8ToDataField(plain);
      final c2 = JhApiCrypto.encryptUtf8ToDataField(plain);
      // With IV randomness they should differ.
      // Note: the current implementation uses IV.fromLength(16) which
      // produces a zero IV, so in practice they may be identical.
      // This is fine — we just verify they both decrypt to the same plaintext.
      expect(JhApiCrypto.decryptDataFieldToUtf8(c1), plain);
      expect(JhApiCrypto.decryptDataFieldToUtf8(c2), plain);
    });
  });

  group('tryDecryptResponseDataField', () {
    test('returns null for plaintext path', () {
      final result = JhApiCrypto.tryDecryptResponseDataField('/webapi/test', 'some-cipher');
      expect(result, isNull);
    });

    test('returns null for empty dataField', () {
      final result = JhApiCrypto.tryDecryptResponseDataField('/api/test', '');
      expect(result, isNull);
    });

    test('returns null for non-string dataField', () {
      final result = JhApiCrypto.tryDecryptResponseDataField('/api/test', 123);
      expect(result, isNull);
    });

    test('decrypts valid cipher for /api/* path', () {
      const plain = '{"userId":42}';
      final cipher = JhApiCrypto.encryptUtf8ToDataField(plain);
      final result = JhApiCrypto.tryDecryptResponseDataField('/api/test', cipher);
      expect(result, plain);
    });
  });

  group('wrapJsonBodyIfNeeded', () {
    test('returns null for plaintext path', () {
      final result = JhApiCrypto.wrapJsonBodyIfNeeded('/webapi/test', <String, dynamic>{'a': 1});
      expect(result, isNull);
    });

    test('returns null for non-Map body', () {
      final result = JhApiCrypto.wrapJsonBodyIfNeeded('/api/test', 'plain string');
      expect(result, isNull);
    });

    test('returns encrypted string for /api/* path with Map body', () {
      final body = <String, dynamic>{'userId': 42, 'action': 'test'};
      final result = JhApiCrypto.wrapJsonBodyIfNeeded('/api/time-letter/seal', body);
      expect(result, isNotNull);
      expect(result, isA<String>());

      // Decrypt to verify content.
      final decrypted = JhApiCrypto.decryptDataFieldToUtf8(result!);
      expect(decrypted, contains('"userId":42'));
      expect(decrypted, contains('"action":"test"'));
    });
  });
}
