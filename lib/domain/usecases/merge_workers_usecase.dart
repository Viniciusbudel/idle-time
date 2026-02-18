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
    final candidates = availableWorkers.where((w) {
      return w.era == targetEra && w.rarity == targetRarity && !w.isDeployed;
    }).toList();

    if (candidates.length < 3) {
      return MergeWorkersResult(
        success: false,
        error:
            "Not enough workers to merge. Need 3 ${targetRarity.displayName} workers from ${targetEra.displayName}.",
      );
    }

    final consumed = candidates.take(3).toList();
    return _doMerge(consumed, targetEra, targetRarity);
  }

  /// Merge specific workers by ID (for manual selection)
  MergeWorkersResult executeWithIds({
    required List<Worker> allWorkers,
    required List<String> workerIds,
  }) {
    if (workerIds.length < 3) {
      return MergeWorkersResult(
        success: false,
        error: "Select 3 workers to merge.",
      );
    }

    final selected = <Worker>[];
    for (final id in workerIds.take(3)) {
      final w = allWorkers.where((w) => w.id == id).firstOrNull;
      if (w == null) {
        return MergeWorkersResult(success: false, error: "Worker not found.");
      }
      if (w.isDeployed) {
        return MergeWorkersResult(
          success: false,
          error: "${w.displayName} is deployed. Recall first.",
        );
      }
      selected.add(w);
    }

    // Validate all same era + rarity
    final era = selected.first.era;
    final rarity = selected.first.rarity;
    if (selected.any((w) => w.era != era || w.rarity != rarity)) {
      return MergeWorkersResult(
        success: false,
        error: "All 3 workers must be the same era and rarity.",
      );
    }

    return _doMerge(selected, era, rarity);
  }

  MergeWorkersResult _doMerge(
    List<Worker> consumed,
    WorkerEra era,
    WorkerRarity rarity,
  ) {
    final consumedIds = consumed.map((w) => w.id).toList();

    final nextRarity = _getNextRarity(rarity);
    if (nextRarity == null) {
      return MergeWorkersResult(
        success: false,
        error: "Cannot merge ${rarity.displayName} workers further.",
      );
    }

    final newWorker = WorkerFactory.create(
      era: era,
      rarity: nextRarity,
      name: null,
      specialAbility: null,
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
