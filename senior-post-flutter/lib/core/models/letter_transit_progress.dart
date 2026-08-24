import 'domain_models.dart';

/// Client-side transit ratio from sent time → expected arrival.
/// Matching / pending letters have no route yet, so this returns null.
double? letterTransitProgress(
  MailboxLetter letter, {
  DateTime? now,
}) {
  switch (letter.status) {
    case LetterStatus.pending:
      return null;
    case LetterStatus.delivered:
    case LetterStatus.registered:
      return 1.0;
    case LetterStatus.matched:
    case LetterStatus.delivering:
      break;
  }
  final eta = letter.expectedArrivalAt;
  if (eta == null) {
    return null;
  }
  final clock = now ?? DateTime.now();
  final total = eta.difference(letter.sentAt).inMinutes;
  if (total <= 0) {
    return 1.0;
  }
  final done = clock.difference(letter.sentAt).inMinutes;
  return (done / total).clamp(0.0, 1.0);
}

bool letterIsWaitingForMatch(MailboxLetter letter) {
  return letter.status == LetterStatus.pending;
}

bool letterIsInTransit(MailboxLetter letter) {
  return letter.status == LetterStatus.delivering ||
      letter.status == LetterStatus.matched;
}
