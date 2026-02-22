import '../entities/game_state.dart';
import '../entities/worker.dart';
import '../entities/enums.dart';
import '../entities/prestige_upgrade.dart';

/// Use case for summoning new workers using the Temporal Rift Gacha system.
/// Use case for summoning new workers using the Temporal Rift Gacha system.
class SummonWorkerUseCase {
  /// Summon a single worker from the Temporal Rift.
  /// Returns the updated [GameState] and the summoned [Worker].
  ({GameState state, Worker worker}) execute(
    GameState state, {
    WorkerEra? targetEra,
  }) {
    final timekeepersLevel = PrestigeUpgradeType.timekeepersFavor.clampLevel(
      state.paradoxPointsSpent[PrestigeUpgradeType.timekeepersFavor.id] ?? 0,
    );
    final luckFactor = timekeepersLevel * 0.05;
    final rarity = WorkerFactory.rollRarity(luckFactor: luckFactor);
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
}
