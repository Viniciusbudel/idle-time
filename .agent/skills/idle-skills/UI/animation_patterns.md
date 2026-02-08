# Animation Patterns

Complex animation sequences and patterns for professional game UI.

## Entrance Animations

### Staggered Fade-In
```dart
void addStaggeredFadeIn(List<Component> components, {
  double staggerDelay = 0.1,
  double duration = 0.3,
}) {
  for (var i = 0; i < components.length; i++) {
    components[i].add(
      OpacityEffect.fadeIn(
        EffectController(
          duration: duration,
          startDelay: i * staggerDelay,
          curve: Curves.easeOut,
        ),
      ),
    );
  }
}
```

### Slide-In from Direction
```dart
enum SlideDirection { left, right, top, bottom }

void slideIn(Component component, SlideDirection direction, {
  double distance = 500,
  double duration = 0.5,
}) {
  final startPos = component.position.clone();
  
  switch (direction) {
    case SlideDirection.left:
      component.position.x -= distance;
      break;
    case SlideDirection.right:
      component.position.x += distance;
      break;
    case SlideDirection.top:
      component.position.y -= distance;
      break;
    case SlideDirection.bottom:
      component.position.y += distance;
      break;
  }
  
  component.add(
    MoveEffect.to(
      startPos,
      EffectController(
        duration: duration,
        curve: Curves.easeOutCubic,
      ),
    ),
  );
}
```

### Pop-In Effect
```dart
void popIn(Component component, {double duration = 0.4}) {
  component.scale = Vector2.all(0);
  component.add(
    ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(
        duration: duration,
        curve: Curves.elasticOut,
      ),
    ),
  );
}
```

## Exit Animations

### Fade Out and Remove
```dart
void fadeOutAndRemove(Component component, {
  double duration = 0.3,
  VoidCallback? onComplete,
}) {
  component.add(
    OpacityEffect.fadeOut(
      EffectController(duration: duration),
    )..onComplete = () {
      component.removeFromParent();
      onComplete?.call();
    },
  );
}
```

### Shrink and Disappear
```dart
void shrinkAndRemove(Component component) {
  component.add(
    SequenceEffect([
      ScaleEffect.to(
        Vector2.all(0),
        EffectController(
          duration: 0.3,
          curve: Curves.easeInBack,
        ),
      ),
    ])..onComplete = () => component.removeFromParent(),
  );
}
```

## Transition Animations

### Screen Transition
```dart
class ScreenTransition {
  static Future<void> crossFade(
    Component oldScreen,
    Component newScreen,
    FlameGame game,
  ) async {
    // Add new screen
    newScreen.opacity = 0;
    game.add(newScreen);
    
    // Fade out old, fade in new
    await Future.wait([
      oldScreen.add(
        OpacityEffect.fadeOut(
          EffectController(duration: 0.3),
        ),
      ).future,
      newScreen.add(
        OpacityEffect.fadeIn(
          EffectController(
            duration: 0.3,
            startDelay: 0.1,
          ),
        ),
      ).future,
    ]);
    
    oldScreen.removeFromParent();
  }
  
  static Future<void> slideTransition(
    Component oldScreen,
    Component newScreen,
    FlameGame game,
    {SlideDirection direction = SlideDirection.left}
  ) async {
    final screenWidth = game.size.x;
    
    // Position new screen off-screen
    switch (direction) {
      case SlideDirection.left:
        newScreen.position.x = screenWidth;
        break;
      case SlideDirection.right:
        newScreen.position.x = -screenWidth;
        break;
      default:
        break;
    }
    
    game.add(newScreen);
    
    // Slide both screens
    await Future.wait([
      oldScreen.add(
        MoveEffect.by(
          Vector2(-screenWidth, 0),
          EffectController(duration: 0.4, curve: Curves.easeInOut),
        ),
      ).future,
      newScreen.add(
        MoveEffect.by(
          Vector2(-screenWidth, 0),
          EffectController(duration: 0.4, curve: Curves.easeInOut),
        ),
      ).future,
    ]);
    
    oldScreen.removeFromParent();
  }
}
```

