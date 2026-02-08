import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/widgets.dart'; // for Curves
import 'package:time_factory/core/constants/game_assets.dart';

class CityBackground extends SpriteComponent with HasGameRef {
  CityBackground() : super(priority: -100);

  @override
  Future<void> onLoad() async {
    // Load the background image
    sprite = await gameRef.loadSprite(
      GameAssets.backgroundCity.replaceFirst('assets/images/', ''),
    );

    // Scale to slightly larger than screen for parallax breathing
    size = gameRef.size * 1.1;
    position = Vector2(0, 0); // Start at top-left

    // Center it initially relative to overscan
    final overscan = size - gameRef.size;
    position = -overscan / 2;

    // Add breathing effect (slow gentle movement)
    add(
      MoveEffect.by(
        Vector2(-20, -20),
        EffectController(
          duration: 10,
          reverseDuration: 10,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Maintain 1.1x scale
    this.size = size * 1.1;

    // Recenter approximately (resetting position might be jarring,
    // but needed to handle resize accurately)
    // We don't reset position here to avoid jumping during resize,
    // relying on the scale update to cover mostly.
  }
}
