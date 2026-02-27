import 'dart:math';

import 'package:flame/components.dart';
import 'package:time_factory/core/constants/game_assets.dart';

class CityBackground extends SpriteComponent with HasGameRef {
  double _breathTime = 0.0;
  Vector2 _basePosition = Vector2.zero();

  CityBackground() : super(priority: -100);

  @override
  Future<void> onLoad() async {
    // Load the background image.
    sprite = await gameRef.loadSprite(
      GameAssets.backgroundCity.replaceFirst('assets/images/', ''),
    );

    // Scale to slightly larger than screen for parallax breathing.
    size = gameRef.size * 1.1;
    final overscan = size - gameRef.size;
    _basePosition = -overscan / 2;
    position = _basePosition.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _breathTime += dt;

    // 20s cycle: 0 -> -20 -> 0 to match prior ping-pong drift.
    final phase = (_breathTime / 20.0) * (2 * pi);
    final pingPong = 0.5 - 0.5 * cos(phase); // 0..1..0
    final drift = -20.0 * pingPong;
    position.setValues(_basePosition.x + drift, _basePosition.y + drift);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Maintain 1.1x scale.
    this.size = size * 1.1;
    final overscan = this.size - size;
    _basePosition = -overscan / 2;
  }
}
