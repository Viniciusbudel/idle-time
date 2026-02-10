import 'dart:math';
import '../entities/game_state.dart';
import '../entities/worker.dart';
import '../entities/enums.dart';

/// Use case for summoning new workers using the Temporal Rift Gacha system.
class SummonWorkerUseCase {
  static final _random = Random();

  /// Rarity weights (higher = more common)
  static const Map<WorkerRarity, double> _rarityWeights = {
    WorkerRarity.common: 60.0,
    WorkerRarity.rare: 25.0,
    WorkerRarity.epic: 10.0,
    WorkerRarity.legendary: 4.0,
    WorkerRarity.paradox: 1.0,
  };

  /// Summon a single worker from the Temporal Rift.
  /// Returns the updated [GameState] and the summoned [Worker].
  ({GameState state, Worker worker}) execute(
    GameState state, {
    WorkerEra? targetEra,
  }) {
    final rarity = _rollRarity();
    final era =
        targetEra ??
        WorkerEra.values.firstWhere(
          (e) => e.id == state.currentEraId,
          orElse: () => WorkerEra.victorian,
        );

    final worker = WorkerFactory.create(era: era, rarity: rarity);

    final newWorkers = Map<String, Worker>.from(state.workers);
    newWorkers[worker.id] = worker;

    final newState = state.copyWith(
      workers: newWorkers,
      totalWorkersPulled: state.totalWorkersPulled + 1,
    );

    return (state: newState, worker: worker);
  }

  /// Roll for rarity using weighted random
  WorkerRarity _rollRarity() {
    final totalWeight = _rarityWeights.values.fold(0.0, (a, b) => a + b);
    double roll = _random.nextDouble() * totalWeight;

    for (final entry in _rarityWeights.entries) {
      roll -= entry.value;
      if (roll <= 0) {
        return entry.key;
      }
    }
    return WorkerRarity.common;
  }
}
