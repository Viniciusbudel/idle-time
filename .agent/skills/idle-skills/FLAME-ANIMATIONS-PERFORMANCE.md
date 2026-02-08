# Antigravity - Flutter Flame Professional Animations & Performance

## Skill Overview
This skill enables Claude to create high-performance, professional-grade animations and visual effects in Flutter using the Flame game engine. Use this skill when building games, interactive experiences, or any Flutter application requiring smooth, optimized animations with advanced effects.

## When to Use This Skill
- Creating game animations (sprites, particles, effects)
- Building performant UI animations in Flame-based apps
- Implementing physics-based motion and interactions
- Designing smooth transitions and visual effects
- Optimizing animation performance for 60+ FPS
- Creating particle systems and special effects
- Building custom animation controllers and sequences
- Implementing gesture-driven animations

## Core Principles

### 1. Performance-First Architecture
```dart
// GOOD: Use component pooling for frequently created/destroyed objects
class BulletPool extends Component {
  final List<Bullet> _pool = [];
  final int maxSize = 100;
  
  Bullet obtain() {
    if (_pool.isNotEmpty) {
      return _pool.removeLast()..reset();
    }
    return Bullet();
  }
  
  void free(Bullet bullet) {
    if (_pool.length < maxSize) {
      _pool.add(bullet);
    }
  }
}

// BAD: Creating new objects every frame
void update(double dt) {
  add(Bullet()); // Memory allocation on every update
}
```

### 2. Efficient Update Cycles
```dart
// GOOD: Delta-time based animations
class SmoothSprite extends SpriteAnimationComponent {
  double velocity = 100.0;
  
  @override
  void update(double dt) {
    super.update(dt);
    position.x += velocity * dt; // Frame-rate independent
  }
}

// BAD: Frame-dependent animation
void update(double dt) {
  position.x += 5; // Inconsistent speed across devices
}
```

### 3. Smart Component Lifecycle
```dart
// GOOD: Proper cleanup and resource management
class EffectComponent extends PositionComponent with HasGameRef {
  late SpriteAnimation animation;
  
  @override
  Future<void> onLoad() async {
    animation = await gameRef.loadSpriteAnimation(
      'effect.png',
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: 0.1,
        textureSize: Vector2.all(64),
      ),
    );
  }
  
  @override
  void onRemove() {
    // Clean up if needed
    super.onRemove();
  }
}
```

## Animation Patterns

### Sprite Animations
```dart
class AnimatedCharacter extends SpriteAnimationGroupComponent 
    with HasGameRef {
  
  @override
  Future<void> onLoad() async {
    // Load multiple animations
    final idle = await gameRef.loadSpriteAnimation(
      'character.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2(32, 32),
        texturePosition: Vector2(0, 0),
      ),
    );
    
    final run = await gameRef.loadSpriteAnimation(
      'character.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        texturePosition: Vector2(0, 32),
      ),
    );
    
    animations = {
      CharacterState.idle: idle,
      CharacterState.running: run,
    };
    
    current = CharacterState.idle;
  }
  
  void setState(CharacterState newState) {
    if (current != newState) {
      current = newState;
    }
  }
}
```

### Particle Effects
```dart
class ExplosionEffect extends Component {
  final Vector2 position;
  
  ExplosionEffect(this.position);
  
  @override
  Future<void> onLoad() async {
    final particle = ParticleSystemComponent(
      particle: Particle.generate(
        count: 50,
        lifespan: 1.0,
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(0, 100), // Gravity
          speed: Vector2.random() * 200,
          position: position.clone(),
          child: CircleParticle(
            radius: 3.0,
            paint: Paint()
              ..color = Color.lerp(
                Colors.orange,
                Colors.red,
                i / 50,
              )!,
          ),
        ),
      ),
    );
    
    parent?.add(particle);
    removeFromParent(); // Self-remove after spawning particles
  }
}
```

### Tweening & Easing
```dart
import 'package:flame/effects.dart';

class SmoothTransition extends PositionComponent {
  void moveToPosition(Vector2 target, {double duration = 1.0}) {
    add(
      MoveEffect.to(
        target,
        EffectController(
          duration: duration,
          curve: Curves.easeInOutCubic,
        ),
      ),
    );
  }
  
  void fadeOut({VoidCallback? onComplete}) {
    add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.5),
        onComplete: onComplete,
      ),
    );
  }
  
  void scaleUp() {
    add(
      ScaleEffect.to(
        Vector2.all(1.5),
        EffectController(
          duration: 0.3,
          curve: Curves.elasticOut,
        ),
      ),
    );
  }
}
```

