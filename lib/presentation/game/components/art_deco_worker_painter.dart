import 'dart:math';
import 'package:flutter/material.dart';
import 'package:time_factory/domain/entities/enums.dart';

/// Procedural Art Deco Worker Icon
///
/// Features:
/// - gold / black color palette
/// - Geometric sunburst patterns
/// - Sharp, angular lines
class ArtDecoWorkerPainter extends CustomPainter {
  final WorkerRarity rarity;
  final Color neonColor;

  ArtDecoWorkerPainter({required this.rarity, required this.neonColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    _drawBackground(canvas, center, radius);
    _drawSunburst(canvas, center, radius, neonColor);
    _drawWorkerSilhouette(canvas, center, radius * 0.5);
    _drawBorder(canvas, center, radius, neonColor);
  }

  void _drawBackground(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color =
          const Color(0xFF1A1A1A) // Charcoal Black
      ..style = PaintingStyle.fill;

    // Hexagon base
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * pi / 180;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSunburst(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color.withOpacity( 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Fan lines from bottom
    final start = center + Offset(0, radius * 0.5);
    for (int i = -3; i <= 3; i++) {
      final angle = (i * 20 - 90) * pi / 180;
      final endX = center.dx + radius * cos(angle);
      final endY = center.dy + radius * sin(angle) * 0.8;
      canvas.drawLine(start, Offset(endX, endY), paint);
    }
  }

  void _drawWorkerSilhouette(Canvas canvas, Offset center, double radius) {
    // Stylized "Metropolis" worker (geometric head and shoulders)
    final paint = Paint()
      ..color =
          const Color(0xFFD4AF37) // Art Deco Gold
      ..style = PaintingStyle.fill;

    final path = Path();
    // Head (Circle)
    canvas.drawCircle(center - Offset(0, radius * 0.5), radius * 0.4, paint);

    // Shoulders (Trapezoid)
    path.moveTo(center.dx - radius * 0.8, center.dy + radius);
    path.lineTo(center.dx + radius * 0.8, center.dy + radius);
    path.lineTo(center.dx + radius * 0.5, center.dy);
    path.lineTo(center.dx - radius * 0.5, center.dy);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawBorder(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color =
          const Color(0xFFD4AF37) // Gold Border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Hexagon border
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * pi / 180;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
