/// Unified letter compose destination for 3.0 slow-social flows.
enum ComposeKind {
  /// Time letter to the signed-in user.
  selfTimeLetter,

  /// Postal letter (standard/registered) to a pen pal.
  penPalMail,

  /// Time letter to an established pen pal.
  penPalTimeLetter,

  /// Topic mailbox submission (currently maps to postcard create API).
  topicMailbox,
}

/// Navigation payload for [ComposeFlowPage].
class ComposeIntent {
  const ComposeIntent({
    this.kind,
    this.peerId,
    this.peerNickname,
    this.peerCountryLabel,
    this.topicKey,
  });

  /// When null, the flow starts with a destination picker.
  final ComposeKind? kind;
  final String? peerId;
  final String? peerNickname;
  final String? peerCountryLabel;

  /// One of [TopicMailboxCatalog] keys: hometown, retirement, oldPhoto.
  final String? topicKey;

  ComposeIntent copyWith({
    ComposeKind? kind,
    String? peerId,
    String? peerNickname,
    String? peerCountryLabel,
    String? topicKey,
  }) {
    return ComposeIntent(
      kind: kind ?? this.kind,
      peerId: peerId ?? this.peerId,
      peerNickname: peerNickname ?? this.peerNickname,
      peerCountryLabel: peerCountryLabel ?? this.peerCountryLabel,
      topicKey: topicKey ?? this.topicKey,
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
