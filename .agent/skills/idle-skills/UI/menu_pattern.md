# Menu Patterns

Complete implementations for common game menu screens.

## Main Menu

```dart
class MainMenuScreen extends Component with HasGameRef {
  @override
  Future<void> onLoad() async {
    // Background
    final bg = SpriteComponent(
      sprite: await gameRef.loadSprite('backgrounds/main_menu.png'),
      size: gameRef.size,
    );
    add(bg);
    
    // Game title
    final title = TextComponent(
      text: 'AWESOME GAME',
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(blurRadius: 10, color: Colors.black)],
        ),
      ),
      position: Vector2(gameRef.size.x / 2, gameRef.size.y * 0.25),
      anchor: Anchor.center,
    );
    add(title);
    
    // Buttons
    final playButton = GameButton(
      text: 'PLAY',
      onPressed: _onPlayPressed,
      position: Vector2(gameRef.size.x / 2, gameRef.size.y * 0.5),
      size: Vector2(250, 70),
    );
    add(playButton);
    
    final settingsButton = GameButton(
      text: 'SETTINGS',
      onPressed: _onSettingsPressed,
      position: Vector2(gameRef.size.x / 2, gameRef.size.y * 0.62),
      size: Vector2(250, 70),
    );
    add(settingsButton);
    
    final exitButton = GameButton(
      text: 'EXIT',
      onPressed: _onExitPressed,
      position: Vector2(gameRef.size.x / 2, gameRef.size.y * 0.74),
      size: Vector2(250, 70),
    );
    add(exitButton);
    
    // Entrance animations
    _animateEntrance();
  }
  
  void _animateEntrance() {
    // Title fade and scale
    title.opacity = 0;
    title.scale = Vector2.all(0.5);
    title.add(
      ParallelEffect([
        OpacityEffect.fadeIn(EffectController(duration: 0.5)),
        ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(duration: 0.5, curve: Curves.easeOutBack),
        ),
      ]),
    );
    
    // Stagger button reveals
    final buttons = [playButton, settingsButton, exitButton];
    for (var i = 0; i < buttons.length; i++) {
      buttons[i].opacity = 0;
      buttons[i].add(
        OpacityEffect.fadeIn(
          EffectController(
            duration: 0.3,
            startDelay: 0.5 + i * 0.1,
          ),
        ),
      );
    }
  }
}
```

## Pause Menu

```dart
class PauseMenu extends Component with HasGameRef {
  @override
  Future<void> onLoad() async {
    // Dimmed background
    final dimmer = RectangleComponent(
      size: gameRef.size,
      paint: Paint()..color = Colors.black.withOpacity(0.8),
    );
    add(dimmer);
    
    // Panel
    final panelWidth = 400.0;
    final panelHeight = 500.0;
    final panel = RoundedRectangle(
      size: Vector2(panelWidth, panelHeight),
      backgroundColor: Color(0xFF1A1A1A),
      borderRadius: 20,
    );
    panel.position = (gameRef.size - Vector2(panelWidth, panelHeight)) / 2;
    add(panel);
    
    // PAUSED text
    final pausedText = TextComponent(
      text: 'PAUSED',
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
      ),
      position: Vector2(panelWidth / 2, 60),
      anchor: Anchor.center,
    );
    panel.add(pausedText);
    
    // Resume button
    panel.add(GameButton(
      text: 'RESUME',
      onPressed: () => gameRef.resumeEngine(),
      position: Vector2(panelWidth / 2, 180),
      size: Vector2(280, 60),
    ));
    
    // Restart button
    panel.add(GameButton(
      text: 'RESTART',
      onPressed: _onRestart,
      position: Vector2(panelWidth / 2, 260),
      size: Vector2(280, 60),
    ));
    
    // Main Menu button
    panel.add(GameButton(
      text: 'MAIN MENU',
      onPressed: _onMainMenu,
      position: Vector2(panelWidth / 2, 340),
      size: Vector2(280, 60),
    ));
    
    // Settings button
    panel.add(IconButton(
      iconPath: 'ui/settings_icon.png',
      onPressed: _onSettings,
      position: Vector2(panelWidth / 2, 420),
    ));
    
    // Entrance animation
    panel.scale = Vector2.all(0.8);
    panel.opacity = 0;
    panel.add(
      ParallelEffect([
        OpacityEffect.fadeIn(EffectController(duration: 0.2)),
        ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(duration: 0.3, curve: Curves.easeOutBack),
        ),
      ]),
    );
  }
}
```

See other patterns in this file for Settings Menu, Level Select, and Game Over screens.