import '../entities/worker.dart';
import '../entities/enums.dart';

class MergeWorkersResult {
  final bool success;
  final Worker? newWorker;
  final List<String> consumedWorkerIds;
  final String? error;

  MergeWorkersResult({
    required this.success,
    this.newWorker,
    this.consumedWorkerIds = const [],
    this.error,
  });
}

class MergeWorkersUseCase {
  MergeWorkersResult execute({
    required List<Worker> availableWorkers,
    required WorkerEra targetEra,
    required WorkerRarity targetRarity,
  }) {
    // 1. Filter workers by era, rarity, and NOT deployed
    final candidates = availableWorkers.where((w) {
      return w.era == targetEra && w.rarity == targetRarity && !w.isDeployed;
    }).toList();

    // 2. Check if we have at least 3
    if (candidates.length < 3) {
      return MergeWorkersResult(
        success: false,
        error:
            "Not enough workers to merge. Need 3 ${targetRarity.displayName} workers from ${targetEra.displayName}.",
      );
    }

    // 3. Select first 3
    final consumed = candidates.take(3).toList();
    final consumedIds = consumed.map((w) => w.id).toList();

    // 4. Determine next rarity
    final nextRarity = _getNextRarity(targetRarity);
    if (nextRarity == null) {
      return MergeWorkersResult(
        success: false,
        error: "Cannot merge ${targetRarity.displayName} workers further.",
      );
    }

    // 5. Create new worker
    final newWorker = WorkerFactory.create(
      era: targetEra,
      rarity: nextRarity,
      name: null, // Factory will generate default
      specialAbility: null, // Factory might generate
    );

    return MergeWorkersResult(
      success: true,
      newWorker: newWorker,
      consumedWorkerIds: consumedIds,
    );
  }

  WorkerRarity? _getNextRarity(WorkerRarity current) {
    const order = [
      WorkerRarity.common,
      WorkerRarity.rare,
      WorkerRarity.epic,
      WorkerRarity.legendary,
      WorkerRarity.paradox,
    ];

    final index = order.indexOf(current);
    if (index == -1 || index >= order.length - 1) {
      return null;
    }
    return order[index + 1];
  }
}
