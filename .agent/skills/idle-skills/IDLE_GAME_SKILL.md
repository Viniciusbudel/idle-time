# Idle Game Development with Flutter/Flame - SKILL.md

## Overview
This skill provides comprehensive guidance for developing idle/incremental games using Flutter and Flame engine. It covers architecture patterns, state management, game mechanics, UI/UX patterns, and performance optimization specifically tailored for idle game development.

## When to Use This Skill
- Creating idle/incremental/clicker games in Flutter
- Implementing progression systems, prestige mechanics, or offline progress
- Building games with passive resource generation
- Developing games with exponential growth curves
- Any game requiring persistent state and number-heavy calculations

---

## Architecture Patterns

### 1. Clean Architecture with Game-Specific Layers

**Structure:**
```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── utils/
│   └── services/
├── domain/
│   ├── entities/          # Pure game logic models
│   ├── repositories/      # Abstract interfaces
│   └── usecases/         # Business logic
├── data/
│   ├── models/           # Data transfer objects
│   ├── repositories/     # Concrete implementations
│   └── datasources/      # Local/remote data
├── presentation/
│   ├── game/             # Flame game components
│   ├── ui/               # Flutter UI widgets
│   ├── state/            # State management
│   └── screens/
└── main.dart
```

**Key Principles:**
- **Domain layer** contains pure Dart (no Flutter/Flame dependencies)
- **Game entities** separate from **UI widgets** and **Flame components**
- **Repository pattern** for save/load operations
- **Use cases** encapsulate single game actions (e.g., `UpgradeBuildingUseCase`, `CollectResourcesUseCase`)

### 2. State Management Pattern: Riverpod + Notifiers

**Why Riverpod for Idle Games:**
- Compile-time safety for game state
- Easy dependency injection for use cases
- Efficient rebuilds for constantly updating numbers
- Family providers for dynamic game entities (buildings, upgrades)

**Pattern:**
```dart
// Domain Entity
class GameResource {
  final BigInt amount;
  final BigInt perSecond;
  
  const GameResource({
    required this.amount,
    required this.perSecond,
  });
  
  GameResource copyWith({BigInt? amount, BigInt? perSecond}) {
    return GameResource(
      amount: amount ?? this.amount,
      perSecond: perSecond ?? this.perSecond,
    );
  }
}

// State Notifier
class GameResourceNotifier extends Notifier<GameResource> {
  @override
  GameResource build() {
    return const GameResource(
      amount: BigInt.zero,
      perSecond: BigInt.zero,
    );
  }
  
  void addAmount(BigInt amount) {
    state = state.copyWith(amount: state.amount + amount);
  }
  
  void updatePerSecond(BigInt perSecond) {
    state = state.copyWith(perSecond: perSecond);
  }
}

// Provider
final gameResourceProvider = NotifierProvider<GameResourceNotifier, GameResource>(
  GameResourceNotifier.new,
);

// Family Provider for multiple resources
final resourceProvider = NotifierProvider.family<ResourceNotifier, GameResource, ResourceType>(
  ResourceNotifier.new,
);
```

**Alternative: BLoC Pattern** (if team preference)
- Use for complex event-driven scenarios
- Better for undo/redo mechanics
- More verbose but explicit state transitions

### 3. Entity Component System (ECS) for Flame

**Pattern for Game Objects:**
```dart
// Component-based architecture
class BuildingComponent extends Component with HasGameRef<IdleGame> {
  final String id;
  final BigInt baseCost;
  final double productionRate;
  
  int level = 0;
  
  BuildingComponent({
    required this.id,
    required this.baseCost,
    required this.productionRate,
  });
  
  BigInt get currentCost => baseCost * BigInt.from(pow(1.15, level));
  
  @override
  void update(double dt) {
    super.update(dt);
    // Update production based on delta time
    gameRef.produceResource(productionRate * dt * level);
  }
}

// Mixin for tap behavior
mixin Tappable on Component {
  void onTap();
}

// Mixin for visual feedback
mixin PulseEffect on Component {
  double pulseScale = 1.0;
  
  void pulse() {
    pulseScale = 1.2;
    // Animate back to 1.0
  }
}
```

### 4. Game Loop Architecture

