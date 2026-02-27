import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/entities/enums.dart';

/// component that orchestrates the "Void Explosion" hiring sequence:
/// 1. Singularity Formation (Event Horizon + Swirling Accretion Disk)
/// 2. Critical Mass (Pulse)
/// 3. Void Explosion (Reveal Worker)
class HiringEffectComponent extends PositionComponent with HasGameReference {
  final Worker worker;
  final VoidCallback onSpawnWorker;

  HiringEffectComponent({
    required this.worker,
    required this.onSpawnWorker,
    required Vector2 position,
  }) : super(position: position, size: Vector2.all(150), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final rarityColor = _getRarityColor(worker.rarity);

    // Sequence of animations

    // 0.0s: Form Singularity & Accretion Disk
    _spawnSingularity(rarityColor);
    _startAccretionDisk(rarityColor);

    // 1.5s: Explosion & Reveal
    add(
      TimerComponent(
        period: 1.5,
        removeOnFinish: true,
        onTick: () {
          _triggerVoidExplosion(rarityColor);
          onSpawnWorker();
        },
      ),
    );

    // 3.0s: Cleanup self
    add(
      TimerComponent(
        period: 3.0,
        removeOnFinish: true,
        onTick: () => removeFromParent(),
      ),
    );
  }

  @override
  void updateTree(double dt) {
    update(dt);
    final snapshot = children.toList(growable: false);
    for (final child in snapshot) {
      child.updateTree(dt);
    }
  }

  void _spawnSingularity(Color color) {
    // 1. Event Horizon (The Void)
    // Black circle that grows
    final eventHorizon = CircleComponent(
      radius: 20,
      anchor: Anchor.center,
      position: size / 2,
      paint: Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    eventHorizon.scale = Vector2.zero();
    eventHorizon.add(
      _scaleTo(
        eventHorizon,
        Vector2.all(1.0),
        EffectController(duration: 0.5, curve: Curves.easeOutBack),
      ),
    );
    eventHorizon.add(
      _scaleTo(
        eventHorizon,
        Vector2.zero(),
        EffectController(
          startDelay: 1.3,
          duration: 0.1,
          curve: Curves.easeInExpo,
        ),
      ),
    );
    add(eventHorizon);

    // 2. Photon Ring (Glowing Edge)
    final photonRing = CircleComponent(
      radius: 22,
      anchor: Anchor.center,
      position: size / 2,
      paint: Paint()
        ..color = color.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    photonRing.scale = Vector2.zero();
    photonRing.add(
      _scaleTo(
        photonRing,
        Vector2.all(1.0),
        EffectController(duration: 0.5, curve: Curves.easeOutBack),
      ),
    );
    photonRing.add(
      _scaleTo(
        photonRing,
        Vector2.zero(),
        EffectController(
          startDelay: 1.3,
          duration: 0.1,
          curve: Curves.easeInExpo,
        ),
      ),
    );
    add(photonRing);
  }

  void _startAccretionDisk(Color color) {
    // Swirling particles getting sucked in
    add(
      TimerComponent(
        period: 0.05,
        repeat: true,
        autoStart: true,
        // Stop emitting just before explosion
        onTick: () {
          // Check if we are past the explosion time (1.5s) manually or just let it fade?
          // We'll trust the component cleanup handles it or simple logic:
          // We can't easily check 'time' here without tracking it.
          // Let's just emit for a set duration by removing this timer?
          // Or just let them spawn until parent is removed (particles die anyway).

          final random = Random();
          for (int i = 0; i < 3; i++) {
            add(
              ParticleSystemComponent(
                particle: _AccretionParticle(
                  center: size / 2,
                  color: color,
                  radius: 60 + random.nextDouble() * 20,
                  angle: random.nextDouble() * 2 * pi,
                ),
              ),
            );
          }
        },
      )..add(
        // Remove emitter before explosion so no new particles spawn during boom
        RemoveEffect(delay: 1.3),
      ),
    );
  }

  void _triggerVoidExplosion(Color color) {
    // 1. Shockwave
    final shockwave = CircleComponent(
      radius: 10,
      anchor: Anchor.center,
      position: size / 2,
      paint: Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    shockwave.add(
      _scaleTo(
        shockwave,
        Vector2.all(8.0),
        EffectController(duration: 0.4, curve: Curves.easeOutQuad),
      ),
    );
    shockwave.add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.4),
        onComplete: () => removeFromParent(),
      ),
    );
    add(shockwave);

    // 2. Flash
    add(
      CircleComponent(
        radius: 50,
        anchor: Anchor.center,
        position: size / 2,
        paint: Paint()
          ..color = Colors.white
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      )..add(
        OpacityEffect.fadeOut(
          EffectController(duration: 0.3, curve: Curves.easeIn),
          onComplete: () => removeFromParent(),
        ),
      ),
    );

    // 3. Debris / Ejecta
    final random = Random();
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 30,
          lifespan: 1.0,
          generator: (i) {
            final angle = random.nextDouble() * 2 * pi;
            final speed = 100.0 + random.nextDouble() * 200.0;
            return AcceleratedParticle(
              position: size / 2,
              speed: Vector2(cos(angle), sin(angle)) * speed,
              child: CircleParticle(
                radius: 2.0,
                paint: Paint()..color = color.withOpacity(0.8),
              ),
            );
          },
        ),
      ),
    );
  }

  ScaleEffect _scaleTo(
    PositionComponent target,
    Vector2 scale,
    EffectController controller,
  ) {
    final effect = ScaleEffect.to(scale, controller);
    effect.target = target;
    return effect;
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

// Custom Particle for the 3D swirling effect (Scaled down from PortalGame)
class _AccretionParticle extends Particle {
  final Vector2 center;
  final Color color;
  double radius;
  double angle;
  final double speed;
  final double tilt = 0.4; // 3D Tilt effect

  _AccretionParticle({
    required this.center,
    required this.color,
    required this.radius,
    required this.angle,
  }) : speed = 4.0 + Random().nextDouble() * 4.0, // Faster swirl
       super(lifespan: 0.8); // Short life as it sucks in

  @override
  void update(double dt) {
    super.update(dt);
    angle += speed * dt; // Rotate
    radius -= 80 * dt; // Rapidly spiral in
    if (radius < 0) radius = 0; // Clamp
  }

  @override
  void render(Canvas canvas) {
    // 3D Projection
    final x = cos(angle) * radius;
    final y = sin(angle) * radius * tilt;
    final pos = center + Vector2(x, y);

    final opacity = (lifespan - progress * lifespan) / lifespan;

    final paint = Paint()..color = color.withOpacity(1.0 * opacity);
    canvas.drawCircle(pos.toOffset(), 1.5, paint);
  }
}
