import 'package:flutter/material.dart';
import 'package:time_factory/core/theme/era_theme.dart';
import 'dart:math';
import 'dart:ui';

/// Applies era-specific visual overlays (Scanlines vs Sepia/Grain)
class EraOverlay extends StatefulWidget {
  final EraTheme theme;
  final double intensity;

  const EraOverlay({super.key, required this.theme, this.intensity = 0.0});

  @override
  State<EraOverlay> createState() => _EraOverlayState();
}

class _EraOverlayState extends State<EraOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat(); // Loop animation for noise/glitch
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _EraPainter(
              theme: widget.theme,
              intensity: widget.intensity,
              seed: _controller.value, // Force repaint every frame
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _EraPainter extends CustomPainter {
  final EraTheme theme;
  final double intensity;
  final double seed;
  final Random _rng;

  _EraPainter({
    required this.theme,
    required this.intensity,
    required this.seed,
  }) : _rng = Random(); // New random seed each frame (pseudo)
  // Actually Random() without seed uses implementation specific.
  // For true noise animation, we rely on CustomPainter being rebuilt.

  @override
  void paint(Canvas canvas, Size size) {
    if (theme.useScanlines) {
      _drawScanlines(canvas, size);
    } else {
      _drawSepiaFilm(canvas, size);
    }
  }

  void _drawScanlines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03 + intensity * 0.02)
      ..strokeWidth = 1;

    // Scanlines every 4px
    for (double y = 0; y < size.height; y += 4) {
      // Occasional faint flicker line
      if (_rng.nextDouble() > 0.1) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    }

    // Glitch block
    if (intensity > 0.5 && _rng.nextDouble() < 0.1) {
      final barPaint = Paint()
        ..color = theme.primaryColor.withValues(alpha: 0.1);
      final y = _rng.nextDouble() * size.height;
      final h = _rng.nextDouble() * 50;
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, h), barPaint);
    }
  }

  void _drawSepiaFilm(Canvas canvas, Size size) {
    // 1. Sepia Tint Overlay (easiest way to tint)
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = const Color(0xFF704214)
            .withValues(alpha: 0.1) // Brown
        ..blendMode = BlendMode.softLight, // Or overlay
    );

    // 2. Film Grain (Simulated) - Optimized with drawPoints
    final grainPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final points = <Offset>[];
    // Reduce count to 150 for performance, but slightly thicker
    for (int i = 0; i < 150; i++) {
      points.add(
        Offset(_rng.nextDouble() * size.width, _rng.nextDouble() * size.height),
      );
    }
    canvas.drawPoints(PointMode.points, points, grainPaint);

    // 3. Vertical Scratches (Old Film)
    if (_rng.nextDouble() < 0.05) {
      // Occasional scratch
      final scratchPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.05)
        ..strokeWidth = 1;
      final x = _rng.nextDouble() * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), scratchPaint);
    }

    // 4. Vignette (Dark edges)
    // Cache shader if possible, or just draw.
    // Gradient creation every frame is okay but could be cached.
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.2, // Slightly larger
      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
      stops: const [0.6, 1.0],
    );

    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(covariant _EraPainter oldDelegate) {
    return true; // Always animate
  }
}
