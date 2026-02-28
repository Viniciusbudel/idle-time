import 'package:flutter/material.dart';

/// HUD-style segmented progress bar for the tech screen.
/// Replaces soft material LinearProgressIndicator with hard-edged segments.
class HudSegmentedProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final Color? backgroundColor;
  final double height;
  final int segmentCount;
  final double segmentGap;
  final String? label;
  final TextStyle? labelStyle;

  const HudSegmentedProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.backgroundColor,
    this.height = 6,
    this.segmentCount = 10,
    this.segmentGap = 2,
    this.label,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Colors.white.withValues(alpha: 0.08);
    final filledSegments = (value * segmentCount).floor();
    final partialFill = (value * segmentCount) - filledSegments;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalGap = segmentGap * (segmentCount - 1);
                final segmentWidth =
                    (constraints.maxWidth - totalGap) / segmentCount;

                return Row(
                  children: List.generate(segmentCount, (index) {
                    final isFilled = index < filledSegments;
                    final isPartial =
                        index == filledSegments && partialFill > 0;

                    return Row(
                      children: [
                        SizedBox(
                          width: segmentWidth,
                          height: height,
                          child: _SegmentPainter(
                            fillRatio: isFilled
                                ? 1.0
                                : (isPartial ? partialFill : 0.0),
                            color: color,
                            backgroundColor: bg,
                          ),
                        ),
                        if (index < segmentCount - 1)
                          SizedBox(width: segmentGap),
                      ],
                    );
                  }),
                );
              },
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 8),
          Text(
            label!,
            style:
                labelStyle ??
                TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ],
    );
  }
}

class _SegmentPainter extends StatelessWidget {
  final double fillRatio;
  final Color color;
  final Color backgroundColor;

  const _SegmentPainter({
    required this.fillRatio,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SegmentCustomPainter(
        fillRatio: fillRatio,
        color: color,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class _SegmentCustomPainter extends CustomPainter {
  final double fillRatio;
  final Color color;
  final Color backgroundColor;

  _SegmentCustomPainter({
    required this.fillRatio,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // Fill
    if (fillRatio > 0) {
      final fillWidth = size.width * fillRatio;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, fillWidth, size.height),
        Paint()..color = color,
      );

      // Glow on filled leading edge
      if (fillRatio < 1.0) {
        canvas.drawRect(
          Rect.fromLTWH(fillWidth - 1.5, 0, 1.5, size.height),
          Paint()
            ..color = color.withValues(alpha: 0.7)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SegmentCustomPainter oldDelegate) =>
      oldDelegate.fillRatio != fillRatio || oldDelegate.color != color;
}
