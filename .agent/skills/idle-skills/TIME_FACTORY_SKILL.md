# Time Factory: Paradox Industries - Development Skill

## Overview
This skill provides comprehensive guidance for developing **Time Factory: Paradox Industries**, a dark cyberpunk idle game built with Flutter/Flame. This document should be consulted before implementing any game feature to ensure consistency with the game's vision, architecture, and design principles.

## When to Use This Skill
- Implementing any Time Factory game feature
- Creating UI components for the cyberpunk aesthetic
- Developing game mechanics (loops, workers, paradox, prestige)
- Building the factory grid system
- Implementing monetization features
- Creating particle effects and visual polish
- Writing narrative/lore content
- Balancing game economy

---

## 🎯 GAME VISION

**High Concept:**  
A dark cyberpunk idle game where you exploit time loops to build a temporal factory empire in 2247 Neo-Tokyo, inspired by H.G. Wells' "The Time Machine."

**Core Pillars:**
1. **Time as Resource** - Time itself is harvested and manipulated
2. **Dark Narrative** - Consequences matter, ethical horror undertones
3. **Cyberpunk Aesthetic** - Neon-soaked, rain-slicked, glitch-heavy
4. **Hybrid-Casual** - Idle base + RPG collection + strategy layers
5. **Respectful Monetization** - Player-first F2P model

**Target Experience:**
- Session length: 2-5 minutes
- Satisfying number growth with philosophical depth
- Visual spectacle (neon, particles, glitches)
- Narrative that rewards long-term engagement

---

## 🎨 VISUAL STYLE GUIDE

### Color Palette (ALWAYS USE THESE)

```dart
// Core Cyberpunk Colors
class TimeFactoryColors {
  // Primary Colors
  static const electricCyan = Color(0xFF00F0FF);      // Time energy, UI accents
  static const hotMagenta = Color(0xFFFF006E);        // Danger, paradox, errors
  static const acidGreen = Color(0xFF39FF14);         // Success, production, money
  static const deepPurple = Color(0xFF8B00FF);        // Premium currency
  static const voltageYellow = Color(0xFFFFFF00);     // Alerts, timekeepers
  
  // Background/Atmosphere
  static const voidBlack = Color(0xFF0A0E27);         // Base background
  static const midnightBlue = Color(0xFF1A1F3A);      // Secondary panels
  static const smokeGray = Color(0xFF2D2D44);         // Inactive elements
  
  // Gradients
  static const neonGradient = LinearGradient(
    colors: [electricCyan, deepPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const paradoxGradient = LinearGradient(
    colors: [hotMagenta, deepPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
```

### Typography

```dart
class TimeFactoryTextStyles {
  // Headers - use for important titles
  static const header = TextStyle(
    fontFamily: 'Orbitron', // Futuristic, geometric font
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: TimeFactoryColors.electricCyan,
    letterSpacing: 2.0,
  );
  
  // Body - use for general text
  static const body = TextStyle(
    fontFamily: 'Roboto Mono', // Monospace for tech feel
    fontSize: 14,
    color: Colors.white70,
  );
  
  // Numbers - use for all CE/resource displays
  static const numbers = TextStyle(
    fontFamily: 'Share Tech Mono',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: TimeFactoryColors.acidGreen,
  );
  
  // Glitch text - use for warnings/errors
  static const glitch = TextStyle(
    fontFamily: 'VT323', // Terminal-style font
    fontSize: 16,
    color: TimeFactoryColors.hotMagenta,
    letterSpacing: 1.5,
  );
}
```

### UI Components (MUST-HAVE Effects)

**Every UI element should have:**
1. **Neon Glow** - BoxShadow with bloom effect
2. **CRT Scanlines** - Subtle horizontal lines overlay
3. **Tap Feedback** - Scale + color flash + haptic
4. **Glitch on Errors** - RGB split + horizontal offset

**Button Template:**
```dart
class CyberpunkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool isGlitching;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed == null ? null : () {
            HapticFeedback.mediumImpact();
            onPressed!();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              label.toUpperCase(),
              style: TimeFactoryTextStyles.header.copyWith(
                fontSize: 16,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

**Scanline Overlay (Apply to all screens):**
```dart
class ScanlinesOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: ScanlinePainter(),
        child: Container(),
      ),
    );
  }
}

class ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;
    
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

