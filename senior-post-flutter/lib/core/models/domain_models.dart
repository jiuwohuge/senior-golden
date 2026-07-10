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
    this.gender = 0,
    required this.bio,
    required this.interests,
    this.interestTagIds = const [],
    this.avatarUrl,
    this.avatarAuditStatus,
    this.isVip = false,
    this.deletionRequestedAt,
    this.deletionEffectiveAt,
    this.postalFriend = false,
    this.emailVerified = false,
    this.language,
    this.city,
    this.latitude,
    this.longitude,
    this.writingStyle,
  });

  final String id;
  final String nickname;
  final String email;
  final String countryCode;
  final String countryName;
  final int birthYear;
  final int gender;
  final String bio;
  final List<String> interests;
  final List<int> interestTagIds;
  final String? avatarUrl;

  /// 0 待审核 1 通过 2 驳回（仅本人资料接口返回）
  final int? avatarAuditStatus;
  final bool isVip;

  bool get hasAvatar => avatarUrl != null && avatarUrl!.trim().isNotEmpty;

  bool get isAvatarAuditPending => hasAvatar && avatarAuditStatus == 0;
  bool get isAvatarAuditRejected => hasAvatar && avatarAuditStatus == 2;
  bool get isAvatarAuditApproved =>
      !hasAvatar || avatarAuditStatus == null || avatarAuditStatus == 1;
  final DateTime? deletionRequestedAt;
  final DateTime? deletionEffectiveAt;

  /// 当前浏览者与该用户是否为邮政好友（名录用户卡）
  final bool postalFriend;

  /// 邮箱是否已验证绑定（仅邮箱账号有意义）
  final bool emailVerified;

  /// 用户语言标签，如 zh-CN
  final String? language;

  final String? city;
  final double? latitude;
  final double? longitude;

  /// concise | narrative | emotional
  final String? writingStyle;

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
      gender: (m['gender'] as num?)?.toInt() ?? 0,
      bio: (m['bio'] as String?) ?? '',
      interests: interestNames,
      interestTagIds: interestIds,
      avatarUrl: m['avatarUrl'] as String?,
      avatarAuditStatus: (m['avatarAuditStatus'] as num?)?.toInt(),
      isVip: m['isVip'] as bool? ?? false,
      deletionRequestedAt: delReq,
      deletionEffectiveAt: delEff,
      postalFriend: m['postalFriend'] as bool? ?? false,
      emailVerified: m['emailVerified'] as bool? ?? false,
      language: m['language'] as String?,
      city: m['city'] as String?,
      latitude: (m['latitude'] as num?)?.toDouble(),
      longitude: (m['longitude'] as num?)?.toDouble(),
      writingStyle: m['writingStyle'] as String?,
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
    int? avatarAuditStatus,
    bool? isVip,
    DateTime? deletionRequestedAt,
    DateTime? deletionEffectiveAt,
    bool? emailVerified,
    String? language,
    String? city,
    double? latitude,
    double? longitude,
    String? writingStyle,
  }) {
    return AppUser(
      id: id,
      nickname: nickname ?? this.nickname,
      email: email,
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      birthYear: birthYear,
      gender: gender,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      interestTagIds: interestTagIds ?? this.interestTagIds,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarAuditStatus: avatarAuditStatus ?? this.avatarAuditStatus,
      isVip: isVip ?? this.isVip,
      deletionRequestedAt: deletionRequestedAt ?? this.deletionRequestedAt,
      deletionEffectiveAt: deletionEffectiveAt ?? this.deletionEffectiveAt,
      postalFriend: postalFriend,
      emailVerified: emailVerified ?? this.emailVerified,
      language: language ?? this.language,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      writingStyle: writingStyle ?? this.writingStyle,
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
    this.canSendLetter = true,
    this.isOwner = false,
    this.machineReviewNote,
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

  /// 是否可向作者寄信（本人帖子为 false，与后端 `canSendLetter` 对齐）
  final bool canSendLetter;

  /// 当前用户是否为作者（详情接口 `owner`）
  final bool isOwner;

  /// 机审摘要（作者详情接口，驳回时可能有说明）
  final String? machineReviewNote;

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
    this.replyTo,
    this.likeCount = 0,
    this.likedByMe = false,
    this.replies = const [],
  });

  final String id;
  final AppUser author;
  final String content;
  final DateTime createdAt;
  final AppUser? replyTo;
  final int likeCount;
  final bool likedByMe;
  final List<WallComment> replies;

  WallComment copyWith({int? likeCount, bool? likedByMe}) {
    return WallComment(
      id: id,
      author: author,
      content: content,
      createdAt: createdAt,
      replyTo: replyTo,
      likeCount: likeCount ?? this.likeCount,
      likedByMe: likedByMe ?? this.likedByMe,
      replies: replies,
    );
  }
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
