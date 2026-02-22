import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/text_styles.dart';

class FloatingTextComponent extends TextComponent {
  final Color color;

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
             shadows: [
               Shadow(color: color.withOpacity( 0.8), blurRadius: 10),
             ],
           ),
         ),
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    // Move up
    add(
      MoveEffect.by(
        Vector2(0, -80),
        EffectController(duration: 1.5, curve: Curves.easeOut),
      ),
    );

    // Scale down and remove
    add(
      ScaleEffect.to(
        Vector2.zero(),
        EffectController(
          duration: 0.5,
          startDelay: 1.0, // Wait a bit before shrinking
          curve: Curves.easeIn,
        ),
        onComplete: () => removeFromParent(),
      ),
    );

    // Scale up slightly at start for pop effect
    scale = Vector2.all(0.5);
    add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.2, curve: Curves.elasticOut),
      ),
    );
  }
}
