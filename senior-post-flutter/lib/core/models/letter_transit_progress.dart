import 'domain_models.dart';

/// Server-authoritative transit ratio. The client never derives progress from
/// wall-clock timestamps because those may be serialized without a zone.
double? letterTransitProgress(MailboxLetter letter) {
  switch (letter.status) {
    case LetterStatus.pending:
      return null;
    case LetterStatus.delivered:
    case LetterStatus.registered:
      return 1.0;
    case LetterStatus.matched:
    case LetterStatus.delivering:
      return letter.transitProgressRatio?.clamp(0.0, 1.0);
  }
}

bool letterIsWaitingForMatch(MailboxLetter letter) {
  return letter.status == LetterStatus.pending;
}

bool letterIsInTransit(MailboxLetter letter) {
  return letter.status == LetterStatus.delivering ||
      letter.status == LetterStatus.matched;
}
