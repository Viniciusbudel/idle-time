# TIME FACTORY: PARADOX INDUSTRIES
## Game Design Document v1.0

---

## 🎯 HIGH CONCEPT

**Elevator Pitch:**  
"You're a rogue chrono-engineer in 2247 Neo-Tokyo who discovered how to exploit time loops for profit. Build a temporal factory empire by harvesting workers from different eras, but beware—every paradox you create brings you closer to the Timekeepers..."

**Genre:** Cyberpunk Temporal Idle/Incremental  
**Platform:** Mobile (iOS/Android) - Flutter/Flame  
**Target Audience:** 16-35, fans of sci-fi, cyberpunk, and strategic idle games  
**Session Length:** 2-5 minutes (perfect for commute/breaks)  
**Retention Hook:** "What era will I unlock next? What happens when time collapses?"

---

## 📖 NARRATIVE & WORLD

### Core Story

**Year 2247 - Neo-Tokyo Undercity**

You were a low-level technician at **ChronoCorp**, the megacorporation that monopolizes time travel for the elite. During a routine maintenance shift, you discovered the **Möbius Protocol**—a forbidden equation that lets you create closed time loops without paradox detectors noticing.

You stole a decommissioned **Temporal Rift Generator** and escaped to the Undercity, where desperate people will pay anything for resources pulled from other timelines. Your basement becomes a temporal sweatshop, exploiting workers from eras that "never existed" in official history.

**The Dark Twist:** Every loop you create generates **Temporal Debt**—reality's way of balancing the equation. Push too far, and the **Timekeepers** (mysterious entities that patrol broken timelines) will come for you. Or worse, time itself might collapse into a singularity.

### Thematic Influences

**H.G. Wells "The Time Machine":**
- The **Eloi/Morlock** dynamic: Surface (rich corps) vs. Undercity (you)
- Time as a resource to be exploited
- Consequence of meddling with temporal mechanics
- Evolution across eras

**Cyberpunk Core:**
- Megacorporations control everything, including time
- Neon-soaked aesthetic with rain-slicked streets
- Technology as both liberation and oppression
- You're the underdog hacker fighting the system

**Dark Elements:**
- Workers don't know they're in a loop (ethical horror)
- Each "prestige" is you abandoning a timeline to collapse
- ChronoCorp sends "Erasers" to hunt you down
- Time isn't infinite—there's an endgame where reality breaks

---

## 🎨 VISUAL AESTHETIC

### Cyberpunk Neon Color Palette

