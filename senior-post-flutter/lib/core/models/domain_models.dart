/// 与后端 VO 对齐的客户端领域模型（明信片墙、信箱、流水等）。
library;

class AppUser {
  const AppUser({
    required this.id,
    required this.nickname,
    required this.email,
    required this.countryCode,
    required this.countryName,
    required this.birthYear,
    required this.bio,
    required this.interests,
    this.interestTagIds = const [],
    this.avatarUrl,
    this.isVip = false,
    this.deletionRequestedAt,
    this.deletionEffectiveAt,
  });

  final String id;
  final String nickname;
  final String email;
  final String countryCode;
  final String countryName;
  final int birthYear;
  final String bio;
  final List<String> interests;
  final List<int> interestTagIds;
  final String? avatarUrl;
  final bool isVip;
  final DateTime? deletionRequestedAt;
  final DateTime? deletionEffectiveAt;

  int get age => DateTime.now().year - birthYear;

  /// 与后端 [AppPublicUserVO] / 名录分页 VO 字段对齐（`email` 可能为空串）。
  factory AppUser.fromPublicVoJson(Map<String, dynamic> m) {
    final id = (m['id'] as num?)?.toInt() ?? 0;
    final birthYear = (m['birthYear'] as num?)?.toInt() ?? 1970;
    final cc = (m['countryCode'] as String?) ?? '';
    final countryName = (m['countryName'] as String?)?.trim().isNotEmpty == true
        ? (m['countryName'] as String).trim()
        : cc;
    var interestNames = const <String>[];
    final namesRaw = m['interestTagNames'];
    if (namesRaw is List<dynamic>) {
      interestNames = namesRaw
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    var interestIds = const <int>[];
    final idsRaw = m['interestTagIds'];
    if (idsRaw is List<dynamic>) {
      interestIds = idsRaw.whereType<num>().map((e) => e.toInt()).toList();
    }
    DateTime? delReq;
    final dr = m['deletionRequestedAt'];
    if (dr is String && dr.isNotEmpty) {
      delReq = DateTime.tryParse(dr);
    }
    DateTime? delEff;
    final de = m['deletionEffectiveAt'];
    if (de is String && de.isNotEmpty) {
      delEff = DateTime.tryParse(de);
    }
    return AppUser(
      id: '$id',
      nickname: (m['nickname'] as String?) ?? 'User',
      email: (m['email'] as String?) ?? '',
      countryCode: cc,
      countryName: countryName,
      birthYear: birthYear,
      bio: (m['bio'] as String?) ?? '',
      interests: interestNames,
      interestTagIds: interestIds,
      avatarUrl: m['avatarUrl'] as String?,
      isVip: m['isVip'] as bool? ?? false,
      deletionRequestedAt: delReq,
      deletionEffectiveAt: delEff,
    );
  }

  AppUser copyWith({
    String? nickname,
    String? bio,
    String? countryCode,
    String? countryName,
    List<String>? interests,
    List<int>? interestTagIds,
    String? avatarUrl,
    bool? isVip,
    DateTime? deletionRequestedAt,
    DateTime? deletionEffectiveAt,
  }) {
    return AppUser(
      id: id,
      nickname: nickname ?? this.nickname,
      email: email,
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      birthYear: birthYear,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      interestTagIds: interestTagIds ?? this.interestTagIds,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVip: isVip ?? this.isVip,
      deletionRequestedAt: deletionRequestedAt ?? this.deletionRequestedAt,
      deletionEffectiveAt: deletionEffectiveAt ?? this.deletionEffectiveAt,
    );
  }
}

class WallPost {
  const WallPost({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.commentCount,
    this.imageUrl,
    this.imageUrls,
    this.reviewStatus,
    this.postStatus,
  });

  final String id;
  final AppUser author;
  final String content;
  final DateTime createdAt;
  final int commentCount;
  final String? imageUrl;
  final List<String>? imageUrls;
  final int? reviewStatus;

  /// 1 公开 2 隐藏 3 违规删除（「我的明信片」接口返回）
  final int? postStatus;

  List<String> get resolvedImageUrls {
    if (imageUrls != null && imageUrls!.isNotEmpty) {
      return imageUrls!;
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return <String>[imageUrl!];
    }
    return const <String>[];
  }
}

class WallComment {
  const WallComment({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final AppUser author;
  final String content;
  final DateTime createdAt;
}

enum LetterType { registered, standard }

enum LetterStatus { delivering, delivered, registered }

enum LetterSendMode { standardPost, registeredMail, directVip }

class MailboxLetter {
  MailboxLetter({
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
    this.contentHidden = false,
    this.expectedArrivalAt,
    this.actualArrivalAt,
  });

  final String id;
  final AppUser peer;
  final String preview;
  final String body;
  final LetterType type;
  LetterStatus status;
  final DateTime sentAt;
  DateTime? deliveryAt;
  final bool outgoing;
  final LetterSendMode sendMode;
  final bool contentHidden;
  final DateTime? expectedArrivalAt;
  final DateTime? actualArrivalAt;
}

/// 邮政 Tab「Connections」：好友（笔友）列表行，语义对齐 `GET /api/mailbox/friends`。
class FriendListRow {
  const FriendListRow({
    required this.peer,
    required this.lastMessage,
    required this.lastTime,
  });

  final AppUser peer;
  final String lastMessage;
  final DateTime lastTime;
}

class StampLedgerLine {
  const StampLedgerLine({
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
