/// Worker eras available in the game
enum WorkerEra {
  victorian('victorian', 'Victorian Era', 1890),
  roaring20s('roaring_20s', 'Roaring 20s', 1920),
  atomicAge('atomic_age', 'Atomic Age', 1950),
  cyberpunk80s('cyberpunk_80s', 'Cyberpunk 80s', 1980),
  neoTokyo('neo_tokyo', 'Neo-Tokyo', 2247),
  postSingularity('post_singularity', 'Post-Singularity', 2400),
  ancientRome('ancient_rome', 'Ancient Rome', -50),
  farFuture('far_future', 'Far Future', 8000);

  final String id;
  final String displayName;
  final int year;

  const WorkerEra(this.id, this.displayName, this.year);

  /// Get era multiplier from game constants
  double get multiplier {
    const multipliers = {
      'victorian': 1.0,
      'roaring_20s': 2.0,
      'atomic_age': 4.0,
      'cyberpunk_80s': 8.0,
      'neo_tokyo': 16.0,
      'post_singularity': 32.0,
      'ancient_rome': 64.0,
      'far_future': 128.0,
    };
    return multipliers[id] ?? 1.0;
  }

  /// Hire cost in CE for this era (Base cost for first hire)
  BigInt get hireCost {
    const costs = {
      'victorian': 150,
      'roaring_20s': 525, // 150 × 3.5
      'atomic_age': 1800, // 150 × 12.0
      'cyberpunk_80s': 6750, // 150 × 45.0
      'neo_tokyo': 27000, // 150 × 180.0
      'post_singularity': 112500, // 150 × 750.0
      'ancient_rome': 450000, // 150 × 3000.0
      'far_future': 1800000, // 150 × 12000.0
    };
    return BigInt.from(costs[id] ?? 150);
  }
}

/// Worker rarity tiers - REBALANCED production multipliers
enum WorkerRarity {
  common('common', 'Common', 1.0),
  rare('rare', 'Rare', 3.5),
  epic('epic', 'Epic', 13),
  legendary('legendary', 'Legendary', 40.0),
  paradox('paradox', 'Paradox', 150.0);

  final String id;
  final String displayName;
  final double productionMultiplier;

  const WorkerRarity(this.id, this.displayName, this.productionMultiplier);
}

/// Station types available in the factory
enum StationType {
  basicLoop('basic_loop', 'Basic Loop Chamber', 3, 5, WorkerEra.victorian),
  dualHelix('dual_helix', 'Dual Helix Chamber', 3, 8, WorkerEra.roaring20s),
  nuclearReactor(
    'nuclear_reactor',
    'Nuclear Reactor',
    3,
    10,
    WorkerEra.atomicAge,
  ),
  paradoxAmplifier(
    'paradox_amplifier',
    'Paradox Amplifier',
    3,
    5,
    WorkerEra.atomicAge,
  ),
  timeDistortion(
    'time_distortion',
    'Time Distortion Field',
    3,
    8,
    WorkerEra.cyberpunk80s,
  ),
  riftGenerator('rift_generator', 'Rift Generator', 3, 6, WorkerEra.neoTokyo);

  final String id;
  final String displayName;
  final int workerSlots;
  final int maxSlotsCap;
  final WorkerEra era;

  const StationType(
    this.id,
    this.displayName,
    this.workerSlots,
    this.maxSlotsCap,
    this.era,
  );
}

/// Resource types
enum ResourceType {
  chronoEnergy('chrono_energy', '⚡ Chrono-Energy', 'CE'),
  timeShards('time_shards', '🔮 Time Shards', 'TS'),
  paradoxPoints('paradox_points', '⏳ Paradox Points', 'PP');

  final String id;
  final String displayName;
  final String abbreviation;

  const ResourceType(this.id, this.displayName, this.abbreviation);
}

/// Prestige upgrade types
enum PrestigeUpgrade {
  chronoMastery(
    'chrono_mastery',
    'Chrono Mastery',
    '+10% CE production per point',
  ),
  riftStability(
    'rift_stability',
    'Rift Stability',
    '-5% paradox accumulation per point',
  ),
  eraInsight(
    'era_insight',
    'Era Insight',
    '+1 starting era unlocked per point',
  ),
  offlineBonus(
    'offline_bonus',
    'Temporal Memory',
    '+10% offline efficiency per point',
  ),
  timekeepersFavor(
    'timekeepers_favor',
    "Timekeeper's Favor",
    'Raids easier, better rewards',
  );

  final String id;
  final String displayName;
  final String description;

  const PrestigeUpgrade(this.id, this.displayName, this.description);
}