## Interactive Animations

### Hover Effect (for desktop/web)
```dart
class HoverableComponent extends PositionComponent with HoverCallbacks {
  bool _isHovered = false;
  
  @override
  void onHoverEnter() {
    _isHovered = true;
    add(
      ScaleEffect.to(
        Vector2.all(1.05),
        EffectController(duration: 0.15),
      ),
    );
  }
  
  @override
  void onHoverExit() {
    _isHovered = false;
    add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.15),
      ),
    );
  }
}
```

### Press Animation
```dart
mixin PressAnimation on Component implements TapCallbacks {
  void animatePress() {
    add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2.all(0.9),
          EffectController(duration: 0.1),
        ),
        ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(duration: 0.1, curve: Curves.easeOutBack),
        ),
      ]),
    );
  }
}
```

### Shake Effect
```dart
void shake(Component component, {
  double intensity = 10,
  int count = 5,
  double duration = 0.5,
}) {
  final originalPos = component.position.clone();
  final random = Random();
  
  final effects = <Effect>[];
  for (var i = 0; i < count; i++) {
    effects.add(
      MoveEffect.to(
        originalPos + Vector2(
          (random.nextDouble() - 0.5) * intensity,
          (random.nextDouble() - 0.5) * intensity,
        ),
        EffectController(duration: duration / count),
      ),
    );
  }
  
  effects.add(
    MoveEffect.to(
      originalPos,
      EffectController(duration: duration / count),
    ),
  );
  
  component.add(SequenceEffect(effects));
}
```

## Looping Animations

### Pulse Effect
```dart
void addPulseEffect(Component component, {
  double minScale = 0.95,
  double maxScale = 1.05,
  double duration = 1.0,
}) {
  component.add(
    SequenceEffect([
      ScaleEffect.to(
        Vector2.all(maxScale),
        EffectController(duration: duration / 2, curve: Curves.easeInOut),
      ),
      ScaleEffect.to(
        Vector2.all(minScale),
        EffectController(duration: duration / 2, curve: Curves.easeInOut),
      ),
    ], infinite: true),
  );
}
```

### Floating Animation
```dart
void addFloatingEffect(Component component, {
  double amplitude = 10,
  double duration = 2.0,
}) {
  final startY = component.position.y;
  
  component.add(
    SequenceEffect([
      MoveEffect.to(
        Vector2(component.position.x, startY - amplitude),
        EffectController(duration: duration / 2, curve: Curves.easeInOut),
      ),
      MoveEffect.to(
        Vector2(component.position.x, startY + amplitude),
        EffectController(duration: duration / 2, curve: Curves.easeInOut),
      ),
    ], infinite: true),
  );
}
```

### Rotation Animation
```dart
void addRotationEffect(Component component, {
  double rotationsPerSecond = 0.5,
}) {
  component.add(
    RotateEffect.by(
      2 * pi,
      EffectController(
        duration: 1 / rotationsPerSecond,
        infinite: true,
      ),
    ),
  );
}
```

## Value Interpolation

### Smooth Counter
```dart
class SmoothCounter extends Component {
  double _currentValue = 0;
  double _targetValue = 0;
  final double _interpolationSpeed = 5.0;
  
  void setTarget(double target) {
    _targetValue = target;
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    final diff = _targetValue - _currentValue;
    if (diff.abs() > 0.1) {
      _currentValue += diff * _interpolationSpeed * dt;
    } else {
      _currentValue = _targetValue;
    }
  }
  
  int get displayValue => _currentValue.round();
}
```

