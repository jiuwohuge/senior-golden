import 'package:flutter_test/flutter_test.dart';
import 'package:senior_post_flutter/core/device/location_access.dart';

void main() {
  tearDown(LocationPromptMemory.reset);

  test('每个触发点本进程只消费一次，设置为每次都允许', () {
    expect(LocationPromptMemory.consume(LocationPromptReason.compose), isTrue);
    expect(LocationPromptMemory.consume(LocationPromptReason.compose), isFalse);
    expect(LocationPromptMemory.consume(LocationPromptReason.mailbox), isTrue);
    expect(LocationPromptMemory.consume(LocationPromptReason.settings), isTrue);
    expect(LocationPromptMemory.consume(LocationPromptReason.settings), isTrue);
  });
}
