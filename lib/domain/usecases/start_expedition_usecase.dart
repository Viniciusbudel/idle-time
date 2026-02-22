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

class StartExpeditionUseCase {
  List<ExpeditionSlot> get availableSlots => ExpeditionSlot.defaults;

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

  ExpeditionSlot? getSlotById(String slotId) {
    for (final slot in availableSlots) {
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
}