### Color Transition
```dart
void transitionColor(
  Component component,
  Color targetColor, {
  double duration = 0.5,
}) {
  component.add(
    ColorEffect(
      targetColor,
      EffectController(duration: duration),
      opacityTo: targetColor.opacity,
    ),
  );
}
```

## Particle Animations

### Confetti Explosion
```dart
void spawnConfetti(Vector2 position, FlameGame game) {
  final confetti = ParticleSystemComponent(
    particle: Particle.generate(
      count: 50,
      lifespan: 2,
      generator: (i) {
        final angle = Random().nextDouble() * 2 * pi;
        final speed = 100 + Random().nextDouble() * 200;
        
        return AcceleratedParticle(
          acceleration: Vector2(0, 200), // Gravity
          speed: Vector2(cos(angle), sin(angle)) * speed,
          child: CircleParticle(
            radius: 3 + Random().nextDouble() * 3,
            paint: Paint()..color = Color.fromARGB(
              255,
              Random().nextInt(256),
              Random().nextInt(256),
              Random().nextInt(256),
            ),
          ),
        );
      },
    ),
    position: position,
  );
  
  game.add(confetti);
}
```

### Sparkle Effect
```dart
void addSparkleEffect(Vector2 position, FlameGame game) {
  game.add(
    ParticleSystemComponent(
      particle: Particle.generate(
        count: 20,
        lifespan: 1,
        generator: (i) => MovingParticle(
          from: position,
          to: position + (Vector2.random() - Vector2.all(0.5)) * 50,
          child: ScalingParticle(
            to: 0,
            child: CircleParticle(
              radius: 2,
              paint: Paint()..color = Colors.yellow.withOpacity(0.8),
            ),
          ),
        ),
      ),
      position: position,
    ),
  );
}
```

## Combo Animations

### Achievement Popup
```dart
class AchievementPopup extends PositionComponent {
  final String achievementText;
  
  AchievementPopup({
    required this.achievementText,
    required Vector2 position,
  }) : super(position: position, anchor: Anchor.center);
  
  @override
  Future<void> onLoad() async {
    // Panel with text
    final panel = InfoPanel(
      title: '🏆 Achievement!',
      content: achievementText,
      size: Vector2(350, 120),
    );
    add(panel);
    
    // Complex animation sequence
    panel.position.y -= 100; // Start above
    panel.opacity = 0;
    
    add(
      SequenceEffect([
        // Slide in and fade in
        ParallelEffect([
          MoveEffect.by(
            Vector2(0, 100),
            EffectController(duration: 0.4, curve: Curves.easeOut),
          ),
          OpacityEffect.fadeIn(
            EffectController(duration: 0.3),
          ),
        ]),
        // Wait
        DelayEffect(2.0),
        // Slide out and fade out
        ParallelEffect([
          MoveEffect.by(
            Vector2(0, -100),
            EffectController(duration: 0.3, curve: Curves.easeIn),
          ),
          OpacityEffect.fadeOut(
            EffectController(duration: 0.3),
          ),
        ]),
      ])..onComplete = () => removeFromParent(),
    );
  }
}
```

## Performance Tips

1. **Reuse Effects**: Create effect templates and apply to multiple components
2. **Remove Completed Effects**: Always set `removeOnFinish: true` for one-time animations
3. **Batch Similar Animations**: Use `ParallelEffect` for simultaneous animations
4. **Optimize Particle Count**: Limit particles to 100-200 for mobile devices
5. **Use Object Pooling**: For frequently created/destroyed animated components

## Animation Timing Reference

| Action | Duration | Curve |
|--------|----------|-------|
| Button Press | 0.1s | easeInOut |
| Menu Reveal | 0.4s | easeOutCubic |
| Screen Transition | 0.5s | easeInOutCubic |
| Achievement Popup | 0.4s in, 2s hold, 0.3s out | easeOut/easeIn |
| Error Shake | 0.5s | linear |
| Value Counter | 0.6s | easeOut |
| Hover Response | 0.15s | easeOut |