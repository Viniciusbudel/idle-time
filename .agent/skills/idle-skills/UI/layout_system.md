# Layout Systems

Responsive positioning strategies for game UI across different screen sizes and aspect ratios.

## Core Layout Patterns

### Anchor-Based Positioning

```dart
// Screen corners
final topLeft = Vector2.zero();
final topRight = Vector2(gameRef.size.x, 0);
final bottomLeft = Vector2(0, gameRef.size.y);
final bottomRight = gameRef.size.clone();
final center = gameRef.size / 2;

// Component with anchor
component = MyComponent(
  position: topRight,
  anchor: Anchor.topRight, // Component's anchor point
);
```

### Safe Area System

```dart
class SafeAreaLayout {
  final FlameGame game;
  late final EdgeInsets safeArea;
  
  SafeAreaLayout(this.game) {
    // Get platform safe area (notches, system UI)
    safeArea = MediaQuery.of(game.buildContext!).padding;
  }
  
  Vector2 get topLeft => Vector2(safeArea.left, safeArea.top);
  Vector2 get topRight => Vector2(
    game.size.x - safeArea.right,
    safeArea.top,
  );
  Vector2 get bottomLeft => Vector2(
    safeArea.left,
    game.size.y - safeArea.bottom,
  );
  Vector2 get bottomRight => Vector2(
    game.size.x - safeArea.right,
    game.size.y - safeArea.bottom,
  );
  
  Vector2 getSafePosition(Anchor anchor) {
    switch (anchor) {
      case Anchor.topLeft:
        return topLeft;
      case Anchor.topRight:
        return topRight;
      case Anchor.bottomLeft:
        return bottomLeft;
      case Anchor.bottomRight:
        return bottomRight;
      case Anchor.center:
        return Vector2(
          game.size.x / 2,
          game.size.y / 2,
        );
      default:
        return Vector2.zero();
    }
  }
}
```

### Grid Layout

```dart
class GridLayout {
  final Vector2 gridSize;
  final int columns;
  final int rows;
  final double spacing;
  
  GridLayout({
    required this.gridSize,
    required this.columns,
    required this.rows,
    this.spacing = 10,
  });
  
  Vector2 getCellPosition(int col, int row) {
    final cellWidth = (gridSize.x - (columns - 1) * spacing) / columns;
    final cellHeight = (gridSize.y - (rows - 1) * spacing) / rows;
    
    return Vector2(
      col * (cellWidth + spacing),
      row * (cellHeight + spacing),
    );
  }
  
  Vector2 getCellSize() {
    final cellWidth = (gridSize.x - (columns - 1) * spacing) / columns;
    final cellHeight = (gridSize.y - (rows - 1) * spacing) / rows;
    return Vector2(cellWidth, cellHeight);
  }
}
```

### Flex Layout (Horizontal/Vertical)

```dart
class FlexLayout extends PositionComponent {
  final Axis direction;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;
  
  FlexLayout({
    required this.direction,
    this.spacing = 10,
    this.mainAxisAlignment = MainAxisAlignment.start,
    required Vector2 position,
  }) : super(position: position);
  
  @override
  void onChildrenChanged(Component child, ChildrenChangeType type) {
    super.onChildrenChanged(child, type);
    if (type == ChildrenChangeType.added) {
      _relayout();
    }
  }
  
  void _relayout() {
    var offset = 0.0;
    
    for (final child in children.whereType<PositionComponent>()) {
      if (direction == Axis.horizontal) {
        child.position = Vector2(offset, 0);
        offset += child.size.x + spacing;
      } else {
        child.position = Vector2(0, offset);
        offset += child.size.y + spacing;
      }
    }
    
    // Update container size
    if (direction == Axis.horizontal) {
      size = Vector2(offset - spacing, _maxHeight());
    } else {
      size = Vector2(_maxWidth(), offset - spacing);
    }
  }
  
  double _maxHeight() {
    return children
        .whereType<PositionComponent>()
        .map((c) => c.size.y)
        .fold(0.0, max);
  }
  
  double _maxWidth() {
    return children
        .whereType<PositionComponent>()
        .map((c) => c.size.x)
        .fold(0.0, max);
  }
}
```

## Responsive Scaling

### Reference Resolution Scaling

