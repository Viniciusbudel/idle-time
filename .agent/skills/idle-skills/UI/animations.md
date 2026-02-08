# Animation Curves Reference

Visual guide to easing curves for smooth, professional animations.

## Standard Curves

### Linear
```dart
Curves.linear
```
**Use for**: Progress bars, constant motion
**Feel**: Mechanical, consistent
**Duration**: Any

### Ease
```dart
Curves.ease
```
**Use for**: General-purpose animations
**Feel**: Smooth, natural
**Duration**: 0.3-0.5s

### EaseIn
```dart
Curves.easeIn
Curves.easeInSine
Curves.easeInQuad
Curves.easeInCubic
Curves.easeInQuart
Curves.easeInQuint
```
**Use for**: Exit animations, disappearing elements
**Feel**: Starts slow, accelerates
**Duration**: 0.2-0.4s

### EaseOut
```dart
Curves.easeOut
Curves.easeOutSine
Curves.easeOutQuad
Curves.easeOutCubic
Curves.easeOutQuart
Curves.easeOutQuint
```
**Use for**: Entrance animations, appearing elements
**Feel**: Starts fast, decelerates
**Duration**: 0.3-0.5s
**Most versatile curve family**

### EaseInOut
```dart
Curves.easeInOut
Curves.easeInOutSine
Curves.easeInOutQuad
Curves.easeInOutCubic
Curves.easeInOutQuart
Curves.easeInOutQuint
```
**Use for**: Transitions, screen changes
**Feel**: Smooth acceleration and deceleration
**Duration**: 0.4-0.6s

## Specialized Curves

### Bounce
```dart
Curves.bounceIn
Curves.bounceOut
Curves.bounceInOut
```
**Use for**: Playful interactions, game elements
**Feel**: Energetic, springy
**Duration**: 0.5-0.8s
**Note**: Can feel unprofessional if overused

### Elastic
```dart
Curves.elasticIn
Curves.elasticOut
Curves.elasticInOut
```
**Use for**: Attention-grabbing elements, special effects
**Feel**: Stretchy, exaggerated
**Duration**: 0.6-1.0s
**Note**: Very playful, use sparingly

### Back
```dart
Curves.easeInBack
Curves.easeOutBack
Curves.easeInOutBack
```
**Use for**: Drawer openings, modal appearances
**Feel**: Anticipation, overshoot
**Duration**: 0.4-0.6s
**Popular for modern UI**

## Recommended Combinations

### Button Interactions
```dart
// Press down
ScaleEffect.to(
  Vector2.all(0.95),
  EffectController(duration: 0.1, curve: Curves.easeOut),
)

// Release
ScaleEffect.to(
  Vector2.all(1.0),
  EffectController(duration: 0.1, curve: Curves.easeOutBack),
)
```

### Menu Reveal
```dart
// Stagger items with easeOutCubic
for (var i = 0; i < items.length; i++) {
  items[i].add(
    OpacityEffect.fadeIn(
      EffectController(
        duration: 0.4,
        startDelay: i * 0.1,
        curve: Curves.easeOutCubic,
      ),
    ),
  );
}
```

### Screen Transitions
```dart
// Slide out (current screen)
MoveEffect.by(
  Vector2(-gameRef.size.x, 0),
  EffectController(
    duration: 0.5,
    curve: Curves.easeInCubic,
  ),
)

// Slide in (new screen)
MoveEffect.by(
  Vector2(-gameRef.size.x, 0),
  EffectController(
    duration: 0.5,
    curve: Curves.easeOutCubic,
  ),
)
```

### Achievement Popup
```dart
// Enter with bounce
ScaleEffect.to(
  Vector2.all(1.0),
  EffectController(
    duration: 0.6,
    curve: Curves.elasticOut,
  ),
)

// Exit smoothly
OpacityEffect.fadeOut(
  EffectController(
    duration: 0.3,
    curve: Curves.easeIn,
  ),
)
```

