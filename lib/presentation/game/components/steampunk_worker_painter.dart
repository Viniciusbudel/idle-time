import 'dart:math';
import 'package:flutter/material.dart';

import 'package:time_factory/domain/entities/enums.dart';

class SteampunkWorkerPainter extends CustomPainter {
  final WorkerRarity rarity;
  final Color neonColor;

  SteampunkWorkerPainter({required this.rarity, required this.neonColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    _drawGear(canvas, center, radius, Colors.amber.shade900); // Brass/Copper
    _drawNeonAccents(canvas, center, radius * 0.7);
    _drawGoggles(canvas, center, radius * 0.4);
  }

  void _drawGear(Canvas canvas, Offset center, double radius, Color color) {
    // 1. Gear Teeth
    final teethCount = 8;
    final toothDepth = radius * 0.2;
    final innerRadius = radius - toothDepth;

    final path = Path();
    for (int i = 0; i < teethCount; i++) {
      final angle = (2 * pi / teethCount) * i;
      final nextAngle = (2 * pi / teethCount) * (i + 1);
      final toothWidthAngle = (2 * pi / teethCount) * 0.4; // Width of tooth

      // Start at base of tooth
      final x1 = center.dx + cos(angle) * innerRadius;
      final y1 = center.dy + sin(angle) * innerRadius;

      if (i == 0) path.moveTo(x1, y1);

      // Tip of tooth start
      final x2 = center.dx + cos(angle + 0.1) * radius;
      final y2 = center.dy + sin(angle + 0.1) * radius;
      path.lineTo(x2, y2);

      // Tip of tooth end
      final x3 = center.dx + cos(angle + toothWidthAngle - 0.1) * radius;
      final y3 = center.dy + sin(angle + toothWidthAngle - 0.1) * radius;
      path.lineTo(x3, y3);

      // Base of next tooth
      final x4 = center.dx + cos(angle + toothWidthAngle) * innerRadius;
      final y4 = center.dy + sin(angle + toothWidthAngle) * innerRadius;
      path.lineTo(x4, y4);

      // Arc to next tooth
      // path.arcTo(...) - simple line to next tooth base
      final xStartNext = center.dx + cos(nextAngle) * innerRadius;
      final yStartNext = center.dy + sin(nextAngle) * innerRadius;
      path.lineTo(xStartNext, yStartNext);
    }
    path.close();

    // Fill Gear with Gradient
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.brown.shade800, Colors.orange.shade900],
        stops: const [0.3, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, paint);

    // Inner Hole (Dark Void)
    canvas.drawCircle(
      center,
      radius * 0.4,
      Paint()..color = const Color(0xFF1A1A1A),
    );

    // Brass Rim around hole
    canvas.drawCircle(
      center,
      radius * 0.4,
      Paint()
        ..color = const Color(0xFFB8860B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  void _drawNeonAccents(Canvas canvas, Offset center, double radius) {
    // Neon Ring inside gear
    final paint = Paint()
      ..color = neonColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0); // Glow

    canvas.drawCircle(center, radius, paint);

    // Sharp Core Ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity( 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _drawGoggles(Canvas canvas, Offset center, double width) {
    // Stylized Goggles
    final goggleRadius = width * 0.6;
    final leftEye = center + Offset(-width * 0.6, 0);
    final rightEye = center + Offset(width * 0.6, 0);

    // Frame
    final framePaint = Paint()
      ..color =
          const Color(0xFFCD7F32) // Bronze
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(leftEye, goggleRadius, framePaint);
    canvas.drawCircle(rightEye, goggleRadius, framePaint);

    // Bridge
    canvas.drawLine(
      leftEye + Offset(goggleRadius, 0),
      rightEye + Offset(-goggleRadius, 0),
      framePaint..strokeWidth = 2.0,
    );

    // Lenses (Neon filled)
    final lensPaint = Paint()
      ..color = neonColor.withOpacity( 0.6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(leftEye, goggleRadius * 0.8, lensPaint);
    canvas.drawCircle(rightEye, goggleRadius * 0.8, lensPaint);

    // Glint
    final glintPaint = Paint()
      ..color = Colors.white.withOpacity( 0.9)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(leftEye + const Offset(-2, -2), 1.5, glintPaint);
    canvas.drawCircle(rightEye + const Offset(-2, -2), 1.5, glintPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