**Primary Colors:**
- **Electric Cyan** (#00F0FF) - Time energy, UI accents
- **Hot Magenta** (#FF006E) - Danger, paradox warnings, errors
- **Acid Green** (#39FF14) - Success states, production, money
- **Deep Purple** (#8B00FF) - Premium currency, rare items
- **Voltage Yellow** (#FFFF00) - Alerts, timekeepers

**Background/Atmosphere:**
- **Void Black** (#0A0E27) - Base background
- **Midnight Blue** (#1A1F3A) - Secondary panels
- **Smoke Gray** (#2D2D44) - Inactive elements
- **Neon glow** on EVERYTHING (bloom post-processing)

### Art Style Reference

**Visual Inspirations:**
- Blade Runner 2049 (rain, neon reflections)
- Cyberpunk 2077 (HUD design, glitch effects)
- Ghostrunner (fast-paced neon combat feel)
- Akira (Japanese cyberpunk, chaotic energy)

**UI Style:**
- **Glitchy CRT scanlines** on all panels
- **Holographic** projections for menus
- **Pixelated noise** when time is unstable
- **ASCII art** easter eggs in terminal windows
- **Kanji/Katakana** mixed with English for that Neo-Tokyo feel

### Character Design

**Worker Eras (Unlockable):**

1. **Victorian Era (1890s)** - Sepia-toned, steam-powered prosthetics, goggles
2. **Roaring 20s (1920s)** - Art deco patterns, flapper aesthetic, brass
3. **Atomic Age (1950s)** - Retro-futurism, chrome, optimistic colors
4. **Cyberpunk 80s (1980s)** - Synthwave, cassette tapes, early cyber implants
5. **Neo-Tokyo (2247)** - Full cybernetic, holographic, your era
6. **Post-Singularity (2400s)** - Abstract, energy beings, incomprehensible
7. **Ancient Rome (50 BC)** - Togas with circuit patterns, marble with LEDs
8. **Far Future (8000s)** - Time-evolved humans, crystalline, cosmic

**Each era has unique visual flair but with cyberpunk neon overlay**

---

## 🎮 CORE GAME MECHANICS

### 1. THE TEMPORAL LOOP (Core Idle Mechanic)

**Base Resource:** **⚡ Chrono-Energy (CE)**
- Primary currency
- Generates passively based on active loops
- Used to: buy workers, upgrade machines, unlock eras

**How Loops Work:**
```
Loop Cycle = Worker Input → Time Compression → Output Multiplier

Example:
- Victorian Worker (1 CE/sec base production)
- Time Loop Level 3 (3x compression)
- Output: 3 CE/sec
```

**Visual:**
- Worker sprite appears
- Does work animation
- Dissolves in cyan particles
- Reappears (loop complete)
- Floating "+3 CE" text

**Technical Implementation:**
```dart
class TemporalLoop {
  final Worker worker;
  final int compressionLevel; // How many loops per second
  
  BigInt calculateProduction(double deltaTime) {
    return worker.baseProduction 
      * BigInt.from(compressionLevel) 
      * worker.eraMultiplier;
  }
}
```

### 2. WORKER SYSTEM (RPG Collection Meta)

**Worker Properties:**
- **Era:** Determines visual style and base stats
- **Rarity:** Common → Rare → Epic → Legendary → Paradox
- **Specialization:** Production, Speed, Efficiency, Paradox Resistance
- **Level:** Upgradeable with resources

**Unlock Progression:**
```
Start: Victorian Era (3 workers unlocked)
  ↓
Reach 1K CE → Unlock Roaring 20s
  ↓
Reach 100K CE → Unlock Atomic Age
  ↓
...and so on
```

**Worker Cards (Gacha-lite):**
- Spend **🔮 Time Shards** (premium currency)
- Pull random workers from unlocked eras
- Legendary workers have unique abilities:
  - "Tesla's Heir" - Generates bonus CE every 10 loops
  - "Quantum Twin" - Counts as 2 workers in same slot

**UI Design:**
- Holographic trading card aesthetic
- Glitch effect when pulling rare
- Worker rotates in 3D (Flame's 3D capabilities)

### 3. THE FACTORY BUILDER

**Layout:**
- **Grid-based factory** (5x5 at start, expandable)
- Place **Temporal Stations** where workers loop
- Stations have adjacency bonuses

**Station Types:**
1. **Basic Loop Chamber** - 1 worker slot
2. **Dual Helix Chamber** - 2 workers, 20% synergy bonus
3. **Paradox Amplifier** - Boosts adjacent stations by 50%
4. **Time Distortion Field** - Slows time for 2x production
5. **Rift Generator** - Unlocks at prestige, creates instability

**Merge Mechanic:**
- Combine 2 identical stations → Upgraded version
- Level 1 Station + Level 1 Station = Level 2 Station
- Max Level: 5 (glowing, unstable, awesome)

**Visual:**
- Isometric or top-down view
- Neon conduits connect stations
- Energy pulses flow between them
- Glitch effects on high-level stations

### 4. PARADOX SYSTEM (Risk/Reward)

**Temporal Debt Meter:**
- Fills as you create more loops
- At 100% → **Reality Fracture Event**
- You must either:
  - **Stabilize** (spend resources, slow down)
  - **Embrace Chaos** (trigger paradox for massive bonus)

**Paradox Events:**
When triggered voluntarily:
- Screen glitches intensely
- Random era workers get swapped
- 5-minute buff: **3x production** but -50% worker efficiency
- Chance to unlock **Paradox Workers** (rarest tier)

**Timekeeper Raids:**
- At high paradox levels, ChronoCorp sends "Erasers"
- Mini tower-defense: deploy workers to defend factory
- Win: Huge rewards + story progression
- Lose: 10% resource penalty, but lore reveals

**Visual:**
- Reality "tears" with magenta cracks
- Time flows backward briefly
- Workers age rapidly then de-age
- Glitch scanlines intensify

### 5. PRESTIGE: TIMELINE COLLAPSE

**The Mechanic:**
When you prestige, you're **abandoning this timeline** to collapse into a singularity.

**How it Works:**
- Requires 1M CE minimum
- Reset all workers, stations, progress
- Gain **⏳ Paradox Points (PP)** based on total CE earned
- PP provides permanent multipliers

**Formula:**
```
Paradox Points = floor(sqrt(Total_CE_Lifetime / 1,000,000))
```

**Permanent Upgrades (Purchased with PP):**
- **Chrono Mastery** - +10% base production per point
- **Rift Stability** - Reduce paradox accumulation
- **Era Insight** - Start new runs with 2 eras unlocked
- **Timekeeper's Favor** - Raids are easier, better rewards

**Narrative:**
- Each prestige shows a cutscene of the timeline imploding
- You escape through a rift to a "new" 2247
- But things are slightly different (environmental details change)
- After 10+ prestiges, hints that you're stuck in a meta-loop

**Visual:**
- Everything gets sucked into center (particle vortex)
- Cyan → Magenta color shift
- "Timeline #[X] Collapsed" message
- Brief lore snippet about what "you" left behind

---

## 🎯 PROGRESSION SYSTEMS

### Early Game (0-30 mins)

**Goal:** Learn core loop, get first dopamine hits

**Milestones:**
- Tutorial: "You've stolen the Rift Generator. Start your first loop."
- Hire 3 Victorian workers
- Reach 1,000 CE (unlock Roaring 20s era)
- Build first Dual Helix Chamber
- First paradox event (scripted, safe)

**Pacing:**
- Rapid unlocks every 2-3 minutes
- Satisfying number growth (10 → 100 → 1K)
- Story snippets via "Terminal Messages" from unknown ally

### Mid Game (30 mins - 5 hours)

**Goal:** Build factory empire, experiment with paradoxes

**Milestones:**
- Unlock all 8 eras
- Factory grid expanded to 8x8
- First Timekeeper Raid (story boss)
- Reach 100K CE
- Unlock "Merge" for stations

**Pacing:**
- Unlocks every 10-15 minutes
- Introduce complexity (synergies, placement strategy)
- Paradox meter starts mattering

### Late Game (5+ hours)

**Goal:** Optimize, chase prestige, uncover dark truth

**Milestones:**
- First Prestige (timeline collapse)
- Unlock Paradox Workers (legendary tier)
- Reach 1M CE in single run
- Discover "The Endgame" (secret 9th era)

**Endgame Reveal:**
- After enough prestiges, you realize YOU are a Timekeeper
- You've been testing this loop across infinite timelines
- Choice: Break the cycle (credits) or Continue (infinite mode)

---

## 💎 MONETIZATION (Ethical F2P)

### Premium Currency: 🔮 Time Shards

**How to Earn (Free):**
- Daily login: 10 shards/day
- Complete achievements: 5-50 shards
- Paradox events: Random drops (5-20)
- Weekly challenges: 100 shards
- Prestige reward: 50 shards

**How to Buy:**
- $0.99 → 100 shards
- $4.99 → 600 shards (+20% bonus)
- $9.99 → 1,300 shards (+30% bonus)
- $19.99 → 3,000 shards (+50% bonus)

**What Shards Buy:**
- Worker card pulls (50 shards = 1 pull)
- Instant 4-hour time skip (30 shards)
- Cosmetic factory skins (100-500 shards)
- Premium Battle Pass (800 shards)

### Rewarded Video Ads (Player Choice)

**Options:**
1. **"Time Boost"** - Watch ad → 2x production for 4 hours
2. **"Paradox Chest"** - Watch ad → Random premium reward
3. **"Offline Bonus"** - Watch ad → Double offline earnings
4. **"Emergency Stabilization"** - Watch ad → Reset paradox meter

**Frequency Limit:** Max 10 ads/day to prevent fatigue

### Battle Pass (Seasonal)

**Free Track:**
- Every 5 levels: Small CE bonus, common workers, shards
- Lore entries about ChronoCorp's history

**Premium Track ($4.99):**
- Every level: Better rewards
- Exclusive cosmetics (neon skins, holographic effects)
- Legendary worker guaranteed at Level 50
- Unique factory theme (e.g., "Blade Runner Rain")

**Season Length:** 30 days
**Progression:** Play daily for XP, complete challenges

### One-Time Purchases

**"Ad-Free Paradise"** - $2.99
- Removes forced ads (keeps rewarded ads)
- 200 Time Shards bonus
- Exclusive "No Ads" badge on profile

**"Starter Pack"** - $4.99 (Limited time)
- 500 Time Shards
- 1 Legendary worker of choice
- 24-hour 3x production boost
- Only purchasable once

**"Timekeeper's Edition"** - $9.99
- All of Starter Pack
- Permanent +20% CE production
- Exclusive "Singularity" factory skin
- Unlock all eras immediately (still need CE to hire workers)

### Fair Monetization Principles

✅ **DO:**
- Make game fully playable F2P
- Ads are always player choice (except maybe 1 daily interstitial)
- Premium currency earnable through play
- No pay-to-win (just pay-to-progress-faster)

❌ **DON'T:**
- Energy systems that block play
- Aggressive pop-up ads
- Loot boxes (worker pulls have visible odds)
- Progress-blocking paywalls

---

## 🎨 UI/UX DESIGN MOCKUP

### Main Factory Screen

```
┌─────────────────────────────────────────┐
│ ⚡ 45.2K CE/sec  🔮 127 Shards  ⚠️ 67%  │ ← Status Bar
├─────────────────────────────────────────┤
│                                         │
│     [FACTORY GRID - Isometric View]     │
│                                         │
│   ╔═╗ ╔═╗ ╔═╗ ╔═╗ [ ][ ][ ]           │
│   ║█║ ║█║ ║█║ ║█║  (empty slots)       │
│   ╚═╝ ╚═╝ ╚═╝ ╚═╝                      │
│    ↓   ↓   ↓   ↓                       │
│   [Neon energy flowing between]        │
│                                         │
│   Total: ⚡ 1.2M CE                     │
│   Paradox: ▓▓▓▓▓▓▓░░░ 67%              │
├─────────────────────────────────────────┤
│ [Workers] [Factory] [Tech] [Prestige]  │ ← Bottom Nav
└─────────────────────────────────────────┘
```

**Cyberpunk Touches:**
- CRT scanline overlay on entire screen
- Glitch effect on paradox meter when high
- Neon glow around buttons
- Raindrop particles falling (subtle)
- Background: Undercity skyline with neon signs

### Worker Collection Screen

```
┌─────────────────────────────────────────┐
│          🎴 TEMPORAL WORKERS 🎴         │
├─────────────────────────────────────────┤
│  Filter: [All Eras ▼] [Rarity ▼]       │
├─────────────────────────────────────────┤
│                                         │
│  ┏━━━━━━┓  ┏━━━━━━┓  ┏━━━━━━┓         │
│  ┃ VIC  ┃  ┃ 1920 ┃  ┃ ATOM ┃         │
│  ┃ MECH ┃  ┃FLAPR ┃  ┃ ENGI ┃         │
│  ┃ Lv.5 ┃  ┃ Lv.3 ┃  ┃ Lv.8 ┃         │
│  ┃⭐⭐⭐┃  ┃⭐⭐  ┃  ┃⭐⭐⭐⭐┃         │
│  ┗━━━━━━┛  ┗━━━━━━┛  ┗━━━━━━┛         │
│   12 CE/s    18 CE/s   45 CE/s         │
│                                         │
│  [Deploy] [Upgrade] [Retire]           │
├─────────────────────────────────────────┤
│  [Pull Worker - 50 🔮] [Watch Ad: Free]│
└─────────────────────────────────────────┘
```

**Visual Effects:**
- Cards have holographic shimmer
- Legendary cards have animated glitch edges
- Tap card → Flips to show stats/lore

### Prestige Screen

```
┌─────────────────────────────────────────┐
│        ⏳ TIMELINE COLLAPSE ⏳          │
├─────────────────────────────────────────┤
│                                         │
│     "Abandon this timeline to gain     │
│      power for your next attempt"      │
│                                         │
│   Current CE Lifetime: 2,450,000       │
│                                         │
│   Will Gain: 49 Paradox Points         │
│                                         │
│   ┌───────────────────────────┐        │
│   │  Current Bonuses:         │        │
│   │  • +50% CE Production     │        │
│   │  • +2 Starting Eras       │        │
│   │  • 30% Faster Loops       │        │
│   └───────────────────────────┘        │
│                                         │
│  ⚠️  This will reset ALL progress      │
│                                         │
│ [Cancel]        [COLLAPSE TIMELINE]    │
└─────────────────────────────────────────┘
```

**Animation:**
- Vortex swirling in background
- Magenta lightning flashes
- Button pulses with danger color

---

## 🎵 AUDIO DESIGN

### Music

**Main Theme:**
- Synthwave with dark undertones
- Arpeggiators (time loop feel)
- Heavy bass (oppressive megacorp vibe)
- Reference: Blade Runner 2049 OST meets Hotline Miami

**Era-Specific Stems:**
- Victorian: Add steam hisses, clock ticks
- 1920s: Jazz saxophone layer
- Atomic: Theremin, retro sci-fi bleeps
- Cyberpunk 80s: More synth, drum machines
- Far Future: Ethereal, cosmic ambience

**Dynamic Music:**
- Low paradox: Calm, steady rhythm
- High paradox (>70%): Music glitches, tempo increases
- Raid event: Aggressive combat track kicks in

### Sound Effects

**Essential SFX:**
- **Loop Complete:** "Whoosh" + electric zap
- **CE Gained:** Satisfying "ding" with pitch variation
- **Unlock:** Triumphant synth chord progression
- **Paradox Warning:** Distorted alarm
- **Worker Deploy:** Materialization sound (Star Trek transporter)
- **Merge:** Two sounds colliding into harmony
- **Prestige:** Reality tearing, deep bass rumble

**Juicy Feedback:**
- Every tap: Small electric spark sound
- UI navigation: Cyberpunk beeps (different tones)
- Rare pull: Dramatic "legendary" music sting

### Haptic Feedback

- Tap worker: Light vibration
- Paradox event: Medium pulse
- Prestige: Strong, sustained vibration during collapse
- Timekeeper raid: Rhythmic pulses during combat

---

## 🏗️ TECHNICAL ARCHITECTURE

### Using the Idle Game Skill Patterns

**State Management: Riverpod**
```dart
// Main game state
@riverpod
class GameState extends _$GameState {
  @override
  GameData build() {
    return GameData(
      chronoEnergy: BigInt.zero,
      timeShards: 0,
      workers: {},
      stations: {},
      paradoxLevel: 0.0,
      unlockedEras: {'victorian'},
    );
  }
  
  void addChronoEnergy(BigInt amount) {
    state = state.copyWith(
      chronoEnergy: state.chronoEnergy + amount,
    );
  }
}

// Workers by era
@riverpod
class WorkersByEra extends _$WorkersByEra {
  @override
  Map<String, List<Worker>> build(String era) {
    return ref.watch(gameStateProvider).workers
      .where((w) => w.era == era)
      .toList();
  }
}
```

**Game Loop: Fixed Time Step**
```dart
class TimeFactoryGame extends FlameGame {
  final GameController controller;
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Update at 30 ticks/sec for consistency
    controller.tick(dt);
    
    // Visual updates can be 60fps
    _updateParticles(dt);
    _updateAnimations(dt);
  }
}

class GameController {
  double accumulator = 0.0;
  static const tickRate = 1.0 / 30.0;
  
  void tick(double dt) {
    accumulator += dt;
    
    while (accumulator >= tickRate) {
      accumulator -= tickRate;
      
      // Update production
      _calculateProduction(tickRate);
      _updateParadoxMeter(tickRate);
      _checkUnlocks();
      _autoSave();
    }
  }
}
```

**BigInt Number Handling**
```dart
class NumberFormatter {
  static String formatCE(BigInt amount) {
    if (amount < BigInt.from(1000)) {
      return amount.toString();
    }
    
    // Cyberpunk style: "45.2K" "1.2M" "3.4B"
    final suffixes = ['', 'K', 'M', 'B', 'T', 'Qa', 'Qi'];
    double value = amount.toDouble();
    int idx = 0;
    
    while (value >= 1000 && idx < suffixes.length - 1) {
      value /= 1000;
      idx++;
    }
    
    return '${value.toStringAsFixed(1)}${suffixes[idx]}';
  }
  
  // Glitch effect for high numbers
  static String formatWithGlitch(BigInt amount, bool shouldGlitch) {
    final base = formatCE(amount);
    if (!shouldGlitch) return base;
    
    // Randomly corrupt characters
    return base.split('').map((char) {
      return Random().nextDouble() > 0.9 ? _glitchChar() : char;
    }).join();
  }
}
```

**Particle System for Juiciness**
```dart
class CEGainParticle extends ParticleComponent {
  CEGainParticle({
    required Vector2 position,
    required BigInt amount,
  }) {
    // Cyan particles that float up
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 10,
          generator: (i) => AcceleratedParticle(
            speed: Vector2(0, -50),
            child: CircleParticle(
              radius: 2,
              paint: Paint()..color = const Color(0xFF00F0FF),
            ),
          ),
        ),
      ),
    );
    
    // Floating number text
    add(
      TextComponent(
        text: '+${NumberFormatter.formatCE(amount)} CE',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFF39FF14),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      )..add(
        MoveEffect.by(
          Vector2(0, -50),
          EffectController(duration: 1.0),
        ),
      )..add(
        OpacityEffect.fadeOut(
          EffectController(duration: 1.0),
        ),
      ),
    );
  }
}
```

**Glitch Shader for Cyberpunk Feel**
```dart
// Custom fragment shader for screen distortion
const glitchShader = '''
uniform float time;
uniform float glitchIntensity;
uniform sampler2D texture;

void main() {
  vec2 uv = gl_FragCoord.xy;
  
  // Horizontal glitch bars
  if (mod(time * 10.0 + uv.y * 100.0, 100.0) < glitchIntensity) {
    uv.x += sin(time * 50.0) * 0.1 * glitchIntensity;
  }
  
  // RGB split
  float offset = 0.005 * glitchIntensity;
  vec4 color;
  color.r = texture2D(texture, uv + vec2(offset, 0.0)).r;
  color.g = texture2D(texture, uv).g;
  color.b = texture2D(texture, uv - vec2(offset, 0.0)).b;
  color.a = 1.0;
  
  // Scanlines
  color.rgb -= mod(uv.y, 2.0) < 1.0 ? 0.1 : 0.0;
  
  gl_FragColor = color;
}
''';

class GlitchEffect extends Component {
  double intensity = 0.0; // 0.0 to 1.0
  
  @override
  void render(Canvas canvas) {
    // Apply shader based on paradox level
    if (intensity > 0.0) {
      canvas.saveLayer(null, Paint()..shader = _glitchShader);
      // Render game
      canvas.restore();
    }
  }
}
```

**Offline Progress Calculation**
```dart
class OfflineProgressService {
  OfflineProgressResult calculate({
    required DateTime lastSaveTime,
    required GameData gameState,
  }) {
    final now = DateTime.now();
    final offlineDuration = now.difference(lastSaveTime);
    
    // Cap at 8 hours for balance
    final cappedSeconds = min(
      offlineDuration.inSeconds,
      8 * 60 * 60,
    ).toDouble();
    
    // 70% efficiency when offline (with narrative justification)
    const offlineEfficiency = 0.7;
    
    final totalCE = gameState.productionPerSecond
      .multiply(BigInt.from(cappedSeconds.toInt()))
      .multiply(BigInt.from(70))
      .divide(BigInt.from(100));
    
    // Also calculate paradox that accumulated
    final paradoxGain = (gameState.paradoxPerSecond * cappedSeconds)
      .clamp(0.0, 100.0);
    
    return OfflineProgressResult(
      duration: Duration(seconds: cappedSeconds.toInt()),
      ceGained: totalCE,
      paradoxGained: paradoxGain,
      compressed: cappedSeconds * offlineEfficiency,
    );
  }
}

// UI Display
class OfflineDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0A0E27),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF00F0FF), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glitch effect on title
            const GlitchText(
              'TEMPORAL SYNC COMPLETE',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF00F0FF),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your loops ran for ${_formatDuration(result.duration)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            
            // Neon container for earnings
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF39FF14), width: 2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF39FF14).withOpacity(0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'GENERATED',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    NumberFormatter.formatCE(result.ceGained),
                    style: const TextStyle(
                      fontSize: 36,
                      color: Color(0xFF39FF14),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'CHRONO-ENERGY',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            
            if (result.paradoxGained > 0) ...[
              const SizedBox(height: 16),
              Text(
                '⚠️ Paradox increased by ${result.paradoxGained.toStringAsFixed(1)}%',
                style: const TextStyle(color: Color(0xFFFF006E)),
              ),
            ],
            
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00F0FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('COLLECT'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 📊 BALANCING & ECONOMY

### Production Curve

**Target Progression:**
```
Time Played → CE Total → Unlock
0-5 min     → 1K        → Roaring 20s
10 min      → 10K       → Atomic Age
30 min      → 100K      → Cyberpunk 80s
1 hour      → 1M        → Neo-Tokyo
2 hours     → 10M       → Post-Singularity
4 hours     → 100M      → First Prestige viable
```

**Worker Costs (Victorian Era Example):**
```
Worker #1:   100 CE
Worker #2:   150 CE   (1.5x multiplier)
Worker #3:   225 CE   (1.5x)
Worker #4:   338 CE
...
Worker #N:   100 × 1.5^(N-1)
```

**Station Costs:**
```
Basic Loop Chamber:      1,000 CE
Dual Helix Chamber:      5,000 CE
Paradox Amplifier:      25,000 CE
Time Distortion Field:  100,000 CE
Rift Generator:       1,000,000 CE
```

**Era Multipliers:**
```
Victorian (1890):     1.0x base
Roaring 20s:          2.0x
Atomic Age:           4.0x
Cyberpunk 80s:        8.0x
Neo-Tokyo:           16.0x
Post-Singularity:    32.0x
Ancient Rome:        64.0x
Far Future:         128.0x
```

### Prestige Scaling

**First Prestige:** ~4 hours, gains 5-10 PP
**Second:** ~2 hours (with bonuses), gains 15-20 PP
**Third:** ~1 hour, gains 30-40 PP
**Nth:** Diminishing but always progress

**Paradox Point Shop:**
```
Chrono Mastery I:      5 PP  → +10% production (repeatable)
Rift Stability I:      3 PP  → -5% paradox gain
Era Unlock:           10 PP  → Start with +1 era
Worker Capacity:       8 PP  → +5 max workers
Offline Bonus:         6 PP  → +10% offline efficiency
Merge Unlock:         15 PP  → Unlock station merging
Auto-Loop:            20 PP  → Workers auto-deploy
```

### Paradox Generation

**Base Rate:**
```
Paradox/sec = (Total_Workers × 0.1) + (Station_Count × 0.05)
```

**Reduction Methods:**
- Rift Stability upgrades
- "Stabilizer" stations (reduce paradox in radius)
- Watching ads for emergency stabilization
- Certain legendary workers have "Paradox Resistant" trait

**At 100% Paradox:**
- Forced choice: Prestige or Trigger Event
- Can't hire new workers until resolved
- Production continues but risks increase

---

## 🎭 NARRATIVE INTEGRATION

### Terminal Messages (Lore Delivery)

**Triggered by milestones:**

```
[ENCRYPTED MESSAGE RECEIVED]
> From: UNKNOWN
> "I see you've found the Möbius Protocol. 
   ChronoCorp will notice soon. Be ready."
> [End Transmission]
```

**After First Prestige:**
```
[TEMPORAL ANOMALY DETECTED]
> Timeline #0001 collapsed.
> You remember... but no one else does.
> The factory is new. But you aren't.
> What have you done?
```

**At 50% Paradox:**
```
[SYSTEM WARNING]
> Reality integrity: 50%
> ChronoCorp Erasers en route
> ETA: 12 hours
> Recommendation: Cease operations immediately
> [You ignore this]
```

**ChronoCorp Lore Snippets:**

Collectible data logs found randomly:

> **LOG #0451:**  
> "The board approved Project Ouroboros today.  
> They want to loop their own lifespans.  
> Immortality through recursion.  
> I fear what they'll become."

> **LOG #1337:**  
> "Test Subject #7 experienced the 'Eternal Return'.  
> After 1,000 loops, they no longer recognize themselves.  
> Memory becomes meaningless when you've lived infinite versions."

### Character: The Ally

**Name:** ECHO (Encrypted Chrono-Hacker Online)

- Mysterious figure who helps you
- Leaves tips in Terminal
- Reveals they're ALSO looping
- Plot twist: They're you from a failed timeline

**Their Messages:**
- "Worker efficiency drops after loop #10000. Rotate them."
- "ChronoCorp's Erasers can be bribed with Time Shards..."
- "Have you wondered what happens if you DON'T prestige at 1M CE?"

### Endings (After 10+ Prestiges)

**Ending A: Break the Cycle**
- Refuse to prestige despite hitting threshold
- Reality collapses, but you escape to linear time
- Lost your power, but free
- Credits roll with "The End?"

**Ending B: Become the Timekeeper**
- Prestige 20+ times
- ChronoCorp offers you a job
- You become what you fought against
- New Game+ mode unlocks (play as Eraser)

**Ending C: The Singularity** (Secret)
- Reach 1 Billion CE without prestige
- All timelines merge into one
- You become a post-human entity
- Unlock "God Mode" (creative sandbox)

---

## 🚀 DEVELOPMENT ROADMAP

### Phase 1: MVP (Weeks 1-4)

**Core Features:**
- Basic idle loop (CE generation)
- 3 eras (Victorian, 1920s, Atomic)
- Simple factory (3x3 grid, basic stations)
- Worker hiring/upgrading
- Save/Load system
- Offline progress
- Basic UI (no shaders yet)

**Goal:** Playable vertical slice, test core loop

### Phase 2: Polish & Juice (Weeks 5-6)

**Add:**
- Particle effects for all actions
- Glitch shader for paradox
- Sound effects & music
- Haptic feedback
- Animated number displays
- CRT scanline overlay
- Neon glow effects

**Goal:** Game feels GOOD to play

### Phase 3: Meta-Systems (Weeks 7-8)

**Add:**
- Paradox system fully implemented
- Prestige mechanic
- Timekeeper Raids (tower defense)
- Achievement system
- Merge mechanics for stations

**Goal:** Long-term engagement hooks

### Phase 4: Monetization (Week 9)

**Add:**
- Time Shard currency
- Worker card pulls
- Rewarded video ads
- Battle Pass framework
- IAP integration

**Goal:** Ethical F2P ready

### Phase 5: Content Expansion (Week 10)

**Add:**
- Remaining eras (5-8)
- More worker types
- Advanced stations
- Lore terminals
- Multiple endings

**Goal:** Depth and replayability

### Phase 6: Beta Testing (Weeks 11-12)

**Focus:**
- Balance tuning
- Bug fixes
- User feedback integration
- Performance optimization
- Localization prep (at least PT-BR)

**Goal:** Launch-ready polish

### Post-Launch Content

**Season 1 (Month 2):**
- New "Alternate History" era (e.g., Steampunk Future)
- Legendary worker: "Tesla's Ghost"
- New station: "Quantum Entangler"
- Battle Pass v1

**Season 2 (Month 3):**
- PvP leaderboards (who can prestige fastest)
- Guilds/Alliances (shared factories)
- Special event: "Timekeeper Invasion"

---

## 🎯 SUCCESS METRICS (KPIs)

### Retention Targets

- **D1:** 40%+ (strong tutorial + offline hook)
- **D7:** 20%+ (prestige unlock keeps them)
- **D30:** 8-10% (narrative + seasons)

### Monetization Targets

- **ARPDAU:** $0.15-0.25 (hybrid casual standard)
- **Conversion:** 3-5% (IAP buyers)
- **Ad Revenue:** 60% of total (rewarded video focus)
- **IAP Revenue:** 40% of total

### Engagement Targets

- **Session Length:** 3-5 minutes average
- **Sessions/Day:** 4-6 (morning, lunch, evening, bedtime)
- **Ad Views/DAU:** 3-5 (voluntary, rewarded)

---

## 🎨 MARKETING ASSETS

### App Store Screenshots (Cyberpunk Hooks)

**Screenshot 1:** Factory Overview
- Neon-lit factory with workers looping
- Text overlay: "EXPLOIT TIME. BUILD EMPIRES."

**Screenshot 2:** Era Collection
- Worker cards fanned out, glowing
- Text: "RECRUIT FROM EVERY ERA"

**Screenshot 3:** Paradox Event
- Screen glitching, reality tearing
- Text: "BREAK REALITY. FACE CONSEQUENCES."

**Screenshot 4:** Prestige Screen
- Timeline collapsing vortex
- Text: "RESET. ASCEND. REPEAT."

**Screenshot 5:** Raid Defense
- Timekeepers attacking, workers defending
- Text: "DEFEND YOUR TEMPORAL EMPIRE"

### Trailer Script (30 seconds)

```
[0-5s]   Black screen. Clock ticking sound.
         Text appears: "2247. Neo-Tokyo."
         
[5-10s]  Factory boots up. Neon lights flicker.
         Victorian worker materializes, loops, dissolves.
         Numbers rapidly increase.
         
[10-15s] Quick cuts: Different eras, workers, stations merging.
         Music intensifies. Synthwave drop.
         
[15-20s] PARADOX WARNING flashes. Screen glitches.
         Timekeeper appears. Battle ensues.
         
[20-25s] Timeline COLLAPSES. Prestige screen.
         "AGAIN." appears.
         
[25-30s] Logo: TIME FACTORY: PARADOX INDUSTRIES
         "Download Now. Break Time."
```

### Influencer Kit

**What to Send:**
- Early access code with 10,000 Time Shards
- Lore document (spoiler-free)
- Custom worker card with their face/avatar
- Exclusive "Influencer Edition" factory skin

**Suggested Streamers:**
- Mobile gaming channels (5K-100K subs)
- Sci-fi/cyberpunk enthusiasts
- Idle game communities

---

## 📝 TECHNICAL REQUIREMENTS

### Minimum Device Specs

**Android:**
- Android 8.0+
- 2GB RAM
- OpenGL ES 3.0
- 150MB storage

**iOS:**
- iOS 13+
- iPhone 7 or newer
- Metal support
- 150MB storage

### Performance Targets

- **60 FPS** on mid-range devices (2020+)
- **30 FPS minimum** on low-end (2018)
- **< 200ms** touch response
- **< 2s** cold start time
- **< 100MB** RAM usage during play

### Dependencies (Flutter)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.17.0
  flutter_riverpod: ^2.5.1
  shared_preferences: ^2.2.2
  audioplayers: ^5.2.1
  vibration: ^1.8.4
  google_mobile_ads: ^5.0.0 # AdMob
  in_app_purchase: ^3.1.13
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  flutter_animate: ^4.5.0 # For juicy animations
  
dev_dependencies:
  build_runner: ^2.4.8
  freezed: ^2.4.7
  json_serializable: ^6.7.1
  flutter_test:
    sdk: flutter
```

---

## 🎓 LEARNING RESOURCES FOR TEAM

**Cyberpunk Art:**
- [Blade Runner 2049 Concept Art](https://www.artstation.com/search?q=blade%20runner%202049)
- [Cyberpunk Color Palettes](https://colorhunt.co/palettes/cyberpunk)

**Idle Game Design:**
- [The Mathematics of Idle Games](https://gameanalytics.com/blog/idle-game-mathematics/)
- [Antimatter Dimensions](https://ivark.github.io/) (reference for prestige layers)

**Flutter/Flame:**
- [Flame Documentation](https://docs.flame-engine.org/)
- [Riverpod Best Practices](https://riverpod.dev/)

**H.G. Wells "The Time Machine":**
- [Full Text (Free)](https://www.gutenberg.org/ebooks/35)
- Key themes to reference: Class divide, evolution, consequence

---

## ✅ FINAL CHECKLIST

Before Launch:

- [ ] Core loop is fun for 5 minutes
- [ ] Tutorial is < 1 minute
- [ ] Numbers feel satisfying to watch
- [ ] All SFX are juicy and responsive
- [ ] Offline progress works correctly
- [ ] First prestige is achievable in 3-4 hours
- [ ] No game-breaking bugs
- [ ] Privacy policy & GDPR compliance
- [ ] Ad placements are respectful
- [ ] IAPs tested on real accounts
- [ ] Analytics integrated (Firebase)
- [ ] App Store listing optimized (ASO)
- [ ] Press kit ready for influencers
- [ ] Community Discord/Reddit set up
- [ ] Support email active
- [ ] Soft launch in 1-2 countries first

---

## 🎉 CLOSING THOUGHTS

**Time Factory: Paradox Industries** combines:
- ✨ The addictive loop of idle games
- 🌃 The aesthetic power of cyberpunk
- 📖 The philosophical depth of H.G. Wells
- 🎮 Modern hybrid-casual retention mechanics

**Core Promise:**  
"A thoughtful, visually stunning idle game where every click echoes across timelines, and every choice has weight."

**Unique Selling Points:**
1. Time itself is a resource
2. Dark narrative with real consequences
3. Cyberpunk aesthetic rarely seen in mobile idle
4. Ethical F2P (respects player time & money)
5. Deep prestige system with philosophical endings

This isn't just another clicker. It's a meditation on loops, consequences, and the price of progress—wrapped in neon and synthesizers.

---

**Ready to break time?** 🕰️⚡

---

*Document Version: 1.0*  
*Last Updated: 2026-02-06*  
*Next Review: After MVP Complete*