**Pattern: Separate Game Logic from Rendering**
```dart
class IdleGame extends FlameGame {
  late final GameController _controller;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Initialize game controller (handles logic)
    _controller = GameController(
      saveRepository: ref.read(saveRepositoryProvider),
    );
    
    // Add visual components
    await add(BackgroundComponent());
    await add(UIOverlayComponent());
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Update game logic at fixed intervals
    _controller.tick(dt);
  }
}

// Separate controller for game logic
class GameController {
  final SaveRepository saveRepository;
  double _accumulator = 0.0;
  
  static const tickRate = 1.0 / 30.0; // 30 ticks per second
  
  GameController({required this.saveRepository});
  
  void tick(double dt) {
    _accumulator += dt;
    
    // Fixed time step for consistent game logic
    while (_accumulator >= tickRate) {
      _accumulator -= tickRate;
      _updateGameState(tickRate);
    }
  }
  
  void _updateGameState(double dt) {
    // Update resources
    // Check for unlocks
    // Process upgrades
    // Auto-save check
  }
}
```

---

## UI/UX Patterns for Idle Games

### 1. Number Formatting Pattern

**Problem:** Large numbers (e.g., 1.5e+308) are unreadable
**Solution:** Suffix notation with proper formatting

```dart
class NumberFormatter {
  static final _suffixes = [
    '', 'K', 'M', 'B', 'T', 'Qa', 'Qi', 'Sx', 'Sp', 'Oc', 'No', 'Dc',
    'Ud', 'Dd', 'Td', 'Qad', 'Qid', 'Sxd', 'Spd', 'Ocd', 'Nod', 'Vg',
    'Uvg', // Add more as needed
  ];
  
  static String format(BigInt number, {int decimals = 2}) {
    if (number < BigInt.from(1000)) {
      return number.toString();
    }
    
    // Convert to double for calculation
    double value = number.toDouble();
    int suffixIndex = 0;
    
    while (value >= 1000 && suffixIndex < _suffixes.length - 1) {
      value /= 1000;
      suffixIndex++;
    }
    
    return '${value.toStringAsFixed(decimals)}${_suffixes[suffixIndex]}';
  }
  
  // Scientific notation for extreme numbers
  static String formatScientific(BigInt number) {
    final str = number.toString();
    if (str.length <= 3) return str;
    
    final exponent = str.length - 1;
    final mantissa = '${str[0]}.${str.substring(1, min(3, str.length))}';
    return '${mantissa}e${exponent}';
  }
  
  // Format with commas for readability
  static String formatWithCommas(BigInt number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
```

**UI Pattern: Animated Number Display**
```dart
class AnimatedNumberDisplay extends ConsumerWidget {
  final ProviderListenable<BigInt> numberProvider;
  final TextStyle? style;
  
  const AnimatedNumberDisplay({
    required this.numberProvider,
    this.style,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final number = ref.watch(numberProvider);
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(
        begin: number.toDouble(),
        end: number.toDouble(),
      ),
      builder: (context, value, child) {
        return Text(
          NumberFormatter.format(BigInt.from(value)),
          style: style ?? Theme.of(context).textTheme.headlineMedium,
        );
      },
    );
  }
}
```

### 2. Progression Feedback Pattern

**Visual Feedback for Actions:**
```dart
// Particle effect for resource gain
class ResourceGainEffect extends Component with HasGameRef {
  final Vector2 position;
  final String text;
  
  ResourceGainEffect({required this.position, required this.text});
  
  @override
  void onLoad() {
    // Float upward and fade out
    add(
      MoveEffect.by(
        Vector2(0, -50),
        EffectController(duration: 1.0),
      ),
    );
    
    add(
      OpacityEffect.fadeOut(
        EffectController(duration: 1.0),
        onComplete: removeFromParent,
      ),
    );
  }
}

// Progress bar for upgrades/purchases
class ProgressToAffordWidget extends ConsumerWidget {
  final BigInt currentAmount;
  final BigInt targetCost;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = (currentAmount.toDouble() / targetCost.toDouble())
        .clamp(0.0, 1.0);
    
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[800],
          valueColor: AlwaysStoppedAnimation(
            progress >= 1.0 ? Colors.green : Colors.orange,
          ),
        ),
        if (progress < 1.0)
          Text(
            'Need ${NumberFormatter.format(targetCost - currentAmount)} more',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
      ],
    );
  }
}
```

