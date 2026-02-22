import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/domain/entities/enums.dart';

class VoidHiringGame extends FlameGame {
  final VoidCallback onComplete;
  final WorkerRarity rarity;
  final Random _random = Random();

  VoidHiringGame({required this.onComplete, required this.rarity});

  @override
  Color backgroundColor() => const Color(0x00000000); // Transparent

  @override
  Future<void> onLoad() async {
    final center = size / 2;
    final rarityColor = _getRarityColor(rarity);

    // 1. Singularity Formation (Black Hole)
    _spawnSingularity(center, rarityColor);

    // 2. Accretion Disk (Swirling Particles)
    _startAccretionDisk(center, rarityColor);

    // 3. Explosion Trigger
    add(
      TimerComponent(
        period: 1.5,
        removeOnFinish: true,
        onTick: () => _triggerVoidExplosion(center, rarityColor),
      ),
    );

    // 4. Cleanup & Complete
    add(
      TimerComponent(
        period: 2.2, // Allow explosion to fade
        removeOnFinish: true,
        onTick: () => onComplete(),
      ),
    );
  }

  void _spawnSingularity(Vector2 center, Color color) {
    // Event Horizon (Black Void)
    add(
      CircleComponent(
          radius: 30,
          anchor: Anchor.center,
          position: center,
          paint: Paint()
            ..color = Colors.black
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        )
        ..scale = Vector2.zero()
        ..add(
          ScaleEffect.to(
            Vector2.all(1.0),
            EffectController(duration: 0.6, curve: Curves.easeOutBack),
          ),
        )
        ..add(
          ScaleEffect.to(
            Vector2.zero(),
            EffectController(
              startDelay: 1.3,
              duration: 0.1,
              curve: Curves.easeInExpo,
            ),
          ),
        ),
    );

    // Photon Ring (Glowing Edge)
    add(
      CircleComponent(
          radius: 32,
          anchor: Anchor.center,
          position: center,
          paint: Paint()
            ..color = color.withOpacity( 0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        )
        ..scale = Vector2.zero()
        ..add(
          ScaleEffect.to(
            Vector2.all(1.0),
            EffectController(duration: 0.6, curve: Curves.easeOutBack),
          ),
        )
        ..add(
          ScaleEffect.to(
            Vector2.zero(),
            EffectController(
              startDelay: 1.3,
              duration: 0.1,
              curve: Curves.easeInExpo,
            ),
          ),
        ),
    );
  }

  void _startAccretionDisk(Vector2 center, Color color) {
    add(
      TimerComponent(
        period: 0.04,
        repeat: true,
        autoStart: true,
        onTick: () {
          for (int i = 0; i < 4; i++) {
            add(
              ParticleSystemComponent(
                particle: _AccretionParticle(
                  center: center,
                  color: color,
                  radius: 100 + _random.nextDouble() * 30, // Start far out
                  angle: _random.nextDouble() * 2 * pi,
                ),
              ),
            );
          }
        },
      )..add(RemoveEffect(delay: 1.3)), // Stop emitting before boom
    );
  }

  void _triggerVoidExplosion(Vector2 center, Color color) {
    // Shockwave
    add(
      CircleComponent(
          radius: 10,
          anchor: Anchor.center,
          position: center,
          paint: Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6.0
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        )
        ..add(
          ScaleEffect.to(
            Vector2.all(15.0), // Massive expansion
            EffectController(duration: 0.5, curve: Curves.easeOutQuad),
          ),
        )
        ..add(
          OpacityEffect.fadeOut(
            EffectController(duration: 0.5),
            onComplete: () => removeFromParent(),
          ),
        ),
    );

    // Blinding Flash
    add(
      CircleComponent(
        radius: 80,
        anchor: Anchor.center,
        position: center,
        paint: Paint()
          ..color = Colors.white
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
      )..add(
        OpacityEffect.fadeOut(
          EffectController(duration: 0.4, curve: Curves.easeIn),
          onComplete: () => removeFromParent(),
        ),
      ),
    );

    // High Velocity Ejecta
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 60,
          lifespan: 0.8,
          generator: (i) {
            final angle = _random.nextDouble() * 2 * pi;
            final speed = 200.0 + _random.nextDouble() * 300.0;
            return AcceleratedParticle(
              position: center,
              speed: Vector2(cos(angle), sin(angle)) * speed,
              child: CircleParticle(
                radius: 2.5,
                paint: Paint()..color = color.withOpacity( 0.9),
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

// 3D Swirl Particle
class _AccretionParticle extends Particle {
  final Vector2 center;
  final Color color;
  double radius;
  double angle;
  final double speed;
  final double tilt = 0.5;

  _AccretionParticle({
    required this.center,
    required this.color,
    required this.radius,
    required this.angle,
  }) : speed = 5.0 + Random().nextDouble() * 3.0,
       super(lifespan: 0.6);

  @override
  void update(double dt) {
    super.update(dt);
    angle += speed * dt;
    radius -= 150 * dt; // Suck in fast
    if (radius < 0) radius = 0;
  }

  @override
  void render(Canvas canvas) {
    final x = cos(angle) * radius;
    final y = sin(angle) * radius * tilt;
    final pos = center + Vector2(x, y);
    final opacity = (lifespan - progress * lifespan) / lifespan;
    final paint = Paint()..color = color.withOpacity( opacity);
    canvas.drawCircle(pos.toOffset(), 2.0, paint);
  }
}
