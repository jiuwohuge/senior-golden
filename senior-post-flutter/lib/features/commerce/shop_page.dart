import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/biz_error_codes.dart';
import '../../core/session/app_session.dart';
import '../../widgets/postal/postal.dart';

/// 商品聚合页（静态阶段）：邮票说明、VIP 入口、邮票 SKU 占位，预留 API 接入点。
class ShopPage extends ConsumerWidget {
  const ShopPage({super.key, this.triggerBizCode, this.hint});

  final int? triggerBizCode;
  final String? hint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final mq = MediaQuery.sizeOf(context);
    final maxW = mq.width >= 600 ? 560.0 : double.infinity;

    // TODO(2026-Q2): 替换为 GET /api/commerce/catalog 等
    final stampSkus = <_StampSkuPlaceholder>[
      const _StampSkuPlaceholder(
        title: '邮票 · 直购',
        subtitle: '购买固定数量邮票，即时到账（支付流程接入后启用）',
        badge: '直购',
        stamps: 10,
      ),
      const _StampSkuPlaceholder(
        title: '邮票 · 礼包',
        subtitle: '组合商品附赠邮票，适合长期写信用户',
        badge: '礼包',
        stamps: 30,
      ),
      const _StampSkuPlaceholder(
        title: '限时 · 赠票',
        subtitle: '活动期购买指定商品可获赠邮票（规则以运营配置为准）',
        badge: '活动',
        stamps: 5,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('邮票与会员')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  children: [
                    if (triggerBizCode != null ||
                        (hint != null && hint!.isNotEmpty))
                      _ContextBanner(code: triggerBizCode, hint: hint),
                    PostalCardEnvelope(
                      header: const PostalSectionTitle(
                        title: '邮票从哪来',
                        subtitle: '以下说明为当前产品规则摘要，细则以服务端配置为准',
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _bullet(context, '每日可领取或累积一定额度邮票（见个人中心邮票徽章）。'),
                          _bullet(
                            context,
                            '挂号信、平邮加速、提前拆信等会消耗邮票；会员可按规则减免或享受直达邮路。',
                          ),
                          _bullet(context, '后续将支持应用内购买邮票包、活动赠票及第三方合规支付渠道。'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    PostalCardEnvelope(
                      accent: PostalTokens.postboxGreen,
                      header: PostalSectionTitle(
                        title: '会员 · VIP',
                        subtitle: session.isVip
                            ? '您已是会员，可继续查看权益说明'
                            : '开通会员可获得更多邮政能力与邮票权益',
                        trailing: session.isVip
                            ? Icon(
                                Icons.verified_rounded,
                                color: PostalTokens.postboxGreen,
                                size: 28,
                              )
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '会员权益由服务端配置（如挂号信减免、平邮加速等），'
                            '支付与签约流程接入后将在此页或独立收银台完成。',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: PostalTokens.inkSecondary,
                                  height: 1.45,
                                ),
                          ),
                          const SizedBox(height: 14),
                          PostalButton(
                            label: session.isVip ? '查看会员中心' : '前往会员中心',
                            onPressed: () => context.push('/profile/vip'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '邮票商品',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '以下为静态占位卡片；商品 ID、价格、库存将由商品系统 API 下发并渲染。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PostalTokens.inkTertiary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...stampSkus.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _StampSkuCard(sku: s),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {
                        // TODO: 对账 / 订单列表页
                        PostalSnack.show(
                          context,
                          '订单与支付记录：待商品系统接入后开放',
                          tone: PostalSnackTone.info,
                        );
                      },
                      child: const Text('订单与记录（占位）'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget _bullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: PostalTokens.stampVermilion,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextBanner extends StatelessWidget {
  const _ContextBanner({this.code, this.hint});

  final int? code;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final lines = <String>[];
    if (code == BizErrorCodes.stampInsufficient) {
      lines.add('当前操作需要更多邮票，您可在下方选择购买方式或开通会员。');
    } else if (code == BizErrorCodes.vipRequired) {
      lines.add('该功能需要会员身份，请前往会员中心了解开通方式。');
    } else if (code != null) {
      lines.add('业务提示（代码 $code）');
    }
    if (hint != null && hint!.isNotEmpty) {
      lines.add(hint!);
    }
    if (lines.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: PostalTokens.stampVermilionMuted,
        borderRadius: PostalTokens.shapeMd,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.local_post_office_rounded,
                color: PostalTokens.stampVermilion,
                size: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  lines.join('\n'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PostalTokens.inkNavy,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StampSkuPlaceholder {
  const _StampSkuPlaceholder({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.stamps,
  });

  final String title;
  final String subtitle;
  final String badge;
  final int stamps;
}

class _StampSkuCard extends StatelessWidget {
  const _StampSkuCard({required this.sku});

  final _StampSkuPlaceholder sku;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PostalTokens.paperCard,
        borderRadius: PostalTokens.shapeMd,
        border: Border.all(color: PostalTokens.perforationLine),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: PostalTokens.postboxGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: PostalTokens.postboxGreen.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    sku.badge,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: PostalTokens.postboxGreen,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '×${sku.stamps} 邮票',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              sku.title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              sku.subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PostalTokens.inkSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '价格：—',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PostalTokens.inkTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: () {
                    // TODO: POST /api/commerce/checkout 或唤起收银台
                    PostalSnack.show(
                      context,
                      '收银台：待商品与支付网关接入',
                      tone: PostalSnackTone.info,
                    );
                  },
                  child: const Text('购买（占位）'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
