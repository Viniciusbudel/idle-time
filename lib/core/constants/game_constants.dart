/// Game balancing constants for Time Factory
/// All balancing numbers centralized here for easy tuning
class GameConstants {
  GameConstants._();

  // ===== WORKER COSTS =====
  /// Base cost for first worker
  static const int workerBaseCost = 100;

  /// Cost multiplier per worker owned (geometric growth)
  static const double workerCostGrowth = 1.5;

  /// Upgrade cost multiplier per level
  static const double workerUpgradeCostGrowth = 1.2;

  // ===== PRODUCTION =====
  /// Victorian era base CE/sec production
  static const int victorianBaseProduction = 1;

  /// Production multiplier per worker level
  static const double productionLevelMultiplier = 1.2;

  // ===== ERA MULTIPLIERS =====
  static const Map<String, double> eraMultipliers = {
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
  /// CE required to unlock each era
  static const Map<String, int> eraUnlockThresholds = {
    'victorian': 0, // Unlocked by default
    'roaring_20s': 1000, // 1K CE
    'atomic_age': 100000, // 100K CE
    'cyberpunk_80s': 10000000, // 10M CE
    'neo_tokyo': 1000000000, // 1B CE
    'post_singularity': 100000000000, // 100B CE
    'ancient_rome': 10000000000000, // 10T CE
    'far_future': 1000000000000000, // 1Qa CE
  };

  // ===== ERA ORDER =====
  static const List<String> eraOrder = [
    'victorian',
    'roaring_20s',
    'atomic_age',
    'cyberpunk_80s',
    'neo_tokyo',
    'post_singularity',
    'ancient_rome',
    'far_future',
  ];

  // ===== STATION COSTS =====
  static const int basicStationCost = 500;
  static const int dualHelixStationCost = 2000;
  static const int paradoxAmplifierCost = 5000;
  static const double stationCostGrowth = 1.4;

  // ===== STATION BONUSES =====
  static const double dualHelixSynergyBonus = 0.2; // 20%
  static const double paradoxAmplifierBonus = 0.5; // 50%
  static const double timeDistortionMultiplier = 2.0; // 2x

  // ===== PARADOX SYSTEM =====
  /// Paradox accumulation per worker per second
  static const double paradoxPerWorkerPerSecond = 0.001; // 0.1%

  /// Paradox accumulation per station per second
  static const double paradoxPerStationPerSecond = 0.0005; // 0.05%

  /// Bonus paradox for mixing eras
  static const double paradoxPerEraVariety = 0.002; // 0.2%

  /// Paradox level that triggers warning
  static const double paradoxWarningThreshold = 0.7; // 70%

  /// Maximum paradox before forced event
  static const double paradoxMaxThreshold = 1.0; // 100%

  // ===== PARADOX EVENT REWARDS =====
  /// Base production multiplier during paradox event
  static const double paradoxEventBaseMultiplier = 2.0;

  /// Additional multiplier per paradox level
  static const double paradoxEventLevelMultiplier = 3.0;

  /// Paradox event duration
  static const Duration paradoxEventDuration = Duration(minutes: 5);

  /// Paradox reduction after embracing chaos
  static const double paradoxReductionAfterEvent = 0.3; // 30%

  // ===== PRESTIGE =====
  /// Minimum CE to prestige
  static const int prestigeMinimumCE = 1000000; // 1M

  /// Prestige points per √(CE / 1M)
  static const int prestigeFormulaBase = 1000000;

  /// Production bonus per prestige point spent on Chrono Mastery
  static const double chronoMasteryBonus = 0.1; // 10%

  /// Paradox reduction per point spent on Rift Stability
  static const double riftStabilityBonus = 0.05; // 5%

  /// Starting eras unlocked per point spent on Era Insight
  static const int eraInsightBonus = 1;

  /// Offline efficiency bonus per point spent
  static const double offlineBonusPerPoint = 0.1; // 10%

  // ===== OFFLINE PROGRESS =====
  /// Maximum offline time in hours
  static const int maxOfflineHours = 8;

  /// Base offline efficiency
  static const double baseOfflineEfficiency = 0.7; // 70%

  /// Minimum offline time to trigger dialog.md (seconds)
  static const int minOfflineSecondsForDialog = 60;

  // ===== GAME LOOP =====
  /// Ticks per second for game logic
  static const double ticksPerSecond = 30.0;

  /// Fixed time step
  static const double tickRate = 1.0 / ticksPerSecond;

  /// Auto-save interval
  static const Duration autoSaveInterval = Duration(seconds: 30);

  // ===== UI =====
  /// Maximum refresh rate for UI numbers (Hz)
  static const double maxUIRefreshRate = 10.0;

  /// Particle count cap for performance
  static const int maxParticles = 100;

  // ===== GACHA / WORKER PULLS =====
  static const int workerPullCost = 50; // Time Shards
  static const Map<String, double> rarityDropRates = {
    'common': 0.60, // 60%
    'rare': 0.25, // 25%
    'epic': 0.12, // 12%
    'legendary': 0.029, // 2.9%
    'paradox': 0.001, // 0.1%
  };

  // ===== DAILY REWARDS =====
  static const int dailyLoginShards = 10;
  static const int prestigeRewardShards = 50;
}
