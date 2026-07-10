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

  /// Legacy topic key (unused for POST_OFFICE).
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
