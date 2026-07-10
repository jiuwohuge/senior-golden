/// Tests for ComposeIntent and its factory fromLegacyTimeLetterExtra.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:senior_post_flutter/features/compose/compose_intent.dart';

void main() {
  group('ComposeIntent defaults', () {
    test('all fields are null by default', () {
      final intent = ComposeIntent();
      expect(intent.kind, isNull);
      expect(intent.peerId, isNull);
      expect(intent.peerNickname, isNull);
      expect(intent.peerCountryLabel, isNull);
      expect(intent.topicKey, isNull);
    });
  });

  group('ComposeIntent copyWith', () {
    test('returns same instance with no args', () {
      final a = ComposeIntent(kind: ComposeKind.selfTimeLetter);
      final b = a.copyWith();
      expect(b.kind, ComposeKind.selfTimeLetter);
    });

    test('overrides only specified fields', () {
      final a = ComposeIntent(kind: ComposeKind.selfTimeLetter);
      final b = a.copyWith(kind: ComposeKind.postOffice, topicKey: 'hometown');
      expect(b.kind, ComposeKind.postOffice);
      expect(b.topicKey, 'hometown');
      expect(b.peerId, isNull);
    });
  });

  group('fromLegacyTimeLetterExtra', () {
    test('toSelf true produces selfTimeLetter', () {
      final extra = <dynamic, dynamic>{'toSelf': true};
      final intent = ComposeIntent.fromLegacyTimeLetterExtra(extra);
      expect(intent.kind, ComposeKind.selfTimeLetter);
      expect(intent.peerId, isNull);
    });

    test('with recipientId and nickname produces penPalTimeLetter', () {
      final extra = <dynamic, dynamic>{
        'recipientId': '42',
        'recipientNickname': 'Alice',
      };
      final intent = ComposeIntent.fromLegacyTimeLetterExtra(extra);
      expect(intent.kind, ComposeKind.penPalTimeLetter);
      expect(intent.peerId, '42');
      expect(intent.peerNickname, 'Alice');
    });

    test('empty extra defaults to penPalTimeLetter with nulls', () {
      final extra = <dynamic, dynamic>{};
      final intent = ComposeIntent.fromLegacyTimeLetterExtra(extra);
      expect(intent.kind, ComposeKind.penPalTimeLetter);
      expect(intent.peerId, isNull);
    });
  });

  group('ComposeKind contains all values', () {
    test('has four members', () {
      expect(ComposeKind.values.length, 4);
    });
    test('selfTimeLetter is present', () {
      expect(ComposeKind.values, contains(ComposeKind.selfTimeLetter));
    });
    test('penPalMail is present', () {
      expect(ComposeKind.values, contains(ComposeKind.penPalMail));
    });
    test('penPalTimeLetter is present', () {
      expect(ComposeKind.values, contains(ComposeKind.penPalTimeLetter));
    });
    test('postOffice is present', () {
      expect(ComposeKind.values, contains(ComposeKind.postOffice));
    });
  });
}
