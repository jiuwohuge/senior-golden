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
    this.fromFirstLetterGuide = false,
    this.initialParagraphs,
    this.templateId,
  });

  /// When null, the flow starts with a destination picker.
  final ComposeKind? kind;
  final String? peerId;
  final String? peerNickname;
  final String? peerCountryLabel;

  /// Legacy topic key (unused for POST_OFFICE).
  final String? topicKey;

  /// 来自首封信引导：正文步展示模板提示。
  final bool fromFirstLetterGuide;

  /// 预填段落（模板）。
  final List<String>? initialParagraphs;
  final String? templateId;

  ComposeIntent copyWith({
    ComposeKind? kind,
    String? peerId,
    String? peerNickname,
    String? peerCountryLabel,
    String? topicKey,
    bool? fromFirstLetterGuide,
    List<String>? initialParagraphs,
    String? templateId,
  }) {
    return ComposeIntent(
      kind: kind ?? this.kind,
      peerId: peerId ?? this.peerId,
      peerNickname: peerNickname ?? this.peerNickname,
      peerCountryLabel: peerCountryLabel ?? this.peerCountryLabel,
      topicKey: topicKey ?? this.topicKey,
      fromFirstLetterGuide:
          fromFirstLetterGuide ?? this.fromFirstLetterGuide,
      initialParagraphs: initialParagraphs ?? this.initialParagraphs,
      templateId: templateId ?? this.templateId,
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