**Pattern: Unlock Animations**
```dart
class UnlockAnimationComponent extends SpriteAnimationComponent {
  UnlockAnimationComponent({required Vector2 position}) : super(
    position: position,
    size: Vector2(100, 100),
  );
  
  @override
  Future<void> onLoad() async {
    animation = await gameRef.loadSpriteAnimation(
      'unlock_effect.png',
      SpriteAnimationData.sequenced(
        amount: 12,
        stepTime: 0.1,
        textureSize: Vector2(100, 100),
        loop: false,
      ),
    );
    
    // Add scale effect
    add(ScaleEffect.by(
      Vector2.all(1.5),
      EffectController(
        duration: 0.5,
        reverseDuration: 0.5,
      ),
    ));
    
    // Remove after animation
    Future.delayed(Duration(milliseconds: 1200), () {
      removeFromParent();
    });
  }
}
```

### 3. Offline Progress Pattern

**Pattern: Calculate offline earnings on app resume**
```dart
class OfflineProgressService {
  final SaveRepository _saveRepository;
  
  Future<OfflineProgressResult> calculateOfflineProgress({
    required DateTime lastSaveTime,
    required GameState gameState,
    Duration? maxOfflineTime,
  }) async {
    final now = DateTime.now();
    final offlineDuration = now.difference(lastSaveTime);
    
    // Cap offline earnings to prevent exploits
    final cappedDuration = maxOfflineTime != null
        ? Duration(
            seconds: min(
              offlineDuration.inSeconds,
              maxOfflineTime.inSeconds,
            ),
          )
        : offlineDuration;
    
    // Calculate production during offline time
    final offlineSeconds = cappedDuration.inSeconds;
    
    // Apply offline efficiency modifier (e.g., 50% efficiency)
    const offlineEfficiency = 0.5;
    
    final totalProduction = gameState.productionPerSecond
        .multiply(BigInt.from(offlineSeconds))
        .multiply(BigInt.from((offlineEfficiency * 100).toInt()))
        .divide(BigInt.from(100));
    
    return OfflineProgressResult(
      duration: cappedDuration,
      resourcesGained: totalProduction,
      wasOffline: offlineDuration.inSeconds > 60, // More than 1 minute
    );
  }
}

// UI for offline progress
class OfflineProgressDialog extends StatelessWidget {
  final OfflineProgressResult result;
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 64, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'Welcome Back!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              'You were away for ${_formatDuration(result.duration)}',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text('Earned while away:'),
                  SizedBox(height: 8),
                  Text(
                    NumberFormatter.format(result.resourcesGained),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Collect'),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}
```

### 4. Prestige/Ascension Pattern

**Domain Model:**
```dart
class PrestigeSystem {
  final BigInt currentResources;
  final int currentPrestigeLevel;
  final PrestigeConfig config;
  
  // Calculate prestige currency earned
  BigInt calculatePrestigeCurrency() {
    // Common formula: sqrt(resources / threshold)
    if (currentResources < config.threshold) {
      return BigInt.zero;
    }
    
    final resourceRatio = currentResources.toDouble() / 
                          config.threshold.toDouble();
    final prestigeAmount = sqrt(resourceRatio).floor();
    
    return BigInt.from(prestigeAmount);
  }
  
  // Calculate production multiplier from prestige
  double calculateMultiplier() {
    return 1.0 + (currentPrestigeLevel * config.multiplierPerLevel);
  }
  
  bool canPrestige() {
    return calculatePrestigeCurrency() > BigInt.zero;
  }
}

// Prestige UI
class PrestigeButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final prestigeSystem = PrestigeSystem(
      currentResources: gameState.totalResources,
      currentPrestigeLevel: gameState.prestigeLevel,
      config: gameState.prestigeConfig,
    );
    
    final canPrestige = prestigeSystem.canPrestige();
    final willGain = prestigeSystem.calculatePrestigeCurrency();
    
    return ElevatedButton(
      onPressed: canPrestige 
          ? () => _showPrestigeConfirmation(context, ref, willGain)
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: canPrestige ? Colors.purple : Colors.grey,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      child: Column(
        children: [
          Text('PRESTIGE', style: TextStyle(fontSize: 20)),
          if (canPrestige)
            Text(
              'Gain ${NumberFormatter.format(willGain)} Prestige Points',
              style: TextStyle(fontSize: 12),
            )
          else
            Text(
              'Need ${NumberFormatter.format(prestigeSystem.config.threshold)}',
              style: TextStyle(fontSize: 12),
            ),
        ],
      ),
    );
  }
}
```

