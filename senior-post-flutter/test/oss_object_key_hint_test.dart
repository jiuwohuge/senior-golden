import 'package:flutter_test/flutter_test.dart';
import 'package:senior_post_flutter/core/oss/oss_object_key_hint.dart';

void main() {
  test('parses plain objectKey', () {
    expect(
      tryParseOssObjectKey('app/uploads/postcard/42/ab12cd34-ef56-7890-abcd-ef1234567890.jpg'),
      'app/uploads/postcard/42/ab12cd34-ef56-7890-abcd-ef1234567890.jpg',
    );
  });

  test('parses key from presigned URL path', () {
    final key = 'app/uploads/avatar/9/550e8400-e29b-41d4-a716-446655440000.png';
    final url =
        'https://bucket.oss-ap-southeast-1.aliyuncs.com/$key?OSSAccessKeyId=x&Expires=1&Signature=y';
    expect(tryParseOssObjectKey(url), key);
  });

  test('rejects wrong scene', () {
    expect(tryParseOssObjectKey('app/uploads/other/1/x.jpg'), isNull);
  });

  test('rejects mock URLs', () {
    expect(tryParseOssObjectKey('https://picsum.photos/200'), isNull);
  });
}
