import 'package:flutter/material.dart';

import '../app/theme/postal_tokens.dart';

/// 顶部「邮戳」装饰圆环 + 齿孔条，强化邮政世界观且不干扰可读性。
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
            child: CustomPaint(
              size: const Size(56, 56),
              painter: _PostmarkRingPainter(
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _PostmarkRingPainter extends CustomPainter {
  _PostmarkRingPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, size.width * 0.38, paint);
    canvas.drawCircle(center, size.width * 0.28, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 内容区顶部细齿孔分隔，暗示邮票齿边。
class PostalPerforationStrip extends StatelessWidget {
  const PostalPerforationStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 10),
      painter: _PerforationPainter(
        color: PostalTokens.perforationLine.withValues(alpha: 0.9),
      ),
    );
  }
}

class _PerforationPainter extends CustomPainter {
  _PerforationPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const gap = 7.0;
    final paint = Paint()..color = color;
    for (double x = 0; x < size.width; x += gap) {
      canvas.drawCircle(Offset(x + gap / 2, size.height / 2), 1.8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
