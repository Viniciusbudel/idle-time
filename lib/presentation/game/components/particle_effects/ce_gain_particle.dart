import 'dart:math';
import 'package:flame/components.dart';

import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/presentation/game/components/particle_effects/floating_text.dart';
import 'package:time_factory/core/utils/number_formatter.dart';

class CEGainParticle extends Component with HasGameRef {
  final Vector2 position;
  final BigInt amount;

  CEGainParticle({required this.position, required this.amount});

  @override
  Future<void> onLoad() async {
    // 1. Cyan particles floating upward
    // Cap particle count to avoid performance hit on huge numbers, but scale subtly
    final particleCount = min(
      ((amount.toDouble()) / 10).floor(),
      20,
    ).clamp(5, 20);

    final particleSystem = ParticleSystemComponent(
      particle: Particle.generate(
        count: particleCount,
        lifespan: 1.5,
        generator: (i) {
          final rng = Random();
          return AcceleratedParticle(
            position: position, // Start exactly at tap
            speed: Vector2(
              rng.nextDouble() * 40 - 20, // Horizontal spread
              -50 - rng.nextDouble() * 50, // Upward velocity
            ),
            child: CircleParticle(
              radius: 1.5 + rng.nextDouble() * 2,
              paint: Paint()
                ..color = TimeFactoryColors.electricCyan.withValues(
                  alpha: 0.6 + rng.nextDouble() * 0.4,
                )
                ..blendMode = BlendMode.srcOver, // Simple blend
            ),
          );
        },
      ),
    );

    gameRef.add(particleSystem);

    // 2. Floating number text
    final textComponent = FloatingTextComponent(
      text: '+${NumberFormatter.formatCE(amount)}',
      position: position + Vector2(0, -20), // Start slightly above tap
      color: TimeFactoryColors.acidGreen,
    );

    gameRef.add(textComponent);

    // Auto-remove this controller
    removeFromParent();
  }
}
