# UI Component Templates

Ready-to-use component templates for common game UI elements.

## Button Components

### Basic Button
```dart
class GameButton extends PositionComponent with TapCallbacks, HasGameRef {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  
  late final RoundedRectangle _background;
  late final TextComponent _label;
  bool _isPressed = false;
  
  GameButton({
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF4A90E2),
    this.textColor = const Color(0xFFFFFFFF),
    required Vector2 position,
    Vector2? size,
  }) : super(
    position: position,
    size: size ?? Vector2(200, 60),
    anchor: Anchor.center,
  );
  
  @override
  Future<void> onLoad() async {
    // Background
    _background = RoundedRectangle(
      size: size,
      backgroundColor: backgroundColor,
      borderRadius: 8.0,
    );
    add(_background);
    
    // Label
    _label = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: TextStyle(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: size / 2,
    );
    add(_label);
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    _isPressed = true;
    scale = Vector2.all(0.95);
    _background.backgroundColor = backgroundColor.withOpacity(0.8);
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    _handleRelease();
    onPressed();
  }
  
  @override
  void onTapCancel(TapCancelEvent event) {
    _handleRelease();
  }
  
  void _handleRelease() {
    _isPressed = false;
    scale = Vector2.all(1.0);
    _background.backgroundColor = backgroundColor;
  }
}

// Helper component for rounded rectangle
class RoundedRectangle extends PositionComponent {
  Color backgroundColor;
  final double borderRadius;
  
  RoundedRectangle({
    required Vector2 size,
    required this.backgroundColor,
    this.borderRadius = 8.0,
  }) : super(size: size);
  
  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = backgroundColor;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(rrect, paint);
  }
}
```

### Icon Button
```dart
class IconButton extends PositionComponent with TapCallbacks, HasGameRef {
  final String iconPath;
  final VoidCallback onPressed;
  final double iconSize;
  
  late final SpriteComponent _icon;
  
  IconButton({
    required this.iconPath,
    required this.onPressed,
    required Vector2 position,
    this.iconSize = 48,
  }) : super(
    position: position,
    size: Vector2.all(iconSize + 16),
    anchor: Anchor.center,
  );
  
  @override
  Future<void> onLoad() async {
    // Background circle
    add(CircleComponent(
      radius: size.x / 2,
      paint: Paint()..color = const Color(0x40000000),
    ));
    
    // Icon
    _icon = SpriteComponent(
      sprite: await gameRef.loadSprite(iconPath),
      size: Vector2.all(iconSize),
      anchor: Anchor.center,
      position: size / 2,
    );
    add(_icon);
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    scale = Vector2.all(0.9);
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    scale = Vector2.all(1.0);
    onPressed();
  }
  
  @override
  void onTapCancel(TapCancelEvent event) {
    scale = Vector2.all(1.0);
  }
}
```

## Progress Bars

### Health Bar
```dart
class HealthBar extends PositionComponent {
  double _currentHealth;
  final double maxHealth;
  final Vector2 barSize;
  final Color fillColor;
  final Color backgroundColor;
  
  late final RectangleComponent _background;
  late final RectangleComponent _fill;
  
  HealthBar({
    required double currentHealth,
    required this.maxHealth,
    required Vector2 position,
    this.barSize = const Vector2(200, 20),
    this.fillColor = const Color(0xFF4CAF50),
    this.backgroundColor = const Color(0xFF2C2C2C),
  }) : _currentHealth = currentHealth,
       super(position: position, size: barSize);
  
  @override
  Future<void> onLoad() async {
    // Background
    _background = RectangleComponent(
      size: size,
      paint: Paint()..color = backgroundColor,
    );
    add(_background);
    
    // Fill
    _fill = RectangleComponent(
      size: Vector2(size.x * (_currentHealth / maxHealth), size.y),
      paint: Paint()..color = fillColor,
    );
    add(_fill);
  }
  
  void updateHealth(double newHealth) {
    _currentHealth = newHealth.clamp(0, maxHealth);
    final targetWidth = size.x * (_currentHealth / maxHealth);
    
    // Smooth interpolation
    _fill.add(
      SizeEffect.to(
        Vector2(targetWidth, size.y),
        EffectController(duration: 0.3, curve: Curves.easeOut),
      ),
    );
    
    // Color transition on low health
    if (_currentHealth / maxHealth < 0.3) {
      _fill.paint.color = const Color(0xFFE53935);
    }
  }
}
```

