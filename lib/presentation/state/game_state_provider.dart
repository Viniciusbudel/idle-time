import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/worker.dart';
import '../../domain/entities/station.dart';
import '../../domain/entities/enums.dart';
import '../../domain/usecases/hire_worker_usecase.dart';
import '../../domain/usecases/prestige_usecase.dart';
import '../../domain/usecases/check_era_unlocks_usecase.dart';
import '../../domain/usecases/embrace_chaos_usecase.dart';
import '../../domain/usecases/summon_worker_usecase.dart';
import '../../domain/usecases/merge_stations_usecase.dart';
import '../../domain/usecases/production_loop_usecase.dart';
import '../../domain/usecases/upgrade_station_usecase.dart';
import '../../domain/usecases/check_tech_completion_usecase.dart';
import '../../core/services/save_service.dart';
import '../../core/constants/tech_data.dart';
import 'dart:async';

/// Main game state provider
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((
  ref,
) {
  return GameStateNotifier();
});

/// Notifier for managing game state
class GameStateNotifier extends StateNotifier<GameState> {
  final HireWorkerUseCase _hireWorkerUseCase = HireWorkerUseCase();
  final PrestigeUseCase _prestigeUseCase = PrestigeUseCase();
  final CheckEraUnlocksUseCase _checkEraUnlocksUseCase =
      CheckEraUnlocksUseCase();
  final EmbraceChaosUseCase _embraceChaosUseCase = EmbraceChaosUseCase();
  final SummonWorkerUseCase _summonWorkerUseCase = SummonWorkerUseCase();
  final MergeStationsUseCase _mergeStationsUseCase = MergeStationsUseCase();
  final UpgradeStationUseCase _upgradeStationUseCase = UpgradeStationUseCase();
  final SaveService _saveService = SaveService();

  Timer? _autoSaveTimer;
  Timer? _tickTimer;

