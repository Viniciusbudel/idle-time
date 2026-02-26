import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/services.dart';
import 'package:time_factory/core/constants/game_assets.dart';
import 'package:time_factory/presentation/game/time_factory_game.dart';

class ReactorComponent extends PositionComponent
    with TapCallbacks, HasGameReference<TimeFactoryGame> {
  static const double _baseSpinSpeed = 0.7;
  static const double _tapSpinBoost = 0.45;
  static const double _maxSpinSpeed = 6.0;
  static const double _spinDecayPerSecond = 1.8;

  final SvgComponent _icon;

  double _spinSpeed = _baseSpinSpeed;

  ReactorComponent._({required Svg svg, required Vector2 reactorSize})
    : _icon = SvgComponent(
        svg: svg,
        size: reactorSize,
        position: reactorSize / 2,
        anchor: Anchor.center,
      ),
      super(size: reactorSize, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = game.size / 2;
    add(_icon);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = size / 2;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _icon.angle += _spinSpeed * dt;

    if (_spinSpeed > _baseSpinSpeed) {
      _spinSpeed = math.max(
        _baseSpinSpeed,
        _spinSpeed - (_spinDecayPerSecond * dt),
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.handleReactorTap();
    HapticFeedback.mediumImpact();

    _spinSpeed = (_spinSpeed + _tapSpinBoost).clamp(
      _baseSpinSpeed,
      _maxSpinSpeed,
    );

    add(
      ScaleEffect.to(
        Vector2.all(0.93),
        EffectController(duration: 0.06, reverseDuration: 0.08),
      ),
    );
  }

  static Future<ReactorComponent> create(double size, {String? eraId}) async {
    final path = GameAssets.steampunkReactor.replaceFirst('assets/', '');
    final svg = await Svg.load(path);
    return ReactorComponent._(svg: svg, reactorSize: Vector2.all(size));
  }
}
