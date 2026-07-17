import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../models/domain_models.dart';

/// 后端未配对时常返回 `?` / `unknown` / id=0；此类占位不应直接展示给用户。
bool isUnresolvedLetterPeer(AppUser peer) {
  final id = int.tryParse(peer.id) ?? 0;
  if (id <= 0) return true;
  final n = peer.nickname.trim().toLowerCase();
  return n.isEmpty ||
      n == '?' ||
      n == 'unknown' ||
      n == 'user' ||
      n == '未知' ||
      n == '未知收件人';
}

/// 信件对端展示名：真实昵称，或「推荐中」等友好占位。
String letterPeerDisplayTitle({
  required AppLocalizations l10n,
  required AppUser peer,
  LetterMode? mode,
}) {
  if (!isUnresolvedLetterPeer(peer)) {
    return peer.nickname.trim();
  }
  // 邮局在途未配对：强调「正在为你找有缘人」，避免技术词。
  if (mode == LetterMode.postOffice || mode == null) {
    return l10n.letterPeerRecommending;
  }
  return l10n.letterPeerUnknown;
}
