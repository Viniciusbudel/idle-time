import 'dart:math';
import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';

class GlitchOverlay extends StatefulWidget {
  final bool isActive;
  final double intensity;

  const GlitchOverlay({
    super.key,
    required this.isActive,
    this.intensity = 1.0,
  });

  @override
  State<GlitchOverlay> createState() => _GlitchOverlayState();
}

class _GlitchOverlayState extends State<GlitchOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(GlitchOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _GlitchPainter(
              seed: _controller.value,
              intensity: widget.intensity,
              rng: _rng,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _GlitchPainter extends CustomPainter {
  final double seed;
  final double intensity;
  final Random rng;

  _GlitchPainter({
    required this.seed,
    required this.intensity,
    required this.rng,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Random Chromatic Aberration Shift
    if (rng.nextDouble() < 0.3 * intensity) {
      final offset = (rng.nextDouble() - 0.5) * 20 * intensity;
      _drawChromaticShift(canvas, size, offset);
    }

    // 2. Random Horizontal Glitch Bars
    if (rng.nextDouble() < 0.2 * intensity) {
      _drawGlitchBars(canvas, size);
    }

    // 3. Static/Noise Overlay
    if (rng.nextDouble() < 0.1 * intensity) {
      _drawNoise(canvas, size);
    }

    // 4. Cyan/Magenta Flash
    if (rng.nextDouble() < 0.05 * intensity) {
      canvas.drawColor(
        (rng.nextBool()
                ? TimeFactoryColors.electricCyan
                : TimeFactoryColors.hotMagenta)
            .withValues(alpha: 0.05 * intensity),
        BlendMode.screen,
      );
    }
  }

  void _drawChromaticShift(Canvas canvas, Size size, double offset) {
    final paint = Paint()..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(offset, 0, size.width, size.height),
      paint..color = TimeFactoryColors.electricCyan.withValues(alpha: 0.1),
    );
    canvas.drawRect(
      Rect.fromLTWH(-offset, 0, size.width, size.height),
      paint..color = TimeFactoryColors.hotMagenta.withValues(alpha: 0.1),
    );
  }

  void _drawGlitchBars(Canvas canvas, Size size) {
    final barCount = (rng.nextInt(3) + 1);
    for (int i = 0; i < barCount; i++) {
      final y = rng.nextDouble() * size.height;
      final h = rng.nextDouble() * 20 * intensity;
      final xOffset = (rng.nextDouble() - 0.5) * 50 * intensity;

      final paint = Paint()
        ..color =
            (rng.nextBool()
                    ? TimeFactoryColors.electricCyan
                    : TimeFactoryColors.hotMagenta)
                .withValues(alpha: 0.2 * intensity);

      canvas.drawRect(Rect.fromLTWH(xOffset, y, size.width, h), paint);

      // Secondary small block
      if (rng.nextBool()) {
        canvas.drawRect(
          Rect.fromLTWH(
            rng.nextDouble() * size.width,
            y,
            rng.nextDouble() * 100,
            h,
          ),
          paint..color = Colors.white.withValues(alpha: 0.3),
        );
      }
    }
  }

  void _drawNoise(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05 * intensity)
      ..strokeWidth = 1;

    for (int i = 0; i < 20; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GlitchPainter oldDelegate) => true;
}
