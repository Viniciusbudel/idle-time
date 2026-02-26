import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/services.dart';
import 'package:time_factory/core/constants/game_assets.dart';
import 'package:time_factory/presentation/game/time_factory_game.dart';
import 'package:flame/effects.dart';

class FallbackReactor extends SvgComponent
    with TapCallbacks, HasGameRef<TimeFactoryGame> {
  FallbackReactor({super.svg, super.size}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = gameRef.size / 2;

    // Add a spin effect since it's the fallback for the "animated" reactor
    final spinEffect = RotateEffect.by(
      6.28, // 360 degrees
      EffectController(
        duration: 1.0, // FAST spin to identify FALLBACK
        infinite: true,
      ),
    );
    spinEffect.target = this;
    add(spinEffect);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = size / 2;
  }

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.handleReactorTap();
    HapticFeedback.mediumImpact();
    final tapBounce = ScaleEffect.to(
      Vector2.all(0.9),
      EffectController(duration: 0.05, reverseDuration: 0.05),
    );
    tapBounce.target = this;
    add(tapBounce);
  }

  static Future<FallbackReactor> create(double size) async {
    // Svg.load looks in 'assets/' by default? Or 'assets/images/'?
    // The previous error "assets/icons/..." suggests it prepended "assets/" to "icons/..."
    // So if we want "assets/images/icons/...", we should pass "images/icons/..."
    final path = GameAssets.temporalReactor.replaceFirst('assets/', '');
    final svg = await Svg.load(path);
    return FallbackReactor(svg: svg, size: Vector2.all(size));
  }
}
