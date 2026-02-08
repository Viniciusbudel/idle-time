---
name: mobile-app-design
description: Create distinctive, production-grade mobile app interfaces with exceptional UI/UX quality. Use this skill when the user asks to build mobile screens, app prototypes, mobile components, or native-feeling applications (examples include iOS/Android apps, mobile dashboards, onboarding flows, React Native components, or any mobile-first interface). Generates creative, polished code and design that avoids generic mobile templates.
license: Complete terms in LICENSE.txt
---

This skill guides creation of distinctive, production-grade mobile app interfaces that avoid generic template aesthetics. Implement real working code with exceptional attention to mobile UX patterns, gesture interactions, and platform-appropriate design details.

The user provides mobile app requirements: a screen, flow, component, or complete application to build. They may include context about the target platform (iOS/Android/cross-platform), audience, or technical constraints.

## Mobile Design Thinking

Before coding, understand the mobile context and commit to a BOLD design direction:
- **Platform**: iOS-native feel, Android Material Design, or distinctive cross-platform identity?
- **User Context**: When/where/how will users interact? Standing, sitting, one-handed, urgent tasks, leisurely browsing?
- **Interaction Model**: Gesture-first, voice-enabled, camera-integrated, location-aware, notification-driven?
- **Tone**: Pick an extreme: surgical precision, playful chaos, zen minimalism, data-dense productivity, social warmth, luxury refinement, gaming energy, editorial sophistication, etc.
- **Memorable Element**: What's the signature interaction or visual that makes this app unforgettable?

**CRITICAL**: Mobile demands even stronger opinions than web. Screen real estate is precious - every pixel must justify its presence. Choose bold minimalism OR rich maximalism, never tepid middle ground.

Then implement working code (React Native, SwiftUI, Flutter, or HTML/CSS/JS for mobile web) that is:
- Production-grade with smooth 60fps performance
- Gesture-aware and thumb-zone optimized
- Platform-appropriate yet distinctive
- Delightful in micro-interactions and transitions

## Mobile-Specific Aesthetics Guidelines

### Typography for Small Screens
- **Hierarchy Through Scale**: Aggressive size differences (48px headlines vs 14px body). Medium sizes (18-24px) feel uncommitted.
- **Distinctive Fonts**: Avoid SF Pro, Roboto, system defaults unless intentionally leveraging platform identity. Choose characterful typefaces that remain legible at mobile sizes.
- **Dynamic Type Respect**: Support accessibility scaling, but design for the default size first.
- **Reading Comfort**: Line height 1.4-1.6 for body text. Generous margins (20-24px) for text blocks.

### Color & Visual System
- **High Contrast**: Mobile screens vary wildly (bright sunlight to dark bedrooms). Ensure WCAG AA minimum, target AAA.
- **Consistent Theme Variables**: Define color systems that work across light/dark modes.
- **Accent Colors**: Use sparingly for calls-to-action. One bold accent outperforms gradient rainbows.
- **Atmospheric Backgrounds**: Subtle gradients, noise textures, or depth layers - but never compromise text legibility.

### Motion & Micro-Interactions
- **Native-Feeling Physics**: Use spring animations (tension, friction) over linear easing. iOS: bouncy and fluid. Android: snappy and responsive.
- **Gesture Feedback**: Immediate visual response to touch (scale, opacity, haptic simulation in code comments).
- **Purposeful Transitions**: Every screen change tells spatial story (slide, modal rise, zoom, dissolve). Match mental model.
- **Performance First**: Animate transforms and opacity only. Avoid animating layout properties. Target 60fps minimum.
- **Loading States**: Never show blank screens. Skeleton screens, progressive loading, optimistic updates.

### Layout & Spatial Design
- **Thumb Zones**: Primary actions in bottom third. Critical info in top third. Middle is gesture territory.
- **Bottom Navigation**: Most accessible. Tab bars, floating action buttons, gesture areas.
- **Safe Areas**: Respect notches, rounded corners, home indicators. Use as design features, not constraints.
- **Generous Touch Targets**: 44pt minimum (iOS), 48dp minimum (Android). Add invisible padding if needed.
- **White Space as UI**: Breathing room prevents mis-taps and reduces cognitive load.
- **Cards & Containers**: Elevation/shadows create hierarchy. But don't over-layer - flat can be powerful too.

