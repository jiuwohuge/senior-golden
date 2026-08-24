import 'package:flutter_test/flutter_test.dart';
import 'package:senior_post_flutter/core/models/domain_models.dart';
import 'package:senior_post_flutter/core/models/letter_transit_progress.dart';

MailboxLetter _letter({
  required LetterStatus status,
  required DateTime sentAt,
  DateTime? expectedArrivalAt,
}) {
  return MailboxLetter(
    id: '1',
    peer: const AppUser(
      id: '2',
      nickname: 'Ada',
      email: '',
      countryCode: 'US',
      countryName: 'United States',
      birthYear: 1958,
      bio: '',
      interests: [],
    ),
    preview: '',
    body: '',
    type: LetterType.standard,
    status: status,
    sentAt: sentAt,
    expectedArrivalAt: expectedArrivalAt,
  );
}

void main() {
  final sent = DateTime(2026, 8, 1, 12);
  final eta = DateTime(2026, 8, 11, 12);

  test('pending match has no progress percent', () {
    expect(
      letterTransitProgress(
        _letter(status: LetterStatus.pending, sentAt: sent, expectedArrivalAt: eta),
      ),
      isNull,
    );
  });

  test('delivering uses sent-to-eta ratio', () {
    final mid = DateTime(2026, 8, 6, 12);
    expect(
      letterTransitProgress(
        _letter(
          status: LetterStatus.delivering,
          sentAt: sent,
          expectedArrivalAt: eta,
        ),
        now: mid,
      ),
      closeTo(0.5, 0.001),
    );
  });

  test('delivered is complete', () {
    expect(
      letterTransitProgress(
        _letter(status: LetterStatus.delivered, sentAt: sent),
      ),
      1.0,
    );
  });
}
