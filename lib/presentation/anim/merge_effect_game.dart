import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// Black hole merge animation — 3 worker orbs spiral into a singularity,
/// accretion disk forms, gravitational collapse, then void explosion
/// reveals the new merged worker.
class MergeEffectGame extends FlameGame {
  final VoidCallback onComplete;
  final Color primaryColor;
  final Random _random = Random();

  MergeEffectGame({required this.onComplete, this.primaryColor = Colors.white});

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    final center = size / 2;

    // Phase 1: 3 Worker Orbs appear at triangle positions (0.0–0.3s)
    _spawnWorkerOrbs(center);

    // Phase 2: Singularity forms at center (0.2s)
    _spawnSingularity(center);

    // Phase 3: Accretion disk swirls (0.2–1.2s)
    _startAccretionDisk(center);

    // Phase 4: Gravitational collapse — orbs consumed (1.0s)
    // (handled by orb animation timing)

    // Phase 5: Void explosion + shockwave (1.2s)
    add(
      TimerComponent(
        period: 1.2,
        removeOnFinish: true,
        onTick: () => _triggerVoidExplosion(center),
      ),
    );

    // Phase 6: Complete
    add(
      TimerComponent(
        period: 1.8,
        removeOnFinish: true,
        onTick: () => onComplete(),
      ),
    );
  }

  /// 3 orbs at 120° intervals, spiraling inward
  void _spawnWorkerOrbs(Vector2 center) {
    const orbCount = 3;
    const startRadius = 120.0;
    final orbColors = [
      primaryColor.withValues(alpha: 0.9),
      primaryColor.withValues(alpha: 0.7),
      primaryColor.withValues(alpha: 0.5),
    ];

    for (int i = 0; i < orbCount; i++) {
      final startAngle = (i / orbCount) * 2 * pi;

      // Glowing orb
      add(
        ParticleSystemComponent(
          particle: _SpiralOrbParticle(
            center: center,
            startRadius: startRadius,
            startAngle: startAngle,
            color: orbColors[i],
            orbRadius: 6.0 - i * 1.0,
          ),
        ),
      );

      // Trail particles for each orb
      add(
        ParticleSystemComponent(
          particle: Particle.generate(
            count: 30,
            lifespan: 1.0,
            generator: (j) => _OrbTrailParticle(
              center: center,
              startRadius: startRadius - j * 2.0,
              startAngle: startAngle + j * 0.08,
              color: orbColors[i],
              delayFactor: j * 0.02,
            ),
          ),
        ),
      );
    }
  }

  void _spawnSingularity(Vector2 center) {
    // Event Horizon (grows from nothing)
    add(
      CircleComponent(
          radius: 20,
          anchor: Anchor.center,
          position: center,
          paint: Paint()
            ..color = Colors.black
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        )
        ..scale = Vector2.zero()
        ..add(
          ScaleEffect.to(
            Vector2.all(1.0),
            EffectController(
              startDelay: 0.1,
              duration: 0.5,
              curve: Curves.easeOutBack,
            ),
          ),
        )
        ..add(
          ScaleEffect.to(
            Vector2.all(2.0), // Grows as it absorbs
            EffectController(
              startDelay: 0.6,
              duration: 0.5,
              curve: Curves.easeInQuart,
            ),
          ),
        )
        ..add(
          ScaleEffect.to(
            Vector2.zero(), // Collapse before explosion
            EffectController(
              startDelay: 1.15,
              duration: 0.05,
              curve: Curves.easeInExpo,
            ),
          ),
        ),
    );

    // Photon Ring (glowing edge)
    add(
      CircleComponent(
          radius: 22,
          anchor: Anchor.center,
          position: center,
          paint: Paint()
            ..color = primaryColor.withValues(alpha: 0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        )
        ..scale = Vector2.zero()
        ..add(
          ScaleEffect.to(
            Vector2.all(1.0),
            EffectController(
              startDelay: 0.1,
              duration: 0.5,
              curve: Curves.easeOutBack,
            ),
          ),
        )
        ..add(
          ScaleEffect.to(
            Vector2.all(2.0),
            EffectController(
              startDelay: 0.6,
              duration: 0.5,
              curve: Curves.easeInQuart,
            ),
          ),
        )
        ..add(
          ScaleEffect.to(
            Vector2.zero(),
            EffectController(
              startDelay: 1.15,
              duration: 0.05,
              curve: Curves.easeInExpo,
            ),
          ),
        ),
    );

    // Inner glow ring — pulsing
    add(
      CircleComponent(
          radius: 15,
          anchor: Anchor.center,
          position: center,
          paint: Paint()
            ..color = primaryColor.withValues(alpha: 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8.0
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
        )
        ..scale = Vector2.zero()
        ..add(
          ScaleEffect.to(
            Vector2.all(1.2),
            EffectController(
              startDelay: 0.2,
              duration: 0.8,
              curve: Curves.easeOut,
            ),
          ),
        )
        ..add(
          ScaleEffect.to(
            Vector2.zero(),
            EffectController(
              startDelay: 1.15,
              duration: 0.05,
              curve: Curves.easeInExpo,
            ),
          ),
        ),
    );
  }

  void _startAccretionDisk(Vector2 center) {
    add(
      TimerComponent(
        period: 0.03,
        repeat: true,
        autoStart: true,
        onTick: () {
          for (int i = 0; i < 3; i++) {
            add(
              ParticleSystemComponent(
                particle: _AccretionParticle(
                  center: center,
                  color: primaryColor,
                  radius: 70 + _random.nextDouble() * 40,
                  angle: _random.nextDouble() * 2 * pi,
                ),
              ),
            );
          }
        },
      )..add(RemoveEffect(delay: 1.1)), // Stop before explosion
    );
  }

  void _triggerVoidExplosion(Vector2 center) {
    // Double shockwave ring
    for (int i = 0; i < 2; i++) {
      add(
        CircleComponent(
            radius: 8,
            anchor: Anchor.center,
            position: center,
            paint: Paint()
              ..color = i == 0 ? primaryColor : Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = i == 0 ? 5.0 : 2.0
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, i == 0 ? 3 : 1),
          )
          ..add(
            ScaleEffect.to(
              Vector2.all(i == 0 ? 18.0 : 12.0),
              EffectController(
                startDelay: i * 0.05,
                duration: 0.5,
                curve: Curves.easeOutQuad,
              ),
            ),
          )
          ..add(
            OpacityEffect.fadeOut(
              EffectController(startDelay: i * 0.05, duration: 0.5),
              onComplete: () => removeFromParent(),
            ),
          ),
      );
    }

    // Blinding flash
    add(
      CircleComponent(
        radius: 60,
        anchor: Anchor.center,
        position: center,
        paint: Paint()
          ..color = Colors.white
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40),
      )..add(
        OpacityEffect.fadeOut(
          EffectController(duration: 0.35, curve: Curves.easeIn),
          onComplete: () => removeFromParent(),
        ),
      ),
    );

    // High-velocity ejecta rays (directional)
    for (int ray = 0; ray < 8; ray++) {
      final angle = (ray / 8) * 2 * pi;
      add(
        ParticleSystemComponent(
          particle: Particle.generate(
            count: 8,
            lifespan: 0.6,
            generator: (i) {
              final speed = 200.0 + _random.nextDouble() * 300.0;
              final spread = (_random.nextDouble() - 0.5) * 0.3;
              return AcceleratedParticle(
                position: center.clone(),
                speed:
                    Vector2(cos(angle + spread), sin(angle + spread)) * speed,
                child: ComputedParticle(
                  renderer: (canvas, particle) {
                    final opacity = 1.0 - particle.progress;
                    final size = (3.0 - particle.progress * 2.0).clamp(
                      0.5,
                      3.0,
                    );
                    canvas.drawCircle(
                      Offset.zero,
                      size,
                      Paint()..color = primaryColor.withValues(alpha: opacity),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
    }

    // Scattered debris particles
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 40,
          lifespan: 0.8,
          generator: (i) {
            final angle = _random.nextDouble() * 2 * pi;
            final speed = 100.0 + _random.nextDouble() * 200.0;
            return AcceleratedParticle(
              position: center.clone(),
              speed: Vector2(cos(angle), sin(angle)) * speed,
              acceleration: Vector2(0, 60), // Slight gravity
              child: ComputedParticle(
                renderer: (canvas, particle) {
                  final opacity = 1.0 - particle.progress;
                  final paint = Paint()
                    ..color = Color.lerp(
                      primaryColor,
                      Colors.white,
                      _random.nextDouble() * 0.4,
                    )!.withValues(alpha: opacity);
                  canvas.drawCircle(Offset.zero, 1.5, paint);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Worker orb that spirals into the center with 3D tilt
class _SpiralOrbParticle extends Particle {
  final Vector2 center;
  final double startRadius;
  final double startAngle;
  final Color color;
  final double orbRadius;
  double _currentRadius;
  double _currentAngle;

  _SpiralOrbParticle({
    required this.center,
    required this.startRadius,
    required this.startAngle,
    required this.color,
    this.orbRadius = 5.0,
  }) : _currentRadius = startRadius,
       _currentAngle = startAngle,
       super(lifespan: 1.1);

  @override
  void update(double dt) {
    super.update(dt);
    // Accelerating spiral inward
    final speed = 3.0 + progress * 8.0; // Gets faster
    _currentAngle += speed * dt;
    _currentRadius = startRadius * (1.0 - progress);
    if (_currentRadius < 0) _currentRadius = 0;
  }

  @override
  void render(Canvas canvas) {
    final x = cos(_currentAngle) * _currentRadius;
    final y = sin(_currentAngle) * _currentRadius * 0.45; // 3D tilt
    final pos = center + Vector2(x, y);
    final opacity = (1.0 - progress * 0.3).clamp(0.0, 1.0);
    final currentSize = orbRadius * (1.0 - progress * 0.5);

    // Glow
    canvas.drawCircle(
      pos.toOffset(),
      currentSize * 2.5,
      Paint()
        ..color = color.withValues(alpha: opacity * 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Core
    canvas.drawCircle(
      pos.toOffset(),
      currentSize,
      Paint()..color = color.withValues(alpha: opacity),
    );

    // Hot center
    canvas.drawCircle(
      pos.toOffset(),
      currentSize * 0.4,
      Paint()..color = Colors.white.withValues(alpha: opacity * 0.8),
    );
  }
}

/// Trail particle behind each orb
class _OrbTrailParticle extends Particle {
  final Vector2 center;
  final double startRadius;
  final double startAngle;
  final Color color;
  final double delayFactor;
  double _currentRadius;
  double _currentAngle;

  _OrbTrailParticle({
    required this.center,
    required this.startRadius,
    required this.startAngle,
    required this.color,
    this.delayFactor = 0.0,
  }) : _currentRadius = startRadius,
       _currentAngle = startAngle,
       super(lifespan: 0.8);

  @override
  void update(double dt) {
    super.update(dt);
    final t = (progress - delayFactor).clamp(0.0, 1.0);
    final speed = 2.5 + t * 6.0;
    _currentAngle += speed * dt;
    _currentRadius = startRadius * (1.0 - t);
  }

  @override
  void render(Canvas canvas) {
    final t = (progress - delayFactor).clamp(0.0, 1.0);
    if (t <= 0) return;
    final x = cos(_currentAngle) * _currentRadius;
    final y = sin(_currentAngle) * _currentRadius * 0.45;
    final pos = center + Vector2(x, y);
    final opacity = (1.0 - t) * 0.5;
    canvas.drawCircle(
      pos.toOffset(),
      1.5,
      Paint()..color = color.withValues(alpha: opacity),
    );
  }
}

/// Accretion disk particle — ambient swirl around the black hole
class _AccretionParticle extends Particle {
  final Vector2 center;
  final Color color;
  double radius;
  double angle;
  final double speed;

  _AccretionParticle({
    required this.center,
    required this.color,
    required this.radius,
    required this.angle,
  }) : speed = 4.0 + Random().nextDouble() * 4.0,
       super(lifespan: 0.5);

  @override
  void update(double dt) {
    super.update(dt);
    angle += speed * dt;
    radius -= 120 * dt;
    if (radius < 0) radius = 0;
  }

  @override
  void render(Canvas canvas) {
    final x = cos(angle) * radius;
    final y = sin(angle) * radius * 0.45; // 3D tilt
    final pos = center + Vector2(x, y);
    final opacity = (1.0 - progress) * 0.6;
    canvas.drawCircle(
      pos.toOffset(),
      1.5,
      Paint()..color = color.withValues(alpha: opacity),
    );
  }
}