### Platform Considerations
- **iOS Aesthetic**: Blurred backgrounds, translucency, large titles, swipe gestures, SF Symbols, haptics
- **Android Aesthetic**: Material elevation, FABs, navigation drawer, ripple effects, Material icons
- **Cross-Platform Identity**: Develop a unique visual language that feels native everywhere through shared motion principles and adaptive components

### Mobile-Specific Details
- **Pull-to-Refresh**: Custom animations beyond the default spinner
- **Empty States**: Delightful illustrations or helpful guidance, never blank screens
- **Permissions Prompts**: Contextual explanations before system dialogs
- **Onboarding**: Skip if possible. If required, make it skippable and memorable (max 3 screens).
- **Input Methods**: Appropriate keyboards, autocomplete, validation that doesn't annoy
- **Offline States**: Graceful degradation, clear sync status, offline-first when possible
- **Notifications**: Respectful, actionable, timely - never spammy

## Implementation Guidelines

### Flutter-Specific Excellence

Flutter's declarative UI and rich widget ecosystem enable extraordinary mobile experiences. Follow these patterns for production-grade apps:

#### Typography System
```dart
// app_typography.dart
class AppTypography {
  // Custom font families for distinctive identity
  static const String displayFont = 'Playfair Display';  // Headlines
  static const String bodyFont = 'Source Sans Pro';      // Body text
  static const String accentFont = 'Space Mono';         // Numbers, labels
  
  static TextTheme textTheme = TextTheme(
    // Display styles - bold, attention-grabbing
    displayLarge: TextStyle(
      fontFamily: displayFont,
      fontSize: 57,
      fontWeight: FontWeight.w700,
      height: 1.12,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontFamily: displayFont,
      fontSize: 45,
      fontWeight: FontWeight.w600,
      height: 1.16,
    ),
    
    // Headline styles - section headers
    headlineLarge: TextStyle(
      fontFamily: displayFont,
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontFamily: bodyFont,
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.29,
    ),
    
    // Title styles - cards, list items
    titleLarge: TextStyle(
      fontFamily: bodyFont,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.27,
    ),
    titleMedium: TextStyle(
      fontFamily: bodyFont,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.5,
      letterSpacing: 0.15,
    ),
    
    // Body styles - main content
    bodyLarge: TextStyle(
      fontFamily: bodyFont,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: bodyFont,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.43,
      letterSpacing: 0.25,
    ),
    
    // Label styles - buttons, captions
    labelLarge: TextStyle(
      fontFamily: accentFont,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.43,
      letterSpacing: 1.25,
      textBaseline: TextBaseline.alphabetic,
    ),
  );
}
```

#### Color System with Semantic Naming
```dart
// app_colors.dart
class AppColors {
  // Never use generic names - be specific and semantic
  
  // Primary palette - defines brand identity
  static const deepOcean = Color(0xFF0A2463);
  static const electricCoral = Color(0xFFFF6B9D);
  static const sunburstGold = Color(0xFFFFA823);
  
  // Surface colors - backgrounds and containers
  static const cloudWhite = Color(0xFFFAFAFA);
  static const midnightCanvas = Color(0xFF0F0F1E);
  static const frostedGlass = Color(0x1AFFFFFF);
  
  // Semantic colors - communicate meaning
  static const successMeadow = Color(0xFF2DD881);
  static const warningAmber = Color(0xFFFFB020);
  static const errorCrimson = Color(0xFFFF4757);
  static const infoSapphire = Color(0xFF3498DB);
  
  // Text hierarchy
  static const inkPrimary = Color(0xFF1A1A1A);
  static const inkSecondary = Color(0xFF6B6B6B);
  static const inkTertiary = Color(0xFF9E9E9E);
  static const inkInverse = Color(0xFFFFFFFF);
  
  // Create theme-aware color scheme
  static ColorScheme lightScheme = ColorScheme.light(
    primary: deepOcean,
    secondary: electricCoral,
    tertiary: sunburstGold,
    surface: cloudWhite,
    background: cloudWhite,
    error: errorCrimson,
    onPrimary: inkInverse,
    onSecondary: inkInverse,
    onSurface: inkPrimary,
    onBackground: inkPrimary,
  );
  
  static ColorScheme darkScheme = ColorScheme.dark(
    primary: electricCoral,
    secondary: sunburstGold,
    tertiary: deepOcean,
    surface: midnightCanvas,
    background: Color(0xFF0A0A12),
    error: errorCrimson,
    onPrimary: inkInverse,
    onSecondary: midnightCanvas,
    onSurface: inkInverse,
    onBackground: inkInverse,
  );
}
```

