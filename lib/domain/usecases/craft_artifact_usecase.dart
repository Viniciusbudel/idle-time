import 'dart:math';

import 'package:time_factory/core/constants/artifact_forge_balance.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/worker_artifact.dart';

class CraftArtifactResult {
  final GameState newState;
  final WorkerArtifact artifact;
  final int dustSpent;
  final bool pityTriggered;

  const CraftArtifactResult({
    required this.newState,
    required this.artifact,
    required this.dustSpent,
    required this.pityTriggered,
  });
}

class CraftArtifactUseCase {
  static const int _inventoryCap = 999;
  final Random _random;

  CraftArtifactUseCase({Random? random}) : _random = random ?? Random();

  int get pityThreshold => ArtifactForgeBalance.pityThreshold;

  int getCraftCost(WorkerRarity minimumRarity) {
    return ArtifactForgeBalance.craftCostByMinimumRarity[minimumRarity] ?? 0;
  }

  CraftArtifactResult? execute(
    GameState currentState, {
    required WorkerRarity minimumRarity,
    WorkerEra? targetEra,
  }) {
    final dustCost = getCraftCost(minimumRarity);
    if (dustCost <= 0) return null;
    if (currentState.artifactDust < dustCost) return null;
    if (currentState.inventory.length >= _inventoryCap) return null;

    final nextStreak = currentState.artifactCraftStreak + 1;
    final pityTriggered = nextStreak >= pityThreshold;

    final rolledRarity = pityTriggered
        ? _rollPityRarity(minimumRarity)
        : _rollRarity(minimumRarity);

    final craftEra = targetEra ?? _resolveCurrentEra(currentState.currentEraId);
    final artifact = WorkerArtifact.generate(rolledRarity, craftEra);
    final newInventory = List<WorkerArtifact>.from(currentState.inventory)
      ..add(artifact);

    final isHighRarity =
        rolledRarity == WorkerRarity.legendary ||
        rolledRarity == WorkerRarity.paradox;

    final newState = currentState.copyWith(
      artifactDust: currentState.artifactDust - dustCost,
      artifactCraftStreak: isHighRarity ? 0 : nextStreak,
      inventory: newInventory,
    );

    return CraftArtifactResult(
      newState: newState,
      artifact: artifact,
      dustSpent: dustCost,
      pityTriggered: pityTriggered,
    );
  }

  WorkerRarity _rollRarity(WorkerRarity minimumRarity) {
    final eligibleRarities = WorkerRarity.values
        .where((rarity) => rarity.index >= minimumRarity.index)
        .toList();

    final weights = <WorkerRarity, double>{};
    for (final rarity in eligibleRarities) {
      weights[rarity] = ArtifactForgeBalance.craftRarityWeights[rarity] ?? 0.0;
    }

    final totalWeight = weights.values.fold(0.0, (sum, weight) => sum + weight);
    if (totalWeight <= 0) return minimumRarity;

    var roll = _random.nextDouble() * totalWeight;
    for (final entry in weights.entries) {
      roll -= entry.value;
      if (roll <= 0) {
        return entry.key;
      }
    }

    return weights.keys.last;
  }

  WorkerRarity _rollPityRarity(WorkerRarity minimumRarity) {
    if (minimumRarity == WorkerRarity.paradox) {
      return WorkerRarity.paradox;
    }

    final pityRoll = _random.nextDouble();
    if (pityRoll < ArtifactForgeBalance.pityParadoxChance &&
        minimumRarity.index <= WorkerRarity.legendary.index) {
      return WorkerRarity.paradox;
    }

    return WorkerRarity.legendary.index >= minimumRarity.index
        ? WorkerRarity.legendary
        : minimumRarity;
  }

  WorkerEra _resolveCurrentEra(String eraId) {
    return WorkerEra.values.firstWhere(
      (era) => era.id == eraId,
      orElse: () => WorkerEra.victorian,
    );
  }
}
