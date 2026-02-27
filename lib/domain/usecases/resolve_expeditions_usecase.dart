import 'dart:math';

import 'package:time_factory/core/constants/tech_data.dart';
import 'package:time_factory/domain/entities/expedition.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/prestige_upgrade.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/worker.dart';

class ResolveExpeditionsResult {
  final GameState newState;
  final List<Expedition> newlyResolved;

  const ResolveExpeditionsResult({
    required this.newState,
    required this.newlyResolved,
  });
}

class ResolveExpeditionsUseCase {
  ExpeditionReward estimateRewardPreview(
    GameState state, {
    required List<Worker> workers,
    required Duration duration,
    required ExpeditionRisk risk,
    bool succeeded = true,
    String? eraId,
  }) {
    final int durationSeconds = duration.inSeconds.clamp(1, 60 * 60 * 24);
    return _calculateRewardFromCrew(
      state: state,
      workers: workers,
      durationSeconds: durationSeconds,
      risk: risk,
      succeeded: succeeded,
      slotEraId: eraId,
    );
  }

  ResolveExpeditionsResult execute(
    GameState currentState, {
    DateTime? now,
    double Function()? randomRoll,
  }) {
    final currentTime = now ?? DateTime.now();
    final Random random = Random();
    final double Function() nextRoll = randomRoll ?? random.nextDouble;

    final updatedExpeditions = <Expedition>[];
    final newlyResolved = <Expedition>[];
    final Map<String, Worker> updatedWorkers = Map<String, Worker>.from(
      currentState.workers,
    );
    final Map<String, Station> updatedStations = Map<String, Station>.from(
      currentState.stations,
    );

    for (final expedition in currentState.expeditions) {
      if (expedition.resolved || currentTime.isBefore(expedition.endTime)) {
        updatedExpeditions.add(expedition);
        continue;
      }

      final bool succeeded = nextRoll() <= expedition.successProbability;
      final ExpeditionReward reward = _calculateReward(
        currentState,
        expedition,
        succeeded: succeeded,
      );

      var lostWorkers = const <String>[];
      var lostArtifactCount = 0;
      if (!succeeded) {
        final failureResult = _applyFailureLoss(
          updatedWorkers,
          updatedStations,
          expedition.workerIds,
        );
        lostWorkers = failureResult.lostWorkerIds;
        lostArtifactCount = failureResult.lostArtifactCount;
      }

      final resolved = expedition.copyWith(
        resolved: true,
        wasSuccessful: succeeded,
        resolvedReward: reward,
        lostWorkerIds: lostWorkers,
        lostArtifactCount: lostArtifactCount,
      );
      updatedExpeditions.add(resolved);
      newlyResolved.add(resolved);
    }

    if (newlyResolved.isEmpty) {
      return ResolveExpeditionsResult(
        newState: currentState,
        newlyResolved: const [],
      );
    }

    return ResolveExpeditionsResult(
      newState: currentState.copyWith(
        expeditions: updatedExpeditions,
        workers: updatedWorkers,
        stations: updatedStations,
      ),
      newlyResolved: newlyResolved,
    );
  }

  _FailureLossResult _applyFailureLoss(
    Map<String, Worker> workers,
    Map<String, Station> stations,
    List<String> expeditionWorkerIds,
  ) {
    final List<String> lostWorkerIds = <String>[];
    var lostArtifactCount = 0;

    for (final String workerId in expeditionWorkerIds) {
      final Worker? worker = workers.remove(workerId);
      if (worker == null) {
        continue;
      }
      lostWorkerIds.add(workerId);
      lostArtifactCount += worker.equippedArtifacts.length;
    }

    if (lostWorkerIds.isNotEmpty) {
      for (final MapEntry<String, Station> entry in stations.entries) {
        final List<String> cleaned = entry.value.workerIds
            .where((String workerId) => !lostWorkerIds.contains(workerId))
            .toList();
        if (cleaned.length != entry.value.workerIds.length) {
          stations[entry.key] = entry.value.copyWith(workerIds: cleaned);
        }
      }
    }

    return _FailureLossResult(
      lostWorkerIds: lostWorkerIds,
      lostArtifactCount: lostArtifactCount,
    );
  }

  ExpeditionReward _calculateReward(
    GameState state,
    Expedition expedition, {
    required bool succeeded,
  }) {
    final List<Worker> assignedWorkers = <Worker>[];
    for (final workerId in expedition.workerIds) {
      final worker = state.workers[workerId];
      if (worker != null) {
        assignedWorkers.add(worker);
      }
    }

    final durationSeconds = expedition.endTime
        .difference(expedition.startTime)
        .inSeconds
        .clamp(1, 60 * 60 * 24);
    final String? slotEraId = ExpeditionSlot.byId(expedition.slotId)?.eraId;

    return _calculateRewardFromCrew(
      state: state,
      workers: assignedWorkers,
      durationSeconds: durationSeconds,
      risk: expedition.risk,
      succeeded: succeeded,
      slotEraId: slotEraId,
    );
  }

