# Dialog System

Complete modal dialog implementation for game UI.

## Basic Dialog Component

```dart
class GameDialog extends PositionComponent with HasGameRef {
  final String title;
  final String message;
  final List<DialogButton> buttons;
  final bool dismissible;
  
  GameDialog({
    required this.title,
    required this.message,
    required this.buttons,
    this.dismissible = true,
  });
  
  @override
  Future<void> onLoad() async {
    final screenSize = gameRef.size;
    final dialogWidth = min(screenSize.x * 0.85, 450.0);
    final dialogHeight = min(screenSize.y * 0.7, 400.0);
    
    // Backdrop
    final backdrop = RectangleComponent(
      size: screenSize,
      paint: Paint()..color = Colors.black.withOpacity(0.75),
    );
    
    if (dismissible) {
      backdrop.add(TapCallbacks()
        ..onTapDown = (_) => close());
    }
    add(backdrop);
    
    // Dialog panel
    final panel = _createPanel(dialogWidth, dialogHeight);
    panel.position = (screenSize - Vector2(dialogWidth, dialogHeight)) / 2;
    add(panel);
    
    // Entrance animation
    _animateEntrance(panel);
  }
  
  Component _createPanel(double width, double height) {
    final panel = PositionComponent(size: Vector2(width, height));
    
    // Background
    panel.add(RoundedRectangle(
      size: Vector2(width, height),
      backgroundColor: Color(0xFF2A2A2A),
      borderRadius: 16,
    ));
    
    // Title
    panel.add(TextComponent(
      text: title,
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
      position: Vector2(width / 2, 40),
      anchor: Anchor.center,
    ));
    
    // Message
    panel.add(TextComponent(
      text: message,
      textRenderer: TextPaint(style: TextStyle(fontSize: 18)),
      position: Vector2(30, 100),
    ));
    
    // Buttons
    final buttonY = height - 80;
    final buttonSpacing = width / (buttons.length + 1);
    
    for (var i = 0; i < buttons.length; i++) {
      panel.add(GameButton(
        text: buttons[i].text,
        onPressed: () {
          buttons[i].onPressed();
          close();
        },
        position: Vector2(buttonSpacing * (i + 1), buttonY),
        size: Vector2(150, 55),
      ));
    }
    
    return panel;
  }
  
  void _animateEntrance(Component panel) {
    panel.scale = Vector2.all(0.7);
    panel.opacity = 0;
    
    panel.add(
      ParallelEffect([
        OpacityEffect.fadeIn(EffectController(duration: 0.25)),
        ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(duration: 0.35, curve: Curves.easeOutBack),
        ),
      ]),
    );
  }
  
  void close() {
    add(
      SequenceEffect([
        ParallelEffect([
          OpacityEffect.fadeOut(EffectController(duration: 0.2)),
          ScaleEffect.to(
            Vector2.all(0.8),
            EffectController(duration: 0.2, curve: Curves.easeIn),
          ),
        ]),
      ])..onComplete = () => removeFromParent(),
    );
  }
}

class DialogButton {
  final String text;
  final VoidCallback onPressed;
  
  DialogButton({required this.text, required this.onPressed});
}
```

## Confirmation Dialog

```dart
void showConfirmationDialog(
  FlameGame game,
  String title,
  String message,
  VoidCallback onConfirm,
) {
  game.add(
    GameDialog(
      title: title,
      message: message,
      buttons: [
        DialogButton(text: 'CANCEL', onPressed: () {}),
        DialogButton(text: 'CONFIRM', onPressed: onConfirm),
      ],
    ),
  );
}
```

## Achievement Dialog

```dart
class AchievementDialog extends GameDialog {
  final String achievementName;
  final String iconPath;
  
  AchievementDialog({
    required this.achievementName,
    required this.iconPath,
  }) : super(
    title: '🎉 ACHIEVEMENT UNLOCKED!',
    message: achievementName,
    buttons: [
      DialogButton(text: 'AWESOME!', onPressed: () {}),
    ],
    dismissible: true,
  );
  
  // Add sparkle particle effects, custom styling, etc.
}
```

Use these dialog patterns to create consistent, polished modal interactions throughout your game.