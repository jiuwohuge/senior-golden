import 'package:flutter_test/flutter_test.dart';
import 'package:senior_post_flutter/core/models/domain_models.dart';

void main() {
  test('LetterStatus includes registered for postal flow', () {
    expect(LetterStatus.values, contains(LetterStatus.registered));
  });

  test('LetterSendMode distinguishes direct VIP', () {
    expect(LetterSendMode.directVip, isNot(equals(LetterSendMode.registeredMail)));
  });
}