### 5. Buy Max / Buy X Pattern

**Smart Purchase Pattern:**
```dart
class PurchaseCalculator {
  // Calculate maximum affordable quantity
  static int calculateMaxAffordable({
    required BigInt currentMoney,
    required BigInt baseCost,
    required int currentOwned,
    required double growthRate, // e.g., 1.15
  }) {
    if (currentMoney < baseCost) return 0;
    
    // Use geometric series formula
    // Total cost = baseCost * (1 - r^n) / (1 - r)
    // Solve for n
    
    final r = growthRate;
    final currentMultiplier = pow(r, currentOwned);
    final adjustedBaseCost = baseCost.toDouble() * currentMultiplier;
    
    if (currentMoney.toDouble() < adjustedBaseCost) return 0;
    
    // Binary search for maximum affordable
    int low = 1;
    int high = 1000; // Reasonable upper bound
    int maxAffordable = 0;
    
    while (low <= high) {
      int mid = (low + high) ~/ 2;
      final totalCost = _calculateTotalCost(
        baseCost: baseCost,
        currentOwned: currentOwned,
        quantity: mid,
        growthRate: growthRate,
      );
      
      if (totalCost <= currentMoney) {
        maxAffordable = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
    
    return maxAffordable;
  }
  
  static BigInt _calculateTotalCost({
    required BigInt baseCost,
    required int currentOwned,
    required int quantity,
    required double growthRate,
  }) {
    // Geometric series sum
    final r = growthRate;
    final start = pow(r, currentOwned);
    final sum = start * (1 - pow(r, quantity)) / (1 - r);
    
    return BigInt.from((baseCost.toDouble() * sum).round());
  }
}

// UI Component
class BuyButtonRow extends ConsumerWidget {
  final String buildingId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final building = ref.watch(buildingProvider(buildingId));
    final money = ref.watch(currencyProvider);
    
    return Row(
      children: [
        _BuyButton(
          label: 'Buy 1',
          onPressed: () => ref.read(buildingProvider(buildingId).notifier)
              .purchase(1),
          cost: building.currentCost,
          canAfford: money >= building.currentCost,
        ),
        _BuyButton(
          label: 'Buy 10',
          onPressed: () => ref.read(buildingProvider(buildingId).notifier)
              .purchase(10),
          cost: building.getCostForQuantity(10),
          canAfford: money >= building.getCostForQuantity(10),
        ),
        _BuyButton(
          label: 'Buy Max',
          onPressed: () {
            final maxQty = PurchaseCalculator.calculateMaxAffordable(
              currentMoney: money,
              baseCost: building.baseCost,
              currentOwned: building.owned,
              growthRate: building.costGrowthRate,
            );
            ref.read(buildingProvider(buildingId).notifier)
                .purchase(maxQty);
          },
          cost: null, // Dynamic
          canAfford: money >= building.currentCost,
        ),
      ],
    );
  }
}
```

### 6. Achievement System Pattern

**Domain Model:**
```dart
abstract class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  
  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
  });
  
  bool checkCompletion(GameState state);
  AchievementReward? getReward();
}

class ResourceAchievement extends Achievement {
  final BigInt targetAmount;
  final String resourceType;
  
  ResourceAchievement({
    required super.id,
    required super.name,
    required super.description,
    required super.iconPath,
    required this.targetAmount,
    required this.resourceType,
  });
  
  @override
  bool checkCompletion(GameState state) {
    return state.getResource(resourceType) >= targetAmount;
  }
  
  @override
  AchievementReward getReward() {
    return AchievementReward(
      multiplier: 1.05, // 5% bonus
      description: '5% production bonus',
    );
  }
}

// Achievement tracker
class AchievementTracker extends ChangeNotifier {
  final List<Achievement> _achievements;
  final Set<String> _unlockedIds = {};
  
  void checkAchievements(GameState state) {
    bool anyUnlocked = false;
    
    for (final achievement in _achievements) {
      if (_unlockedIds.contains(achievement.id)) continue;
      
      if (achievement.checkCompletion(state)) {
        _unlockedIds.add(achievement.id);
        anyUnlocked = true;
        _showAchievementNotification(achievement);
      }
    }
    
    if (anyUnlocked) notifyListeners();
  }
}
```