#### Animation System
```dart
// app_animations.dart
class AppAnimations {
  // Curves - define motion personality
  static const Curve springy = Curves.easeOutBack;        // Playful bounce
  static const Curve smooth = Curves.easeInOutCubic;      // Professional glide
  static const Curve snappy = Curves.easeOutExpo;         // Quick & responsive
  static const Curve elastic = ElasticOutCurve(0.8);      // Exaggerated spring
  
  // Durations - consistent timing
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration dramatic = Duration(milliseconds: 800);
  
  // Reusable animation builders
  static Widget fadeIn({
    required Widget child,
    Duration? duration,
    Curve? curve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration ?? normal,
      curve: curve ?? smooth,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: child,
      ),
      child: child,
    );
  }
  
  static Widget slideIn({
    required Widget child,
    Offset begin = const Offset(0, 0.3),
    Duration? duration,
    Curve? curve,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: begin, end: Offset.zero),
      duration: duration ?? normal,
      curve: curve ?? springy,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(value.dx * 100, value.dy * 100),
        child: child,
      ),
      child: child,
    );
  }
}
```

#### Gesture-Rich Interactive Components
```dart
// Example: Custom button with micro-interactions
class DynamicButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  
  const DynamicButton({
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    Key? key,
  }) : super(key: key);
  
  @override
  State<DynamicButton> createState() => _DynamicButtonState();
}

class _DynamicButtonState extends State<DynamicButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.quick,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.snappy),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: AnimatedContainer(
            duration: AppAnimations.quick,
            curve: AppAnimations.smooth,
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? AppColors.deepOcean,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isPressed
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.deepOcean.withOpacity(0.3),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
            ),
            child: Text(
              widget.text,
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: AppColors.inkInverse,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

#### Advanced Animations with ImplicitlyAnimatedWidget
```dart
// Custom animated gradient background
class AnimatedGradientContainer extends ImplicitlyAnimatedWidget {
  final List<Color> colors;
  final Widget child;
  
  const AnimatedGradientContainer({
    required this.colors,
    required this.child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
    Key? key,
  }) : super(duration: duration, curve: curve, key: key);
  
  @override
  AnimatedWidgetBaseState<AnimatedGradientContainer> createState() =>
      _AnimatedGradientContainerState();
}

class _AnimatedGradientContainerState
    extends AnimatedWidgetBaseState<AnimatedGradientContainer> {
  ColorTween? _color1;
  ColorTween? _color2;
  
  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _color1 = visitor(
      _color1,
      widget.colors[0],
      (value) => ColorTween(begin: value),
    ) as ColorTween?;
    _color2 = visitor(
      _color2,
      widget.colors[1],
      (value) => ColorTween(begin: value),
    ) as ColorTween?;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _color1?.evaluate(animation) ?? widget.colors[0],
            _color2?.evaluate(animation) ?? widget.colors[1],
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: widget.child,
    );
  }
}
```

#### Hero Transitions for Screen Navigation
```dart
// List item with Hero animation
class AnimatedListItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final VoidCallback onTap;
  
  const AnimatedListItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.onTap,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'item-$id',
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(Spacing.md),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Text(
                        title,
                        style: AppTypography.textTheme.titleLarge?.copyWith(
                          color: AppColors.inkInverse,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

#### Performance Optimization
```dart
// Use const constructors aggressively
const SizedBox(height: Spacing.md)

// Separate widgets for rebuilding optimization
class _AnimatedSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Only this widget rebuilds on animation
    return AnimatedBuilder(...);
  }
}

// RepaintBoundary for expensive widgets
RepaintBoundary(
  child: ComplexCustomPainter(),
)

// ListView.builder for long lists (never ListView with children)
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// Cached network images
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => ShimmerPlaceholder(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

#### Platform-Adaptive Design
```dart
// Adaptive layouts based on platform
Widget build(BuildContext context) {
  final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
  
  return isIOS
      ? CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Title'),
          ),
          child: content,
        )
      : Scaffold(
          appBar: AppBar(
            title: Text('Title'),
          ),
          body: content,
        );
}

