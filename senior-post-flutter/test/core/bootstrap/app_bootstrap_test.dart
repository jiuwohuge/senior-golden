import 'package:flutter_test/flutter_test.dart';
import 'package:senior_post_flutter/core/bootstrap/app_bootstrap.dart';

void main() {
  test('parses resolved legal document URLs from bootstrap', () {
    final data = AppBootstrapData.fromJson({
      'minRegisterAge': 45,
      'countries': <dynamic>[],
      'termsUrl': ' https://example.com/terms ',
      'privacyUrl': 'https://example.com/privacy',
    });

    expect(data.termsUrl, 'https://example.com/terms');
    expect(data.privacyUrl, 'https://example.com/privacy');
  });

  test('legal document URLs default to empty until configured', () {
    final data = AppBootstrapData.fromJson({
      'minRegisterAge': 45,
      'countries': <dynamic>[],
    });

    expect(data.termsUrl, isEmpty);
    expect(data.privacyUrl, isEmpty);
  });
}