### Sequence & Parallel Effects
```dart
class ComplexAnimation extends SpriteComponent {
  void playIntro() {
    // Sequential effects
    add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2.all(1.2),
          EffectController(duration: 0.2),
        ),
        ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(duration: 0.2),
        ),
        MoveEffect.by(
          Vector2(0, -20),
          EffectController(duration: 0.5, curve: Curves.easeOut),
        ),
      ]),
    );
    
    // Parallel effects
    add(
      ParallelEffect([
        RotateEffect.by(
          2 * pi,
          EffectController(duration: 1.0),
        ),
        ColorEffect(
          Colors.blue,
          EffectController(duration: 1.0),
          opacityFrom: 0.5,
          opacityTo: 1.0,
        ),
      ]),
    );
  }
}
```

## Performance Optimization Techniques

### 1. Render Culling
```dart
class OptimizedComponent extends PositionComponent with HasGameRef {
  @override
  void render(Canvas canvas) {
    // Only render if visible on screen
    if (!isVisibleInCamera()) return;
    
    super.render(canvas);
  }
  
  bool isVisibleInCamera() {
    final camera = gameRef.camera;
    final screenRect = camera.visibleWorldRect;
    return screenRect.overlaps(toRect());
  }
}
```

### 2. Component Pooling Pattern
```dart
class PooledParticleSystem {
  final List<Particle> _inactive = [];
  final List<Particle> _active = [];
  final int poolSize = 200;
  
  PooledParticleSystem() {
    // Pre-allocate particles
    for (int i = 0; i < poolSize; i++) {
      _inactive.add(Particle());
    }
  }
  
  void emit(Vector2 position, Vector2 velocity) {
    if (_inactive.isEmpty) return;
    
    final particle = _inactive.removeLast();
    particle.reset(position, velocity);
    _active.add(particle);
  }
  
  void update(double dt) {
    _active.removeWhere((particle) {
      particle.update(dt);
      if (particle.isDead) {
        _inactive.add(particle);
        return true;
      }
      return false;
    });
  }
}
```

### 3. Batch Rendering
```dart
class BatchedSprites extends Component with HasGameRef {
  final List<SpriteComponent> sprites = [];
  late Canvas _canvas;
  
  @override
  void render(Canvas canvas) {
    _canvas = canvas;
    
    // Batch similar sprites together
    canvas.save();
    
    for (final sprite in sprites) {
      if (sprite.isVisibleInCamera()) {
        sprite.render(canvas);
      }
    }
    
    canvas.restore();
  }
}
```

### 4. Update Throttling
```dart
class ThrottledComponent extends Component {
  double updateInterval = 0.1; // Update every 100ms
  double timeSinceUpdate = 0;
  
  @override
  void update(double dt) {
    timeSinceUpdate += dt;
    
    if (timeSinceUpdate >= updateInterval) {
      performExpensiveUpdate(timeSinceUpdate);
      timeSinceUpdate = 0;
    }
  }
  
  void performExpensiveUpdate(double dt) {
    // Expensive logic here
  }
}
```

## Advanced Animation Techniques

### Custom Easing Functions
```dart
class CustomEasing {
  static double bounce(double t) {
    if (t < 1 / 2.75) {
      return 7.5625 * t * t;
    } else if (t < 2 / 2.75) {
      return 7.5625 * (t -= 1.5 / 2.75) * t + 0.75;
    } else if (t < 2.5 / 2.75) {
      return 7.5625 * (t -= 2.25 / 2.75) * t + 0.9375;
    } else {
      return 7.5625 * (t -= 2.625 / 2.75) * t + 0.984375;
    }
  }
  
  static double elastic(double t) {
    return sin(13 * pi / 2 * t) * pow(2, 10 * (t - 1));
  }
}
```

### Physics-Based Animations
```dart
class PhysicsSprite extends SpriteComponent {
  Vector2 velocity = Vector2.zero();
  Vector2 acceleration = Vector2(0, 200); // Gravity
  double damping = 0.98;
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Apply physics
    velocity += acceleration * dt;
    velocity *= damping;
    position += velocity * dt;
    
    // Bounce off ground
    if (position.y > gameRef.size.y - size.y) {
      position.y = gameRef.size.y - size.y;
      velocity.y *= -0.8; // Bounce with energy loss
    }
  }
}
```

