/// 兼容旧引用：原 `PostalPostmarkHeader` / `PostalPerforationStrip` 现位于
/// `widgets/postal/postal_painters.dart`。新代码请改用 `widgets/postal/postal.dart`。
library;

import 'package:flutter/material.dart';

import 'postal/postal_painters.dart';

export 'postal/postal_painters.dart' show PostalPerforationStrip;

/// 旧版本的顶部邮戳头，保留以避免破坏其他 import。
class PostalPostmarkHeader extends StatelessWidget {
  const PostalPostmarkHeader({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          right: 12,
          top: 8,
          child: IgnorePointer(
            child: PostmarkRing(
              size: 56,
              strokeWidth: 1.6,
              color: Colors.white.withValues(alpha: 0.32),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