---

## 🏗️ ARCHITECTURE REQUIREMENTS

### Project Structure (MUST FOLLOW)

```
lib/
├── core/
│   ├── constants/
│   │   ├── game_constants.dart       # All balancing numbers
│   │   ├── colors.dart                # TimeFactoryColors
│   │   └── text_styles.dart           # TimeFactoryTextStyles
│   ├── utils/
│   │   ├── number_formatter.dart      # CE formatting with suffixes
│   │   ├── time_calculator.dart       # Loop calculations
│   │   └── paradox_calculator.dart    # Paradox mechanics
│   └── services/
│       ├── save_service.dart          # Save/load with compression
│       ├── audio_service.dart         # Sound effects + music
│       └── analytics_service.dart     # Firebase events
├── domain/
│   ├── entities/
│   │   ├── worker.dart                # Worker model
│   │   ├── station.dart               # Factory station model
│   │   ├── game_state.dart            # Main game state
│   │   └── temporal_loop.dart         # Loop mechanics
│   ├── repositories/
│   │   └── game_repository.dart       # Abstract interface
│   └── usecases/
│       ├── hire_worker_usecase.dart
│       ├── upgrade_station_usecase.dart
│       ├── trigger_paradox_usecase.dart
│       └── prestige_usecase.dart
├── data/
│   ├── models/
│   │   └── save_data.dart             # Serializable save model
│   └── repositories/
│       └── game_repository_impl.dart
├── presentation/
│   ├── game/                          # Flame game components
│   │   ├── time_factory_game.dart
│   │   ├── components/
│   │   │   ├── worker_component.dart
│   │   │   ├── station_component.dart
│   │   │   ├── particle_effects/
│   │   │   └── glitch_effects/
│   │   └── systems/
│   │       ├── game_controller.dart
│   │       └── production_system.dart
│   ├── ui/                            # Flutter UI
│   │   ├── widgets/
│   │   │   ├── cyberpunk_button.dart
│   │   │   ├── animated_number.dart
│   │   │   ├── worker_card.dart
│   │   │   └── paradox_meter.dart
│   │   └── screens/
│   │       ├── factory_screen.dart
│   │       ├── workers_screen.dart
│   │       ├── prestige_screen.dart
│   │       └── tech_tree_screen.dart
│   └── state/                         # Riverpod providers
│       ├── game_state_provider.dart
│       ├── workers_provider.dart
│       └── stations_provider.dart
└── main.dart
```

### State Management Pattern

**ALWAYS use Riverpod with this pattern:**

```dart
// 1. Domain Entity (Pure Dart, no Flutter)
@freezed
class Worker with _$Worker {
  const factory Worker({
    required String id,
    required WorkerEra era,
    required int level,
    required BigInt baseProduction,
    required WorkerRarity rarity,
  }) = _Worker;
  
  factory Worker.fromJson(Map<String, dynamic> json) =>
      _$WorkerFromJson(json);
}

// 2. Notifier (Business Logic)
@riverpod
class WorkerNotifier extends _$WorkerNotifier {
  @override
  Worker build(String workerId) {
    // Load worker from game state
    return ref.watch(gameStateProvider).workers[workerId]!;
  }
  
  void upgrade() {
    final current = state;
    final cost = _calculateUpgradeCost(current.level);
    
    if (ref.read(gameStateProvider).chronoEnergy >= cost) {
      ref.read(gameStateProvider.notifier).spendCE(cost);
      state = current.copyWith(level: current.level + 1);
    }
  }
}

// 3. UI Consumer
class WorkerCard extends ConsumerWidget {
  final String workerId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worker = ref.watch(workerNotifierProvider(workerId));
    
    return CyberpunkButton(
      label: 'Upgrade Lv.${worker.level}',
      color: TimeFactoryColors.electricCyan,
      onPressed: () {
        ref.read(workerNotifierProvider(workerId).notifier).upgrade();
      },
    );
  }
}
```

---

## 🎮 CORE MECHANICS IMPLEMENTATION

### 1. Number Handling (CRITICAL)

**ALWAYS use BigInt for currency/resources:**

