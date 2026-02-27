import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class TemporalAnomalyComponent extends PositionComponent with TapCallbacks {
  final VoidCallback onTapped;
  late final CircleComponent _blackHole;
  late final CircleComponent _glow;

  double _lifeTimer = 10.0;
  double _pulseTimer = 0.0;

  TemporalAnomalyComponent({required Vector2 position, required this.onTapped})
    : super(position: position, size: Vector2(60, 60), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    _glow = CircleComponent(
      radius: 40,
      anchor: Anchor.center,
      position: size / 2,
      paint: Paint()
        ..color = Colors.purpleAccent.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );

    _blackHole = CircleComponent(
      radius: 20,
      anchor: Anchor.center,
      position: size / 2,
      paint: Paint()..color = const Color(0xFF050510),
    );

    add(_glow);
    add(_blackHole);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifeTimer -= dt;
    if (_lifeTimer <= 0) {
      removeFromParent();
      return;
    }

    _pulseTimer += dt * 4;
    final scale = 1.0 + 0.15 * sin(_pulseTimer);
    _glow.scale = Vector2.all(scale);

    // Fade out at end of life
    if (_lifeTimer < 2.0) {
      final opacity = _lifeTimer / 2.0;
      _glow.paint.color = Colors.purpleAccent.withOpacity(0.5 * opacity);
      _blackHole.paint.color = const Color(0xFF050510).withOpacity(opacity);
    }
  }

  @override
  void updateTree(double dt) {
    update(dt);
    final snapshot = children.toList(growable: false);
    for (final child in snapshot) {
      child.updateTree(dt);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTapped();
    removeFromParent();
    event.handled = true;
  }
}