### Skeletal Animation
```dart
class SkeletalCharacter extends Component {
  final List<Bone> bones = [];
  
  void updateSkeleton(double dt) {
    // Forward kinematics
    for (final bone in bones) {
      if (bone.parent != null) {
        bone.worldPosition = bone.parent!.worldPosition + 
          bone.localPosition.rotated(bone.parent!.worldRotation);
        bone.worldRotation = bone.parent!.worldRotation + bone.localRotation;
      } else {
        bone.worldPosition = bone.localPosition;
        bone.worldRotation = bone.localRotation;
      }
    }
  }
  
  void inverseKinematics(Bone endEffector, Vector2 target) {
    // Simple 2-bone IK
    final parent = endEffector.parent;
    if (parent == null) return;
    
    // Calculate angles to reach target
    final toTarget = target - parent.worldPosition;
    final angle = atan2(toTarget.y, toTarget.x);
    parent.worldRotation = angle;
  }
}

class Bone {
  Bone? parent;
  Vector2 localPosition;
  double localRotation;
  Vector2 worldPosition = Vector2.zero();
  double worldRotation = 0;
  
  Bone({
    this.parent,
    required this.localPosition,
    this.localRotation = 0,
  });
}
```

## Camera & Viewport Animations

### Smooth Camera Follow
```dart
class SmoothCameraController extends Component with HasGameRef {
  PositionComponent? target;
  double smoothness = 5.0;
  
  @override
  void update(double dt) {
    if (target == null) return;
    
    final camera = gameRef.camera;
    final currentPos = camera.viewfinder.position;
    final targetPos = target!.position;
    
    // Smooth lerp to target
    final newPos = currentPos + (targetPos - currentPos) * (dt * smoothness);
    camera.viewfinder.position = newPos;
  }
}
```

### Camera Shake
```dart
extension CameraShakeExtension on CameraComponent {
  void shake({double intensity = 10.0, double duration = 0.5}) {
    final originalPosition = viewfinder.position.clone();
    
    viewfinder.add(
      SequenceEffect([
        // Shake effect
        MoveEffect.by(
          Vector2.random() * intensity,
          EffectController(
            duration: duration / 10,
            curve: Curves.easeInOut,
          ),
        ),
        // More shake iterations
        for (int i = 0; i < 9; i++)
          MoveEffect.by(
            Vector2.random() * intensity * (1 - i / 9),
            EffectController(
              duration: duration / 10,
              curve: Curves.easeInOut,
            ),
          ),
        // Return to original position
        MoveEffect.to(
          originalPosition,
          EffectController(
            duration: duration / 10,
            curve: Curves.easeOut,
          ),
        ),
      ]),
    );
  }
}
```

## Memory Management

### Texture Atlas Usage
```dart
class OptimizedAssetManager {
  late SpriteSheet spriteSheet;
  
  Future<void> loadAssets() async {
    // Load single sprite sheet instead of individual images
    final image = await Flame.images.load('sprite_sheet.png');
    
    spriteSheet = SpriteSheet(
      image: image,
      srcSize: Vector2.all(32),
    );
  }
  
  Sprite getSprite(int x, int y) {
    return spriteSheet.getSprite(x, y);
  }
  
  SpriteAnimation getAnimation(int row, int count) {
    return spriteSheet.createAnimation(
      row: row,
      stepTime: 0.1,
      to: count,
    );
  }
}
```

### Lazy Loading Pattern
```dart
class LazyLoadedComponent extends PositionComponent {
  bool _loaded = false;
  
  @override
  void update(double dt) {
    if (!_loaded && isVisibleInCamera()) {
      loadResources();
      _loaded = true;
    }
    
    super.update(dt);
  }
  
  Future<void> loadResources() async {
    // Load only when needed
  }
  
  bool isVisibleInCamera() {
    // Check if in camera view
    return true;
  }
}
```

## Debugging & Profiling

### Performance Monitoring
```dart
class PerformanceMonitor extends Component with HasGameRef {
  final List<double> frameTimes = [];
  int frameCount = 0;
  double totalTime = 0;
  
  @override
  void update(double dt) {
    frameTimes.add(dt);
    totalTime += dt;
    frameCount++;
    
    if (frameTimes.length > 60) {
      frameTimes.removeAt(0);
    }
    
    if (totalTime > 1.0) {
      final fps = frameCount / totalTime;
      final avgFrameTime = frameTimes.reduce((a, b) => a + b) / frameTimes.length;
      
      print('FPS: ${fps.toStringAsFixed(1)}, Avg Frame Time: ${(avgFrameTime * 1000).toStringAsFixed(2)}ms');
      
      frameCount = 0;
      totalTime = 0;
    }
  }
}
```

