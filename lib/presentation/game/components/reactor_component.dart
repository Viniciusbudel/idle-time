import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_lottie/flame_lottie.dart';
import 'package:flutter/services.dart';
import 'package:time_factory/core/constants/game_assets.dart';
import 'package:time_factory/presentation/game/time_factory_game.dart';

class ReactorComponent extends LottieComponent
    with TapCallbacks, HasGameRef<TimeFactoryGame> {
  ReactorComponent(super.composition, {super.size})
    : super(anchor: Anchor.center, repeating: true);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Ensure it's centered in the game world
    position = gameRef.size / 2;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = size / 2;
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Forward tap to game logic
    gameRef.handleReactorTap();

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Visual feedback (scale down)
    // add(
    //   ScaleEffect.to(
    //     Vector2.all(0.9),
    //     EffectController(duration: 0.05, reverseDuration: 0.05),
    //   ),
    // );
  }

  static Future<ReactorComponent> create(double size) async {
    final composition = await AssetLottie(GameAssets.lottieReactor).load();
    return ReactorComponent(composition, size: Vector2.all(size));
  }
}