  ExpeditionReward _calculateRewardFromCrew({
    required GameState state,
    required List<Worker> workers,
    required int durationSeconds,
    required ExpeditionRisk risk,
    required bool succeeded,
    String? slotEraId,
  }) {
    final rewardedShards = succeeded ? risk.shardReward * 2 : 0;
    final rewardedArtifactDropChance = succeeded
        ? _buffedRelicDropChance(risk: risk, workers: workers)
        : 0.0;

    var totalWorkerPower = BigInt.zero;
    for (final Worker worker in workers) {
      totalWorkerPower += worker.currentProduction;
    }

    if (totalWorkerPower <= BigInt.zero) {
      return ExpeditionReward(
        chronoEnergy: BigInt.zero,
        timeShards: rewardedShards,
        artifactDropChance: rewardedArtifactDropChance,
      );
    }

    final baseChronoEnergy = totalWorkerPower * BigInt.from(durationSeconds);
    final chamberOpportunityMultiplier = _chamberOpportunityMultiplier(state);
    final compensatedBaseChronoEnergy = _applyMultiplier(
      baseChronoEnergy,
      chamberOpportunityMultiplier,
    );

    final guaranteedChronoEnergy = _applyMultiplier(
      compensatedBaseChronoEnergy,
      2.0 + risk.ceMultiplier * 1.3,
    );
    final successBonusChronoEnergy = _applyMultiplier(
      compensatedBaseChronoEnergy,
      0.8 + risk.ceMultiplier * 1.1,
    );
    final baselineChronoEnergy =
        guaranteedChronoEnergy +
        (succeeded ? successBonusChronoEnergy : BigInt.zero);
    final expeditionBuffMultiplier = _expeditionBuffMultiplier(
      workers: workers,
      durationSeconds: durationSeconds,
      risk: risk,
    );
    final finalChronoEnergy = _applyMultiplier(
      baselineChronoEnergy,
      expeditionBuffMultiplier,
    );
    // Economy rebalance: keep expedition CE at 30% of the previous buffed output.
    final tunedChronoEnergy = _applyMultiplier(finalChronoEnergy, 0.30);
    final eraBalancedChronoEnergy = _applyMultiplier(
      tunedChronoEnergy,
      _expeditionEraMultiplier(slotEraId),
    );

    return ExpeditionReward(
      chronoEnergy: eraBalancedChronoEnergy,
      timeShards: rewardedShards,
      artifactDropChance: rewardedArtifactDropChance,
    );
  }

  double _chamberOpportunityMultiplier(GameState state) {
    final maxStationBonus = state.stations.values.fold<double>(
      1.0,
      (best, station) =>
          station.productionBonus > best ? station.productionBonus : best,
    );
    final techMultiplier = TechData.calculateEfficiencyMultiplier(
      state.techLevels,
    );
    final chronoMasteryLevel = PrestigeUpgradeType.chronoMastery.clampLevel(
      state.paradoxPointsSpent[PrestigeUpgradeType.chronoMastery.id] ?? 0,
    );
    final chronoMasteryMultiplier = 1.0 + (chronoMasteryLevel * 0.1);

    // Expeditions should compensate opportunity cost from chambers and tech,
    // but keep a hard cap to avoid runaway late-game explosions.
    final compensation =
        maxStationBonus * sqrt(techMultiplier) * chronoMasteryMultiplier;
    return compensation.clamp(1.5, 40.0);
  }

  BigInt _applyMultiplier(BigInt value, double multiplier) {
    if (multiplier == 1.0) return value;
    const precision = 10000;
    final scaled = (multiplier * precision).round();
    return value * BigInt.from(scaled) ~/ BigInt.from(precision);
  }

  double _expeditionBuffMultiplier({
    required List<Worker> workers,
    required int durationSeconds,
    required ExpeditionRisk risk,
  }) {
    if (workers.isEmpty) {
      return 1.0;
    }

    final double durationHours = (durationSeconds / 3600.0).clamp(0.5, 24.0);
    final double durationBonus = pow(durationHours, 0.35).toDouble();

    double rarityTotal = 0.0;
    var artifactCount = 0;
    for (final Worker worker in workers) {
      rarityTotal += _rarityBuffScore(worker.rarity);
      artifactCount += worker.equippedArtifacts.length;
    }

    final double averageRarityScore = rarityTotal / workers.length;
    final double rarityBonus = 1.0 + (averageRarityScore * 1.5);
    final double artifactBonus = 1.0 + (artifactCount.clamp(0, 15) * 0.04);
    final double riskBonus = 0.9 + (risk.ceMultiplier * 0.25);

    final double multiplier =
        4.2 * durationBonus * rarityBonus * artifactBonus * riskBonus;
    return multiplier.clamp(3.0, 18.0);
  }

  double _rarityBuffScore(WorkerRarity rarity) {
    switch (rarity) {
      case WorkerRarity.common:
        return 0.0;
      case WorkerRarity.rare:
        return 0.25;
      case WorkerRarity.epic:
        return 0.5;
      case WorkerRarity.legendary:
        return 0.75;
      case WorkerRarity.paradox:
        return 1.0;
    }
  }

  double _buffedRelicDropChance({
    required ExpeditionRisk risk,
    required List<Worker> workers,
  }) {
    final double baseChance = (risk.artifactDropChance + 0.08).clamp(0.0, 0.95);
    if (workers.isEmpty) {
      return baseChance.clamp(0.0, 0.95);
    }

    double rarityTotal = 0.0;
    var artifactCount = 0;
    for (final Worker worker in workers) {
      rarityTotal += _rarityBuffScore(worker.rarity);
      artifactCount += worker.equippedArtifacts.length;
    }

    final double averageRarityScore = rarityTotal / workers.length;
    final double rarityBonus = averageRarityScore * 0.10;
    final double artifactBonus = (artifactCount * 0.015).clamp(0.0, 0.12);

    final double buffedChance =
        (baseChance * 1.35) + 0.04 + rarityBonus + artifactBonus;
    return buffedChance.clamp(0.0, 0.95);
  }

  double _expeditionEraMultiplier(String? eraId) {
    // Early-game Victorian runs were overpaying CE relative to progression pace.
    if (eraId == WorkerEra.victorian.id) {
      return 0.10;
    }
    return 1.0;
  }
}

class _FailureLossResult {
  final List<String> lostWorkerIds;
  final int lostArtifactCount;

  const _FailureLossResult({
    required this.lostWorkerIds,
    required this.lostArtifactCount,
  });
}