---

## Performance Optimization Patterns

### 1. BigInt Optimization Pattern

**Problem:** BigInt operations are slow
**Solution:** Cache calculations and use int when possible

```dart
class OptimizedResource {
  BigInt _amount = BigInt.zero;
  BigInt _perSecond = BigInt.zero;
  
  // Cache for display
  String? _cachedDisplay;
  BigInt? _lastDisplayAmount;
  
  String get displayAmount {
    if (_cachedDisplay == null || _lastDisplayAmount != _amount) {
      _cachedDisplay = NumberFormatter.format(_amount);
      _lastDisplayAmount = _amount;
    }
    return _cachedDisplay!;
  }
  
  // Use double for calculations when safe
  void addProduction(double deltaTime) {
    // Only convert to BigInt when necessary
    if (_perSecond < BigInt.from(1000000)) {
      final toAdd = (_perSecond.toDouble() * deltaTime).floor();
      _amount += BigInt.from(toAdd);
    } else {
      // Use BigInt for large numbers
      final toAdd = _perSecond.multiply(
        BigInt.from((deltaTime * 1000).toInt())
      ).divide(BigInt.from(1000));
      _amount += toAdd;
    }
  }
}
```

### 2. Update Batching Pattern

**Pattern: Batch UI updates**
```dart
class BatchedUpdateController {
  final Duration updateInterval;
  Timer? _updateTimer;
  final List<VoidCallback> _updateCallbacks = [];
  
  BatchedUpdateController({
    this.updateInterval = const Duration(milliseconds: 100),
  });
  
  void registerUpdate(VoidCallback callback) {
    _updateCallbacks.add(callback);
    _ensureTimerRunning();
  }
  
  void _ensureTimerRunning() {
    _updateTimer ??= Timer.periodic(updateInterval, (_) {
      for (final callback in _updateCallbacks) {
        callback();
      }
    });
  }
  
  void dispose() {
    _updateTimer?.cancel();
    _updateCallbacks.clear();
  }
}

// Usage in provider
final batchUpdateProvider = Provider((ref) {
  final controller = BatchedUpdateController();
  ref.onDispose(controller.dispose);
  return controller;
});
```

### 3. Lazy Component Loading

**Pattern: Only render visible components**
```dart
class LazyComponentLoader extends Component with HasGameRef {
  final List<Component> _allComponents = [];
  final Set<Component> _activeComponents = {};
  final Camera camera;
  
  @override
  void update(double dt) {
    super.update(dt);
    
    final viewportRect = camera.visibleWorldRect;
    
    for (final component in _allComponents) {
      final isVisible = _isInViewport(component, viewportRect);
      final isActive = _activeComponents.contains(component);
      
      if (isVisible && !isActive) {
        add(component);
        _activeComponents.add(component);
      } else if (!isVisible && isActive) {
        component.removeFromParent();
        _activeComponents.remove(component);
      }
    }
  }
  
  bool _isInViewport(Component component, Rect viewport) {
    // Check if component bounds intersect viewport
    return true; // Implement based on component type
  }
}
```

---

## Save/Load Pattern

### Comprehensive Save System

