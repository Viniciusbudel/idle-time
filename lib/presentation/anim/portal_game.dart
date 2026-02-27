import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class PortalGame extends FlameGame {
  final Color primaryColor;

  PortalGame({required this.primaryColor});

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    final center = size / 2;

    // 0. The Void (Black backdrop for the hole to pop)
    // Optional, but helps if the background isn't pure black

    // 1. Accretion Disk ( The "Swirl" )
    // A flattened ring of spinning particles to simulate 3D perspective
    add(
      TimerComponent(
        period: 0.05,
        repeat: true,
        onTick: () {
          // Emit multiple particles per tick for density
          for (int i = 0; i < 5; i++) {
            add(
              ParticleSystemComponent(
                particle: _AccretionParticle(
                  center: center,
                  color: primaryColor,
                  radius: 80 + Random().nextDouble() * 40, // Band width
                  angle: Random().nextDouble() * 2 * pi,
                ),
              ),
            );
          }
        },
      ),
    );

    // 2. Event Horizon (The Black Void)
    add(
      CircleComponent(
        radius: 25.0,
        anchor: Anchor.center,
        paint: Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      )..position = center,
    );

    // 3. Photon Ring (The glowing edge of the black hole)
    add(
      CircleComponent(
        radius: 26.0,
        anchor: Anchor.center,
        paint: Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      )..position = center,
    );

    // 4. "Hawking Radiation" / Suction Stream
    // Particles spanning from far out and getting sucked IN
    add(
      TimerComponent(
        period: 0.02,
        repeat: true,
        onTick: () {
          final angle = Random().nextDouble() * 2 * pi;
          final dist = 180.0;
          final startPos =
              center + Vector2(cos(angle), sin(angle)) * dist; // Start far out

          add(
            ParticleSystemComponent(
              particle: AcceleratedParticle(
                position: startPos,
                speed: (center - startPos) * 1.5, // Initial pull
                child: ComputedParticle(
                  lifespan: 1.5,
                  renderer: (canvas, particle) {
                    // Make them look like they are stretching as they fall in
                    // Distance to center
                    // We don't have easy access to current position in ComputedParticle without tracking.
                    // But AcceleratedParticle updates the position of the canvas context effectively?
                    // No, AcceleratedParticle translates the canvas.

                    final paint = Paint()
                      ..color = primaryColor.withValues(
                        alpha: (1.0 - particle.progress) * 0.8,
                      )
                      ..style = PaintingStyle.fill;

                    canvas.drawCircle(
                      Offset.zero,
                      1.5 * (1.0 - particle.progress),
                      paint,
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom Particle for the 3D disk effect
class _AccretionParticle extends Particle {
  final Vector2 center;
  final Color color;
  double radius;
  double angle;
  final double speed;
  final double tilt = 0.4; // 0.0 = flat line, 1.0 = circle

  _AccretionParticle({
    required this.center,
    required this.color,
    required this.radius,
    required this.angle,
  }) : speed = 2.0 + Random().nextDouble() * 2.0,
       super(lifespan: 2.0);

  @override
  void update(double dt) {
    super.update(dt);
    angle += speed * dt; // Rotate
    radius -= 10 * dt; // Slowly spiral in
  }

  @override
  void render(Canvas canvas) {
    // 3D Projection:
    // x = cos(angle) * r
    // y = sin(angle) * r * tilt

    final x = cos(angle) * radius;
    final y = sin(angle) * radius * tilt;

    final pos = center + Vector2(x, y);

    // Depth Cueing:
    // If y is negative (top half, "behind" the hole), maybe darker or smaller?
    // Actually, simple Z-sort is hard here.
    // Let's just draw.

    final opacity = (lifespan - progress * lifespan) / lifespan; // Fade out

    final paint = Paint()..color = color.withOpacity(0.6 * opacity);

    canvas.drawCircle(pos.toOffset(), 2.0, paint);
  }
}
