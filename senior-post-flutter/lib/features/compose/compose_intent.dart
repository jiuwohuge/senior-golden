/// Unified letter compose destination for 4.0 slow-social flows.
enum ComposeKind {
  /// Time letter to the signed-in user (SELF_TIME / bu_time_letter).
  selfTimeLetter,

  /// Postal letter (DIRECT) to a pen pal / peer.
  penPalMail,

  /// Time letter to an established pen pal.
  penPalTimeLetter,

  /// Post office pool letter (POST_OFFICE, no recipient; match in M3).
  postOffice,
}

/// Navigation payload for [ComposeFlowPage]（单页写信桌）.
class ComposeIntent {
  const ComposeIntent({
    this.kind,
    this.peerId,
    this.peerNickname,
    this.peerCountryLabel,
    this.topicKey,
    this.initialParagraphs,
    this.templateId,
    this.parentLetterId,
    this.draftId,
    this.topicTagId,
    this.deliveryDate,
  });

  /// When null, the flow starts with a destination picker.
  final ComposeKind? kind;
  final String? peerId;
  final String? peerNickname;
  final String? peerCountryLabel;

  /// Legacy topic key (unused for POST_OFFICE).
  final String? topicKey;

  /// 预填段落（模板）。
  final List<String>? initialParagraphs;
  final String? templateId;

  /// 回信时带上父信 id，用于线程关联。
  final String? parentLetterId;

  /// 从草稿列表继续写时带回已有草稿 id，静默保存会覆盖同一条。
  final String? draftId;

  /// 草稿还原的主题邮票 sys_tag.id。
  final int? topicTagId;

  /// 时光信草稿还原的送达日。
  final DateTime? deliveryDate;

  ComposeIntent copyWith({
    ComposeKind? kind,
    String? peerId,
    String? peerNickname,
    String? peerCountryLabel,
    String? topicKey,
    List<String>? initialParagraphs,
    String? templateId,
    String? parentLetterId,
    String? draftId,
    int? topicTagId,
    DateTime? deliveryDate,
  }) {
    return ComposeIntent(
      kind: kind ?? this.kind,
      peerId: peerId ?? this.peerId,
      peerNickname: peerNickname ?? this.peerNickname,
      peerCountryLabel: peerCountryLabel ?? this.peerCountryLabel,
      topicKey: topicKey ?? this.topicKey,
      initialParagraphs: initialParagraphs ?? this.initialParagraphs,
      templateId: templateId ?? this.templateId,
      parentLetterId: parentLetterId ?? this.parentLetterId,
      draftId: draftId ?? this.draftId,
      topicTagId: topicTagId ?? this.topicTagId,
      deliveryDate: deliveryDate ?? this.deliveryDate,
    );
  }

  /// Maps legacy `/time-letter/compose` extras.
  factory ComposeIntent.fromLegacyTimeLetterExtra(Map<dynamic, dynamic> extra) {
    final toSelf = extra['toSelf'] == true;
    if (toSelf) {
      return const ComposeIntent(kind: ComposeKind.selfTimeLetter);
    }
    return ComposeIntent(
      kind: ComposeKind.penPalTimeLetter,
      peerId: extra['recipientId'] as String?,
      peerNickname: extra['recipientNickname'] as String?,
    );
  }
}
