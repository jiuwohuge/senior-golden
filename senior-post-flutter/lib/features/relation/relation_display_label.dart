import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../core/models/domain_models.dart';

String relationDisplayLabel(AppLocalizations l10n, RelationDisplayState state) {
  return switch (state) {
    RelationDisplayState.stranger => l10n.relationStateStranger,
    RelationDisplayState.contacting => l10n.relationStateContacting,
    RelationDisplayState.canAddPenpal => l10n.relationStateCanAddPenpal,
    RelationDisplayState.pendingOut => l10n.relationStatePendingOut,
    RelationDisplayState.pendingIn => l10n.relationStatePendingIn,
    RelationDisplayState.penpal => l10n.relationStatePenpal,
  };
}
