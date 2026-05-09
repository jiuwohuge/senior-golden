import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/bootstrap/app_bootstrap.dart';
import '../../core/env/app_env.dart';
import '../../core/mock/mock_repository.dart';
import '../../widgets/postal/postal.dart';

class VipCenterPage extends ConsumerWidget {
  const VipCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(mockSessionProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final bootstrapAsync = ref.watch(appBootstrapProvider(lang));

    return Scaffold(
      appBar: AppBar(title: const Text('VIP center')),
      body: SafeArea(
        child: bootstrapAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Failed to load VIP info\n$e'),
            ),
          ),
          data: (bootstrap) {
            final v = bootstrap.vipProduct;
            final title = v.displayName;
            final subtitle = v.taglineForLanguage(lang);
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                PostalCardEnvelope(
                  header: PostalSectionTitle(
                    title: title,
                    subtitle: subtitle,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PostalStampBadge(
                        isVip: session.isVip,
                        balance: session.stampBalance,
                        cap: session.dailyStampCap,
                      ),
                      const SizedBox(height: 10),
                      if (v.unlimitedStampsBenefit)
                        Text(
                          lang.toLowerCase().startsWith('zh')
                              ? '• 会员寄挂号信不消耗邮票（以服务端规则为准）'
                              : '• Unlimited registered mail for members (server rules apply)',
                        ),
                      if (v.standardDeliveryHours > 0)
                        Text(
                          lang.toLowerCase().startsWith('zh')
                              ? '• 平邮优先：约 ${v.standardDeliveryHours} 小时内送达（配置项）'
                              : '• Standard mail priority: ~${v.standardDeliveryHours}h (configured)',
                        )
                      else
                        Text(
                          lang.toLowerCase().startsWith('zh')
                              ? '• 会员平邮加速免扣邮票（以服务端规则为准）'
                              : '• Free speed-up on standard mail for members (server rules apply)',
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (AppEnv.useMock)
                  PostalButton(
                    label: session.isVip ? 'Cancel VIP (mock)' : 'Activate VIP (mock)',
                    onPressed: () {
                      ref.read(mockSessionProvider.notifier).toggleVip();
                      PostalSnack.show(
                        context,
                        'Mock: VIP status changed',
                        tone: PostalSnackTone.success,
                      );
                    },
                  )
                else if (!v.productEnabled)
                  Text(
                    lang.toLowerCase().startsWith('zh')
                        ? 'VIP 购买入口已由运营关闭。'
                        : 'VIP purchase is currently disabled.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  Text(
                    lang.toLowerCase().startsWith('zh')
                        ? '订阅与支付尚未接入；会员权益以账号「VIP」标记为准。'
                        : 'Subscription checkout is not wired yet; benefits follow your account VIP flag.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
