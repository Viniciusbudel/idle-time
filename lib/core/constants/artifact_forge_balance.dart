import 'package:time_factory/domain/entities/enums.dart';

/// Balance tables for Artifact Forge economy.
class ArtifactForgeBalance {
  ArtifactForgeBalance._();

  /// Dust gained when salvaging one artifact by rarity.
  static const Map<WorkerRarity, int> salvageDustByRarity = {
    WorkerRarity.common: 5,
    WorkerRarity.rare: 15,
    WorkerRarity.epic: 40,
    WorkerRarity.legendary: 120,
    WorkerRarity.paradox: 300,
  };

  /// Dust cost for one craft with a minimum rarity target.
  static const Map<WorkerRarity, int> craftCostByMinimumRarity = {
    WorkerRarity.common: 25,
    WorkerRarity.rare: 70,
    WorkerRarity.epic: 180,
    WorkerRarity.legendary: 500,
    WorkerRarity.paradox: 1600,
  };

  /// Base rarity distribution for crafts before minimum-rarity filtering.
  static const Map<WorkerRarity, double> craftRarityWeights = {
    WorkerRarity.common: 58.0,
    WorkerRarity.rare: 30.0,
    WorkerRarity.epic: 9.5,
    WorkerRarity.legendary: 2.0,
    WorkerRarity.paradox: 0.5,
  };

  /// Number of consecutive non-legendary crafts before pity triggers.
  static const int pityThreshold = 8;

  /// Chance to upgrade a pity result from legendary to paradox.
  static const double pityParadoxChance = 0.1;
}