```dart
// Save data model
@freezed
class SaveData with _$SaveData {
  const factory SaveData({
    required DateTime lastSaveTime,
    required int version,
    required Map<String, BigInt> resources,
    required Map<String, int> buildingLevels,
    required Map<String, bool> upgrades,
    required List<String> unlockedAchievements,
    required int prestigeLevel,
    required Map<String, dynamic> settings,
  }) = _SaveData;
  
  factory SaveData.fromJson(Map<String, dynamic> json) =>
      _$SaveDataFromJson(json);
}

// Repository
class SaveRepository {
  final SharedPreferences _prefs;
  static const _saveKey = 'game_save_v1';
  static const _autoSaveInterval = Duration(minutes: 1);
  
  Timer? _autoSaveTimer;
  
  Future<void> enableAutoSave(GameState Function() getState) async {
    _autoSaveTimer = Timer.periodic(_autoSaveInterval, (_) {
      save(getState());
    });
  }
  
  Future<void> save(GameState state) async {
    final saveData = SaveData(
      lastSaveTime: DateTime.now(),
      version: 1,
      resources: state.resources.map(
        (key, value) => MapEntry(key, value.amount),
      ),
      buildingLevels: state.buildings.map(
        (key, value) => MapEntry(key, value.level),
      ),
      upgrades: state.upgrades,
      unlockedAchievements: state.achievements.toList(),
      prestigeLevel: state.prestigeLevel,
      settings: state.settings,
    );
    
    final json = saveData.toJson();
    // Use compression for large saves
    final compressed = gzip.encode(utf8.encode(jsonEncode(json)));
    final base64 = base64Encode(compressed);
    
    await _prefs.setString(_saveKey, base64);
  }
  
  Future<SaveData?> load() async {
    try {
      final base64 = _prefs.getString(_saveKey);
      if (base64 == null) return null;
      
      final compressed = base64Decode(base64);
      final json = jsonDecode(utf8.decode(gzip.decode(compressed)));
      
      return SaveData.fromJson(json);
    } catch (e) {
      // Handle corrupt saves
      return null;
    }
  }
  
  Future<void> exportSave() async {
    final saveString = _prefs.getString(_saveKey);
    if (saveString != null) {
      await Clipboard.setData(ClipboardData(text: saveString));
    }
  }
  
  Future<bool> importSave(String saveString) async {
    try {
      // Validate save
      final compressed = base64Decode(saveString);
      final json = jsonDecode(utf8.decode(gzip.decode(compressed)));
      SaveData.fromJson(json); // Will throw if invalid
      
      await _prefs.setString(_saveKey, saveString);
      return true;
    } catch (e) {
      return false;
    }
  }
}
```

---

## Testing Patterns

### 1. Unit Tests for Game Logic

```dart
void main() {
  group('Purchase Calculator', () {
    test('calculates max affordable correctly', () {
      final maxQty = PurchaseCalculator.calculateMaxAffordable(
        currentMoney: BigInt.from(10000),
        baseCost: BigInt.from(100),
        currentOwned: 0,
        growthRate: 1.15,
      );
      
      expect(maxQty, greaterThan(0));
      
      // Verify total cost doesn't exceed money
      final totalCost = PurchaseCalculator._calculateTotalCost(
        baseCost: BigInt.from(100),
        currentOwned: 0,
        quantity: maxQty,
        growthRate: 1.15,
      );
      
      expect(totalCost, lessThanOrEqualTo(BigInt.from(10000)));
    });
  });
  
  group('Prestige System', () {
    test('calculates prestige currency correctly', () {
      final prestige = PrestigeSystem(
        currentResources: BigInt.from(1000000),
        currentPrestigeLevel: 0,
        config: PrestigeConfig(
          threshold: BigInt.from(100000),
          multiplierPerLevel: 0.1,
        ),
      );
      
      final currency = prestige.calculatePrestigeCurrency();
      expect(currency, greaterThan(BigInt.zero));
    });
  });
}
```

### 2. Widget Tests for UI

```dart
void main() {
  testWidgets('Buy button disabled when cant afford', (tester) async {
    final container = ProviderContainer(
      overrides: [
        currencyProvider.overrideWith((ref) => BigInt.from(50)),
      ],
    );
    
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: BuyButton(
              cost: BigInt.from(100),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
    
    final button = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    
    expect(button.onPressed, isNull);
  });
}
```

---

## Common Anti-Patterns to Avoid

### ❌ Don't: Update UI every frame
```dart
// BAD
@override
void update(double dt) {
  super.update(dt);
  updateUI(); // Called 60 times per second!
}
```

### ✅ Do: Batch updates
```dart
// GOOD
Timer.periodic(Duration(milliseconds: 100), (_) {
  updateUI(); // Called 10 times per second
});
```

