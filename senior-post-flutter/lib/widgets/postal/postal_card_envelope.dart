import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

/// 信封卡片：邮票区 + 邮戳 + 内容；用于明信片墙 / 名录 / 信箱列表统一观感。
class PostalCardEnvelope extends StatelessWidget {
  const PostalCardEnvelope({
    super.key,
    required this.child,
    this.header,
    this.footer,
    this.padding = const EdgeInsets.fromLTRB(
      PostalTokens.s20,
      PostalTokens.s16,
      PostalTokens.s20,
      PostalTokens.s16,
    ),
    this.onTap,
    this.accent = PostalTokens.stampVermilion,
    this.backgroundColor,
  });

  final Widget child;
  final Widget? header;
  final Widget? footer;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color accent;

  /// 信纸底色（读信页按 skinId 覆盖默认信封色）。
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    // Ink 与 ListTile/SwitchListTile 共用同一个 Material 表面，确保背景、
    // hover、focus 和点击水波纹都绘制在卡片之上。
    final content = Ink(
      decoration: BoxDecoration(
        color: backgroundColor ?? PostalTokens.paperEnvelope,
        borderRadius: PostalTokens.shapeMd,
        border: Border.all(color: PostalTokens.perforationLine),
        boxShadow: PostalTokens.shadowSoft,
      ),
      child: ClipRRect(
        borderRadius: PostalTokens.shapeMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    accent,
                    accent.withValues(alpha: 0.7),
                    PostalTokens.stampGold.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            if (header != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PostalTokens.s20,
                  PostalTokens.s16,
                  PostalTokens.s20,
                  PostalTokens.s8,
                ),
                child: header,
              ),
            Padding(padding: padding, child: child),
            if (footer != null)
              Container(
                padding: const EdgeInsets.fromLTRB(
                  PostalTokens.s20,
                  PostalTokens.s12,
                  PostalTokens.s20,
                  PostalTokens.s16,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: PostalTokens.perforationLine,
                      width: 1,
                    ),
                  ),
                ),
                child: footer,
              ),
          ],
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      borderRadius: PostalTokens.shapeMd,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: PostalTokens.shapeMd,
              child: content,
            ),
    );
  }
}