// Adaptive spacing based on screen size
class Spacing {
  static double xs = 4.0;
  static double sm = 8.0;
  static double md = 16.0;
  static double lg = 24.0;
  static double xl = 32.0;
  static double xxl = 48.0;
  
  // Responsive multipliers
  static double scale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return 1.5;  // Tablet
    return 1.0;  // Phone
  }
}
```

#### Custom Painters for Distinctive Graphics
```dart
// Example: Custom wave background
class WaveBackgroundPainter extends CustomPainter {
  final Color color;
  final Animation<double> animation;
  
  WaveBackgroundPainter({required this.color, required this.animation})
      : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final waveHeight = 20.0;
    final waveLength = size.width / 3;
    
    path.moveTo(0, size.height * 0.7);
    
    for (double x = 0; x <= size.width; x += waveLength) {
      path.quadraticBezierTo(
        x + waveLength / 2,
        size.height * 0.7 - waveHeight + (animation.value * 10),
        x + waveLength,
        size.height * 0.7,
      );
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(WaveBackgroundPainter oldDelegate) =>
      color != oldDelegate.color;
}
```

#### Package Recommendations
```yaml
# pubspec.yaml
dependencies:
  # Animations
  flutter_animate: ^4.5.0           # Declarative animations
  lottie: ^3.0.0                    # After Effects animations
  
  # Gestures
  flutter_slidable: ^3.0.0          # Swipe actions
  
  # UI Components
  flutter_staggered_grid_view: ^0.7.0  # Pinterest-style grids
  shimmer: ^3.0.0                   # Loading skeletons
  cached_network_image: ^3.3.0      # Image caching
  
  # State Management (choose one)
  riverpod: ^2.4.0                  # Recommended
  bloc: ^8.1.0                      # Alternative
  
  # Utilities
  responsive_framework: ^1.1.0      # Responsive layouts
  google_fonts: ^6.1.0              # Easy custom fonts
```

### React Native
```javascript
// Use Reanimated for performant animations
// Gesture Handler for native-feeling interactions
// Proper SafeAreaView and Platform-specific code
// Custom fonts via react-native-vector-icons or expo-font
```

### SwiftUI
```swift
// Native platform capabilities
// System fonts or custom typography
// Platform-specific navigation patterns
// Native animation APIs
```

### Mobile Web (HTML/CSS/JS)
```javascript
// Touch-optimized, not just responsive desktop
// Meta viewport properly configured
// Prevent zoom on inputs, fast tap without 300ms delay
// CSS touch-action, user-select for gesture control
```

## Anti-Patterns to Avoid

**NEVER** create:
- Generic template apps (purple gradients, Inter font, centered cards)
- Desktop-first responsive layouts crammed into mobile
- Tiny touch targets requiring surgeon precision
- Hamburger menus hiding critical navigation
- Modal overload interrupting user flows
- Skeuomorphic design without purpose
- Feature bloat on small screens
- Animations that slow down task completion
- Auto-playing content consuming data
- Dark patterns (fake progress, hidden costs, forced sharing)

## Excellence Checklist

Before delivering, verify:
- [ ] One-handed usability for primary flows
- [ ] Instant visual feedback for all interactions
- [ ] Smooth 60fps animations (no jank)
- [ ] Clear information hierarchy at a glance
- [ ] Accessible contrast ratios and touch targets
- [ ] Delightful but purposeful micro-interactions
- [ ] Consistent spacing system (8pt or 4pt grid)
- [ ] Platform-appropriate navigation patterns
- [ ] Loading and error states designed
- [ ] Distinctive visual identity (not template-like)

## Design Philosophy

Mobile apps live in users' pockets and demand attention dozens of times daily. Every interaction should be:
- **Fast**: Respect users' time and attention
- **Clear**: No guessing what happens when you tap
- **Delightful**: Small moments of joy build emotional connection
- **Accessible**: Usable by everyone, in any context
- **Distinctive**: Memorable enough to keep on the home screen

**IMPORTANT**: Match implementation depth to design ambition. A productivity app needs ruthless efficiency and information density. A lifestyle app can luxuriate in generous spacing and elegant transitions. A gaming app demands bold colors and kinetic energy. Execute the vision with precision.

Remember: Mobile is the most intimate computing platform. Design interfaces worthy of living in someone's daily digital life. Be bold, be intentional, and create something people genuinely want to use.