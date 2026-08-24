import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/i18n/postal_format.dart';

/// In-transit track plus a locale percent, so progress is readable, not only a line.
class PostalDeliveryProgress extends StatelessWidget {
  const PostalDeliveryProgress({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 18,
            width: double.infinity,
            child: CustomPaint(
              painter: _DeliveryTrackPainter(progress: clamped),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          PostalFormat.percent(context, clamped),
          style: theme.textTheme.titleSmall?.copyWith(
            color: PostalTokens.postboxGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DeliveryTrackPainter extends CustomPainter {
  const _DeliveryTrackPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    const inset = 7.0;
    final start = Offset(inset, cy);
    final end = Offset(size.width - inset, cy);
    final pos = Offset(
      start.dx + (end.dx - start.dx) * progress,
      cy,
    );

    final rail = Paint()
      ..color = PostalTokens.kraftBrownMuted
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, rail);

    if (progress > 0) {
      final flown = Paint()
        ..color = PostalTokens.postboxGreen
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(start, pos, flown);
    }

    final node = Paint()..color = PostalTokens.kraftBrown;
    canvas.drawCircle(start, 3.2, node);
    canvas.drawCircle(end, 3.2, node..color = PostalTokens.postboxGreenMuted);

    canvas.drawCircle(pos, 6.2, Paint()..color = PostalTokens.stampVermilion);
    canvas.drawCircle(
      pos,
      3.2,
      Paint()..color = PostalTokens.paperEnvelope,
    );
  }

  @override
  bool shouldRepaint(covariant _DeliveryTrackPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
