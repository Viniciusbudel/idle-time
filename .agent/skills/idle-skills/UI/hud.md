# HUD Components

Templates for heads-up display elements in games.

## Score Counter with Animation

```dart
class AnimatedScoreCounter extends PositionComponent {
  int _displayScore = 0;
  int _targetScore = 0;
  final double _animationSpeed = 10.0;
  
  late final TextComponent _scoreText;
  
  @override
  Future<void> onLoad() async {
    _scoreText = TextComponent(
      text: '0',
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
      ),
      anchor: Anchor.topRight,
    );
    add(_scoreText);
  }
  
  void addScore(int points) {
    _targetScore += points;
    
    // Pulse effect on score increase
    _scoreText.add(
      SequenceEffect([
        ScaleEffect.to(Vector2.all(1.3), EffectController(duration: 0.1)),
        ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.1)),
      ]),
    );
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (_displayScore != _targetScore) {
      final diff = _targetScore - _displayScore;
      final change = (diff.abs() * _animationSpeed * dt).ceil();
      
      if (diff > 0) {
        _displayScore = min(_displayScore + change, _targetScore);
      } else {
        _displayScore = max(_displayScore - change, _targetScore);
      }
      
      _scoreText.text = _displayScore.toString();
    }
  }
}
```

## Multi-Segment Health Bar

```dart
class SegmentedHealthBar extends PositionComponent {
  final int segments;
  final double segmentWidth;
  final double segmentHeight;
  final double segmentSpacing;
  int currentSegments;
  
  SegmentedHealthBar({
    required this.segments,
    required this.currentSegments,
    this.segmentWidth = 30,
    this.segmentHeight = 10,
    this.segmentSpacing = 5,
    required Vector2 position,
  }) : super(position: position);
  
  @override
  Future<void> onLoad() async {
    for (var i = 0; i < segments; i++) {
      final segment = RectangleComponent(
        size: Vector2(segmentWidth, segmentHeight),
        position: Vector2(i * (segmentWidth + segmentSpacing), 0),
        paint: Paint()..color = i < currentSegments 
          ? Color(0xFF4CAF50) 
          : Color(0xFF333333),
      );
      add(segment);
    }
  }
  
  void loseSegment() {
    if (currentSegments > 0) {
      currentSegments--;
      final segment = children.elementAt(currentSegments) as RectangleComponent;
      
      // Flash and fade
      segment.add(
        SequenceEffect([
          ColorEffect(
            Colors.red,
            EffectController(duration: 0.2),
          ),
          ColorEffect(
            Color(0xFF333333),
            EffectController(duration: 0.3),
          ),
        ]),
      );
    }
  }
}
```

## Combo Counter

```dart
class ComboCounter extends PositionComponent {
  int _comboCount = 0;
  Timer? _resetTimer;
  final double resetDelay = 2.0;
  
  late final TextComponent _comboText;
  late final TextComponent _multiplierText;
  
  @override
  Future<void> onLoad() async {
    _comboText = TextComponent(
      text: 'COMBO',
      textRenderer: TextPaint(style: TextStyle(fontSize: 20)),
      anchor: Anchor.center,
    );
    add(_comboText);
    
    _multiplierText = TextComponent(
      text: 'x0',
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
      ),
      position: Vector2(0, 30),
      anchor: Anchor.center,
    );
    add(_multiplierText);
    
    opacity = 0;
  }
  
  void incrementCombo() {
    _comboCount++;
    _multiplierText.text = 'x$_comboCount';
    
    // Show combo counter
    if (opacity == 0) {
      add(OpacityEffect.fadeIn(EffectController(duration: 0.2)));
    }
    
    // Pulse animation
    add(
      SequenceEffect([
        ScaleEffect.to(Vector2.all(1.2), EffectController(duration: 0.1)),
        ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.1)),
      ]),
    );
    
    // Reset timer
    _resetTimer?.stop();
    _resetTimer = Timer(resetDelay, onTick: _resetCombo);
  }
  
  void _resetCombo() {
    _comboCount = 0;
    add(OpacityEffect.fadeOut(EffectController(duration: 0.3)));
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    _resetTimer?.update(dt);
  }
}
```

## Mini-map

```dart
class Minimap extends PositionComponent {
  final Vector2 worldSize;
  final Vector2 minimapSize;
  final Color backgroundColor;
  
  Minimap({
    required this.worldSize,
    required this.minimapSize,
    this.backgroundColor = const Color(0x80000000),
    required Vector2 position,
  }) : super(position: position, size: minimapSize);
  
  @override
  void render(Canvas canvas) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = backgroundColor,
    );
    
    // Border
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    
    // Player marker (would be updated based on actual position)
    final playerPos = _worldToMinimapPos(Vector2.zero()); // Example
    canvas.drawCircle(
      playerPos.toOffset(),
      4,
      Paint()..color = Colors.blue,
    );
  }
  
  Vector2 _worldToMinimapPos(Vector2 worldPos) {
    return Vector2(
      (worldPos.x / worldSize.x) * size.x,
      (worldPos.y / worldSize.y) * size.y,
    );
  }
}
```

These HUD components are designed for performance and visual polish. Customize styling to match your game's aesthetic.