  GameStateNotifier() : super(GameState.initial()) {
    _init();
  }
  Future<void> _init() async {
    await loadFromStorage();
    _startAutoSave();
    _startTickTimer();
  }

  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      saveToStorage();
    });
  }

  void _startTickTimer() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _onTick();
    });
  }

  void _onTick() {
    if (state.paradoxEventActive &&
        state.paradoxEventEndTime != null &&
        DateTime.now().isAfter(state.paradoxEventEndTime!)) {
      endParadoxEvent();
    }
    updateLastTickTime();
  }

  /// Apply results from the game loop production tick
  void applyProductionResult(ProductionLoopResult result) {
    state = result.newState;
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _tickTimer?.cancel();
    super.dispose();
  }

  /// Save current state to storage
  Future<void> saveToStorage() async {
    await _saveService.save(state);
    updateLastSaveTime();
  }

  /// Load state from storage
  Future<void> loadFromStorage() async {
    final savedState = await _saveService.load();
    if (savedState != null) {
      state = savedState;
    }
  }

  /// Reset to initial state (for testing or new game)
  void reset() {
    state = GameState.initial();
  }

  /// Load state from saved data
  void loadState(GameState savedState) {
    state = savedState;
  }

  // ===== RESOURCES =====

  /// Add Chrono-Energy
  void addChronoEnergy(BigInt amount) {
    final newAmount = state.chronoEnergy + amount;
    final newLifetime = state.lifetimeChronoEnergy + amount;
    state = state.copyWith(
      chronoEnergy: newAmount,
      lifetimeChronoEnergy: newLifetime,
    );
  }

  /// Spend Chrono-Energy
  bool spendChronoEnergy(BigInt amount) {
    if (state.chronoEnergy < amount) return false;
    final newAmount = state.chronoEnergy - amount;
    state = state.copyWith(chronoEnergy: newAmount);
    return true;
  }

  /// Add Time Shards
  void addTimeShards(int amount) {
    state = state.copyWith(timeShards: state.timeShards + amount);
  }

  /// Spend Time Shards
  bool spendTimeShards(int amount) {
    if (state.timeShards < amount) return false;
    state = state.copyWith(timeShards: state.timeShards - amount);
    return true;
  }

  /// PROCESSED: Manual Click Action
  /// Returns the amount of CE generated
  BigInt manualClick() {
    // 1. Calculate Base Power
    // Base is 1% of current production OR 1, whichever is higher
    BigInt base = state.productionPerSecond ~/ BigInt.from(100);
    if (base < BigInt.one) base = BigInt.one;

    // 2. Apply Tech Multiplier (Pneumatic Hammer)
    final hammerLevel = state.techLevels['pneumatic_hammer'] ?? 0;
    if (hammerLevel > 0) {
      // +100% per level means multiplier = 1 + level
      final multiplier = 1 + hammerLevel;
      base = base * BigInt.from(multiplier);
    }

    // 3. Add to state
    addChronoEnergy(base);

    return base;
  }

  // ===== WORKERS =====

  /// Hire a new worker from a specific era (costs CE based on era)
  /// Limited to 5 hires per era using Cells (CE)
  bool hireWorker(WorkerEra era) {
    // Check limit
    final currentHires = state.eraHires[era.id] ?? 0;
    if (currentHires >= 5) return false;

    if (!spendChronoEnergy(era.hireCost)) return false;

    final worker = _hireWorkerUseCase.execute(era);

    // Add worker and increment hire count
    final newWorkers = Map<String, Worker>.from(state.workers);
    newWorkers[worker.id] = worker;

    final newEraHires = Map<String, int>.from(state.eraHires);
    newEraHires[era.id] = currentHires + 1;

    state = state.copyWith(
      workers: newWorkers,
      totalWorkersPulled: state.totalWorkersPulled + 1,
      eraHires: newEraHires,
    );
    return true;
  }

  /// Summon a worker from the Temporal Rift (costs Time Shards)
  /// Unlimited, does not count towards Cell limit
  Worker? summonWorker({int cost = 10, WorkerEra? targetEra}) {
    if (!spendTimeShards(cost)) return null;

    final result = _summonWorkerUseCase.execute(state, targetEra: targetEra);
    state = result.state;
    return result.worker;
  }

  // ===== TECH ====

  /// Update tech level
  void updateTechLevel(String techId, int level) {
    final newTechLevels = Map<String, int>.from(state.techLevels);
    newTechLevels[techId] = level;
    state = state.copyWith(techLevels: newTechLevels);
  }

  /// Add a new worker
  void addWorker(Worker worker) {
    final newWorkers = Map<String, Worker>.from(state.workers);
    newWorkers[worker.id] = worker;
    state = state.copyWith(
      workers: newWorkers,
      totalWorkersPulled: state.totalWorkersPulled + 1,
    );
  }

  /// Deploy worker to a station
  bool deployWorker(String workerId, String stationId) {
    final worker = state.workers[workerId];
    final station = state.stations[stationId];

    if (worker == null || station == null) return false;
    if (worker.isDeployed) return false;
    if (!station.canAddWorker) return false;

    // Update worker
    final newWorkers = Map<String, Worker>.from(state.workers);
    newWorkers[workerId] = worker.copyWith(
      isDeployed: true,
      deployedStationId: stationId,
    );

    // Update station
    final newStations = Map<String, Station>.from(state.stations);
    newStations[stationId] = station.copyWith(
      workerIds: [...station.workerIds, workerId],
    );

    state = state.copyWith(workers: newWorkers, stations: newStations);
    return true;
  }

  /// Remove worker from station
  void undeployWorker(String workerId) {
    final worker = state.workers[workerId];
    if (worker == null || !worker.isDeployed) return;

    final stationId = worker.deployedStationId;

    // Update worker
    final newWorkers = Map<String, Worker>.from(state.workers);
    newWorkers[workerId] = worker.copyWith(
      isDeployed: false,
      deployedStationId: null,
    );

    // Update station if exists
    final newStations = Map<String, Station>.from(state.stations);
    if (stationId != null && newStations.containsKey(stationId)) {
      newStations[stationId] = newStations[stationId]!.copyWith(
        workerIds: newStations[stationId]!.workerIds
            .where((id) => id != workerId)
            .toList(),
      );
    }

    state = state.copyWith(workers: newWorkers, stations: newStations);
  }

  /// Assign worker to station (alias for deployWorker)
  bool assignWorkerToStation(String workerId, String stationId) {
    return deployWorker(workerId, stationId);
  }

  /// Remove worker from station (alias for undeployWorker)
  void removeWorkerFromStation(String workerId, String stationId) {
    undeployWorker(workerId);
  }

  /// Upgrade a worker
  bool upgradeWorker(String workerId) {
    final worker = state.workers[workerId];
    if (worker == null) return false;

    final cost = worker.upgradeCost;
    if (!spendChronoEnergy(cost)) return false;

    final newWorkers = Map<String, Worker>.from(state.workers);
    newWorkers[workerId] = worker.copyWith(level: worker.level + 1);
    state = state.copyWith(workers: newWorkers);
    return true;
  }

  // ===== STATIONS =====

  bool purchaseStation(StationType type, [int? gridX, int? gridY]) {
    // Era-Specific Limit Check (Mega-Chamber: Max 1 per Era)
    final stationEra = type.era;
    final currentCount = state.getStationCountForEra(stationEra.id);
    if (currentCount >= 1) return false;

    // Use current count for cost scaling (per type or per era? Plan says per type usually,
    // but maybe per era for floor scaling? Sticking to existing per-type scaling for now
    // unless design changes, effectively capping cost scaling at 5th station)
    final ownedCount = state.stations.values
        .where((s) => s.type == type)
        .length;

    final discount = TechData.calculateCostReductionMultiplier(
      state.techLevels,
    );
    final cost = StationFactory.getPurchaseCost(
      type,
      ownedCount,
      discountMultiplier: discount,
    );

    if (!spendChronoEnergy(cost)) return false;

    // Auto-assign grid position if not provided
    final x = gridX ?? (ownedCount % 3);
    final y = gridY ?? (ownedCount ~/ 3);

    final station = StationFactory.create(type: type, gridX: x, gridY: y);

    addStation(station);
    return true;
  }

  /// Add a new station
  void addStation(Station station) {
    final newStations = Map<String, Station>.from(state.stations);
    newStations[station.id] = station;
    state = state.copyWith(stations: newStations);
  }

  /// Upgrade a station
  bool upgradeStation(String stationId) {
    // Check if can afford first (handled in usecase but we need boolean for UI feedback)
    final station = state.stations[stationId];
    if (station == null) return false;

    // Check cost (pre-check for immediate feedback, though usecase validates too)
    if (state.chronoEnergy < station.upgradeCost) return false;

    state = _upgradeStationUseCase.execute(state, stationId);
    return true;
  }

  /// Merge two stations of the same type and level
  bool mergeStations(String stationId1, String stationId2) {
    if (!_mergeStationsUseCase.canMerge(state, stationId1, stationId2)) {
      return false;
    }

    final newState = _mergeStationsUseCase.execute(
      state,
      stationId1,
      stationId2,
    );
    if (newState == null) return false;

    state = newState;
    return true;
  }

  // ===== PARADOX =====

  /// Update paradox level
  void updateParadox(double delta) {
    final newLevel = (state.paradoxLevel + delta).clamp(0.0, 1.0);
    state = state.copyWith(paradoxLevel: newLevel);
  }

  /// Trigger paradox event
  void triggerParadoxEvent() {
    state = state.copyWith(
      paradoxEventActive: true,
      paradoxEventEndTime: DateTime.now().add(const Duration(seconds: 20)),
      paradoxLevel: (state.paradoxLevel * 0.7).clamp(0.0, 1.0), // Reduce by 30%
    );
  }

  /// End paradox event
  void endParadoxEvent() {
    state = state.copyWith(
      paradoxEventActive: false,
      paradoxEventEndTime: null,
    );
  }

  /// Embrace Chaos (Manual trigger)
  void embraceChaos() {
    state = _embraceChaosUseCase.execute(state);
  }

  // ===== PRESTIGE =====

  /// Perform prestige (timeline collapse)
  void prestige() {
    state = _prestigeUseCase.execute(state);
  }

  /// Spend paradox points on upgrade
  bool spendParadoxPoints(String upgradeId, int amount) {
    if (state.availableParadoxPoints < amount) return false;

    final newSpent = Map<String, int>.from(state.paradoxPointsSpent);
    newSpent[upgradeId] = (newSpent[upgradeId] ?? 0) + amount;

    state = state.copyWith(
      availableParadoxPoints: state.availableParadoxPoints - amount,
      paradoxPointsSpent: newSpent,
    );
    return true;
  }

  // ===== ERA UNLOCKS =====

  /// Unlock a new era
  void unlockEra(WorkerEra era) {
    if (state.unlockedEras.contains(era.id)) return;
    state = state.copyWith(unlockedEras: {...state.unlockedEras, era.id});
  }

  /// Check and unlock eras based on CE
  void checkEraUnlocks() {
    state = _checkEraUnlocksUseCase.execute(state);
  }

  // ===== TIMESTAMPS =====

  /// Update last save time
  void updateLastSaveTime() {
    state = state.copyWith(lastSaveTime: DateTime.now());
  }

  /// Advance to a new era
  void advanceEra(String nextEraId, BigInt cost) {
    // Double check we can afford it (validation)
    if (state.chronoEnergy < cost) return;

    // Check completion of current era
    // Note: We assume UI passes the correct nextEraId. Verification is done here.
    // For simplicity, we just check if the current era is complete.
    final checkCompletion = CheckTechCompletionUseCase();
    if (!checkCompletion.execute(state, state.currentEraId)) return;

    final newUnlocked = {...state.unlockedEras, nextEraId};
    final newCompleted = {...state.completedEras, state.currentEraId};

    state = state.copyWith(
      chronoEnergy: state.chronoEnergy - cost,
      currentEraId: nextEraId,
      unlockedEras: newUnlocked,
      completedEras: newCompleted,
    );
  }

  /// Switch to an already unlocked era
  void switchToEra(String eraId) {
    if (state.unlockedEras.contains(eraId)) {
      state = state.copyWith(currentEraId: eraId);
    }
  }

  /// Update last tick time
  /// Debug method to add currency
  void debugAddCurrency(BigInt amount) {
    addChronoEnergy(amount);
  }

  void updateLastTickTime() {
    state = state.copyWith(lastTickTime: DateTime.now());
  }
}

// ===== DERIVED PROVIDERS =====

/// Current Chrono-Energy
final chronoEnergyProvider = Provider<BigInt>((ref) {
  return ref.watch(gameStateProvider).chronoEnergy;
});

/// Paradox level
final paradoxLevelProvider = Provider<double>((ref) {
  return ref.watch(gameStateProvider).paradoxLevel;
});

/// Time Shards
final timeShardsProvider = Provider<int>((ref) {
  return ref.watch(gameStateProvider).timeShards;
});

/// All workers
final workersProvider = Provider<Map<String, Worker>>((ref) {
  return ref.watch(gameStateProvider).workers;
});

/// All stations
final stationsProvider = Provider<Map<String, Station>>((ref) {
  return ref.watch(gameStateProvider).stations;
});
