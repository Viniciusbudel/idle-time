import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/entities/enums.dart';

class WorkerAvatar extends PositionComponent with HasGameRef {
  final Worker worker;
  final Random _rng = Random();

  WorkerAvatar({required this.worker});

  @override
  Future<void> onLoad() async {
    // Center anchor for rotation mechanics
    anchor = Anchor.center;
    size = Vector2.all(40); // Define a clickable/visible area size

    final rarityColor = _getRarityColor(worker.rarity);

    // 1. Pulsing Aura (Background)
    add(
      CircleComponent(
        radius: 12,
        anchor: Anchor.center,
        position: size / 2,
        paint: Paint()
          ..color = rarityColor.withOpacity(0.15)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      )..add(
        ScaleEffect.to(
          Vector2.all(1.5),
          EffectController(
            duration: 2.0,
            reverseDuration: 2.0,
            infinite: true,
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );

    // 2. Rotating Data Ring (Outer)
    // Dashed ring effect using stroke
    add(
      CircleComponent(
        radius: 18,
        anchor: Anchor.center,
        position: size / 2,
        paint: Paint()
          ..color = rarityColor.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      )..add(
        RotateEffect.by(
          2 * pi,
          EffectController(duration: 8.0, infinite: true, curve: Curves.linear),
        ),
      ),
    );

    // 3. Inner Core (The "Worker")
    add(
      CircleComponent(
        radius: 10,
        anchor: Anchor.center,
        position: size / 2,
        paint: Paint()
          ..color = rarityColor
          ..style = PaintingStyle.fill
          ..shader = RadialGradient(
            colors: [Colors.white, rarityColor],
            stops: const [0.2, 1.0],
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: 10)),
      ),
    );

    // 4. Era Year Label (Floating)
    add(
      TextComponent(
        text: worker.era.year.toString(),
        textRenderer: TextPaint(
          style: TimeFactoryTextStyles.numbersSmall.copyWith(
            fontSize: 10,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
        anchor: Anchor.center,
        position: size / 2,
      ),
    );

    // 5. Floating Movement (The whole component moves)
    // We already moved the main component, but let's add relative "hovering" inside local space
    // or just let game sync position.
    // Actually syncWorkers sets position. Let's add a "hover" effect on top of that.
    // Since syncWorkers sets `position = x`, we can't easily use MoveEffect on 'this' without conflict
    // unless we use specific relative effect wrapper.
    // Instead, we let the visuals bob inside the component.
    // But since I used 'size/2' for all children, I can move children or use a wrapper.
    // Let's create a 'VisualRoot' component.

    // Actually, syncWorkers sets initial position. If we want it to drift, we can add a MoveEffect.by
    // Random drift
    final driftOffset = Vector2(
      (_rng.nextDouble() - 0.5) * 60,
      (_rng.nextDouble() - 0.5) * 40,
    );

    add(
      MoveEffect.by(
        driftOffset,
        EffectController(
          duration: 4 + _rng.nextDouble() * 3,
          reverseDuration: 4 + _rng.nextDouble() * 3,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );

    // 6. Data Trail Particles
    // Emitter that leaves small dots behind
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 5, // constant flow not burst
          lifespan: 1.0,
          generator: (i) {
            // We want a trail, so we need to spawn at current global position but stay there?
            // ParticleSystemComponent moves with parent usually?
            // Providing a generic particle generator that spawns RELATIVE to component:
            // To make a trail, particles must NOT move with component.
            // This is tricky in simple composition.
            // For now, simpler "sparkles" around the worker.
            return AcceleratedParticle(
              position:
                  (size / 2) +
                  Vector2(
                    (_rng.nextDouble() - 0.5) * 20,
                    (_rng.nextDouble() - 0.5) * 20,
                  ),
              speed: Vector2(0, -10), // slowly rise
              child: CircleParticle(
                radius: 1.0,
                paint: Paint()..color = rarityColor.withOpacity(0.4),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getRarityColor(WorkerRarity rarity) {
    switch (rarity) {
      case WorkerRarity.common:
        return Colors.grey;
      case WorkerRarity.rare:
        return TimeFactoryColors.electricCyan;
      case WorkerRarity.epic:
        return TimeFactoryColors.deepPurple;
      case WorkerRarity.legendary:
        return Colors.orange;
      case WorkerRarity.paradox:
        return TimeFactoryColors.hotMagenta;
    }
  }
}
