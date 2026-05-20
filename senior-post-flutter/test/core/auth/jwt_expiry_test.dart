import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:senior_post_flutter/core/auth/jwt_expiry.dart';

void main() {
  test('isAuthTokenExpired returns true when exp is in the past', () {
    final exp = DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
    final payload = base64Url.encode(utf8.encode('{"exp":$exp}'));
    final token = 'aaa.$payload.bbb';
    expect(isAuthTokenExpired(token), isTrue);
  });

  test('isAuthTokenExpired returns false when exp is in the future', () {
    final exp = DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
    final payload = base64Url.encode(utf8.encode('{"exp":$exp}'));
    final token = 'aaa.$payload.bbb';
    expect(isAuthTokenExpired(token), isFalse);
  });
}
