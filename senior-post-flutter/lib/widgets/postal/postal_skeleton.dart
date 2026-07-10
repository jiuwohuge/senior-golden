import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

/// 列表骨架屏：低对比纸感闪动。
class PostalSkeletonList extends StatefulWidget {
  const PostalSkeletonList({
    super.key,
    this.itemCount = 4,
    this.itemHeight = 130,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 20),

    /// 为 true 时用于嵌套在外层 [ListView] 等不可无限延展的滚动容器内，避免布局断言/白屏。
    this.shrinkWrap = false,
    this.physics,
  });

  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  State<PostalSkeletonList> createState() => _PostalSkeletonListState();
}

class _PostalSkeletonListState extends State<PostalSkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: widget.shrinkWrap,
      physics:
          widget.physics ??
          (widget.shrinkWrap ? const NeverScrollableScrollPhysics() : null),
      padding: widget.padding,
      itemCount: widget.itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final t = 0.5 + 0.4 * _ctrl.value;
            return Container(
              height: widget.itemHeight,
              decoration: BoxDecoration(
                color: PostalTokens.paperCard.withValues(alpha: t),
                borderRadius: PostalTokens.shapeMd,
                border: Border.all(
                  color: PostalTokens.perforationLine.withValues(alpha: 0.6),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class PostalSkeletonBlock extends StatelessWidget {
  const PostalSkeletonBlock({
    super.key,
    this.height = 16,
    this.width,
    this.radius = 6,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: PostalTokens.paperCard.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