### Health Bar Depletion
```dart
// Smooth but noticeable
SizeEffect.to(
  targetSize,
  EffectController(
    duration: 0.3,
    curve: Curves.easeOutQuad,
  ),
)
```

### Score Counter
```dart
// Gradual increase
// Use custom interpolation in update() method
final diff = targetScore - currentScore;
currentScore += diff * 5.0 * dt; // Linear interpolation
```

### Dialog Background Dim
```dart
// Subtle fade in
OpacityEffect.to(
  0.7,
  EffectController(
    duration: 0.25,
    curve: Curves.easeOut,
  ),
)
```

## Curve Intensity Chart

| Curve Family | Intensity | Best For |
|--------------|-----------|----------|
| Linear | Minimal | Progress indicators |
| Sine | Gentle | Subtle movements |
| Quad | Moderate | General UI |
| Cubic | Strong | Important transitions |
| Quart | Very Strong | Dramatic effects |
| Quint | Extreme | Special emphasis |

## Duration Guidelines

### Quick Feedback (0.1-0.2s)
- Button press/release
- Hover effects
- Toggle switches
- Micro-interactions

### Standard Animations (0.3-0.5s)
- Menu item reveals
- Panel slides
- Fade transitions
- Icon changes

### Dramatic Transitions (0.5-0.8s)
- Screen changes
- Major UI shifts
- Achievement popups
- Loading states

### Special Effects (0.8-1.5s)
- Celebration animations
- Tutorial sequences
- Story transitions
- Complex choreography

## Custom Curves

### Create Custom Cubic Bezier
```dart
// Custom smooth ease-out
final customCurve = Cubic(0.25, 0.1, 0.25, 1.0);

// Custom bounce
final customBounce = Cubic(0.68, -0.55, 0.265, 1.55);
```

### Spring Curve (Physics-based)
```dart
// Requires physics simulation
class SpringCurve extends Curve {
  final double mass;
  final double stiffness;
  final double damping;
  
  SpringCurve({
    this.mass = 1.0,
    this.stiffness = 100.0,
    this.damping = 10.0,
  });
  
  @override
  double transformInternal(double t) {
    // Spring physics calculation
    final w = sqrt(stiffness / mass);
    final zeta = damping / (2 * sqrt(mass * stiffness));
    
    if (zeta < 1) {
      // Underdamped
      final wd = w * sqrt(1 - zeta * zeta);
      return 1 - exp(-zeta * w * t) * cos(wd * t);
    } else {
      // Critically damped or overdamped
      return 1 - exp(-w * t);
    }
  }
}
```

## Anti-Patterns to Avoid

❌ **Don't**: Use `Curves.linear` for UI animations
✅ **Do**: Use easeOut family for natural feel

❌ **Don't**: Make animations too long (>1s for UI)
✅ **Do**: Keep under 0.5s for responsiveness

❌ **Don't**: Mix different curve families in one sequence
✅ **Do**: Use consistent curves for related animations

❌ **Don't**: Overuse bounce/elastic effects
✅ **Do**: Reserve for special moments

❌ **Don't**: Animate too many properties simultaneously
✅ **Do**: Focus on 1-2 key properties per animation

## Testing Animations

```dart
// Debug animation timing
class AnimationDebugger {
  static void logTiming(String name, EffectController controller) {
    final timer = Stopwatch()..start();
    
    controller.onComplete = () {
      print('$name completed in ${timer.elapsedMilliseconds}ms');
      timer.stop();
    };
  }
}
```

## Platform Considerations

### Mobile
- Prefer shorter durations (0.2-0.4s)
- Use easeOut for responsiveness
- Limit complex curves (performance)

### Desktop/Web
- Can use longer durations (0.3-0.6s)
- Hover effects are important
- More complex curves acceptable

### Accessibility
- Provide option to reduce motion
- Ensure animations don't block interaction
- Keep critical feedback < 0.3s