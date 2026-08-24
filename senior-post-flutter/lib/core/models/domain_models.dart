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
    this.relationDisplayState,
    this.recommendReason,
    this.letterCount = 0,
    this.emailVerified = false,
    this.language,
    this.city,
    this.latitude,
    this.longitude,
    this.writingStyle,
    this.firstLetterDone,
    this.bound = false,
    this.bindProvider,
    this.signupChannel,
    this.canBind = false,
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

  final RelationDisplayState? relationDisplayState;
  final String? recommendReason;
  final int letterCount;

  /// 邮箱是否已验证绑定（仅邮箱账号有意义）
  final bool emailVerified;

  /// 用户语言标签，如 zh-CN
  final String? language;

  final String? city;
  final double? latitude;
  final double? longitude;

  /// concise | narrative | emotional
  final String? writingStyle;

  /// 是否已完成 §2.8 首封信引导（null 视为未完成）
  final bool? firstLetterDone;

  /// 是否已绑定邮箱/Google 身份。
  final bool bound;

  /// 登录身份提供方：`email` | `google`，未绑定为 null。
  final String? bindProvider;

  /// 开户方式：`guest` | `email` | `google`。
  final String? signupChannel;

  /// 是否允许绑定或更换登录方式（仅 guest 开户）。
  final bool canBind;

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
      relationDisplayState: RelationDisplayState.fromCode(
        (m['relationDisplayState'] as num?)?.toInt(),
      ),
      recommendReason: m['recommendReason'] as String?,
      letterCount: (m['letterCount'] as num?)?.toInt() ?? 0,
      emailVerified: m['emailVerified'] as bool? ?? false,
      language: m['language'] as String?,
      city: m['city'] as String?,
      latitude: (m['latitude'] as num?)?.toDouble(),
      longitude: (m['longitude'] as num?)?.toDouble(),
      writingStyle: m['writingStyle'] as String?,
      firstLetterDone: m['firstLetterDone'] as bool?,
      bound: m['bound'] as bool? ??
          ((m['email'] as String?)?.trim().isNotEmpty == true),
      bindProvider: m['bindProvider'] as String?,
      signupChannel: m['signupChannel'] as String?,
      canBind: m['canBind'] as bool? ?? false,
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
    bool? firstLetterDone,
    bool? bound,
    String? email,
    String? bindProvider,
    String? signupChannel,
    bool? canBind,
  }) {
    return AppUser(
      id: id,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
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
      firstLetterDone: firstLetterDone ?? this.firstLetterDone,
      bound: bound ?? this.bound,
      bindProvider: bindProvider ?? this.bindProvider,
      signupChannel: signupChannel ?? this.signupChannel,
      canBind: canBind ?? this.canBind,
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

/// PRD §10.3 关系展示态（与后端 RelationDisplayState 整型对齐）
enum RelationDisplayState {
  stranger(1),
  contacting(2),
  canAddPenpal(3),
  pendingOut(4),
  pendingIn(5),
  penpal(6);

  const RelationDisplayState(this.code);
  final int code;

  static RelationDisplayState? fromCode(int? code) {
    if (code == null) return null;
    for (final v in values) {
      if (v.code == code) return v;
    }
    return null;
  }
}

class PenpalListItem {
  const PenpalListItem({
    required this.peerUserId,
    required this.nickname,
    this.avatarUrl,
    this.countryCode,
    this.letterCount = 0,
    this.penpalDays = 0,
    this.penpalSince,
  });

  final String peerUserId;
  final String nickname;
  final String? avatarUrl;
  final String? countryCode;
  final int letterCount;
  final int penpalDays;
  final DateTime? penpalSince;
}

class RelationSnapshot {
  const RelationSnapshot({
    required this.peerUserId,
    required this.displayState,
    this.letterCount = 0,
    this.canAddPenpal = false,
    this.pendingRequestId,
    this.penpal = false,
  });

  final String peerUserId;
  final RelationDisplayState displayState;
  final int letterCount;
  final bool canAddPenpal;
  final String? pendingRequestId;
  final bool penpal;
}

class PostOfficeRelationMessage {
  const PostOfficeRelationMessage({
    required this.messageType,
    this.requestId,
    required this.peer,
    this.letterCount = 0,
    this.canAddPenpal = false,
  });

  final int messageType;
  final String? requestId;
  final AppUser peer;
  final int letterCount;
  final bool canAddPenpal;
}

class ProfileOverview {
  const ProfileOverview({
    this.penpalCount = 0,
    this.letterCount = 0,
    this.timeLetterCount = 0,
  });

  final int penpalCount;
  final int letterCount;
  final int timeLetterCount;
}

enum LetterType { registered, standard }

enum LetterStatus { pending, delivering, delivered, registered, matched }

enum LetterSendMode { standardPost, registeredMail, directVip }

/// PRD letter mode: 1 POST_OFFICE / 2 DIRECT / 3 SELF_TIME
enum LetterMode { postOffice, direct, selfTime }

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
    this.transitProgressRatio,
    this.mode = LetterMode.direct,
    this.auditStatus = 1,
    this.relationDisplayState,
    this.canAddPenpal = false,
    this.recipientRead = false,
    this.fromCountryName,
    this.toCountryName,
    this.postmarkLabel,
    this.skinId,
    this.fontId,
    this.fontSizeTier,
    this.favorited = false,
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
  /// 服务端统一计算的运输进度（0.0～1.0）。
  final double? transitProgressRatio;
  final LetterMode mode;
  final int auditStatus;
  final RelationDisplayState? relationDisplayState;
  final bool canAddPenpal;
  final bool recipientRead;
  final String? fromCountryName;
  final String? toCountryName;
  final String? postmarkLabel;
  final String? skinId;
  final String? fontId;
  /// 字号档 API 值：large | xlarge；空则读信侧按 large。
  final String? fontSizeTier;
  final bool favorited;
}

/// 商店商品，对齐 `CommerceProductVO`。
class CommerceProduct {
  const CommerceProduct({
    required this.id,
    required this.productCode,
    required this.productType,
    required this.titleKey,
    required this.priceCents,
    this.metadata = const {},
    this.sortOrder = 0,
    this.owned = false,
  });

  final String id;
  final String productCode;
  final String productType;
  final String titleKey;
  final int priceCents;
  final Map<String, dynamic> metadata;
  final int sortOrder;
  final bool owned;

  String? get skinId => metadata['skinId'] as String?;
  String? get fontId => metadata['fontId'] as String?;
  String? get templateId => metadata['templateId'] as String?;

  /// 写信模板段落（来自 commerce metadata.paragraphs）
  List<String> get paragraphs {
    final raw = metadata['paragraphs'];
    if (raw is! List) return const [];
    return raw
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}

/// 用户商业权益，对齐 `CommerceEntitlementVO`。
class CommerceEntitlement {
  const CommerceEntitlement({
    required this.entitlementId,
    required this.productId,
    required this.productCode,
    required this.productType,
    required this.titleKey,
    this.source,
    this.expiresAt,
    this.grantedAt,
  });

  final String entitlementId;
  final String productId;
  final String productCode;
  final String productType;
  final String titleKey;
  final String? source;
  final DateTime? expiresAt;
  final DateTime? grantedAt;
}

/// 普通信件草稿，对齐 `LetterDraftVO`。
class LetterDraft {
  const LetterDraft({
    required this.id,
    required this.mode,
    this.toUserId,
    this.content = '',
    this.letterType = LetterType.standard,
    this.topicTagId,
    this.deliveryDate,
    this.updatedAt,
  });

  final String id;
  final String mode;
  final String? toUserId;
  final String content;
  final LetterType letterType;
  final int? topicTagId;
  final DateTime? deliveryDate;
  final DateTime? updatedAt;
}

/// 隐私与通知偏好，对齐 `UserPreferencesVO`。
class UserPreferences {
  const UserPreferences({
    this.hideRecommendations = false,
    this.rejectStrangerMail = false,
    this.pushEnabled = true,
    this.unreadBadges = true,
  });

  final bool hideRecommendations;
  final bool rejectStrangerMail;
  final bool pushEnabled;
  final bool unreadBadges;

  UserPreferences copyWith({
    bool? hideRecommendations,
    bool? rejectStrangerMail,
    bool? pushEnabled,
    bool? unreadBadges,
  }) {
    return UserPreferences(
      hideRecommendations: hideRecommendations ?? this.hideRecommendations,
      rejectStrangerMail: rejectStrangerMail ?? this.rejectStrangerMail,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      unreadBadges: unreadBadges ?? this.unreadBadges,
    );
  }
}

/// 信件导出结果，对齐 `LetterExportResultVO`。
class LetterExportResult {
  const LetterExportResult({this.downloadUrl});

  final String? downloadUrl;
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
