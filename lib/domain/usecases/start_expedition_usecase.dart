import 'dart:math' as math;

import 'package:time_factory/core/constants/game_constants.dart';
import 'package:time_factory/domain/entities/expedition.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/worker.dart';

class StartExpeditionResult {
  final GameState newState;
  final Expedition expedition;

  const StartExpeditionResult({
    required this.newState,
    required this.expedition,
  });
}

class QuickHirePlan {
  final WorkerEra? era;
  final int missingWorkers;
  final int affordableWorkers;
  final BigInt totalCost;

  const QuickHirePlan({
    required this.era,
    required this.missingWorkers,
    required this.affordableWorkers,
    required this.totalCost,
  });

  bool get canHireAny => affordableWorkers > 0;
  bool get fillsCrewGap => affordableWorkers >= missingWorkers;
}

class StartExpeditionUseCase {
  List<ExpeditionSlot> get availableSlots => ExpeditionSlot.catalog;

  List<ExpeditionSlot> getAvailableExpeditionSlots(GameState state) {
    final int playerMaxEraIndex = _getPlayerMaxEraIndex(state);
    return availableSlots
        .where(
          (ExpeditionSlot slot) => slot.unlockEraIndex <= playerMaxEraIndex,
        )
        .toList();
  }

  bool isSlotUnlockedForState(GameState state, String slotId) {
    final availableForState = getAvailableExpeditionSlots(state);
    return getSlotById(slotId, slots: availableForState) != null;
  }

  List<String> autoSelectCrew(ExpeditionSlot slot, Iterable<Worker> workers) {
    final List<Worker> sorted =
        workers.where((Worker worker) => !worker.isDeployed).toList()
          ..sort((Worker a, Worker b) {
            final int rarityOrder = _rarityAssemblyOrder(
              a.rarity,
            ).compareTo(_rarityAssemblyOrder(b.rarity));
            if (rarityOrder != 0) {
              return rarityOrder;
            }
            return b.currentProduction.compareTo(a.currentProduction);
          });

    final Set<String> uniqueIds = <String>{};
    final List<String> selected = <String>[];

    for (final Worker worker in sorted) {
      if (!uniqueIds.add(worker.id)) {
        continue;
      }
      selected.add(worker.id);
      if (selected.length >= slot.requiredWorkers) {
        break;
      }
    }

    return selected;
  }

  QuickHirePlan quickHireForCrewGap(ExpeditionSlot slot, GameState state) {
    final WorkerEra? hireEra = WorkerEra.fromIdOrNull(slot.eraId);
    final List<Worker> availableWorkers = _availableCrewWorkers(state);
    final int missingWorkers =
        slot.requiredWorkers - autoSelectCrew(slot, availableWorkers).length;

    if (hireEra == null || missingWorkers <= 0) {
      return QuickHirePlan(
        era: null,
        missingWorkers: 0,
        affordableWorkers: 0,
        totalCost: BigInt.zero,
      );
    }

    var affordableWorkers = 0;
    var totalCost = BigInt.zero;
    BigInt remainingChronoEnergy = state.chronoEnergy;
    final int currentEraHires = state.eraHires[hireEra.id] ?? 0;

    while (affordableWorkers < missingWorkers) {
      final int projectedHires = currentEraHires + affordableWorkers;
      final BigInt hireCost = _getWorkerHireCost(
        era: hireEra,
        currentHires: projectedHires,
      );
      if (remainingChronoEnergy < hireCost) {
        break;
      }
      affordableWorkers++;
      totalCost += hireCost;
      remainingChronoEnergy -= hireCost;
    }

    return QuickHirePlan(
      era: hireEra,
      missingWorkers: missingWorkers,
      affordableWorkers: affordableWorkers,
      totalCost: totalCost,
    );
  }

  static double calculateSuccessProbability({
    required ExpeditionRisk risk,
    required List<Worker> assignedWorkers,
    required int requiredWorkers,
  }) {
    if (requiredWorkers <= 0 || assignedWorkers.isEmpty) {
      return 0.05;
    }

    final double baseChance = switch (risk) {
      ExpeditionRisk.safe => 0.72,
      ExpeditionRisk.risky => 0.58,
      ExpeditionRisk.volatile => 0.42,
    };

    final double assignmentRatio = (assignedWorkers.length / requiredWorkers)
        .clamp(0.0, 1.0);
    final double assignmentBonus = assignmentRatio * 0.12;

    double rarityScore = 0.0;
    int equippedArtifacts = 0;
    for (final Worker worker in assignedWorkers) {
      rarityScore += _raritySuccessScore(worker.rarity);
      equippedArtifacts += worker.equippedArtifacts.length;
    }
    final double averageRarityScore = rarityScore / assignedWorkers.length;
    final double rarityBonus = averageRarityScore * 0.25;
    final double artifactBonus = (equippedArtifacts * 0.018).clamp(0.0, 0.15);

    return (baseChance + assignmentBonus + rarityBonus + artifactBonus).clamp(
      0.05,
      0.99,
    );
  }