```dart
class ResponsiveScale {
  // Design reference (e.g., iPhone 12 Pro)
  static const referenceWidth = 1170.0;
  static const referenceHeight = 2532.0;
  
  static double getScale(Vector2 screenSize) {
    final widthScale = screenSize.x / referenceWidth;
    final heightScale = screenSize.y / referenceHeight;
    
    // Use minimum to ensure content fits
    return min(widthScale, heightScale);
  }
  
  static double getScaleMax(Vector2 screenSize) {
    final widthScale = screenSize.x / referenceWidth;
    final heightScale = screenSize.y / referenceHeight;
    
    // Use maximum to fill screen
    return max(widthScale, heightScale);
  }
  
  static Vector2 scaleSize(Vector2 originalSize, Vector2 screenSize) {
    final scale = getScale(screenSize);
    return originalSize * scale;
  }
}
```

### Adaptive Component Sizing

```dart
class AdaptiveComponent extends PositionComponent {
  final Vector2 referenceSize;
  
  AdaptiveComponent({
    required this.referenceSize,
    required Vector2 position,
  }) : super(position: position);
  
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    
    final scale = ResponsiveScale.getScale(size);
    this.size = referenceSize * scale;
    this.scale = Vector2.all(scale);
  }
}
```

### Aspect Ratio Handling

```dart
class AspectRatioManager {
  final FlameGame game;
  
  AspectRatioManager(this.game);
  
  double get aspectRatio => game.size.x / game.size.y;
  
  bool get isWidescreen => aspectRatio > 1.8;
  bool get isStandard => aspectRatio >= 1.5 && aspectRatio <= 1.8;
  bool get isSquarish => aspectRatio < 1.5;
  
  // Safe zone percentages
  double get horizontalSafeZone {
    if (isWidescreen) return 0.15; // 15% margin on sides
    if (isStandard) return 0.10;
    return 0.05;
  }
  
  double get verticalSafeZone => 0.10; // 10% margin top/bottom
  
  Rect getSafeRect() {
    return Rect.fromLTWH(
      game.size.x * horizontalSafeZone,
      game.size.y * verticalSafeZone,
      game.size.x * (1 - 2 * horizontalSafeZone),
      game.size.y * (1 - 2 * verticalSafeZone),
    );
  }
}
```

## HUD Layout Patterns

### Fixed Viewport Positioning

```dart
class HUDComponent extends PositionComponent with HasGameRef {
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    
    // Always position relative to viewport, not camera
    if (gameRef.camera.viewport is FixedResolutionViewport) {
      final viewport = gameRef.camera.viewport as FixedResolutionViewport;
      position = Vector2(
        viewport.size.x - 100, // 100 pixels from right
        50, // 50 pixels from top
      );
    }
  }
}
```

### Viewport-Aware Layout

```dart
class ViewportLayout {
  final CameraComponent camera;
  
  ViewportLayout(this.camera);
  
  // Get positions in viewport coordinates
  Vector2 get viewportTopLeft => Vector2.zero();
  
  Vector2 get viewportTopRight {
    return Vector2(camera.viewport.size.x, 0);
  }
  
  Vector2 get viewportBottomLeft {
    return Vector2(0, camera.viewport.size.y);
  }
  
  Vector2 get viewportBottomRight {
    return camera.viewport.size.clone();
  }
  
  Vector2 get viewportCenter {
    return camera.viewport.size / 2;
  }
}
```

## Common Layout Recipes

### Main Menu Layout

```dart
class MainMenuLayout extends PositionComponent {
  @override
  Future<void> onLoad() async {
    final screenSize = gameRef.size;
    
    // Title at top
    final title = TitleComponent();
    title.position = Vector2(screenSize.x / 2, screenSize.y * 0.2);
    title.anchor = Anchor.center;
    add(title);
    
    // Button stack in center
    final buttonLayout = FlexLayout(
      direction: Axis.vertical,
      spacing: 20,
      position: Vector2(screenSize.x / 2, screenSize.y * 0.5),
    );
    buttonLayout.anchor = Anchor.center;
    
    // Add buttons
    buttonLayout.add(MenuButton(text: 'Play'));
    buttonLayout.add(MenuButton(text: 'Settings'));
    buttonLayout.add(MenuButton(text: 'Quit'));
    
    add(buttonLayout);
  }
}
```

### Game HUD Layout

```dart
class GameHUDLayout extends PositionComponent {
  @override
  Future<void> onLoad() async {
    final safeArea = SafeAreaLayout(gameRef);
    
    // Score - top right
    final score = ScoreDisplay(
      position: safeArea.topRight - Vector2(20, -20),
    );
    score.anchor = Anchor.topRight;
    add(score);
    
    // Health - top left
    final health = HealthBar(
      currentHealth: 100,
      maxHealth: 100,
      position: safeArea.topLeft + Vector2(20, 20),
    );
    add(health);
    
    // Timer - top center
    final timer = TimerDisplay(
      position: Vector2(gameRef.size.x / 2, safeArea.topLeft.y + 20),
      initialTime: 60,
    );
    timer.anchor = Anchor.topCenter;
    add(timer);
    
    // Controls - bottom center
    final controls = ControlsLayout(
      position: Vector2(gameRef.size.x / 2, safeArea.bottomRight.y - 80),
    );
    controls.anchor = Anchor.bottomCenter;
    add(controls);
  }
}
```

