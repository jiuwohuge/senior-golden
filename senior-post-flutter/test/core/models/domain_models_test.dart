/// Tests for core domain models: AppUser, WallPost, WallComment,
/// MailboxLetter, FriendListRow, StampLedgerLine, enums.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:senior_post_flutter/core/models/domain_models.dart';

void main() {
  group('AppUser', () {
    test('constructor sets all fields', () {
      final u = AppUser(
        id: '42',
        nickname: 'Alice',
        email: 'alice@example.com',
        countryCode: 'CN',
        countryName: 'China',
        birthYear: 1965,
        gender: 0,
        bio: 'Hello',
        interests: ['reading', 'gardening'],
        interestTagIds: [1, 2],
        avatarUrl: 'https://example.com/avatar.png',
        avatarAuditStatus: 1,
        isVip: true,
        deletionRequestedAt: null,
        deletionEffectiveAt: null,
        postalFriend: true,
      );

      expect(u.id, '42');
      expect(u.nickname, 'Alice');
      expect(u.email, 'alice@example.com');
      expect(u.countryCode, 'CN');
      expect(u.countryName, 'China');
      expect(u.birthYear, 1965);
      expect(u.gender, 0);
      expect(u.bio, 'Hello');
      expect(u.interests, ['reading', 'gardening']);
      expect(u.interestTagIds, [1, 2]);
      expect(u.avatarUrl, 'https://example.com/avatar.png');
      expect(u.avatarAuditStatus, 1);
      expect(u.isVip, true);
      expect(u.postalFriend, true);
    });

    test('age computes from birthYear', () {
      final now = DateTime.now();
      final u = AppUser(
        id: '1',
        nickname: 'Test',
        email: 't@t.com',
        countryCode: 'US',
        countryName: 'USA',
        birthYear: 1960,
        bio: '',
        interests: [],
      );
      expect(u.age, now.year - 1960);
    });

    group('avatar audit getters', () {
      test('hasAvatar is false when avatarUrl is null', () {
        final u = AppUser(
          id: '1', nickname: 'T', email: 't@t.com',
          countryCode: 'US', countryName: 'USA', birthYear: 1960,
          bio: '', interests: [],
        );
        expect(u.hasAvatar, false);
      });

      test('hasAvatar is true when avatarUrl is non-empty', () {
        final u = AppUser(
          id: '1', nickname: 'T', email: 't@t.com',
          countryCode: 'US', countryName: 'USA', birthYear: 1960,
          bio: '', interests: [], avatarUrl: 'https://x.com/pic.png',
        );
        expect(u.hasAvatar, true);
      });

      test('isAvatarAuditRejected when status is 2', () {
        final u = AppUser(
          id: '1', nickname: 'T', email: 't@t.com',
          countryCode: 'US', countryName: 'USA', birthYear: 1960,
          bio: '', interests: [], avatarUrl: 'x.png',
          avatarAuditStatus: 2,
        );
        expect(u.isAvatarAuditRejected, true);
        expect(u.isAvatarAuditPending, false);
        expect(u.isAvatarAuditApproved, false);
      });

      test('isAvatarAuditApproved when no avatar', () {
        final u = AppUser(
          id: '1', nickname: 'T', email: 't@t.com',
          countryCode: 'US', countryName: 'USA', birthYear: 1960,
          bio: '', interests: [],
        );
        expect(u.isAvatarAuditApproved, true);
      });
    });

    group('fromPublicVoJson', () {
      test('parses minimal JSON with defaults', () {
        final m = <String, dynamic>{
          'id': 100,
          'nickname': '老王',
          'email': 'laowang@test.com',
          'countryCode': 'CN',
          'birthYear': 1965,
          'bio': '喜欢种花',
        };
        final u = AppUser.fromPublicVoJson(m);
        expect(u.id, '100');
        expect(u.nickname, '老王');
        expect(u.email, 'laowang@test.com');
        expect(u.countryCode, 'CN');
        expect(u.countryName, 'CN'); // fallback to countryCode
        expect(u.birthYear, 1965);
        expect(u.bio, '喜欢种花');
        expect(u.gender, 0);
        expect(u.interests, []);
        expect(u.isVip, false);
        expect(u.postalFriend, false);
      });

      test('parses full JSON with interest tags', () {
        final m = <String, dynamic>{
          'id': 200,
          'nickname': 'Alice',
          'email': 'a@b.com',
          'countryCode': 'US',
          'countryName': ' United States ',
          'birthYear': 1970,
          'gender': 1,
          'bio': 'Hello world',
          'interestTagNames': ['reading', '  gardening  '],
          'interestTagIds': [3, 5],
          'avatarUrl': 'https://cdn.example.com/a.png',
          'isVip': true,
          'postalFriend': true,
        };
        final u = AppUser.fromPublicVoJson(m);
        expect(u.countryName, 'United States');
        expect(u.gender, 1);
        expect(u.interests, ['reading', 'gardening']);
        expect(u.interestTagIds, [3, 5]);
        expect(u.avatarUrl, 'https://cdn.example.com/a.png');
        expect(u.isVip, true);
        expect(u.postalFriend, true);
      });
    });

    group('copyWith', () {
      test('returns same instance when no arguments', () {
        final u = AppUser(
          id: '1', nickname: 'N', email: 'e@e.com',
          countryCode: 'CN', countryName: 'China', birthYear: 1960,
          bio: '', interests: [],
        );
        final u2 = u.copyWith(); expect(u2.id, u.id); expect(u2.nickname, u.nickname); expect(u2.bio, u.bio);
      });

      test('overrides only given fields', () {
        final u = AppUser(
          id: '1', nickname: 'N', email: 'e@e.com',
          countryCode: 'CN', countryName: 'China', birthYear: 1960,
          bio: '', interests: [],
        );
        final u2 = u.copyWith(nickname: 'NewN', bio: 'New bio');
        expect(u2.nickname, 'NewN');
        expect(u2.bio, 'New bio');
        expect(u2.id, '1');
        expect(u2.countryCode, 'CN');
      });
    });
  });

  group('WallPost', () {
    test('resolvedImageUrls falls back to imageUrl when imageUrls is null', () {
      final author = AppUser(
        id: '1', nickname: 'A', email: 'a@a.com',
        countryCode: 'CN', countryName: 'China', birthYear: 1960,
        bio: '', interests: [],
      );
      final p = WallPost(
        id: 'p1',
        author: author,
        content: 'Hello',
        createdAt: DateTime(2025, 1, 1),
        commentCount: 0,
        imageUrl: 'https://example.com/1.jpg',
      );
      expect(p.resolvedImageUrls, ['https://example.com/1.jpg']);
    });

    test('resolvedImageUrls returns images in order', () {
      final author = AppUser(
        id: '1', nickname: 'A', email: 'a@a.com',
        countryCode: 'CN', countryName: 'China', birthYear: 1960,
        bio: '', interests: [],
      );
      final p = WallPost(
        id: 'p1',
        author: author,
        content: 'Multi-image',
        createdAt: DateTime(2025, 1, 1),
        commentCount: 0,
        imageUrls: ['a.jpg', 'b.jpg'],
      );
      expect(p.resolvedImageUrls, ['a.jpg', 'b.jpg']);
    });

    test('resolvedImageUrls returns empty list when no images', () {
      final author = AppUser(
        id: '1', nickname: 'A', email: 'a@a.com',
        countryCode: 'CN', countryName: 'China', birthYear: 1960,
        bio: '', interests: [],
      );
      final p = WallPost(
        id: 'p1',
        author: author,
        content: 'Text only',
        createdAt: DateTime(2025, 1, 1),
        commentCount: 0,
      );
      expect(p.resolvedImageUrls, []);
    });
  });

  group('WallComment', () {
    test('copyWith updates likeCount and likedByMe', () {
      final author = AppUser(
        id: '1', nickname: 'A', email: 'a@a.com',
        countryCode: 'CN', countryName: 'China', birthYear: 1960,
        bio: '', interests: [],
      );
      final c = WallComment(
        id: 'c1',
        author: author,
        content: 'Nice!',
        createdAt: DateTime(2025, 1, 1),
        likeCount: 5,
        likedByMe: false,
      );
      final c2 = c.copyWith(likeCount: 6, likedByMe: true);
      expect(c2.likeCount, 6);
      expect(c2.likedByMe, true);
      expect(c2.id, 'c1');
    });
  });

  group('Enums', () {
    test('LetterStatus has three values', () {
      expect(LetterStatus.values.length, 3);
      expect(LetterStatus.values, contains(LetterStatus.delivering));
      expect(LetterStatus.values, contains(LetterStatus.delivered));
      expect(LetterStatus.values, contains(LetterStatus.registered));
    });

    test('LetterType has two values', () {
      expect(LetterType.values.length, 2);
      expect(LetterType.values, contains(LetterType.registered));
      expect(LetterType.values, contains(LetterType.standard));
    });

    test('LetterSendMode distinguishes directVip from registeredMail', () {
      expect(LetterSendMode.directVip, isNot(LetterSendMode.registeredMail));
    });
  });

  group('MailboxLetter', () {
    test('fields can be mutated for status and deliveryAt', () {
      final peer = AppUser(
        id: '1', nickname: 'B', email: 'b@b.com',
        countryCode: 'CN', countryName: 'China', birthYear: 1960,
        bio: '', interests: [],
      );
      final letter = MailboxLetter(
        id: 'l1',
        peer: peer,
        preview: 'Hi there',
        body: 'Full body',
        type: LetterType.standard,
        status: LetterStatus.delivering,
        sentAt: DateTime(2025, 1, 1),
      );
      expect(letter.status, LetterStatus.delivering);
      letter.status = LetterStatus.delivered;
      expect(letter.status, LetterStatus.delivered);
      letter.deliveryAt = DateTime(2025, 1, 3);
      expect(letter.deliveryAt, DateTime(2025, 1, 3));
    });
  });

  group('FriendListRow', () {
    test('constructor stores peer info', () {
      final peer = AppUser(
        id: '3', nickname: 'Charlie', email: 'c@c.com',
        countryCode: 'CN', countryName: 'China', birthYear: 1960,
        bio: 'Hi', interests: [],
      );
      final row = FriendListRow(
        peer: peer,
        lastMessage: 'See you',
        lastTime: DateTime(2025, 6, 1),
      );
      expect(row.peer.nickname, 'Charlie');
      expect(row.lastMessage, 'See you');
      expect(row.lastTime, DateTime(2025, 6, 1));
    });
  });

  group('StampLedgerLine', () {
    test('constructor stores ledger line data', () {
      final line = StampLedgerLine(
        id: 's1',
        title: 'Sent letter',
        delta: -1,
        balanceAfter: 42,
        at: DateTime(2025, 5, 1),
      );
      expect(line.title, 'Sent letter');
      expect(line.delta, -1);
      expect(line.balanceAfter, 42);
    });
  });
}

