import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/postal_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/postal/postal_painters.dart';

/// 寄信成功仪式：邮戳盖上 → 信封落入邮筒口。
///
/// 不用 Opacity / 模糊阴影做位移动画，避免模拟器与中低端机掉帧。
Future<void> showDeliverySentOverlay(
  BuildContext context, {
  String? destinationLabel,
}) {
  return showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    barrierColor: PostalTokens.inkNavy.withValues(alpha: 0.48),
    transitionDuration: Duration.zero,
    pageBuilder: (ctx, _, __) {
      return _DeliverySentOverlay(
        destinationLabel: destinationLabel,
        onDone: () => Navigator.of(ctx).pop(),
      );
    },
  );
}

class _DeliverySentOverlay extends StatefulWidget {
  const _DeliverySentOverlay({required this.onDone, this.destinationLabel});

  final VoidCallback onDone;
  final String? destinationLabel;

  @override
  State<_DeliverySentOverlay> createState() => _DeliverySentOverlayState();
}

class _DeliverySentOverlayState extends State<_DeliverySentOverlay>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1320);

  late final AnimationController _ctrl;
  var _didStampHaptic = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _duration);
    _ctrl.addListener(_onTick);
    WidgetsBinding.instance.addPostFrameCallback((_) => _play());
  }

  Future<void> _play() async {
    if (!mounted) return;
    // 系统「减少动态效果」时只停留静态盖戳画面，避免无意义的掉帧动画。
    if (MediaQuery.disableAnimationsOf(context)) {
      _ctrl.value = 1;
      await Future<void>.delayed(const Duration(milliseconds: 720));
      if (mounted) widget.onDone();
      return;
    }
    await _ctrl.forward();
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (mounted) widget.onDone();
  }

  void _onTick() {
    if (_didStampHaptic || _ctrl.value < 0.28) return;
    _didStampHaptic = true;
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTick);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dest = widget.destinationLabel?.trim();
    final year = DateTime.now().year.toString();

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.ritualDeliverySent,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: PostalTokens.paperCream,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: PostalTokens.s20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stageWidth = constraints.maxWidth.clamp(240.0, 340.0);
                    final stageHeight = 268 * stageWidth / 340;
                    return SizedBox(
                      height: stageHeight,
                      width: stageWidth,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: 340,
                          height: 268,
                          child: AnimatedBuilder(
                            animation: _ctrl,
                            builder: (context, _) {
                              final t = _ctrl.value;
                              final appear = Interval(
                                0,
                                0.18,
                                curve: Curves.easeOutCubic,
                              ).transform(t);
                              final stamp = Interval(
                                0.16,
                                0.4,
                                curve: Curves.easeOutBack,
                              ).transform(t);
                              final boxIn = Interval(
                                0.46,
                                0.62,
                                curve: Curves.easeOutCubic,
                              ).transform(t);
                              final drop = Interval(
                                0.58,
                                0.94,
                                curve: Curves.easeInCubic,
                              ).transform(t);

                              return Stack(
                                alignment: Alignment.topCenter,
                                clipBehavior: Clip.hardEdge,
                                children: [
                                  Positioned(
                                    left: 36,
                                    right: 36,
                                    bottom: 0,
                                    child: Transform.translate(
                                      offset: Offset(0, (1 - boxIn) * 18),
                                      child: _PostboxSlot(progress: boxIn),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: Offset(0, drop * 168),
                                    child: Transform.rotate(
                                      angle: drop * 0.08,
                                      child: Transform.scale(
                                        scale: 0.9 + appear * 0.1,
                                        child: RepaintBoundary(
                                          child: _LetterPacket(
                                            destination: dest,
                                            year: year,
                                            stamp: stamp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 信封本体 + 收件行 + 盖戳；阴影用实色偏移块，不用 blur。
class _LetterPacket extends StatelessWidget {
  const _LetterPacket({
    required this.year,
    required this.stamp,
    this.destination,
  });

  final String? destination;
  final String year;
  final double stamp;

  @override
  Widget build(BuildContext context) {
    final to = destination;
    final address = (to == null || to.isEmpty) ? '· · ·' : to;
    return SizedBox(
      width: 292,
      height: 176,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _EnvelopePainter()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 40, 88, 18),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                address,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PostalTokens.inkNavy,
                  fontWeight: FontWeight.w700,
                  fontSize: PostalTokens.minBodyFontSize,
                  height: 1.35,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 14,
            child: Transform.rotate(
              angle: (1 - stamp) * -0.42,
              child: Transform.scale(
                scale: 0.55 + stamp * 0.45,
                child: PostmarkRing(
                  size: 72,
                  color: PostalTokens.stampVermilion,
                  strokeWidth: 2.2,
                  year: year,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnvelopePainter extends CustomPainter {
  const _EnvelopePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 18, size.width, size.height - 18),
      const Radius.circular(10),
    );
    // 实色投影，避免 blur 在模拟器上每帧重算。
    canvas.drawRRect(
      body.shift(const Offset(5, 7)),
      Paint()..color = PostalTokens.inkNavy.withValues(alpha: 0.2),
    );
    canvas.drawRRect(body, Paint()..color = PostalTokens.paperEnvelope);
    canvas.drawRRect(
      body,
      Paint()
        ..color = PostalTokens.kraftBrown.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final flap = Path()
      ..moveTo(8, 22)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width - 8, 22)
      ..close();
    canvas.drawPath(flap, Paint()..color = PostalTokens.kraftBrownMuted);
    canvas.drawPath(
      flap,
      Paint()
        ..color = PostalTokens.kraftBrown.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );

    final seam = Paint()
      ..color = PostalTokens.perforationLine
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(18, size.height * 0.58),
      Offset(size.width - 18, size.height * 0.58),
      seam,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 邮筒投递口：信封从这里落下。
class _PostboxSlot extends StatelessWidget {
  const _PostboxSlot({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 92),
      painter: _PostboxPainter(progress: progress),
    );
  }
}

class _PostboxPainter extends CustomPainter {
  const _PostboxPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final a = progress.clamp(0.0, 1.0);
    if (a <= 0) return;
    final box = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 18, size.width, size.height - 18),
      const Radius.circular(14),
    );
    canvas.drawRRect(
      box,
      Paint()..color = PostalTokens.postboxGreen.withValues(alpha: a),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(18, 8, size.width - 36, 22),
        const Radius.circular(6),
      ),
      Paint()..color = PostalTokens.inkNavy.withValues(alpha: 0.72 * a),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width / 2 - 16, 42, 32, 28),
        const Radius.circular(4),
      ),
      Paint()..color = PostalTokens.stampGold.withValues(alpha: 0.85 * a),
    );
  }

  @override
  bool shouldRepaint(covariant _PostboxPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
