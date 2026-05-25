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
      tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
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
      Rect.fromLTWH(
        notch,
        notch,
        size.width - notch * 2,
        size.height - notch * 2,
      ),
    );
    canvas.drawPath(dashPath, paintEdge);
  }

  @override
  bool shouldRepaint(covariant StampEdgePainter oldDelegate) => false;
}

/// 顶部细齿孔分隔条，暗示邮票齿边。
class PostalPerforationStrip extends StatelessWidget {
  const PostalPerforationStrip({super.key, this.color, this.height = 10});

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
  const PaperTextureBackground({super.key, required this.child, this.color});

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color ?? PostalTokens.paperCream),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _PaperNoisePainter()),
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

/// 聊天页信纸背景：暖色渐变 + 淡邮戳纹样 + 纸面噪点，营造复古信笺氛围。
class PostalChatBackground extends StatelessWidget {
  const PostalChatBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFAF6EE),
            PostalTokens.paperCream,
            PostalTokens.paperEnvelope,
          ],
          stops: [0.0, 0.42, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.85),
                  radius: 1.35,
                  colors: [
                    PostalTokens.postboxGreen.withValues(alpha: 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: CustomPaint(painter: _ChatStationeryPatternPainter()),
          ),
          IgnorePointer(child: CustomPaint(painter: _PaperNoisePainter())),
          child,
        ],
      ),
    );
  }
}

class _ChatStationeryPatternPainter extends CustomPainter {
  static const _motifs = <_StationeryMotif>[
    _StationeryMotif(0.10, 0.14, 52, _MotifKind.postmark, 0.22),
    _StationeryMotif(0.78, 0.08, 44, _MotifKind.postmark, 0.18),
    _StationeryMotif(0.88, 0.32, 38, _MotifKind.stamp, 0.16),
    _StationeryMotif(0.06, 0.48, 36, _MotifKind.stamp, 0.14),
    _StationeryMotif(0.72, 0.58, 48, _MotifKind.postmark, 0.15),
    _StationeryMotif(0.18, 0.72, 40, _MotifKind.envelope, 0.13),
    _StationeryMotif(0.84, 0.78, 34, _MotifKind.envelope, 0.12),
    _StationeryMotif(0.42, 0.22, 30, _MotifKind.stamp, 0.11),
    _StationeryMotif(0.52, 0.88, 46, _MotifKind.postmark, 0.13),
    _StationeryMotif(0.28, 0.38, 28, _MotifKind.envelope, 0.10),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _drawLaidPaperWatermark(canvas, size);
    for (final m in _motifs) {
      final center = Offset(m.x * size.width, m.y * size.height);
      switch (m.kind) {
        case _MotifKind.postmark:
          _drawPostmark(canvas, center, m.size, m.opacity);
        case _MotifKind.stamp:
          _drawStamp(canvas, center, m.size, m.opacity);
        case _MotifKind.envelope:
          _drawEnvelope(canvas, center, m.size, m.opacity);
      }
    }
    _drawCornerPerforations(canvas, size);
  }

  void _drawLaidPaperWatermark(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PostalTokens.kraftBrown.withValues(alpha: 0.035)
      ..strokeWidth = 0.8;
    const gap = 28.0;
    for (double y = -size.height; y < size.height * 2; y += gap) {
      canvas.drawLine(
        Offset(-size.width, y),
        Offset(size.width * 2, y + size.width * 0.55),
        paint,
      );
    }
  }

  void _drawPostmark(
    Canvas canvas,
    Offset center,
    double size,
    double opacity,
  ) {
    final color = PostalTokens.postboxGreen.withValues(alpha: opacity);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(center, size * 0.46, paint);
    canvas.drawCircle(center, size * 0.30, paint);
    final tickPaint = Paint()
      ..color = color
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    final innerR = size * 0.32;
    final outerR = size * 0.42;
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + 0.2;
      final p1 = center + Offset(math.cos(angle), math.sin(angle)) * innerR;
      final p2 = center + Offset(math.cos(angle), math.sin(angle)) * outerR;
      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  void _drawStamp(Canvas canvas, Offset center, double size, double opacity) {
    final rect = Rect.fromCenter(
      center: center,
      width: size * 0.72,
      height: size * 0.88,
    );
    final fill = Paint()
      ..color = PostalTokens.stampVermilion.withValues(alpha: opacity * 0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      fill,
    );
    final border = Paint()
      ..color = PostalTokens.stampVermilion.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      border,
    );
    final notchPaint = Paint()
      ..color = PostalTokens.paperCream.withValues(alpha: 0.85);
    const notchR = 2.2;
    const gap = 7.0;
    for (double x = rect.left + gap; x < rect.right; x += gap) {
      canvas.drawCircle(Offset(x, rect.top), notchR, notchPaint);
      canvas.drawCircle(Offset(x, rect.bottom), notchR, notchPaint);
    }
  }

  void _drawEnvelope(
    Canvas canvas,
    Offset center,
    double size,
    double opacity,
  ) {
    final w = size * 0.9;
    final h = size * 0.62;
    final rect = Rect.fromCenter(center: center, width: w, height: h);
    final fill = Paint()
      ..color = PostalTokens.postboxGreen.withValues(alpha: opacity * 0.4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      fill,
    );
    final border = Paint()
      ..color = PostalTokens.postboxGreen.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      border,
    );
    final flap = Path()
      ..moveTo(rect.left + 4, rect.top + 4)
      ..lineTo(center.dx, rect.top + h * 0.42)
      ..lineTo(rect.right - 4, rect.top + 4);
    canvas.drawPath(
      flap,
      Paint()
        ..color = PostalTokens.postboxGreen.withValues(alpha: opacity * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _drawCornerPerforations(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PostalTokens.perforationLine.withValues(alpha: 0.35);
    const r = 2.0;
    const cols = 5;
    const rowGap = 10.0;
    const colGap = 12.0;
    for (int c = 0; c < cols; c++) {
      canvas.drawCircle(Offset(8 + c * colGap, 6), r, paint);
      canvas.drawCircle(
        Offset(size.width - 8 - c * colGap, size.height - 6),
        r,
        paint,
      );
    }
    for (int row = 0; row < 4; row++) {
      canvas.drawCircle(Offset(6, 8 + row * rowGap), 2, paint);
      canvas.drawCircle(
        Offset(size.width - 6, size.height - 8 - row * rowGap),
        2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _MotifKind { postmark, stamp, envelope }

class _StationeryMotif {
  const _StationeryMotif(this.x, this.y, this.size, this.kind, this.opacity);

  final double x;
  final double y;
  final double size;
  final _MotifKind kind;
  final double opacity;
}