```dart
class NumberFormatter {
  static final _suffixes = [
    '', 'K', 'M', 'B', 'T', 'Qa', 'Qi', 'Sx', 'Sp', 'Oc', 'No', 'Dc'
  ];
  
  /// Format Chrono-Energy with suffixes
  static String formatCE(BigInt amount) {
    if (amount < BigInt.from(1000)) {
      return amount.toString();
    }
    
    double value = amount.toDouble();
    int idx = 0;
    
    while (value >= 1000 && idx < _suffixes.length - 1) {
      value /= 1000;
      idx++;
    }
    
    return '${value.toStringAsFixed(1)}${_suffixes[idx]}';
  }
  
  /// Glitch effect for high paradox levels
  static String formatWithGlitch(BigInt amount, double paradoxLevel) {
    final base = formatCE(amount);
    
    if (paradoxLevel < 0.7) return base;
    
    // Randomly corrupt characters at high paradox
    return base.split('').map((char) {
      if (Random().nextDouble() < (paradoxLevel - 0.7) * 2) {
        return ['@', '#', '\$', '%', '&', '*'][Random().nextInt(6)];
      }
      return char;
    }).join();
  }
}
```

### 2. Production Loop (Fixed Time Step)

```dart
class GameController {
  double _accumulator = 0.0;
  static const _tickRate = 1.0 / 30.0; // 30 ticks per second
  
  void tick(double dt) {
    _accumulator += dt;
    
    while (_accumulator >= _tickRate) {
      _accumulator -= _tickRate;
      _updateProduction(_tickRate);
      _updateParadox(_tickRate);
      _checkUnlocks();
    }
  }
  
  void _updateProduction(double dt) {
    final gameState = ref.read(gameStateProvider);
    BigInt totalProduction = BigInt.zero;
    
    // Calculate from all active loops
    for (final loop in gameState.activeLoops) {
      final worker = gameState.workers[loop.workerId]!;
      final station = gameState.stations[loop.stationId]!;
      
      // Base production × worker level × era multiplier × station bonus
      final production = worker.baseProduction
          .multiply(BigInt.from(worker.level))
          .multiply(BigInt.from((worker.era.multiplier * 100).toInt()))
          .divide(BigInt.from(100))
          .multiply(BigInt.from((station.productionBonus * 100).toInt()))
          .divide(BigInt.from(100));
      
      totalProduction += production;
    }
    
    // Apply delta time
    final toAdd = totalProduction
        .multiply(BigInt.from((dt * 1000).toInt()))
        .divide(BigInt.from(1000));
    
    ref.read(gameStateProvider.notifier).addCE(toAdd);
  }
}
```

### 3. Paradox System

```dart
class ParadoxCalculator {
  /// Calculate paradox generation rate
  static double calculateParadoxRate(GameState state) {
    // Base: 0.1% per worker per second
    final workerParadox = state.activeWorkers.length * 0.001;
    
    // Station paradox: 0.05% per station
    final stationParadox = state.stations.length * 0.0005;
    
    // Era paradox: mixing eras increases instability
    final eraVariety = state.activeWorkers
        .map((w) => w.era)
        .toSet()
        .length;
    final eraParadox = (eraVariety - 1) * 0.002; // Bonus for variety
    
    return workerParadox + stationParadox + eraParadox;
  }
  
  /// Check if paradox event should trigger
  static bool shouldTriggerEvent(double paradoxLevel) {
    if (paradoxLevel >= 1.0) return true; // Forced at 100%
    
    // Random chance increases with level
    return Random().nextDouble() < (paradoxLevel * 0.01);
  }
  
  /// Calculate paradox event rewards
  static ParadoxReward calculateReward(double paradoxLevel) {
    // Higher risk = higher reward
    final multiplier = 2.0 + (paradoxLevel * 3.0); // 2x to 5x
    final duration = Duration(minutes: 5);
    
    return ParadoxReward(
      productionMultiplier: multiplier,
      duration: duration,
      paradoxReduction: paradoxLevel * 0.3, // Reduce by 30%
    );
  }
}
```

### 4. Prestige Calculation