### Inventory Grid

```dart
class InventoryLayout extends PositionComponent {
  final int columns = 5;
  final int rows = 4;
  
  @override
  Future<void> onLoad() async {
    final screenSize = gameRef.size;
    final gridWidth = screenSize.x * 0.8;
    final gridHeight = screenSize.y * 0.6;
    
    final grid = GridLayout(
      gridSize: Vector2(gridWidth, gridHeight),
      columns: columns,
      rows: rows,
      spacing: 10,
    );
    
    final cellSize = grid.getCellSize();
    
    // Create inventory slots
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < columns; col++) {
        final slot = InventorySlot(size: cellSize);
        slot.position = grid.getCellPosition(col, row);
        add(slot);
      }
    }
    
    // Center the grid
    position = (screenSize - Vector2(gridWidth, gridHeight)) / 2;
  }
}
```

### Dialog/Modal Layout

```dart
class DialogLayout extends PositionComponent {
  final String title;
  final String message;
  
  DialogLayout({
    required this.title,
    required this.message,
  });
  
  @override
  Future<void> onLoad() async {
    final screenSize = gameRef.size;
    final dialogWidth = min(screenSize.x * 0.8, 500.0);
    final dialogHeight = min(screenSize.y * 0.6, 400.0);
    
    size = Vector2(dialogWidth, dialogHeight);
    position = (screenSize - size) / 2;
    
    // Background dimmer
    final dimmer = RectangleComponent(
      size: screenSize,
      paint: Paint()..color = Colors.black.withOpacity(0.7),
      position: -position, // Relative to dialog
    );
    add(dimmer);
    
    // Dialog panel
    final panel = RoundedRectangle(
      size: size,
      backgroundColor: const Color(0xFF2C2C2C),
      borderRadius: 16,
    );
    add(panel);
    
    // Title
    final titleText = TextComponent(
      text: title,
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
      position: Vector2(dialogWidth / 2, 40),
      anchor: Anchor.center,
    );
    add(titleText);
    
    // Message
    final messageText = TextComponent(
      text: message,
      textRenderer: TextPaint(style: TextStyle(fontSize: 18)),
      position: Vector2(20, 100),
    );
    add(messageText);
    
    // Buttons
    final buttonLayout = FlexLayout(
      direction: Axis.horizontal,
      spacing: 20,
      position: Vector2(dialogWidth / 2, dialogHeight - 60),
    );
    buttonLayout.anchor = Anchor.center;
    add(buttonLayout);
  }
}
```

## Orientation Handling

```dart
class OrientationAwareLayout extends PositionComponent {
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    
    final isLandscape = size.x > size.y;
    
    if (isLandscape) {
      _layoutForLandscape(size);
    } else {
      _layoutForPortrait(size);
    }
  }
  
  void _layoutForLandscape(Vector2 size) {
    // Horizontal button arrangement
    // Side panels for controls
  }
  
  void _layoutForPortrait(Vector2 size) {
    // Vertical button arrangement
    // Bottom controls
  }
}
```

## Testing Different Screens

```dart
class LayoutDebugger extends Component {
  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Draw safe area boundaries
    final safeArea = SafeAreaLayout(gameRef);
    canvas.drawRect(
      Rect.fromPoints(
        safeArea.topLeft.toOffset(),
        safeArea.bottomRight.toOffset(),
      ),
      paint,
    );
    
    // Draw center guides
    canvas.drawLine(
      Offset(gameRef.size.x / 2, 0),
      Offset(gameRef.size.x / 2, gameRef.size.y),
      paint..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(0, gameRef.size.y / 2),
      Offset(gameRef.size.x, gameRef.size.y / 2),
      paint,
    );
  }
}
```

## Platform-Specific Considerations

### Mobile (Portrait)
- Buttons in bottom 30% of screen
- Critical info in top 20%
- Large touch targets (44x44 dp minimum)

### Mobile (Landscape)
- Split controls to left/right sides
- HUD elements in corners
- Center area for gameplay

### Tablet
- More whitespace between elements
- Larger component sizes
- Multi-column layouts

### Desktop/Web
- Mouse hover states
- Keyboard navigation support
- More compact layouts acceptable