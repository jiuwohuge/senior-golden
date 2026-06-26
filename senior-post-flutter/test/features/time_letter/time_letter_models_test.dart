/// Tests for TimeLetter model classes: TimeLetterItem, TimeLetterDetail,
/// TimeLetterStats, TimeLetterSealResult, TimeLetterRecentRecipient.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:senior_post_flutter/features/time_letter/time_letter_remote.dart';

void main() {
  group('TimeLetterItem', () {
    test('constructor assigns all fields', () {
      final item = TimeLetterItem(
        id: '1',
        status: 2,
        senderId: 's1',
        recipientId: 'r1',
        recipientType: 0,
        bodyPreview: 'Hello there',
        deliveryDate: '2026-07-01',
        deliveryTz: '+08:00',
        sealedAt: '2026-06-01T12:00:00Z',
        deliveredAt: '2026-07-01T12:00:00Z',
        readAt: null,
        cancelDeadlineAt: '2026-06-02T12:00:00Z',
        starFlag: true,
        peerNickname: 'Alice',
        peerAvatarUrl: 'https://example.com/a.png',
        daysUntilDelivery: 5,
        canCancel: true,
        contentTag: 'memory',
        emotionTag: 'warm',
      );
      expect(item.id, '1');
      expect(item.status, 2);
      expect(item.bodyPreview, 'Hello there');
      expect(item.deliveryDate, '2026-07-01');
      expect(item.starFlag, true);
      expect(item.peerNickname, 'Alice');
      expect(item.daysUntilDelivery, 5);
      expect(item.canCancel, true);
      expect(item.contentTag, 'memory');
      expect(item.emotionTag, 'warm');
    });
  });

  group('TimeLetterDetail', () {
    test('constructor assigns all fields', () {
      final detail = TimeLetterDetail(
        id: 'd1',
        status: 2,
        body: 'Full letter body here.',
        senderId: 's1',
        recipientId: 'r1',
        recipientType: 0,
        deliveryDate: '2026-07-01',
        deliveryTz: '+08:00',
        sealedAt: '2026-06-01T12:00:00Z',
        deliveredAt: '2026-07-01T12:00:00Z',
        readAt: null,
        cancelDeadlineAt: '2026-06-02T12:00:00Z',
        starFlag: false,
        senderNickname: 'Alice',
        senderAvatarUrl: 'https://example.com/a.png',
        recipientNickname: 'Bob',
        recipientAvatarUrl: 'https://example.com/b.png',
        canCancel: true,
        canOpen: true,
        estimatedReadMinutes: 3,
        contentTag: 'gratitude',
        emotionTag: 'calm',
        paperTheme: 'vintage',
        paperColor: '#EFE8DC',
        writerCity: 'Beijing',
      );
      expect(detail.id, 'd1');
      expect(detail.body, 'Full letter body here.');
      expect(detail.estimatedReadMinutes, 3);
      expect(detail.paperTheme, 'vintage');
      expect(detail.paperColor, '#EFE8DC');
      expect(detail.writerCity, 'Beijing');
      expect(detail.canOpen, true);
    });
  });

  group('TimeLetterStats', () {
    test('defaults all counts to zero', () {
      const stats = TimeLetterStats();
      expect(stats.inFlightCount, 0);
      expect(stats.deliveredUnreadCount, 0);
      expect(stats.memorialCount, 0);
      expect(stats.todayDeliveredCount, 0);
    });

    test('named constructor sets non-zero values', () {
      const stats = TimeLetterStats(
        inFlightCount: 3,
        deliveredUnreadCount: 5,
        memorialCount: 10,
        todayDeliveredCount: 2,
      );
      expect(stats.inFlightCount, 3);
      expect(stats.deliveredUnreadCount, 5);
      expect(stats.memorialCount, 10);
      expect(stats.todayDeliveredCount, 2);
    });
  });

  group('TimeLetterSealResult', () {
    test('constructor assigns fields', () {
      const result = TimeLetterSealResult(
        id: 'seal1',
        status: 1,
        deliveryDate: '2026-07-01',
        cancelDeadlineAt: '2026-06-02T12:00:00Z',
        stampCost: 1,
        stampBalanceAfter: 42,
      );
      expect(result.id, 'seal1');
      expect(result.stampCost, 1);
      expect(result.stampBalanceAfter, 42);
    });
  });

  group('TimeLetterRecentRecipient', () {
    test('constructor assigns fields', () {
      const r = TimeLetterRecentRecipient(
        userId: 'u1',
        nickname: 'Charlie',
        avatarUrl: 'https://example.com/c.png',
        countryLabel: 'China',
      );
      expect(r.userId, 'u1');
      expect(r.nickname, 'Charlie');
      expect(r.avatarUrl, 'https://example.com/c.png');
      expect(r.countryLabel, 'China');
    });
  });
}
