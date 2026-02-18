import 'package:flutter/material.dart';
import 'game_state.dart';
import 'enums.dart';

/// All achievement types with their trigger conditions and rewards
enum AchievementType {
  // === Hiring ===
  firstHire(
    'first_hire',
    'First Recruit',
    'Hire your first worker',
    Icons.person_add,
    rewardCE: 500,
  ),
  hire10(
    'hire_10',
    'Growing Team',
    'Hire 10 workers',
    Icons.group,
    rewardShards: 5,
  ),
  hire50(
    'hire_50',
    'Factory Foreman',
    'Hire 50 workers',
    Icons.groups,
    rewardShards: 20,
  ),

  // === Earnings ===
  earn10k(
    'earn_10k',
    'Pocket Change',
    'Earn 10,000 CE lifetime',
    Icons.monetization_on_outlined,
    rewardCE: 1000,
  ),
  earn1m(
    'earn_1m',
    'Millionaire',
    'Earn 1,000,000 CE lifetime',
    Icons.diamond_outlined,
    rewardShards: 10,
  ),
  earn1b(
    'earn_1b',
    'Billionaire',
    'Earn 1,000,000,000 CE lifetime',
    Icons.auto_awesome,
    rewardShards: 50,
  ),

  // === Prestige ===
  firstPrestige(
    'first_prestige',
    'Time Loop',
    'Perform your first prestige',
    Icons.loop,
    rewardShards: 5,
  ),
  prestige5(
    'prestige_5',
    'Temporal Expert',
    'Prestige 5 times',
    Icons.all_inclusive,
    rewardShards: 20,
  ),
  prestige10(
    'prestige_10',
    'Paradox Master',
    'Prestige 10 times',
    Icons.cyclone,
    rewardShards: 50,
  ),

  // === Era Progression ===
  reach20s(
    'reach_20s',
    'Roaring Twenties',
    'Unlock the Roaring 20s era',
    Icons.music_note,
    rewardShards: 10,
  ),
  reachAtomic(
    'reach_atomic',
    'Atomic Dawn',
    'Unlock the Atomic Age',
    Icons.science,
    rewardShards: 20,
  ),
  maxTechVictorian(
    'max_tech_victorian',
    'Victorian Master',
    'Max all Victorian technologies',
    Icons.engineering,
    rewardShards: 15,
  ),
  maxTech20s(
    'max_tech_20s',
    'Deco Master',
    'Max all Roaring 20s technologies',
    Icons.architecture,
    rewardShards: 25,
  ),

  // === Factory ===
  stations5(
    'stations_5',
    'Growing Factory',
    'Own 5 stations',
    Icons.factory_outlined,
    rewardCE: 2000,
  ),
  stations10(
    'stations_10',
    'Industrial Giant',
    'Own 10 stations',
    Icons.domain,
    rewardShards: 10,
  ),

  // === Workers ===
  rareWorker(
    'rare_worker',
    'Lucky Find',
    'Obtain a Rare worker',
    Icons.star_half,
    rewardCE: 1000,
  ),
  legendaryWorker(
    'legendary_worker',
    'Legendary Discovery',
    'Obtain a Legendary worker',
    Icons.star,
    rewardShards: 20,
  ),
  paradoxWorker(
    'paradox_worker',
    'Paradox Anomaly',
    'Obtain a Paradox worker',
    Icons.blur_on,
    rewardShards: 50,
  ),
  eraDiversity(
    'era_diversity',
    'Time Diversity',
    'Deploy workers from 3 different eras',
    Icons.diversity_3,
    rewardShards: 15,
  ),

  // === Merging ===
  firstMerge(
    'first_merge',
    'Synthesizer',
    'Merge workers for the first time',
    Icons.merge,
    rewardShards: 5,
  );

  final String id;
  final String displayName;
  final String description;
  final IconData icon;
  final int rewardCE;
  final int rewardShards;

  const AchievementType(
    this.id,
    this.displayName,
    this.description,
    this.icon, {
    this.rewardCE = 0,
    this.rewardShards = 0,
  });

