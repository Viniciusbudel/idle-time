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

  /// Hire cost in CE for this era
  BigInt get hireCost {
    const costs = {
      'victorian': 100,
      'roaring_20s': 500,
      'atomic_age': 2500,
      'cyberpunk_80s': 12500,
      'neo_tokyo': 62500,
      'post_singularity': 312500,
      'ancient_rome': 1562500,
      'far_future': 7812500,
    };
    return BigInt.from(costs[id] ?? 100);
  }
}

/// Worker rarity tiers
enum WorkerRarity {
  common('common', 'Common', 1.0),
  rare('rare', 'Rare', 1.5),
  epic('epic', 'Epic', 2.0),
  legendary('legendary', 'Legendary', 3.0),
  paradox('paradox', 'Paradox', 5.0);

  final String id;
  final String displayName;
  final double productionMultiplier;

  const WorkerRarity(this.id, this.displayName, this.productionMultiplier);
}

/// Station types available in the factory
enum StationType {
  basicLoop('basic_loop', 'Basic Loop Chamber', 1),
  dualHelix('dual_helix', 'Dual Helix Chamber', 2),
  paradoxAmplifier('paradox_amplifier', 'Paradox Amplifier', 0),
  timeDistortion('time_distortion', 'Time Distortion Field', 1),
  riftGenerator('rift_generator', 'Rift Generator', 1);

  final String id;
  final String displayName;
  final int workerSlots;

  const StationType(this.id, this.displayName, this.workerSlots);
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
