import 'package:flutter/material.dart';

/// A scanline overlay that creates a CRT monitor effect.
/// Wrap this around or stack on top of your main content.
class ScanlineOverlay extends StatelessWidget {
  final double opacity;
  final double lineSpacing;

  const ScanlineOverlay({
    super.key,
    this.opacity = 0.03,
    this.lineSpacing = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ScanlinePainter(opacity: opacity, lineSpacing: lineSpacing),
        size: Size.infinite,
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  final double opacity;
  final double lineSpacing;

  _ScanlinePainter({required this.opacity, required this.lineSpacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity( opacity)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) =>
      opacity != oldDelegate.opacity || lineSpacing != oldDelegate.lineSpacing;
}