```dart
class PrestigeCalculator {
  /// Calculate Paradox Points gained from prestige
  static int calculateParadoxPoints(BigInt totalCELifetime) {
    // Formula: floor(sqrt(CE / 1,000,000))
    final ratio = totalCELifetime.toDouble() / 1000000.0;
    return sqrt(ratio).floor();
  }
  
  /// Check if prestige is available
  static bool canPrestige(BigInt currentCE) {
    return currentCE >= BigInt.from(1000000); // 1M minimum
  }
  
  /// Calculate new run bonuses from PP spent
  static GameBonuses calculateBonuses(Map<String, int> ppSpent) {
    return GameBonuses(
      productionMultiplier: 1.0 + (ppSpent['chrono_mastery'] ?? 0) * 0.1,
      paradoxReduction: (ppSpent['rift_stability'] ?? 0) * 0.05,
      startingEras: 1 + (ppSpent['era_unlock'] ?? 0),
      offlineEfficiency: 0.7 + (ppSpent['offline_bonus'] ?? 0) * 0.1,
    );
  }
}
```

---

## 🎨 VISUAL EFFECTS (Juiciness Requirements)

### Particle Effects (MUST IMPLEMENT)

**CE Gain Effect:**
```dart
class CEGainParticle extends ParticleComponent {
  CEGainParticle({
    required Vector2 position,
    required BigInt amount,
  }) {
    // Cyan particles floating upward
    final particleCount = min((amount.toDouble() / 100).floor(), 20);
    
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: particleCount,
          generator: (i) => AcceleratedParticle(
            speed: Vector2(
              Random().nextDouble() * 40 - 20,
              -50 - Random().nextDouble() * 30,
            ),
            child: CircleParticle(
              radius: 2 + Random().nextDouble() * 2,
              paint: Paint()
                ..color = TimeFactoryColors.electricCyan
                ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4),
            ),
          ),
        ),
      ),
    );
    
    // Floating number
    add(
      TextComponent(
        text: '+${NumberFormatter.formatCE(amount)}',
        textRenderer: TextPaint(
          style: TimeFactoryTextStyles.numbers.copyWith(fontSize: 20),
        ),
        position: position,
      )
        ..add(MoveEffect.by(Vector2(0, -80), EffectController(duration: 1.5)))
        ..add(OpacityEffect.fadeOut(EffectController(duration: 1.5))),
    );
  }
}
```

**Glitch Effect Shader:**
```dart
class GlitchShader extends Component {
  double intensity = 0.0; // 0.0 to 1.0 based on paradox level
  
  final FragmentShader shader = FragmentProgram.fromAsset('shaders/glitch.frag');
  
  @override
  void render(Canvas canvas) {
    if (intensity > 0.0) {
      shader.setFloat(0, gameRef.currentTime); // time uniform
      shader.setFloat(1, intensity);           // glitchIntensity uniform
      
      final paint = Paint()..shader = shader;
      canvas.saveLayer(null, paint);
      // Game renders here
      canvas.restore();
    }
  }
}
```

**Glitch Fragment Shader (shaders/glitch.frag):**
```glsl
uniform float time;
uniform float glitchIntensity;
uniform sampler2D texture;

void main() {
  vec2 uv = gl_FragCoord.xy / resolution.xy;
  
  // Horizontal displacement
  if (mod(time * 10.0 + uv.y * 100.0, 100.0) < glitchIntensity * 50.0) {
    uv.x += sin(time * 50.0) * 0.03 * glitchIntensity;
  }
  
  // RGB split
  float offset = 0.005 * glitchIntensity;
  vec4 color;
  color.r = texture2D(texture, uv + vec2(offset, 0.0)).r;
  color.g = texture2D(texture, uv).g;
  color.b = texture2D(texture, uv - vec2(offset, 0.0)).b;
  color.a = 1.0;
  
  // Scanlines
  color.rgb *= 1.0 - (mod(uv.y * resolution.y, 2.0) < 1.0 ? 0.1 : 0.0);
  
  // Random noise at high intensity
  if (glitchIntensity > 0.8) {
    float noise = fract(sin(dot(uv + time, vec2(12.9898, 78.233))) * 43758.5453);
    color.rgb += noise * 0.1 * (glitchIntensity - 0.8);
  }
  
  gl_FragColor = color;
}
```

---

## 💾 SAVE SYSTEM (MUST IMPLEMENT)