  /// Check if this achievement is unlocked given current game state
  bool checkUnlocked(GameState state) {
    switch (this) {
      // Hiring
      case AchievementType.firstHire:
        return state.totalWorkersPulled >= 1;
      case AchievementType.hire10:
        return state.totalWorkersPulled >= 10;
      case AchievementType.hire50:
        return state.totalWorkersPulled >= 50;

      // Earnings
      case AchievementType.earn10k:
        return state.lifetimeChronoEnergy >= BigInt.from(10000);
      case AchievementType.earn1m:
        return state.lifetimeChronoEnergy >= BigInt.from(1000000);
      case AchievementType.earn1b:
        return state.lifetimeChronoEnergy >= BigInt.from(1000000000);

      // Prestige
      case AchievementType.firstPrestige:
        return state.totalPrestiges >= 1;
      case AchievementType.prestige5:
        return state.totalPrestiges >= 5;
      case AchievementType.prestige10:
        return state.totalPrestiges >= 10;

      // Era progression
      case AchievementType.reach20s:
        return state.unlockedEras.contains('roaring_20s');
      case AchievementType.reachAtomic:
        return state.unlockedEras.contains('atomic_age');
      case AchievementType.maxTechVictorian:
        return state.completedEras.contains('victorian');
      case AchievementType.maxTech20s:
        return state.completedEras.contains('roaring_20s');

      // Factory
      case AchievementType.stations5:
        return state.stations.length >= 5;
      case AchievementType.stations10:
        return state.stations.length >= 10;

      // Workers
      case AchievementType.rareWorker:
        return state.workers.values.any(
          (w) => w.rarity.index >= WorkerRarity.rare.index,
        );
      case AchievementType.legendaryWorker:
        return state.workers.values.any(
          (w) => w.rarity == WorkerRarity.legendary,
        );
      case AchievementType.paradoxWorker:
        return state.workers.values.any(
          (w) => w.rarity == WorkerRarity.paradox,
        );
      case AchievementType.eraDiversity:
        final deployedEras = state.activeWorkers.map((w) => w.era).toSet();
        return deployedEras.length >= 3;

      // Merging
      case AchievementType.firstMerge:
        return state.totalMerges >= 1;
    }
  }

  /// Get progress value (0.0 to 1.0) for threshold-based achievements
  double getProgress(GameState state) {
    switch (this) {
      case AchievementType.firstHire:
        return (state.totalWorkersPulled / 1).clamp(0.0, 1.0);
      case AchievementType.hire10:
        return (state.totalWorkersPulled / 10).clamp(0.0, 1.0);
      case AchievementType.hire50:
        return (state.totalWorkersPulled / 50).clamp(0.0, 1.0);
      case AchievementType.earn10k:
        return (state.lifetimeChronoEnergy.toDouble() / 10000).clamp(0.0, 1.0);
      case AchievementType.earn1m:
        return (state.lifetimeChronoEnergy.toDouble() / 1000000).clamp(
          0.0,
          1.0,
        );
      case AchievementType.earn1b:
        return (state.lifetimeChronoEnergy.toDouble() / 1000000000).clamp(
          0.0,
          1.0,
        );
      case AchievementType.firstPrestige:
        return (state.totalPrestiges / 1).clamp(0.0, 1.0);
      case AchievementType.prestige5:
        return (state.totalPrestiges / 5).clamp(0.0, 1.0);
      case AchievementType.prestige10:
        return (state.totalPrestiges / 10).clamp(0.0, 1.0);
      case AchievementType.stations5:
        return (state.stations.length / 5).clamp(0.0, 1.0);
      case AchievementType.stations10:
        return (state.stations.length / 10).clamp(0.0, 1.0);
      case AchievementType.firstMerge:
        return (state.totalMerges / 1).clamp(0.0, 1.0);
      case AchievementType.eraDiversity:
        final eras = state.activeWorkers.map((w) => w.era).toSet().length;
        return (eras / 3).clamp(0.0, 1.0);
      // Boolean achievements — either 0 or 1
      default:
        return checkUnlocked(state) ? 1.0 : 0.0;
    }
  }
}
