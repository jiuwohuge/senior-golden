import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

/// 邮戳同心圆 + 弧文，用于品牌头部装饰。
class PostmarkRing extends StatelessWidget {
  const PostmarkRing({
    super.key,
    this.size = 56,
    this.color,
    this.strokeWidth = 2,
    this.year,
  });

  final double size;
  final Color? color;
  final double strokeWidth;
  final String? year;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _PostmarkRingPainter(
          color: color ?? Colors.white.withValues(alpha: 0.32),
          strokeWidth: strokeWidth,
          year: year,
        ),
      ),
    );
  }
}

class _PostmarkRingPainter extends CustomPainter {
  _PostmarkRingPainter({
    required this.color,
    required this.strokeWidth,
    this.year,
  });

  final Color color;
  final double strokeWidth;
  final String? year;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, size.width * 0.46, paint);
    canvas.drawCircle(center, size.width * 0.34, paint);

    if (year != null) {
      final tp = TextPainter(
        text: TextSpan(
          text: year,
          style: TextStyle(
            color: color,
            fontSize: size.width * 0.18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        center - Offset(tp.width / 2, tp.height / 2),
      );
    }

    final tickPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth * 0.8
      ..strokeCap = StrokeCap.round;
    final innerR = size.width * 0.36;
    final outerR = size.width * 0.44;
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final p1 = center + Offset(math.cos(angle), math.sin(angle)) * innerR;
      final p2 = center + Offset(math.cos(angle), math.sin(angle)) * outerR;
      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PostmarkRingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.year != year;
}

/// 邮票齿边：在矩形外缘绘制半圆切口，需要配合宿主裁剪一起使用。
class StampEdgePainter extends CustomPainter {
  StampEdgePainter({
    this.color = PostalTokens.paperEnvelope,
    this.notch = 6,
    this.gap = 14,
  });

  final Color color;
  final double notch;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final paintEdge = Paint()
      ..color = PostalTokens.perforationLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(Offset.zero & size, paint);

    final r = notch / 2;
    final cutPaint = Paint()..color = Colors.transparent;
    cutPaint.blendMode = BlendMode.clear;

    void cut(double x, double y) {
      canvas.drawCircle(Offset(x, y), r, cutPaint);
    }

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, paint);

    for (double x = gap; x < size.width; x += gap) {
      cut(x, 0);
      cut(x, size.height);
    }
    for (double y = gap; y < size.height; y += gap) {
      cut(0, y);
      cut(size.width, y);
    }
    canvas.restore();

    final dashPath = Path();
    dashPath.addRect(
      Rect.fromLTWH(notch, notch, size.width - notch * 2, size.height - notch * 2),
    );
    canvas.drawPath(dashPath, paintEdge);
  }

  @override
  bool shouldRepaint(covariant StampEdgePainter oldDelegate) => false;
}

/// 顶部细齿孔分隔条，暗示邮票齿边。
class PostalPerforationStrip extends StatelessWidget {
  const PostalPerforationStrip({
    super.key,
    this.color,
    this.height = 10,
  });

  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _PerforationPainter(
        color: color ?? PostalTokens.perforationLine.withValues(alpha: 0.9),
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

/// 平铺纸面纹理（极淡的牛皮纸点状噪声）。
class PaperTextureBackground extends StatelessWidget {
  const PaperTextureBackground({
    super.key,
    required this.child,
    this.color,
  });

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? PostalTokens.paperCream,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _PaperNoisePainter(),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _PaperNoisePainter extends CustomPainter {
  _PaperNoisePainter();
  static final _rng = math.Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PostalTokens.kraftBrown.withValues(alpha: 0.05);
    const step = 18.0;
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        final dx = x + _rng.nextDouble() * step;
        final dy = y + _rng.nextDouble() * step;
        canvas.drawCircle(Offset(dx, dy), 0.6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