### Visual Debugging
```dart
class DebugComponent extends PositionComponent {
  bool showDebugInfo = true;
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    if (showDebugInfo) {
      // Draw bounding box
      final paint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawRect(size.toRect(), paint);
      
      // Draw center point
      canvas.drawCircle(
        size.toOffset() / 2,
        3,
        Paint()..color = Colors.green,
      );
      
      // Draw velocity vector
      final velocityPaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 2;
      
      if (this is PhysicsSprite) {
        final sprite = this as PhysicsSprite;
        canvas.drawLine(
          size.toOffset() / 2,
          size.toOffset() / 2 + sprite.velocity.toOffset() * 0.1,
          velocityPaint,
        );
      }
    }
  }
}
```

## Best Practices Checklist

### Animation Quality
- [ ] Use delta-time (dt) for all animations
- [ ] Implement proper easing curves for natural motion
- [ ] Avoid sudden jumps or teleportation
- [ ] Use appropriate frame rates (60 FPS target)
- [ ] Test animations on low-end devices

### Performance
- [ ] Implement object pooling for frequently created objects
- [ ] Use sprite sheets instead of individual images
- [ ] Cull off-screen components
- [ ] Batch similar rendering operations
- [ ] Profile and measure actual performance

### Code Organization
- [ ] Separate animation logic from game logic
- [ ] Use mixins for reusable behaviors
- [ ] Keep components focused and single-purpose
- [ ] Document complex animation sequences
- [ ] Use effect controllers for timing

### Resource Management
- [ ] Preload assets during initialization
- [ ] Dispose of unused resources
- [ ] Use texture atlases
- [ ] Implement lazy loading for distant objects
- [ ] Monitor memory usage

## Common Patterns

### Animation State Machine
```dart
enum AnimationState { idle, walking, running, jumping, falling }

class StateMachineComponent extends SpriteAnimationGroupComponent {
  AnimationState _currentState = AnimationState.idle;
  final Map<AnimationState, Set<AnimationState>> _validTransitions = {
    AnimationState.idle: {AnimationState.walking, AnimationState.jumping},
    AnimationState.walking: {AnimationState.idle, AnimationState.running, AnimationState.jumping},
    AnimationState.running: {AnimationState.walking, AnimationState.jumping},
    AnimationState.jumping: {AnimationState.falling},
    AnimationState.falling: {AnimationState.idle, AnimationState.walking},
  };
  
  bool transitionTo(AnimationState newState) {
    if (_validTransitions[_currentState]?.contains(newState) ?? false) {
      _currentState = newState;
      current = newState;
      return true;
    }
    return false;
  }
}
```

### Trail Effect
```dart
class TrailEffect extends Component {
  final List<TrailSegment> segments = [];
  final int maxSegments = 20;
  final PositionComponent target;
  
  TrailEffect(this.target);
  
  @override
  void update(double dt) {
    // Add new segment at target position
    segments.insert(0, TrailSegment(
      position: target.position.clone(),
      opacity: 1.0,
    ));
    
    // Update and remove old segments
    segments.removeWhere((segment) {
      segment.opacity -= dt * 2;
      return segment.opacity <= 0;
    });
    
    if (segments.length > maxSegments) {
      segments.removeLast();
    }
  }
  
  @override
  void render(Canvas canvas) {
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final paint = Paint()
        ..color = Colors.white.withOpacity(segment.opacity);
      
      canvas.drawCircle(
        segment.position.toOffset(),
        5.0 * segment.opacity,
        paint,
      );
    }
  }
}

class TrailSegment {
  Vector2 position;
  double opacity;
  
  TrailSegment({required this.position, required this.opacity});
}
```

## Summary

When using this skill, Claude will:
1. Prioritize performance with 60+ FPS target
2. Use delta-time based animations for consistency
3. Implement proper object pooling and resource management
4. Create smooth, professional-looking effects and transitions
5. Follow Flame engine best practices
6. Write clean, maintainable animation code
7. Include proper cleanup and memory management
8. Test performance on target devices
9. Use appropriate design patterns for complex animations
10. Provide debugging and profiling capabilities

This skill ensures animations are not just visually appealing but also performant, maintainable, and production-ready.