import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';

class CyberpunkRain extends Component with HasGameRef {
  final Random _rng = Random();
  late final double _spawnRate;
  double _timer = 0;

  // Config
  final int maxDrops = 50;
  final List<RainDrop> _drops = [];

  CyberpunkRain() {
    // Spawn a drop every 0.1 seconds roughly, adjusted by max drops
    _spawnRate = 0.05;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _timer += dt;
    if (_timer >= _spawnRate && _drops.length < maxDrops) {
      _spawnDrop();
      _timer = 0;
    }

    // Update drops
    for (var i = _drops.length - 1; i >= 0; i--) {
      final drop = _drops[i];
      drop.update(dt);

      if (drop.y > gameRef.size.y) {
        _drops.removeAt(i);
      }
    }
  }

  void _spawnDrop() {
    final x = _rng.nextDouble() * gameRef.size.x;
    final speed = 100 + _rng.nextDouble() * 200;
    final length = 10 + _rng.nextDouble() * 20;
    final color = _rng.nextBool()
        ? TimeFactoryColors.electricCyan
        : TimeFactoryColors.deepPurple;

    _drops.add(
      RainDrop(
        x: x,
        y: -50,
        speed: speed,
        length: length,
        color: color.withOpacity( 0.3 + _rng.nextDouble() * 0.4),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..strokeWidth = 2;

    for (final drop in _drops) {
      paint.color = drop.color;
      canvas.drawLine(
        Offset(drop.x, drop.y),
        Offset(drop.x, drop.y - drop.length), // Draw tail up
        paint,
      );
    }
  }
}

class RainDrop {
  double x;
  double y;
  double speed;
  double length;
  Color color;

  RainDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
    required this.color,
  });

  void update(double dt) {
    y += speed * dt;
  }
}