### Animated Progress Bar
```dart
class AnimatedProgressBar extends PositionComponent {
  double _progress = 0.0;
  final Vector2 barSize;
  
  AnimatedProgressBar({
    required Vector2 position,
    this.barSize = const Vector2(300, 24),
  }) : super(position: position, size: barSize);
  
  @override
  Future<void> onLoad() async {
    // Background with border
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF1A1A1A)
        ..style = PaintingStyle.fill,
    ));
    
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF666666)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    ));
  }
  
  void setProgress(double value, {Duration duration = const Duration(milliseconds: 500)}) {
    _progress = value.clamp(0.0, 1.0);
    
    // Animated gradient fill would be rendered in custom render method
    // This is simplified version
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Gradient fill
    final gradient = LinearGradient(
      colors: [
        const Color(0xFF4A90E2),
        const Color(0xFF67B26F),
      ],
    );
    
    final fillWidth = size.x * _progress;
    final rect = Rect.fromLTWH(2, 2, fillWidth - 4, size.y - 4);
    
    canvas.drawRect(
      rect,
      Paint()..shader = gradient.createShader(rect),
    );
  }
}
```

## Text Components

### Score Display
```dart
class ScoreDisplay extends PositionComponent {
  int _score = 0;
  late final TextComponent _scoreText;
  
  ScoreDisplay({required Vector2 position})
      : super(position: position, anchor: Anchor.topRight);
  
  @override
  Future<void> onLoad() async {
    // Label
    add(TextComponent(
      text: 'SCORE',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFAAAAAA),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topRight,
    ));
    
    // Score value
    _scoreText = TextComponent(
      text: '0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topRight,
      position: Vector2(0, 20),
    );
    add(_scoreText);
  }
  
  void updateScore(int newScore) {
    final oldScore = _score;
    _score = newScore;
    
    // Pulse animation on score increase
    if (newScore > oldScore) {
      _scoreText.add(
        SequenceEffect([
          ScaleEffect.to(
            Vector2.all(1.2),
            EffectController(duration: 0.1),
          ),
          ScaleEffect.to(
            Vector2.all(1.0),
            EffectController(duration: 0.1),
          ),
        ]),
      );
    }
    
    _scoreText.text = newScore.toString();
  }
}
```

### Timer Display
```dart
class TimerDisplay extends PositionComponent {
  double _timeRemaining;
  late final TextComponent _timerText;
  
  TimerDisplay({
    required Vector2 position,
    required double initialTime,
  }) : _timeRemaining = initialTime,
       super(position: position, anchor: Anchor.center);
  
  @override
  Future<void> onLoad() async {
    _timerText = TextComponent(
      text: _formatTime(_timeRemaining),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 48,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      anchor: Anchor.center,
    );
    add(_timerText);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    _timeRemaining -= dt;
    
    if (_timeRemaining < 0) _timeRemaining = 0;
    
    _timerText.text = _formatTime(_timeRemaining);
    
    // Red color when under 10 seconds
    if (_timeRemaining < 10) {
      (_timerText.textRenderer as TextPaint).style = TextStyle(
        color: Color(0xFFE53935),
        fontSize: 48,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      );
    }
  }
  
  String _formatTime(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
```

## Panel Components

### Info Panel
```dart
class InfoPanel extends PositionComponent {
  final String title;
  final String content;
  final VoidCallback? onClose;
  
  InfoPanel({
    required this.title,
    required this.content,
    this.onClose,
    required Vector2 position,
    Vector2? size,
  }) : super(
    position: position,
    size: size ?? Vector2(400, 300),
    anchor: Anchor.center,
  );
  
  @override
  Future<void> onLoad() async {
    // Semi-transparent background
    add(RoundedRectangle(
      size: size,
      backgroundColor: const Color(0xE0000000),
      borderRadius: 12,
    ));
    
    // Title
    add(TextComponent(
      text: title,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, 30),
      anchor: Anchor.center,
    ));
    
    // Content
    add(TextComponent(
      text: content,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFCCCCCC),
          fontSize: 18,
        ),
      ),
      position: Vector2(20, 80),
    ));
    
    // Close button
    if (onClose != null) {
      add(IconButton(
        iconPath: 'ui/close_icon.png',
        onPressed: onClose!,
        position: Vector2(size.x - 20, 20),
      ));
    }
    
    // Entrance animation
    scale = Vector2.all(0.8);
    opacity = 0;
    add(
      SequenceEffect([
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

## Usage Notes

All components support:
- Custom positioning via `position` parameter
- Anchor points for alignment
- Priority ordering for layering
- Animation effects for polish

Extend these templates with game-specific styling and behavior.