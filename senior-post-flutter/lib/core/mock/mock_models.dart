/// 与后端 DTO 对齐的轻量模型（Mock 期间使用）。后端联调阶段可换为契约 DTO。
library;

class MockUser {
  const MockUser({
    required this.id,
    required this.nickname,
    required this.email,
    required this.countryCode,
    required this.countryName,
    required this.birthYear,
    required this.bio,
    required this.interests,
    this.avatarUrl,
    this.isVip = false,
  });

  final String id;
  final String nickname;
  final String email;
  final String countryCode;
  final String countryName;
  final int birthYear;
  final String bio;
  final List<String> interests;
  final String? avatarUrl;
  final bool isVip;

  int get age => DateTime.now().year - birthYear;

  MockUser copyWith({
    String? nickname,
    String? bio,
    String? countryCode,
    String? countryName,
    List<String>? interests,
    String? avatarUrl,
  }) {
    return MockUser(
      id: id,
      nickname: nickname ?? this.nickname,
      email: email,
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      birthYear: birthYear,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVip: isVip,
    );
  }
}

class MockPost {
  const MockPost({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.commentCount,
    this.imageUrl,
  });

  final String id;
  final MockUser author;
  final String content;
  final DateTime createdAt;
  final int commentCount;
  final String? imageUrl;
}

class MockComment {
  const MockComment({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final MockUser author;
  final String content;
  final DateTime createdAt;
}

enum LetterType { registered, standard }

/// 与后端 `LetterBizStatus` 对齐：运输中 / 已送达 / 已挂号（待策略转送达）。
enum LetterStatus { delivering, delivered, registered }

/// 与后端 `LetterSendMode` 对齐。
enum LetterSendMode { standardPost, registeredMail, directVip }

class MockLetter {
  MockLetter({
    required this.id,
    required this.peer,
    required this.preview,
    required this.body,
    required this.type,
    required this.status,
    required this.sentAt,
    this.deliveryAt,
    this.outgoing = true,
    this.sendMode = LetterSendMode.standardPost,
  });

  final String id;
  final MockUser peer;
  final String preview;
  final String body;
  final LetterType type;
  LetterStatus status;
  final DateTime sentAt;
  DateTime? deliveryAt;
  final bool outgoing;
  final LetterSendMode sendMode;
}

/// Mock-only：已建联会话行（真实环境由 TIM getConversationList 提供）。
class MockImConnectionRow {
  const MockImConnectionRow({
    required this.peer,
    required this.lastMessage,
    required this.lastTime,
  });

  final MockUser peer;
  final String lastMessage;
  final DateTime lastTime;
}

class MockStampLedgerEntry {
  const MockStampLedgerEntry({
    required this.id,
    required this.title,
    required this.delta,
    required this.balanceAfter,
    required this.at,
  });

  final String id;
  final String title;
  final int delta;
  final int balanceAfter;
  final DateTime at;
}

class MockInterestTag {
  const MockInterestTag({required this.id, required this.label});
  final String id;
  final String label;
}
