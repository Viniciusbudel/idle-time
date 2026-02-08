import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';

/// Tap effect using pure code-based particles (no sprite loading)
class TapEffect extends Component with HasGameRef {
  final Vector2 position;

  TapEffect({required this.position});

  @override
  Future<void> onLoad() async {
    final rng = Random();

    // Create particle burst with circles instead of sprites
    final particle = ParticleSystemComponent(
      particle: Particle.generate(
        count: 12,
        lifespan: 0.6,
        generator: (i) {
          final angle = (i / 12) * 2 * pi;
          final speed = 80 + rng.nextDouble() * 40;

          return AcceleratedParticle(
            position: position.clone(),
            speed: Vector2(cos(angle) * speed, sin(angle) * speed),
            acceleration: Vector2(0, 50), // Slight gravity
            child: ScalingParticle(
              to: 0.0,
              child: CircleParticle(
                radius: 3 + rng.nextDouble() * 3,
                paint: Paint()
                  ..color = TimeFactoryColors.electricCyan.withValues(
                    alpha: 0.7 + rng.nextDouble() * 0.3,
                  )
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
              ),
            ),
          );
        },
      ),
    );

    gameRef.add(particle);

    // Add a central flash
    final flash = ParticleSystemComponent(
      position: position.clone(),
      particle: ScalingParticle(
        lifespan: 0.3,
        to: 2.0,
        child: CircleParticle(
          radius: 20,
          paint: Paint()
            ..color = Colors.white.withValues(alpha: 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        ),
      ),
    );

    gameRef.add(flash);

    // Auto-remove this controller component
    removeFromParent();
  }
}
