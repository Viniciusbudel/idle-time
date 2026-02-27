import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/text_styles.dart';

class FloatingTextComponent extends TextComponent {
  final Color color;
  static const double _moveDistance = 80.0;
  static const double _moveDuration = 1.5;
  static const double _popInDuration = 0.2;
  static const double _shrinkStart = 1.0;
  static const double _shrinkDuration = 0.5;

  late final Vector2 _startPosition;
  double _elapsed = 0.0;
  bool _queuedRemoval = false;

  FloatingTextComponent({
    required String text,
    required Vector2 position,
    required this.color,
  }) : super(
         text: text,
         position: position,
         textRenderer: TextPaint(
           style: TimeFactoryTextStyles.numbers.copyWith(
             fontSize: 24,
             color: color,
             shadows: [Shadow(color: color.withOpacity(0.8), blurRadius: 10)],
           ),
         ),
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _startPosition = position.clone();
    scale = Vector2.all(0.5);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    final moveT = (_elapsed / _moveDuration).clamp(0.0, 1.0);
    final moveProgress = Curves.easeOut.transform(moveT);
    position.setValues(
      _startPosition.x,
      _startPosition.y - (_moveDistance * moveProgress),
    );

    double nextScale = 1.0;
    if (_elapsed <= _popInDuration) {
      final t = (_elapsed / _popInDuration).clamp(0.0, 1.0);
      nextScale = 0.5 + (Curves.elasticOut.transform(t) * 0.5);
    } else if (_elapsed >= _shrinkStart) {
      final t = ((_elapsed - _shrinkStart) / _shrinkDuration).clamp(0.0, 1.0);
      nextScale = 1.0 - Curves.easeIn.transform(t);
    }
    scale = Vector2.all(nextScale.clamp(0.0, 1.25));

    if (_elapsed >= _moveDuration && !_queuedRemoval) {
      _queuedRemoval = true;
      removeFromParent();
    }
  }
}
