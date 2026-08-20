import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import 'directory_page.dart';
import 'directory_providers.dart';

/// 信箱内「我的笔友」：只展示已有关系，不含推荐/找笔友。
class MyPenpalsPage extends ConsumerWidget {
  const MyPenpalsPage({super.key});

  static const path = '/mailbox/penpals';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: PostalTokens.paperCream,
      appBar: AppBar(title: Text(l10n.mailboxMyPenpals)),
      body: MyPenpalsList(
        onRefresh: () async {
          ref.invalidate(myPenpalsProvider);
          await ref.read(myPenpalsProvider.future);
        },
      ),
    );
  }
}