### ❌ Don't: Use double for currency
```dart
// BAD - loses precision
double money = 0.0;
money += 0.1; // Floating point errors
```

### ✅ Do: Use BigInt for large numbers
```dart
// GOOD
BigInt money = BigInt.zero;
money += BigInt.from(1000);
```

### ❌ Don't: Recalculate costs every frame
```dart
// BAD
BigInt getCost() => baseCost * BigInt.from(pow(1.15, level));
```

### ✅ Do: Cache expensive calculations
```dart
// GOOD
BigInt? _cachedCost;
int? _lastLevel;

BigInt getCost() {
  if (_cachedCost == null || _lastLevel != level) {
    _cachedCost = baseCost * BigInt.from(pow(1.15, level));
    _lastLevel = level;
  }
  return _cachedCost!;
}
```

---

## Recommended Package Ecosystem

```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.17.0              # Game engine
  flutter_riverpod: ^2.5.1   # State management
  freezed_annotation: ^2.4.1 # Immutable models
  json_annotation: ^4.8.1
  shared_preferences: ^2.2.2  # Save system
  intl: ^0.19.0              # Number formatting
  
dev_dependencies:
  build_runner: ^2.4.8
  freezed: ^2.4.7
  json_serializable: ^6.7.1
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.3           # Testing
```

---

## Architecture Decision Records

### ADR-001: Use BigInt for all currency
**Context:** Idle games have exponential growth reaching very large numbers.
**Decision:** Use BigInt for all currency/resource values.
**Consequences:** Prevents overflow, requires custom arithmetic operations.

### ADR-002: Separate game logic from rendering
**Context:** Game logic updates needed independently of frame rate.
**Decision:** Implement game controller with fixed time step.
**Consequences:** Consistent gameplay across devices, easier testing.

### ADR-003: Use Riverpod over BLoC
**Context:** Need efficient state management for frequently changing values.
**Decision:** Use Riverpod with family providers.
**Consequences:** Less boilerplate, compile-time safety, easier DI.

---

## Performance Targets

- **Frame Rate:** Maintain 60 FPS on mid-range devices
- **Memory:** < 150MB RAM usage during active play
- **Battery:** < 5% drain per hour of idle gameplay
- **Save Time:** < 100ms for auto-save operations
- **Cold Start:** < 2 seconds from tap to playable
- **Number Updates:** UI refreshes at 10Hz (not 60Hz)

---

## Accessibility Considerations

```dart
// Ensure tappable areas are large enough
const minTapSize = 48.0;

// Support screen readers
Semantics(
  label: 'Bakery, owned: ${building.level}, cost: ${building.cost}',
  button: true,
  child: BuildingWidget(building: building),
)

// Provide haptic feedback
HapticFeedback.lightImpact(); // On purchase
HapticFeedback.mediumImpact(); // On prestige

// Support high contrast mode
final brightness = MediaQuery.of(context).platformBrightness;

// Reduce motion for accessibility
final reduceMotions = MediaQuery.of(context).disableAnimations;
```

---

## Balancing Formula Reference

```dart
// Building cost progression
cost_n = base_cost × growth_rate^n

// Production scaling
production = base_production × level × (1 + bonus_multipliers)

// Prestige currency (common formula)
prestige_points = floor(sqrt(total_resources / threshold))

// Upgrade costs (linear tiers)
upgrade_cost = tier_base × tier_number^2

// Achievement bonuses (additive)
total_multiplier = 1.0 + Σ(achievement_bonuses)
```

---

## When to Use This Pattern

This comprehensive architecture is appropriate for:
- Medium to large idle games (10+ systems)
- Games with complex progression curves
- Multi-layered prestige systems
- Games requiring offline progress
- Long-term player retention focus

For simple clicker games, a lighter architecture with Provider and basic state management may suffice.

---

## Additional Resources

- [Flame Documentation](https://docs.flame-engine.org/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Idle Game Math](https://gameanalytics.com/blog/idle-game-mathematics/)
- [BigInt Performance Tips](https://dart.dev/guides/language/numbers)

---

## Version History
- v1.0 - Initial idle game architecture pattern (2026-02-06)
