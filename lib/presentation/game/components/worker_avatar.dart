import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/utils/app_log.dart';
import 'package:time_factory/core/utils/worker_icon_helper.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/presentation/game/components/steampunk_worker_painter.dart';
import 'package:time_factory/presentation/game/components/art_deco_worker_painter.dart';

class WorkerAvatar extends PositionComponent with HasGameReference {
  final Worker worker;
  final bool lowPerformanceMode;
  final Random _rng = Random();
  Vector2 _driftOffset = Vector2.zero();
  double _driftDurationSeconds = 5.0;
  double _driftElapsedSeconds = 0.0;
  double _lastDriftFactor = 0.0;

  WorkerAvatar({required this.worker, this.lowPerformanceMode = false});

  @override
  Future<void> onLoad() async {
    // Center anchor for rotation mechanics
    anchor = Anchor.center;
    size = Vector2.all(40); // Define a clickable/visible area size

    final rarityColor = _getRarityColor(worker.rarity);

    if (!lowPerformanceMode) {
      // 1. Pulsing Aura (Background)
      final aura = CircleComponent(
        radius: 12,
        anchor: Anchor.center,
        position: size / 2,
        paint: Paint()
          ..color = rarityColor.withOpacity(0.15)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      final auraPulse = ScaleEffect.to(
        Vector2.all(1.5),
        EffectController(
          duration: 2.0,
          reverseDuration: 2.0,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      );
      auraPulse.target = aura;
      aura.add(auraPulse);
      add(aura);

      // 2. Rotating Data Ring (Outer)
      final ring = _SpinningCircleComponent(
        radiansPerSecond: (2 * pi) / 8.0,
        radius: 18,
        anchor: Anchor.center,
        position: size / 2,
        paint: Paint()
          ..color = rarityColor.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      add(ring);
    }

    // 3. Inner Core (The "Worker" Icon)
    final iconPath = WorkerIconHelper.getIconPath(worker.era, worker.rarity);
    final flamePath = WorkerIconHelper.getFlameLoadPath(
      worker.era,
      worker.rarity,
    );

    try {
      if (WorkerIconHelper.isSvg(worker.era)) {
        // Load SVG using flame_svg
        final svg = await Svg.load(flamePath);
        add(
          SvgComponent(
            svg: svg,
            size: Vector2.all(32),
            anchor: Anchor.center,
            position: size / 2,
            paint: Paint()
              ..colorFilter = ColorFilter.mode(rarityColor, BlendMode.srcIn),
          ),
        );
      } else {
        // Load PNG/raster image via Sprite
        final sprite = await Sprite.load(flamePath);
        add(
          SpriteComponent(
            sprite: sprite,
            size: Vector2.all(32),
            anchor: Anchor.center,
            position: size / 2,
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLog.debug(
        'Failed to load worker icon for ${worker.era.displayName} ${worker.rarity.displayName} ($iconPath)',
        error: e,
        stackTrace: stackTrace,
      );

      // Fallback to Procedural Icon based on Era
      final CustomPainter painter;
      if (worker.era == WorkerEra.roaring20s) {
        painter = ArtDecoWorkerPainter(
          rarity: worker.rarity,
          neonColor: rarityColor,
        );
      } else {
        // Default to Steampunk (Victorian)
        painter = SteampunkWorkerPainter(
          rarity: worker.rarity,
          neonColor: rarityColor,
        );
      }

      add(
        CustomPainterComponent(
          painter: painter,
          size: Vector2.all(40),
          anchor: Anchor.center,
          position: size / 2,
        ),
      );
    }

    // 4. Era Year Label (Floating)
    // add(
    //   TextComponent(
    //     text: worker.era.year.toString(),
    //     textRenderer: TextPaint(
    //       style: TimeFactoryTextStyles.numbersSmall.copyWith(
    //         fontSize: 10,
    //         color: Colors.white,
    //         shadows: [const Shadow(color: Colors.black, blurRadius: 4)],
    //       ),
    //     ),
    //     anchor: Anchor.center,
    //     position: size / 2,
    //   ),
    // );

    if (!lowPerformanceMode) {
      // 5. Floating movement
      _driftOffset = Vector2(
        (_rng.nextDouble() - 0.5) * 60,
        (_rng.nextDouble() - 0.5) * 40,
      );
      _driftDurationSeconds = 4 + _rng.nextDouble() * 3;
      _driftElapsedSeconds = 0.0;
      _lastDriftFactor = 0.0;

      // 6. Data trail particles
      add(
        ParticleSystemComponent(
          particle: Particle.generate(
            count: 5,
            lifespan: 1.0,
            generator: (i) {
              return AcceleratedParticle(
                position:
                    (size / 2) +
                    Vector2(
                      (_rng.nextDouble() - 0.5) * 20,
                      (_rng.nextDouble() - 0.5) * 20,
                    ),
                speed: Vector2(0, -10),
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
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (lowPerformanceMode) return;

    _driftElapsedSeconds += dt;
    final phase = (_driftElapsedSeconds / _driftDurationSeconds) * (2 * pi);
    final driftFactor = 0.5 - 0.5 * cos(phase); // 0..1..0
    final deltaFactor = driftFactor - _lastDriftFactor;
    if (deltaFactor != 0.0) {
      position += _driftOffset * deltaFactor;
    }
    _lastDriftFactor = driftFactor;
  }

  @override
  void updateTree(double dt) {
    update(dt);
    final snapshot = children.toList(growable: false);
    for (final child in snapshot) {
      child.updateTree(dt);
    }
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

class _SpinningCircleComponent extends CircleComponent {
  _SpinningCircleComponent({
    required this.radiansPerSecond,
    required super.radius,
    required super.anchor,
    required super.position,
    required super.paint,
  });

  final double radiansPerSecond;

  @override
  void update(double dt) {
    super.update(dt);
    // Use direct rotation to avoid EffectTarget null-target crashes.
    angle += radiansPerSecond * dt;
  }
}
