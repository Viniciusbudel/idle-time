import 'dart:math';

import 'package:time_factory/core/constants/tech_data.dart';
import 'package:time_factory/domain/entities/expedition.dart';
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
    final rewardedShards = succeeded ? expedition.risk.shardReward * 2 : 0;
    final rewardedArtifactDropChance = succeeded
        ? (expedition.risk.artifactDropChance + 0.08).clamp(0.0, 0.95)
        : 0.0;

    var totalWorkerPower = BigInt.zero;
    for (final workerId in expedition.workerIds) {
      final worker = state.workers[workerId];
      if (worker != null) {
        totalWorkerPower += worker.currentProduction;
      }
    }

    if (totalWorkerPower <= BigInt.zero) {
      return ExpeditionReward(
        chronoEnergy: BigInt.zero,
        timeShards: rewardedShards,
        artifactDropChance: rewardedArtifactDropChance,
      );
    }

    final durationSeconds = expedition.endTime
        .difference(expedition.startTime)
        .inSeconds
        .clamp(1, 60 * 60 * 24);

    final baseChronoEnergy = totalWorkerPower * BigInt.from(durationSeconds);
    final chamberOpportunityMultiplier = _chamberOpportunityMultiplier(state);
    final compensatedBaseChronoEnergy = _applyMultiplier(
      baseChronoEnergy,
      chamberOpportunityMultiplier,
    );

    final guaranteedChronoEnergy = _applyMultiplier(
      compensatedBaseChronoEnergy,
      2.0 + expedition.risk.ceMultiplier * 1.3,
    );
    final successBonusChronoEnergy = _applyMultiplier(
      compensatedBaseChronoEnergy,
      0.8 + expedition.risk.ceMultiplier * 1.1,
    );
    final finalChronoEnergy =
        guaranteedChronoEnergy +
        (succeeded ? successBonusChronoEnergy : BigInt.zero);

    return ExpeditionReward(
      chronoEnergy: finalChronoEnergy,
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
}

class _FailureLossResult {
  final List<String> lostWorkerIds;
  final int lostArtifactCount;

  const _FailureLossResult({
    required this.lostWorkerIds,
    required this.lostArtifactCount,
  });
}