```dart
@freezed
class SaveData with _$SaveData {
  const factory SaveData({
    required DateTime lastSaveTime,
    required int saveVersion,
    required String chronoEnergy,        // BigInt as string
    required int timeShards,
    required Map<String, WorkerData> workers,
    required Map<String, StationData> stations,
    required double paradoxLevel,
    required int prestigeLevel,
    required Map<String, int> paradoxPoints,
    required List<String> unlockedEras,
  }) = _SaveData;
  
  factory SaveData.fromJson(Map<String, dynamic> json) =>
      _$SaveDataFromJson(json);
}

class SaveService {
  final SharedPreferences _prefs;
  static const _saveKey = 'time_factory_save_v1';
  static const _autoSaveInterval = Duration(seconds: 30);
  
  Timer? _autoSaveTimer;
  
  /// Enable auto-save
  void enableAutoSave(GameState Function() getState) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(_autoSaveInterval, (_) {
      save(getState());
    });
  }
  
  /// Save game state (compressed)
  Future<void> save(GameState state) async {
    final saveData = SaveData(
      lastSaveTime: DateTime.now(),
      saveVersion: 1,
      chronoEnergy: state.chronoEnergy.toString(),
      timeShards: state.timeShards,
      workers: state.workers.map((k, v) => MapEntry(k, v.toData())),
      stations: state.stations.map((k, v) => MapEntry(k, v.toData())),
      paradoxLevel: state.paradoxLevel,
      prestigeLevel: state.prestigeLevel,
      paradoxPoints: state.paradoxPoints,
      unlockedEras: state.unlockedEras.toList(),
    );
    
    final json = saveData.toJson();
    
    // Compress for smaller size
    final jsonString = jsonEncode(json);
    final compressed = gzip.encode(utf8.encode(jsonString));
    final base64String = base64Encode(compressed);
    
    await _prefs.setString(_saveKey, base64String);
  }
  
  /// Load game state
  Future<SaveData?> load() async {
    try {
      final base64String = _prefs.getString(_saveKey);
      if (base64String == null) return null;
      
      final compressed = base64Decode(base64String);
      final jsonString = utf8.decode(gzip.decode(compressed));
      final json = jsonDecode(jsonString);
      
      return SaveData.fromJson(json);
    } catch (e) {
      debugPrint('Save corrupted: $e');
      return null;
    }
  }
  
  /// Calculate offline progress
  Future<OfflineProgress> calculateOfflineProgress(
    SaveData save,
    GameState currentState,
  ) async {
    final now = DateTime.now();
    final duration = now.difference(save.lastSaveTime);
    
    // Cap at 8 hours
    final cappedSeconds = min(duration.inSeconds, 8 * 60 * 60).toDouble();
    
    // 70% efficiency offline (narrative: loops are unstable without you)
    const offlineEfficiency = 0.7;
    
    // Calculate production
    final productionPerSecond = currentState.calculateTotalProduction();
    final offlineCE = productionPerSecond
        .multiply(BigInt.from(cappedSeconds.toInt()))
        .multiply(BigInt.from(70))
        .divide(BigInt.from(100));
    
    // Calculate paradox accumulated
    final paradoxRate = ParadoxCalculator.calculateParadoxRate(currentState);
    final paradoxGained = (paradoxRate * cappedSeconds).clamp(0.0, 1.0);
    
    return OfflineProgress(
      duration: Duration(seconds: cappedSeconds.toInt()),
      ceGained: offlineCE,
      paradoxGained: paradoxGained,
      wasOffline: duration.inSeconds > 60,
    );
  }
}
```

---

## 🎵 AUDIO REQUIREMENTS

### Sound Effects (MUST HAVE)

```dart
class AudioService {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  
  // SFX with cyberpunk aesthetic
  Future<void> playCEGain() async {
    await _sfxPlayer.play(AssetSource('sfx/ce_gain.wav'));
    // Short electric "zing" sound
  }
  
  Future<void> playWorkerHire() async {
    await _sfxPlayer.play(AssetSource('sfx/worker_materialize.wav'));
    // Sci-fi transporter sound
  }
  
  Future<void> playParadoxWarning() async {
    await _sfxPlayer.play(AssetSource('sfx/paradox_alarm.wav'));
    // Distorted alarm with glitch
  }
  
  Future<void> playPrestige() async {
    await _sfxPlayer.play(AssetSource('sfx/timeline_collapse.wav'));
    // Deep bass rumble + reality tear
  }
  
  // Music layers (dynamic based on game state)
  Future<void> playMusic(double paradoxLevel) async {
    String track;
    
    if (paradoxLevel < 0.3) {
      track = 'music/ambient_low.mp3';  // Calm synthwave
    } else if (paradoxLevel < 0.7) {
      track = 'music/ambient_mid.mp3';  // Tension building
    } else {
      track = 'music/ambient_high.mp3'; // Chaotic, glitchy
    }
    
    await _musicPlayer.play(AssetSource(track));
    await _musicPlayer.setVolume(0.6);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }
}
```