  ExpeditionSlot? getSlotById(String slotId, {List<ExpeditionSlot>? slots}) {
    for (final slot in slots ?? availableSlots) {
      if (slot.id == slotId) return slot;
    }
    return null;
  }

  StartExpeditionResult? execute(
    GameState currentState, {
    required String slotId,
    required ExpeditionRisk risk,
    required List<String> workerIds,
    DateTime? now,
  }) {
    if (!isSlotUnlockedForState(currentState, slotId)) return null;

    final selectedSlot = getSlotById(slotId);
    if (selectedSlot == null) return null;
    if (workerIds.length != selectedSlot.requiredWorkers) return null;
    if (workerIds.toSet().length != workerIds.length) return null;

    final unresolvedWorkers = _unresolvedWorkerIds(currentState);
    final workersById = currentState.workers;

    for (final workerId in workerIds) {
      final worker = workersById[workerId];
      if (worker == null) return null;
      if (worker.isDeployed) return null;
      if (unresolvedWorkers.contains(workerId)) return null;
    }

    final startAt = now ?? DateTime.now();
    final List<Worker> assignedWorkers = workerIds
        .map((String workerId) => workersById[workerId])
        .whereType<Worker>()
        .toList();

    final expedition = Expedition(
      id: 'exp_${startAt.microsecondsSinceEpoch}_${currentState.expeditions.length}',
      slotId: selectedSlot.id,
      risk: risk,
      workerIds: workerIds,
      startTime: startAt,
      endTime: startAt.add(selectedSlot.duration),
      successProbability: calculateSuccessProbability(
        risk: risk,
        assignedWorkers: assignedWorkers,
        requiredWorkers: selectedSlot.requiredWorkers,
      ),
      resolved: false,
    );

    final updatedExpeditions = List<Expedition>.from(currentState.expeditions)
      ..add(expedition);

    final newState = currentState.copyWith(expeditions: updatedExpeditions);
    return StartExpeditionResult(newState: newState, expedition: expedition);
  }

  Set<String> _unresolvedWorkerIds(GameState state) {
    final ids = <String>{};
    for (final expedition in state.expeditions) {
      if (expedition.resolved) continue;
      ids.addAll(expedition.workerIds);
    }
    return ids;
  }

  List<Worker> _availableCrewWorkers(GameState state) {
    final Set<String> unresolvedWorkers = _unresolvedWorkerIds(state);
    return state.workers.values
        .where((Worker worker) => !worker.isDeployed)
        .where((Worker worker) => !unresolvedWorkers.contains(worker.id))
        .toList();
  }

  int _getPlayerMaxEraIndex(GameState state) {
    var maxEraIndex = 0;

    for (final eraId in state.unlockedEras) {
      final int index = GameConstants.eraOrder.indexOf(eraId);
      if (index > maxEraIndex) {
        maxEraIndex = index;
      }
    }

    return maxEraIndex;
  }

  static double _raritySuccessScore(WorkerRarity rarity) {
    switch (rarity) {
      case WorkerRarity.common:
        return 0.0;
      case WorkerRarity.rare:
        return 0.22;
      case WorkerRarity.epic:
        return 0.42;
      case WorkerRarity.legendary:
        return 0.66;
      case WorkerRarity.paradox:
        return 1.0;
    }
  }

  static int _rarityAssemblyOrder(WorkerRarity rarity) {
    switch (rarity) {
      case WorkerRarity.common:
        return 0;
      case WorkerRarity.rare:
        return 1;
      case WorkerRarity.epic:
        return 2;
      case WorkerRarity.legendary:
        return 3;
      case WorkerRarity.paradox:
        return 4;
    }
  }

  static BigInt _getWorkerHireCost({
    required WorkerEra era,
    required int currentHires,
  }) {
    final double growth = switch (era.id) {
      'atomic_age' => 1.48,
      'cyberpunk_80s' => 1.58,
      _ => 1.40,
    };
    final double multiplier = math.pow(growth, currentHires).toDouble();
    return BigInt.from((era.hireCost.toDouble() * multiplier).toInt());
  }
}
