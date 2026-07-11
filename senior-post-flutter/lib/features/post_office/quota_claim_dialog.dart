import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../widgets/postal/postal_button.dart';
import '../../widgets/postal/postal_snack.dart';
import 'post_office_remote.dart';

/// 每日免费额度领取：不可关闭；领取成功后刷新 [postOfficeHomeProvider]。
///
/// 产品顺序：注册/每日首次 → 领取额度 → 再写首封信（未领取发信会被服务端拦截）。
Future<bool> showDailyQuotaClaimDialog({
  required BuildContext context,
  required WidgetRef ref,
  required int dailyLetterQuota,
}) async {
  final l10n = AppLocalizations.of(context)!;
  var claiming = false;
  var claimed = false;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dlgCtx) {
      return StatefulBuilder(
        builder: (ctx, setLocal) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              icon: Icon(
                Icons.card_giftcard_outlined,
                color: PostalTokens.postboxGreen,
                size: 48,
              ),
              title: Text(l10n.quotaClaimTitle),
              content: Text(l10n.quotaClaimMessage(dailyLetterQuota)),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                // expand:false 避免 Dialog actions 零尺寸 hit-test 灰屏。
                SizedBox(
                  width: 260,
                  child: PostalButton(
                    label: l10n.quotaClaimButton,
                    expand: false,
                    busy: claiming,
                    onPressed: claiming
                        ? null
                        : () async {
                            setLocal(() => claiming = true);
                            try {
                              await ref
                                  .read(postOfficeRemoteRepositoryProvider)
                                  .claimDailyQuota();
                              claimed = true;
                              ref.invalidate(postOfficeHomeProvider);
                              if (dlgCtx.mounted) {
                                Navigator.of(dlgCtx).pop();
                              }
                            } catch (e) {
                              final biz = apiBusinessExceptionFrom(e);
                              if (ctx.mounted) {
                                PostalSnack.show(
                                  ctx,
                                  biz?.message ?? e.toString(),
                                  tone: PostalSnackTone.error,
                                );
                              }
                              setLocal(() => claiming = false);
                            }
                          },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
  return claimed;
}