**Audio Asset Requirements:**
- All SFX must be < 100KB
- Music tracks: 128kbps MP3, loopable
- Use synthesizers (no organic instruments)
- Heavy reverb and distortion for cyberpunk feel

---

## 📊 BALANCING CONSTANTS

**ALL balancing numbers in one place:**

```dart
class GameConstants {
  // ===== WORKER COSTS =====
  static const workerBaseCost = 100;
  static const workerCostGrowth = 1.5;  // Each worker costs 1.5x more
  
  // ===== PRODUCTION =====
  static const victorianBaseProduction = 1;    // 1 CE/sec
  static const productionLevelMultiplier = 1.2; // +20% per level
  
  // ===== ERA MULTIPLIERS =====
  static const eraMultipliers = {
    'victorian': 1.0,
    'roaring_20s': 2.0,
    'atomic_age': 4.0,
    'cyberpunk_80s': 8.0,
    'neo_tokyo': 16.0,
    'post_singularity': 32.0,
    'ancient_rome': 64.0,
    'far_future': 128.0,
  };
  
  // ===== ERA UNLOCK THRESHOLDS =====
  static final eraUnlockCosts = {
    'roaring_20s': BigInt.from(1000),
    'atomic_age': BigInt.from(100000),
    'cyberpunk_80s': BigInt.from(1000000),
    'neo_tokyo': BigInt.from(10000000),
    'post_singularity': BigInt.from(100000000),
    'ancient_rome': BigInt.from(1000000000),
    'far_future': BigInt.from(10000000000),
  };
  
  // ===== PARADOX =====
  static const paradoxPerWorker = 0.001;    // 0.1% per second
  static const paradoxPerStation = 0.0005;  // 0.05% per second
  static const paradoxEventBonus = 3.0;     // 3x production during event
  static const paradoxEventDuration = Duration(minutes: 5);
  
  // ===== PRESTIGE =====
  static final prestigeThreshold = BigInt.from(1000000); // 1M CE
  static const prestigeFormulaDivisor = 1000000.0;
  
  // ===== OFFLINE =====
  static const maxOfflineHours = 8;
  static const offlineEfficiency = 0.7; // 70% production while away
  
  // ===== MONETIZATION =====
  static const dailyFreeShardsDaily = 10;
  static const adRewardShards = 5;
  static const workerPullCostShards = 50;
  static const timeBoostDurationHours = 4;
  static const timeBoostMultiplier = 2.0;
}
```

---

## 🎯 UI/UX PATTERNS

### Animated Number Display (ALWAYS USE FOR CE)

```dart
class AnimatedCEDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ce = ref.watch(gameStateProvider.select((s) => s.chronoEnergy));
    final paradox = ref.watch(gameStateProvider.select((s) => s.paradoxLevel));
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      tween: Tween(begin: ce.toDouble(), end: ce.toDouble()),
      builder: (context, value, child) {
        final shouldGlitch = paradox > 0.7;
        
        return Text(
          NumberFormatter.formatWithGlitch(
            BigInt.from(value),
            shouldGlitch ? paradox : 0.0,
          ),
          style: TimeFactoryTextStyles.numbers.copyWith(
            fontSize: 28,
            shadows: [
              Shadow(
                color: TimeFactoryColors.acidGreen.withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### Worker Card (Collection Display)

```dart
class WorkerCard extends ConsumerWidget {
  final String workerId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worker = ref.watch(workerNotifierProvider(workerId));
    
