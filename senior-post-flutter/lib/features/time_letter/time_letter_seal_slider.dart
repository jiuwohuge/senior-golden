import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

/// 滑动封缄：拖到末端触发 [onSealed]。
class TimeLetterSealSlider extends StatefulWidget {
  const TimeLetterSealSlider({
    super.key,
    required this.label,
    required this.onSealed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onSealed;
  final bool enabled;

  @override
  State<TimeLetterSealSlider> createState() => _TimeLetterSealSliderState();
}

class _TimeLetterSealSliderState extends State<TimeLetterSealSlider> {
  double _drag = 0;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        const thumb = 56.0;
        final track = maxW - thumb;
        final pos = _done ? track : _drag.clamp(0.0, track);
        return GestureDetector(
          onHorizontalDragUpdate: widget.enabled && !_done
              ? (d) => setState(() => _drag += d.delta.dx)
              : null,
          onHorizontalDragEnd: widget.enabled && !_done
              ? (_) {
                  if (_drag >= track * 0.85) {
                    setState(() {
                      _drag = track;
                      _done = true;
                    });
                    widget.onSealed();
                  } else {
                    setState(() => _drag = 0);
                  }
                }
              : null,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: PostalTokens.paperEnvelope,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: PostalTokens.postboxGreen.withValues(alpha: 0.35),
              ),
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Center(
                  child: Text(
                    widget.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: PostalTokens.inkSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Positioned(
                  left: pos,
                  child: Material(
                    elevation: 2,
                    color: widget.enabled
                        ? PostalTokens.postboxGreen
                        : PostalTokens.inkTertiary,
                    borderRadius: BorderRadius.circular(28),
                    child: const SizedBox(
                      width: thumb,
                      height: thumb,
                      child: Icon(
                        Icons.local_post_office_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
