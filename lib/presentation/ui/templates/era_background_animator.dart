import 'dart:math';
import 'package:flutter/material.dart';
import 'package:time_factory/core/theme/era_theme.dart';

class EraBackgroundAnimator extends StatefulWidget {
  final EraAnimationType animationType;
  final Color primaryColor;
  final Color secondaryColor;

  const EraBackgroundAnimator({
    super.key,
    required this.animationType,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<EraBackgroundAnimator> createState() => _EraBackgroundAnimatorState();
}

class _EraBackgroundAnimatorState extends State<EraBackgroundAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  // Star/Partcile positions for relevant animations
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _initParticles();
  }

  @override
  void didUpdateWidget(covariant EraBackgroundAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animationType != oldWidget.animationType) {
      _initParticles();
    }
  }

  void _initParticles() {
    _particles.clear();
    int count = 0;

    switch (widget.animationType) {
      case EraAnimationType.sparkle:
        count = 30;
        break;
      case EraAnimationType.starField:
        count = 100;
        break;
      case EraAnimationType.digitalRain:
        count = 50;
        break;
      case EraAnimationType.cyberScan:
        count = 40; // Add particles for neon rain
        break;
      default:
        count = 0;
    }

    for (int i = 0; i < count; i++) {
      _particles.add(
        _Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          speed: 0.1 + _random.nextDouble() * 0.4,
          size: 1.0 + _random.nextDouble() * 3.0,
          opacity: _random.nextDouble(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _EraAnimationPainter(
            animationValue: _controller.value,
            type: widget.animationType,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
            particles: _particles,
          ),
          isComplex: widget.animationType != EraAnimationType.none,
          willChange: true,
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  double speed;
  double size;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}

class _EraAnimationPainter extends CustomPainter {
  final double animationValue;
  final EraAnimationType type;
  final Color primaryColor;
  final Color secondaryColor;
  final List<_Particle> particles;

  _EraAnimationPainter({
    required this.animationValue,
    required this.type,
    required this.primaryColor,
    required this.secondaryColor,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case EraAnimationType.fogDrift:
        _paintFog(canvas, size);
        break;
      case EraAnimationType.sparkle:
        _paintSparkles(canvas, size);
        break;
      case EraAnimationType.radarPulse:
        _paintRadar(canvas, size);
        break;
      case EraAnimationType.cyberScan:
        _paintCyberScan(canvas, size);
        break;
      case EraAnimationType.digitalRain:
        _paintDigitalRain(canvas, size);
        break;
      case EraAnimationType.starField:
        _paintStarField(canvas, size);
        break;
      case EraAnimationType.none:
        break;
    }
  }

  void _paintFog(Canvas canvas, Size size) {
    // Simulated fog layers moving horizontally
    final paint = Paint()
      ..color = primaryColor.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    final offset1 = (animationValue * size.width) % size.width;
    final offset2 = ((animationValue + 0.5) * size.width) % size.width;

    canvas.drawCircle(
      Offset(offset1, size.height * 0.3),
      size.width * 0.4,
      paint,
    );
    canvas.drawCircle(
      Offset(offset2 - size.width, size.height * 0.6),
      size.width * 0.5,
      paint,
    );
  }

  void _paintSparkles(Canvas canvas, Size size) {
    // Optimization: Batch drawing if possible, but opacity varies per particle.
    // Group particles by approximate opacity for batching?
    // For now, keep individual scaling/opacity but ensure efficient Paint reuse.

    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    for (var p in particles) {
      final progress = (animationValue * p.speed + p.y) % 1.0;
      final opacity = (sin(progress * pi * 2) + 1) / 2 * p.opacity;

      paint.color = primaryColor.withOpacity(opacity * 0.8);

      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  void _paintRadar(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide * 0.8;

    // Expanding rings
    for (int i = 0; i < 3; i++) {
      final progress = (animationValue + i * 0.33) % 1.0;
      final radius = maxRadius * progress;
      final opacity = (1.0 - progress) * 0.5;

      paint.color = primaryColor.withOpacity(opacity);
      canvas.drawCircle(center, radius, paint);
    }

    // Rotating Sweep
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [primaryColor.withOpacity(0.0), primaryColor.withOpacity(0.15)],
        stops: const [0.75, 1.0],
        transform: GradientRotation(animationValue * 2 * pi),
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawCircle(center, maxRadius, sweepPaint);
  }

  void _paintCyberScan(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(0.5)
      ..strokeWidth = 2.0;

    // Moving horizontal line (Scanline)
    final scanY = (animationValue * size.height) % size.height;

    // Draw scanline
    canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), paint);

    // Trailing gradient
    final trailPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [primaryColor.withOpacity(0.0), primaryColor.withOpacity(0.2)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, scanY - 50, size.width, 50));

    canvas.drawRect(Rect.fromLTWH(0, scanY - 50, size.width, 50), trailPaint);

    // Grid effect
    final gridPaint = Paint()
      ..color = secondaryColor.withOpacity(0.1)
      ..strokeWidth = 1.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Add neon rain fallback using the digital rain mechanic
    _paintDigitalRain(canvas, size);
  }

  void _paintDigitalRain(Canvas canvas, Size size) {
    // Simulating simplified matrix rain
    for (var p in particles) {
      // Move down
      double y = (p.y + animationValue * p.speed * 2) % 1.0;
      double drawY = y * size.height;
      double drawX = p.x * size.width;

      final opacity = (1.0 - y) * p.opacity; // Fade out as it goes down

      final paint = Paint()
        ..color =
            (type == EraAnimationType.digitalRain
                    ? const Color(0xFF00FF00)
                    : primaryColor)
                .withOpacity(opacity)
        ..style = PaintingStyle.fill;

      // Draw short vertical dashes (code rain)
      canvas.drawRect(Rect.fromLTWH(drawX, drawY, 2, p.size * 8), paint);

      // Values: Head of the stream is brighter
      final headPaint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(drawX, drawY + (p.size * 8), 2, 2),
        headPaint,
      );
    }
  }

  // Helper for digital rain fallback color
  Color get successColor => const Color(0xFF00FF00);

  void _paintStarField(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    // Center expansion (Warp speed ish)
    final center = Offset(size.width / 2, size.height / 2);

    for (var p in particles) {
      // Move away from center
      double progress = (animationValue * p.speed + p.y) % 1.0;

      // Calculate position relative to center
      double dx = (p.x - 0.5) * size.width * progress * 2;
      double dy = (p.y - 0.5) * size.height * progress * 2;

      final pos = Offset(center.dx + dx * 2, center.dy + dy * 2);

      // Opacity grows with speed/progress
      paint.color = Colors.white.withOpacity(progress * p.opacity);

      if (size.contains(pos)) {
        canvas.drawCircle(pos, p.size * progress, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EraAnimationPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
        type != oldDelegate.type;
  }
}