    return Container(
      width: 150,
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            worker.era.color.withOpacity(0.3),
            TimeFactoryColors.voidBlack,
          ],
        ),
        border: Border.all(
          color: worker.rarity.borderColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: worker.rarity.borderColor.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Worker sprite/image
          Expanded(
            flex: 3,
            child: Image.asset(
              'assets/workers/${worker.era.id}/${worker.id}.png',
              fit: BoxFit.contain,
            ),
          ),
          
          // Info section
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.name,
                    style: TimeFactoryTextStyles.header.copyWith(
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    worker.era.displayName,
                    style: TimeFactoryTextStyles.body.copyWith(
                      fontSize: 10,
                      color: worker.era.color,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.bolt, 
                        color: TimeFactoryColors.acidGreen, 
                        size: 12,
                      ),
                      Text(
                        '${NumberFormatter.formatCE(worker.production)}/s',
                        style: TimeFactoryTextStyles.numbers.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Row(
                    children: List.generate(
                      worker.rarity.stars,
                      (i) => Icon(
                        Icons.star,
                        color: worker.rarity.starColor,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🚨 CRITICAL RULES

### DO's ✅

1. **ALWAYS use BigInt for CE and resources**
2. **ALWAYS apply neon glow effects to buttons/panels**
3. **ALWAYS add scanline overlay to screens**
4. **ALWAYS use TimeFactoryColors constants**
5. **ALWAYS implement haptic feedback on taps**
6. **ALWAYS format numbers with suffixes (K, M, B)**
7. **ALWAYS use fixed time step for game logic (30 TPS)**
8. **ALWAYS compress save data with gzip**
9. **ALWAYS add particle effects for visual feedback**
10. **ALWAYS test on low-end devices (2GB RAM)**

### DON'Ts ❌

1. **NEVER use double for currency** (precision loss)
2. **NEVER update UI at 60 FPS** (battery drain)
3. **NEVER use bright white** (use off-white or cyan)
4. **NEVER use organic sounds** (keep it synthetic)
5. **NEVER block gameplay** (no energy systems)
6. **NEVER show forced ads** (rewarded only)
7. **NEVER ignore paradox level** (affects entire experience)
8. **NEVER use standard Material Design** (custom cyberpunk only)
9. **NEVER forget offline progress calculation**
10. **NEVER skip the glitch effects** (core to aesthetic)

---

## 🧪 TESTING CHECKLIST

Before committing any feature:

- [ ] Numbers formatted correctly (K, M, B suffixes)
- [ ] Neon glow applied to interactive elements
- [ ] Haptic feedback on button press
- [ ] Sound effect plays on action
- [ ] Particle effect spawns on success
- [ ] Works at 60 FPS on Pixel 4a (mid-range test device)
- [ ] Save/load preserves exact state
- [ ] Offline progress calculated accurately
- [ ] Paradox affects are visible (glitch, color shift)
- [ ] No memory leaks (run for 30 minutes)
- [ ] All text uses TimeFactoryTextStyles
- [ ] All colors use TimeFactoryColors
- [ ] Scanlines visible on screen
- [ ] Glitch shader active at high paradox

---

## 📚 REFERENCE DOCUMENTS

**Full Game Design Document:** `TIME_FACTORY_GDD.md`  
**Architecture Patterns:** `IDLE_GAME_SKILL.md`  
**Asset Guidelines:** `docs/asset_guide.md`  
**Balancing Sheet:** `docs/balancing.xlsx`

---

## 🎓 LEARNING RESOURCES

**Cyberpunk Aesthetics:**
- Blade Runner 2049 color grading tutorials
- Cyberpunk 2077 UI deconstruction
- Synthwave color palette generators

**Technical:**
- [Flame Game Engine Docs](https://docs.flame-engine.org/)
- [Riverpod State Management](https://riverpod.dev/)
- [BigInt Performance in Dart](https://dart.dev/guides/language/numbers)
- [Fragment Shaders in Flutter](https://docs.flutter.dev/ui/design/graphics/fragment-shaders)

**Game Design:**
- [Idle Game Math](https://gameanalytics.com/blog/idle-game-mathematics/)
- [Antimatter Dimensions](https://ivark.github.io/) (prestige reference)
- [Universal Paperclips](https://www.decisionproblem.com/paperclips/) (narrative idle)

---

## 🔄 VERSION HISTORY

- **v1.0** (2026-02-06): Initial skill document created
- Game concept: Time Factory: Paradox Industries
- Architecture: Flutter/Flame + Riverpod
- Target: Mobile (iOS/Android)

---

**Remember:** This game is about creating a mesmerizing, thought-provoking experience wrapped in neon and synthesizers. Every system should serve the core fantasy: "I am a rogue time manipulator building an empire in the shadows of a cyberpunk dystopia."

When in doubt, ask: "Does this feel cyberpunk? Is it juicy? Does it respect the player's time?"
