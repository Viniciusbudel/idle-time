import '../entities/game_state.dart';
import '../entities/station.dart';
import '../entities/worker.dart';

/// Use case for merging two stations of the same type and level.
/// Merging combines them into a single station at level + 1.
class MergeStationsUseCase {
  /// Execute the merge.
  /// Returns updated GameState if successful, null if merge is invalid.
  GameState? execute(GameState state, String stationId1, String stationId2) {
    final station1 = state.stations[stationId1];
    final station2 = state.stations[stationId2];

    if (station1 == null || station2 == null) return null;
    if (station1.type != station2.type) return null;
    if (station1.level != station2.level) return null;

    // Create merged station (keep first station's position)
    final newLevel = station1.level + 1;
    final newMaxSlots = station1.type.workerSlots * newLevel;

    final combinedWorkerIds = [...station1.workerIds, ...station2.workerIds];

    final keptWorkerIds = combinedWorkerIds.take(newMaxSlots).toList();
    final orphanedWorkerIds = combinedWorkerIds.skip(newMaxSlots).toList();

    final mergedStation = station1.copyWith(
      level: newLevel,
      workerIds: keptWorkerIds,
    );

    // Update stations map
    final newStations = Map<String, Station>.from(state.stations);
    newStations[stationId1] = mergedStation;
    newStations.remove(stationId2);

    // Mark orphaned workers as unassigned
    final newWorkers = Map<String, Worker>.from(state.workers);
    for (final workerId in orphanedWorkerIds) {
      final worker = state.workers[workerId];
      if (worker != null) {
        newWorkers[workerId] = worker.copyWith(isDeployed: false);
      }
    }

    return state.copyWith(stations: newStations, workers: newWorkers);
  }

  /// Check if two stations can be merged
  bool canMerge(GameState state, String stationId1, String stationId2) {
    final station1 = state.stations[stationId1];
    final station2 = state.stations[stationId2];

    if (station1 == null || station2 == null) return false;
    if (station1.type != station2.type) return false;
    if (station1.level != station2.level) return false;
    if (stationId1 == stationId2) return false;

    return true;
  }
}
