import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/worker.dart';
import '../../domain/entities/daily_mission.dart';
import '../../domain/entities/expedition.dart';
import '../../domain/entities/worker_artifact.dart';
import '../../domain/entities/station.dart';
import '../../domain/entities/enums.dart';
import '../../domain/usecases/hire_worker_usecase.dart';
import '../../domain/usecases/prestige_usecase.dart';
import '../../domain/usecases/embrace_chaos_usecase.dart';
import '../../domain/usecases/summon_worker_usecase.dart';
import '../../domain/usecases/merge_stations_usecase.dart';
import '../../domain/usecases/production_loop_usecase.dart';
import '../../domain/usecases/upgrade_station_usecase.dart';
import '../../domain/usecases/check_tech_completion_usecase.dart';
import '../../domain/usecases/merge_workers_usecase.dart';
import '../../domain/usecases/fit_worker_to_era_usecase.dart';
import '../../domain/entities/prestige_upgrade.dart';
// import '../../domain/entities/daily_reward.dart'; // REMOVED
import '../../domain/usecases/claim_daily_reward_usecase.dart'; // NEW
import '../../domain/usecases/generate_daily_missions_usecase.dart';
import '../../domain/usecases/update_mission_progress_usecase.dart';
import '../../domain/usecases/claim_daily_mission_usecase.dart';
import '../../domain/usecases/salvage_artifact_usecase.dart';
import '../../domain/usecases/craft_artifact_usecase.dart';
import '../../domain/usecases/start_expedition_usecase.dart';
import '../../domain/usecases/resolve_expeditions_usecase.dart';
import '../../domain/usecases/claim_expedition_rewards_usecase.dart';
import '../../core/services/save_service.dart';
import '../../core/constants/era_mastery_constants.dart';
import '../../core/constants/tech_data.dart';
import 'dart:async';
import 'dart:math';

/// Main game state provider
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((
  ref,
) {
  return GameStateNotifier();
});

class QuickHireExpeditionCrewResult {
  final List<String> crewWorkerIds;
  final int hiredWorkers;
  final int missingBefore;
  final int missingAfter;
  final BigInt spentChronoEnergy;

  const QuickHireExpeditionCrewResult({
    required this.crewWorkerIds,
    required this.hiredWorkers,
    required this.missingBefore,
    required this.missingAfter,
    required this.spentChronoEnergy,
  });

  bool get filledCrew => missingAfter <= 0;
}

/// Notifier for managing game state
class GameStateNotifier extends StateNotifier<GameState> {
  final HireWorkerUseCase _hireWorkerUseCase = HireWorkerUseCase();
  final PrestigeUseCase _prestigeUseCase = PrestigeUseCase();
  final EmbraceChaosUseCase _embraceChaosUseCase = EmbraceChaosUseCase();
  final SummonWorkerUseCase _summonWorkerUseCase = SummonWorkerUseCase();
  final MergeStationsUseCase _mergeStationsUseCase = MergeStationsUseCase();
  final UpgradeStationUseCase _upgradeStationUseCase = UpgradeStationUseCase();
  final MergeWorkersUseCase _mergeWorkersUseCase = MergeWorkersUseCase();
  final FitWorkerToEraUseCase _fitWorkerToEraUseCase = FitWorkerToEraUseCase();
  final SaveService _saveService = SaveService();

  late final ClaimDailyRewardUseCase _claimDailyRewardUseCase =
      ClaimDailyRewardUseCase(_hireWorkerUseCase);
  final GenerateDailyMissionsUseCase _generateDailyMissionsUseCase =
      GenerateDailyMissionsUseCase();
  final UpdateMissionProgressUseCase _updateMissionProgressUseCase =
      UpdateMissionProgressUseCase();
  final ClaimDailyMissionUseCase _claimDailyMissionUseCase =
      ClaimDailyMissionUseCase();
  final SalvageArtifactUseCase _salvageArtifactUseCase =
      SalvageArtifactUseCase();
  final CraftArtifactUseCase _craftArtifactUseCase = CraftArtifactUseCase();
  final StartExpeditionUseCase _startExpeditionUseCase =
      StartExpeditionUseCase();
  final ResolveExpeditionsUseCase _resolveExpeditionsUseCase =
      ResolveExpeditionsUseCase();
  final ClaimExpeditionRewardsUseCase _claimExpeditionRewardsUseCase =
      ClaimExpeditionRewardsUseCase();

  final ProductionLoopUseCase _productionLoopUseCase = ProductionLoopUseCase();

  Timer? _autoSaveTimer;
  Timer? _tickTimer;

  // Accumulator for fractional CE production
  double _fractionalAccumulator = 0.0;
  DateTime _runtimeLastTickTime = DateTime.now();

  GameStateNotifier() : super(GameState.initial()) {
    _init();
  }
  Future<void> _init() async {
    await loadFromStorage();
    _ensureDailyMissions();
    _resolveExpeditions();
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
    // Use 1 second tick for global production
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _processGlobalProduction(1.0);
      _onTick();
    });
  }

  /// Process global production loop (CE, Paradox, etc)
  void _processGlobalProduction(double dt) {
    // 1. Calculate Tech Multiplier directly from state data
    // This avoids needing 'ref' access or circular dependencies
    final techMultiplier = TechData.calculateEfficiencyMultiplier(
      state.techLevels,
    );

    // 2. Calculate Time Warp Multiplier (Speed)
    // Increases the effective delta time for all calculations
    final timeWarpMultiplier = TechData.calculateTimeWarpMultiplier(
      state.techLevels,
    );
    final effectiveDt = dt * timeWarpMultiplier;

    // 3. Calculate Auto-Collect (Automation)
    // Generates passive "manual clicks" based on automation level
    final automationLevel = TechData.calculateAutomationLevel(state.techLevels);
    final atomicMasteryLevel = state.getEraMasteryLevel(WorkerEra.atomicAge.id);
    final automationMasteryMultiplier =
        1.0 +
        (atomicMasteryLevel *
            EraMasteryConstants.atomicAutomationBonusPerLevel);
    BigInt? additionalProduction;

    if (automationLevel > 0) {
      final baseManualClick = _calculateManualClickValue();
      // Auto-click amount = Base Click Value * Clicks/Sec * Delta Time
      // We use effectiveDt here too so automation also speeds up with Time Warp?
      // Design decision: Yes, Time Warp speeds up EVERYTHING.
      additionalProduction = BigInt.from(
        baseManualClick.toDouble() *
            automationLevel *
            automationMasteryMultiplier *
            effectiveDt,
      );
    }

    // 4. Execute Production Loop
    final result = _productionLoopUseCase.execute(
      currentState: state,
      dt: effectiveDt, // Use effective delta time
      productionRate: state.productionPerSecond,
      techMultiplier: techMultiplier,
      currentFractionalAccumulator: _fractionalAccumulator,
      additionalProduction: additionalProduction,
    );

    // 5. Update State
    state = result.newState;
    _fractionalAccumulator = result.fractionalRemainder;
  }

  void _onTick() {
    _runtimeLastTickTime = DateTime.now();
    _ensureDailyMissions();
    _resolveExpeditions();

    if (state.paradoxEventActive &&
        state.paradoxEventEndTime != null &&
        DateTime.now().isAfter(state.paradoxEventEndTime!)) {
      endParadoxEvent();
    }
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
    final saveTime = DateTime.now();
    final snapshot = state.copyWith(
      lastTickTime: _runtimeLastTickTime,
      lastSaveTime: saveTime,
    );
    await _saveService.save(snapshot);
    state = snapshot;
  }

  /// Load state from storage
  Future<void> loadFromStorage() async {
    final savedState = await _saveService.load();
    if (savedState != null) {
      state = savedState;
      _runtimeLastTickTime = savedState.lastTickTime ?? DateTime.now();
    }
  }

  /// Reset to initial state (for testing or new game)
  void reset() {
    state = GameState.initial();
    _runtimeLastTickTime = state.lastTickTime ?? DateTime.now();
  }

  /// Load state from saved data
  void loadState(GameState savedState) {
    state = savedState;
    _runtimeLastTickTime = savedState.lastTickTime ?? DateTime.now();
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
    final base = _calculateManualClickValue();

    // 3. Add to state
    addChronoEnergy(base);

    // Tutorial: Step 3 -> 4 (Collect)
    if (state.tutorialStep == 3) {
      advanceTutorial();
    }

    return base;
  }

  /// Helper to calculate the value of a single manual click
  /// REBALANCED: Increased from 1% to 2% base, Pneumatic Hammer +150%/level
  BigInt _calculateManualClickValue() {
    // 1. Calculate Base Power
    // Base is 2% of current TRUE production (including tech multipliers)
    final techMultiplier = TechData.calculateEfficiencyMultiplier(
      state.techLevels,
    );
    final trueProduction =
        state.productionPerSecond.toDouble() * techMultiplier;

    BigInt base = BigInt.from(trueProduction / 50.0); // 2%
    if (base < BigInt.from(2)) base = BigInt.from(2); // Minimum 2

    // 2. Apply Tech Multiplier (Pneumatic Hammer)
    final hammerLevel = state.techLevels['pneumatic_hammer'] ?? 0;
    if (hammerLevel > 0) {
      // REBALANCED: +150% per level (was +100%)
      // Level 1: 2.5x, Level 2: 4.0x, Level 3: 5.5x
      final multiplier = 1.0 + (hammerLevel * 1.5);
      base = BigInt.from((base.toDouble() * multiplier).round());
    }

    // 3. Apply Jazz Improvisation (Roaring 20s)
    final jazzLevel = state.techLevels['jazz_improvisation'] ?? 0;
    if (jazzLevel > 0) {
      // +160% per level (1.6x)
      final multiplier = 1.0 + (jazzLevel * 1.1);
      base = BigInt.from((base.toDouble() * multiplier).round());
    }

    // 4. Apply paradox balance click bonus (+10% per progression step)
    final paradoxClickMultiplier = state.paradoxClickBonusMultiplier;
    if (paradoxClickMultiplier > 1.0) {
      base = BigInt.from((base.toDouble() * paradoxClickMultiplier).round());
    }

    return base;
  }

  // ===== WORKERS =====

  // Helper to get next worker cost (Exponential)
  BigInt getNextWorkerCost(WorkerEra era) {
    final currentHires = state.eraHires[era.id] ?? 0;
    // Era-specific growth to keep late-era hiring in check.
    final growth = switch (era.id) {
      'atomic_age' => 1.48,
      'cyberpunk_80s' => 1.58,
      _ => 1.40,
    };
    // Using double for calculation then back to BigInt
    final multiplier = pow(growth, currentHires).toDouble();
    final cost = (era.hireCost.toDouble() * multiplier).toInt();
    return BigInt.from(cost);
  }

  /// Hire a new worker from a specific era (costs CE based on era)
  /// Unlimited hires, exponential cost
  Worker? hireWorker(WorkerEra era, {WorkerRarity? forceRarity}) {
    final cost = getNextWorkerCost(era);
    if (!spendChronoEnergy(cost)) return null;

    final worker = _hireWorkerUseCase.execute(era, forceRarity: forceRarity);

    // Add worker and increment hire count
    final newWorkers = Map<String, Worker>.from(state.workers);
    newWorkers[worker.id] = worker;

    final currentHires = state.eraHires[era.id] ?? 0;
    final newEraHires = Map<String, int>.from(state.eraHires);
    newEraHires[era.id] = currentHires + 1;

    state = state.copyWith(
      workers: newWorkers,
      totalWorkersPulled: state.totalWorkersPulled + 1,
      eraHires: newEraHires,
    );

    // Tutorial: Step 1 -> 2 (Hire)
    if (state.tutorialStep == 1) {
      advanceTutorial();
    }

    _recordMissionProgress(MissionProgressEvent.hireWorker);
    return worker;
  }

  /// Summon a worker from the Temporal Rift (costs Time Shards)
  /// Unlimited, does not count towards Cell limit
  Worker? summonWorker({int cost = 10, WorkerEra? targetEra}) {
    if (!spendTimeShards(cost)) return null;

    final result = _summonWorkerUseCase.execute(state, targetEra: targetEra);
    state = result.state;

    // Tutorial: Step 1 -> 2 (Hire) - Support shard summon too
    if (state.tutorialStep == 1) {
      advanceTutorial();
    }

    return result.worker;
  }

  // ===== TECH ====

  /// Update tech level
  void updateTechLevel(String techId, int level) {
    final previousLevel = state.techLevels[techId] ?? 0;
    final newTechLevels = Map<String, int>.from(state.techLevels);
    newTechLevels[techId] = level;
    state = state.copyWith(techLevels: newTechLevels);

    if (level > previousLevel) {
      _recordMissionProgress(MissionProgressEvent.buyTechUpgrade);
    }
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

    // Tutorial: Step 2 -> 3 (Assign)
    if (state.tutorialStep == 2) {
      advanceTutorial();
    }

    return true;
  }

  /// Remove worker from station
  bool undeployWorker(String workerId) {
    final worker = state.workers[workerId];
    if (worker == null || !worker.isDeployed) return false;

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
    return true;
  }

  /// Assign worker to station (alias for deployWorker)
  bool assignWorkerToStation(String workerId, String stationId) {
    return deployWorker(workerId, stationId);
  }

  /// Remove worker from station (alias for undeployWorker)
  bool removeWorkerFromStation(String workerId, String stationId) {
    return undeployWorker(workerId);
  }

  /// Equip an artifact to a worker
  bool equipArtifact(String workerId, String artifactId) {
    final worker = state.workers[workerId];
    if (worker == null) return false;

    // Check if worker has free slots
    if (!worker.canEquipArtifact) return false;

    // Find the artifact in inventory
    final artifactIndex = state.inventory.indexWhere((a) => a.id == artifactId);
    if (artifactIndex < 0) return false;

    final artifact = state.inventory[artifactIndex];

    // Remove from inventory
    final newInventory = List<WorkerArtifact>.from(state.inventory);
    newInventory.removeAt(artifactIndex);

    // Add to worker
    final newWorkers = Map<String, Worker>.from(state.workers);
    final newEquipped = List<WorkerArtifact>.from(worker.equippedArtifacts)
      ..add(artifact);
    newWorkers[workerId] = worker.copyWith(equippedArtifacts: newEquipped);

    state = state.copyWith(workers: newWorkers, inventory: newInventory);
    return true;
  }

  /// Unequip an artifact from a worker
  bool unequipArtifact(String workerId, String artifactId) {
    final worker = state.workers[workerId];
    if (worker == null) return false;

    // Find artifact on worker
    final artifactIndex = worker.equippedArtifacts.indexWhere(
      (a) => a.id == artifactId,
    );
    if (artifactIndex < 0) return false;

    final artifact = worker.equippedArtifacts[artifactIndex];

    // Check inventory capacity (increased to 999 to prevent silent equip failures)
    if (state.inventory.length >= 999) return false;

    // Remove from worker
    final newEquipped = List<WorkerArtifact>.from(worker.equippedArtifacts);
    newEquipped.removeAt(artifactIndex);

    final newWorkers = Map<String, Worker>.from(state.workers);
    newWorkers[workerId] = worker.copyWith(equippedArtifacts: newEquipped);

    // Add to inventory
    final newInventory = List<WorkerArtifact>.from(state.inventory)
      ..add(artifact);

    state = state.copyWith(workers: newWorkers, inventory: newInventory);
    return true;
  }

  /// Add an artifact to inventory (e.g., from anomaly drop)
  bool addArtifactToInventory(WorkerArtifact artifact) {
    if (state.inventory.length >= 999) {
      // Inventory full, maybe auto-scrap for time shards in the future?
      return false;
    }

    final newInventory = List<WorkerArtifact>.from(state.inventory)
      ..add(artifact);
    state = state.copyWith(inventory: newInventory);
    return true;
  }

  /// Salvage an artifact from inventory into Artifact Dust.
  /// Returns dust gained (0 when salvage fails).
  int salvageArtifact(String artifactId) {
    final index = state.inventory.indexWhere((a) => a.id == artifactId);
    if (index < 0) return 0;

    final artifact = state.inventory[index];
    final gainedDust = _salvageArtifactUseCase.execute(artifact);

    final newInventory = List<WorkerArtifact>.from(state.inventory)
      ..removeAt(index);

    state = state.copyWith(
      inventory: newInventory,
      artifactDust: state.artifactDust + gainedDust,
    );

    return gainedDust;
  }

  int getArtifactDustValue(WorkerArtifact artifact) {
    return _salvageArtifactUseCase.execute(artifact);
  }

  CraftArtifactResult? craftArtifact({
    required WorkerRarity minimumRarity,
    WorkerEra? targetEra,
  }) {
    final result = _craftArtifactUseCase.execute(
      state,
      minimumRarity: minimumRarity,
      targetEra: targetEra,
    );
    if (result == null) return null;

    state = result.newState;
    return result;
  }

  int getArtifactCraftCost(WorkerRarity minimumRarity) {
    return _craftArtifactUseCase.getCraftCost(minimumRarity);
  }

  int getArtifactCraftPityThreshold() {
    return _craftArtifactUseCase.pityThreshold;
  }

  /// Refit a worker to the current era's technology
  /// This updates the worker's era to currentEraId, increasing their production
  bool fitWorkerToEra(String workerId) {
    final worker = state.workers[workerId];
    if (worker == null) return false;

    try {
      state = _fitWorkerToEraUseCase.execute(worker, state);
      return true;
    } catch (e) {
      // Logic error or insufficient funds (though UI checks too)
      return false;
    }
  }

  /// Merge 3 workers of the same era and rarity into 1 of the next rarity
  MergeWorkersResult mergeWorkers(WorkerEra era, WorkerRarity rarity) {
    // 1. Get available workers
    final activeExpeditionWorkers = _activeExpeditionWorkerIds();
    final available = state.workers.values
        .where((worker) => !activeExpeditionWorkers.contains(worker.id))
        .toList();

    // 2. Execute Use Case
    final result = _mergeWorkersUseCase.execute(
      availableWorkers: available,
      targetEra: era,
      targetRarity: rarity,
    );

    if (!result.success) {
      return result;
    }

    // 3. Update State
    final newWorkers = Map<String, Worker>.from(state.workers);
    final newInventory = List<WorkerArtifact>.from(state.inventory);

    // Remove consumed and recover artifacts
    for (final id in result.consumedWorkerIds) {
      final worker = newWorkers.remove(id);
      if (worker != null && worker.equippedArtifacts.isNotEmpty) {
        newInventory.addAll(worker.equippedArtifacts);
      }
    }

    // Add new worker
    if (result.newWorker != null) {
      newWorkers[result.newWorker!.id] = result.newWorker!;
    }

    // Enforce 999 hard cap
    if (newInventory.length > 999) {
      newInventory.removeRange(999, newInventory.length);
    }

    // Update state
    state = state.copyWith(
      workers: newWorkers,
      inventory: newInventory,
      totalMerges: state.totalMerges + 1,
    );
    _recordMissionProgress(MissionProgressEvent.mergeWorker);
    if (result.newWorker != null) {
      _awardEraMasteryXp(result.newWorker!.era.id, EraMasteryConstants.mergeXp);
    }
    return result;
  }

  /// Merge specific workers by their IDs (manual selection)
  MergeWorkersResult mergeSpecificWorkers(List<String> workerIds) {
    final activeExpeditionWorkers = _activeExpeditionWorkerIds();
    final available = state.workers.values
        .where((worker) => !activeExpeditionWorkers.contains(worker.id))
        .toList();
    final result = _mergeWorkersUseCase.executeWithIds(
      allWorkers: available,
      workerIds: workerIds,
    );

    if (!result.success) return result;

    final newWorkers = Map<String, Worker>.from(state.workers);
    final newInventory = List<WorkerArtifact>.from(state.inventory);

    for (final id in result.consumedWorkerIds) {
      final worker = newWorkers.remove(id);
      if (worker != null && worker.equippedArtifacts.isNotEmpty) {
        newInventory.addAll(worker.equippedArtifacts);
      }
    }

    if (result.newWorker != null) {
      newWorkers[result.newWorker!.id] = result.newWorker!;
    }

    if (newInventory.length > 999) {
      newInventory.removeRange(999, newInventory.length);
    }

    state = state.copyWith(
      workers: newWorkers,
      inventory: newInventory,
      totalMerges: state.totalMerges + 1,
    );
    _recordMissionProgress(MissionProgressEvent.mergeWorker);
    if (result.newWorker != null) {
      _awardEraMasteryXp(result.newWorker!.era.id, EraMasteryConstants.mergeXp);
    }
    return result;
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

    final discount = TechData.calculateCostReductionMultiplier(
      state.techLevels,
    );
    final cost = station.getUpgradeCost(discountMultiplier: discount);

    // Check cost (pre-check for immediate feedback, though usecase validates too)
    if (state.chronoEnergy < cost) return false;

    state = _upgradeStationUseCase.execute(
      state,
      stationId,
      discountMultiplier: discount,
    );
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
    if (PrestigeUpgradeType.removedShopUpgradeIds.contains(upgradeId)) {
      return false;
    }
    if (PrestigeUpgradeType.fromId(upgradeId) == null) {
      return false;
    }
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

  // ===== TIMESTAMPS =====

  /// Update last save time
  void updateLastSaveTime() {
    state = state.copyWith(lastSaveTime: DateTime.now());
  }

  /// Advance to a new era
  /// - Deducts CE cost
  /// - Marks current era as completed
  /// - Switches to next era
  /// - Auto-creates a free starter station for the new era
  /// - Workers from old eras stay deployed in their chambers
  void advanceEra(String nextEraId, BigInt cost) {
    // Double check we can afford it (validation)
    if (state.chronoEnergy < cost) return;

    // Check completion of current era
    final checkCompletion = CheckTechCompletionUseCase();
    if (!checkCompletion.execute(state, state.currentEraId)) return;

    final newUnlocked = {...state.unlockedEras, nextEraId};
    final newCompleted = {...state.completedEras, state.currentEraId};
    final updatedMasteryXp = Map<String, int>.from(state.eraMasteryXp);
    updatedMasteryXp[state.currentEraId] =
        (updatedMasteryXp[state.currentEraId] ?? 0) +
        EraMasteryConstants.eraTechCompletionXp;

    // Auto-create a free starter station for the new era
    final newEraStationType = StationType.values.firstWhere(
      (type) => type.era.id == nextEraId,
      orElse: () => StationType.basicLoop, // Fallback
    );

    final starterStation = StationFactory.create(
      type: newEraStationType,
      gridX: 0,
      gridY: 0,
    );

    final newStations = Map<String, Station>.from(state.stations);
    newStations[starterStation.id] = starterStation;

    state = state.copyWith(
      chronoEnergy: state.chronoEnergy - cost,
      currentEraId: nextEraId,
      unlockedEras: newUnlocked,
      completedEras: newCompleted,
      eraMasteryXp: updatedMasteryXp,
      stations: newStations,
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

  /// Buy a specific prestige upgrade
  bool buyPrestigeUpgrade(PrestigeUpgradeType type) {
    if (type.isRemovedFromShop) {
      return false;
    }
    final currentLevel = state.paradoxPointsSpent[type.id] ?? 0;

    // Check max level cap
    if (type.maxLevel != null && currentLevel >= type.maxLevel!) {
      return false;
    }

    // Calculate cost for next level
    final cost = type.getCost(currentLevel);

    if (state.availableParadoxPoints < cost) {
      return false;
    }

    // Execute purchase
    final newSpent = Map<String, int>.from(state.paradoxPointsSpent);
    newSpent[type.id] = currentLevel + 1;

    state = state.copyWith(
      availableParadoxPoints: state.availableParadoxPoints - cost,
      paradoxPointsSpent: newSpent,
    );
    return true;
  }

  // ===== TUTORIAL =====

  /// Advance tutorial to next step
  void advanceTutorial() {
    if (state.tutorialStep < 5) {
      state = state.copyWith(tutorialStep: state.tutorialStep + 1);
    }
  }

  /// Complete tutorial immediately (for skip/debug)
  void completeTutorial() {
    state = state.copyWith(tutorialStep: 5);
  }

  // ===== ACHIEVEMENTS =====

  /// Unlock an achievement and grant its rewards
  void unlockAchievement(
    String achievementId, {
    int rewardCE = 0,
    int rewardShards = 0,
  }) {
    if (state.unlockedAchievements.contains(achievementId)) return;

    final newAchievements = Set<String>.from(state.unlockedAchievements)
      ..add(achievementId);

    state = state.copyWith(
      unlockedAchievements: newAchievements,
      chronoEnergy: state.chronoEnergy + BigInt.from(rewardCE),
      timeShards: state.timeShards + rewardShards,
    );
  }

  // ===== DAILY REWARDS =====

  /// Check if a daily reward is available to claim
  bool get isDailyRewardAvailable =>
      _claimDailyRewardUseCase.isRewardAvailable(state);

  /// Get the current streak for display (0-7, resets if missed)
  int get currentStreak => _claimDailyRewardUseCase.getCurrentStreak(state);

  /// Claim the daily reward
  ClaimDailyRewardResult? claimDailyReward() {
    final result = _claimDailyRewardUseCase.execute(state);
    if (result != null) {
      state = result.newState;
      updateLastSaveTime(); // Auto-save on claim
    }
    return result;
  }

  // ===== EXPEDITIONS =====

  List<ExpeditionSlot> get expeditionSlots =>
      _startExpeditionUseCase.getAvailableExpeditionSlots(state);

  List<String>? autoAssembleCrewForExpedition(String slotId) {
    final ExpeditionSlot? slot = _startExpeditionUseCase.getSlotById(
      slotId,
      slots: expeditionSlots,
    );
    if (slot == null) return null;

    return _startExpeditionUseCase.autoSelectCrew(
      slot,
      _availableWorkersForExpedition(),
    );
  }

  QuickHireExpeditionCrewResult? quickHireForExpeditionCrew(String slotId) {
    final ExpeditionSlot? slot = _startExpeditionUseCase.getSlotById(
      slotId,
      slots: expeditionSlots,
    );
    if (slot == null) return null;

    final QuickHirePlan plan = _startExpeditionUseCase.quickHireForCrewGap(
      slot,
      state,
    );
    final List<String> crewBefore = _startExpeditionUseCase.autoSelectCrew(
      slot,
      _availableWorkersForExpedition(),
    );
    final int missingBefore = (slot.requiredWorkers - crewBefore.length).clamp(
      0,
      slot.requiredWorkers,
    );

    if (plan.era == null || !plan.canHireAny) {
      return QuickHireExpeditionCrewResult(
        crewWorkerIds: crewBefore,
        hiredWorkers: 0,
        missingBefore: missingBefore,
        missingAfter: missingBefore,
        spentChronoEnergy: BigInt.zero,
      );
    }

    final BigInt chronoEnergyBefore = state.chronoEnergy;
    var hiredWorkers = 0;

    for (var i = 0; i < plan.affordableWorkers; i++) {
      final Worker? hired = hireWorker(
        plan.era!,
        forceRarity: WorkerRarity.common,
      );
      if (hired == null) {
        break;
      }
      hiredWorkers++;
    }

    final List<String> crewAfter = _startExpeditionUseCase.autoSelectCrew(
      slot,
      _availableWorkersForExpedition(),
    );
    final int missingAfter = (slot.requiredWorkers - crewAfter.length).clamp(
      0,
      slot.requiredWorkers,
    );

    return QuickHireExpeditionCrewResult(
      crewWorkerIds: crewAfter,
      hiredWorkers: hiredWorkers,
      missingBefore: missingBefore,
      missingAfter: missingAfter,
      spentChronoEnergy: chronoEnergyBefore - state.chronoEnergy,
    );
  }

  bool startExpedition({
    required String slotId,
    required ExpeditionRisk risk,
    required List<String> workerIds,
  }) {
    final ExpeditionSlot? slot = _startExpeditionUseCase.getSlotById(
      slotId,
      slots: expeditionSlots,
    );
    if (slot == null) return false;
    final bool sameSlotAlreadyActive = state.expeditions.any(
      (Expedition expedition) =>
          !expedition.resolved && expedition.slotId == slotId,
    );
    if (sameSlotAlreadyActive) return false;
    if (workerIds.length != slot.requiredWorkers) return false;
    if (workerIds.toSet().length != workerIds.length) return false;

    final Set<String> activeExpeditionWorkers = _activeExpeditionWorkerIds();
    for (final String workerId in workerIds) {
      final Worker? worker = state.workers[workerId];
      if (worker == null) return false;
      if (activeExpeditionWorkers.contains(workerId)) return false;
    }

    final result = _startExpeditionUseCase.execute(
      state,
      slotId: slotId,
      risk: risk,
      workerIds: workerIds,
    );
    if (result == null) return false;

    state = result.newState;
    return true;
  }

  bool claimExpeditionReward(String expeditionId) {
    return claimExpeditionRewardWithResult(expeditionId) != null;
  }

  ClaimExpeditionRewardsResult? claimExpeditionRewardWithResult(
    String expeditionId,
  ) {
    _resolveExpeditions();
    Expedition? claimedExpedition;
    for (final expedition in state.expeditions) {
      if (expedition.id == expeditionId) {
        claimedExpedition = expedition;
        break;
      }
    }

    final masteryXpByEra = <String, int>{};
    if (claimedExpedition != null &&
        claimedExpedition.resolved &&
        claimedExpedition.wasSuccessful == true) {
      for (final workerId in claimedExpedition.workerIds) {
        final worker = state.workers[workerId];
        if (worker == null) continue;
        masteryXpByEra[worker.era.id] =
            (masteryXpByEra[worker.era.id] ?? 0) +
            EraMasteryConstants.expeditionSuccessXpPerWorker;
      }
    }

    final result = _claimExpeditionRewardsUseCase.execute(state, expeditionId);
    if (result == null) return null;

    state = result.newState;
    _awardEraMasteryXpBatch(masteryXpByEra);
    return result;
  }

  void _resolveExpeditions() {
    if (state.expeditions.isEmpty) return;

    final result = _resolveExpeditionsUseCase.execute(state);
    if (result.newlyResolved.isEmpty) return;

    state = result.newState;
  }

  void _awardEraMasteryXp(String eraId, int amount) {
    if (amount <= 0) return;
    _awardEraMasteryXpBatch({eraId: amount});
  }

  void _awardEraMasteryXpBatch(Map<String, int> masteryXpByEra) {
    if (masteryXpByEra.isEmpty) return;

    final updatedMasteryXp = Map<String, int>.from(state.eraMasteryXp);
    for (final entry in masteryXpByEra.entries) {
      if (entry.value <= 0) continue;
      updatedMasteryXp[entry.key] =
          (updatedMasteryXp[entry.key] ?? 0) + entry.value;
    }
    state = state.copyWith(eraMasteryXp: updatedMasteryXp);
  }

  Set<String> _activeExpeditionWorkerIds() {
    final ids = <String>{};
    for (final expedition in state.expeditions) {
      if (expedition.resolved) continue;
      ids.addAll(expedition.workerIds);
    }
    return ids;
  }

  List<Worker> _availableWorkersForExpedition() {
    final activeExpeditionWorkers = _activeExpeditionWorkerIds();
    return state.workers.values
        .where((Worker worker) => !worker.isDeployed)
        .where((Worker worker) => !activeExpeditionWorkers.contains(worker.id))
        .toList();
  }

  /// Claim a completed daily mission objective.
  bool claimDailyMission(String missionId) {
    _ensureDailyMissions();

    final result = _claimDailyMissionUseCase.execute(state, missionId);
    if (result == null) return false;

    state = result.newState;
    return true;
  }

  void _recordMissionProgress(MissionProgressEvent event, {int amount = 1}) {
    _ensureDailyMissions();

    final updatedMissions = _updateMissionProgressUseCase.execute(
      state.dailyMissions,
      event,
      amount: amount,
    );
    state = state.copyWith(dailyMissions: updatedMissions);
  }

  void _ensureDailyMissions() {
    final now = DateTime.now();
    final lastRefresh = state.lastDailyMissionRefreshTime;
    final shouldRefresh =
        state.dailyMissions.isEmpty ||
        lastRefresh == null ||
        !_isSameCalendarDay(lastRefresh, now);

    if (!shouldRefresh) return;

    final missions = _generateDailyMissionsUseCase.execute(now);
    state = state.copyWith(
      dailyMissions: missions,
      lastDailyMissionRefreshTime: now,
    );
  }

  bool _isSameCalendarDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// ===== DERIVED PROVIDERS =====

/// Current Chrono-Energy
final chronoEnergyProvider = Provider<BigInt>((ref) {
  return ref.watch(gameStateProvider.select((s) => s.chronoEnergy));
});

/// Paradox level
final paradoxLevelProvider = Provider<double>((ref) {
  return ref.watch(gameStateProvider.select((s) => s.paradoxLevel));
});

/// Time Shards
final timeShardsProvider = Provider<int>((ref) {
  return ref.watch(gameStateProvider.select((s) => s.timeShards));
});

/// Current Artifact Dust balance.
final artifactDustProvider = Provider<int>((ref) {
  return ref.watch(gameStateProvider.select((s) => s.artifactDust));
});

/// All workers
final workersProvider = Provider<Map<String, Worker>>((ref) {
  return ref.watch(gameStateProvider.select((s) => s.workers));
});

/// All stations
final stationsProvider = Provider<Map<String, Station>>((ref) {
  return ref.watch(gameStateProvider.select((s) => s.stations));
});

/// Tech Levels map
final techLevelsProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(gameStateProvider.select((s) => s.techLevels));
});

/// Era mastery XP map keyed by era ID.
final eraMasteryXpProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(gameStateProvider.select((s) => s.eraMasteryXp));
});

/// Era mastery levels derived from mastery XP.
final eraMasteryLevelsProvider = Provider<Map<String, int>>((ref) {
  final masteryXp = ref.watch(gameStateProvider.select((s) => s.eraMasteryXp));
  return {
    for (final era in WorkerEra.values)
      era.id: EraMasteryConstants.levelFromXp(masteryXp[era.id] ?? 0),
  };
});

/// Daily missions currently active for the player.
final dailyMissionsProvider = Provider<List<DailyMission>>((ref) {
  return ref.watch(gameStateProvider.select((s) => s.dailyMissions));
});

/// Expeditions that are ongoing or waiting reward claim.
final expeditionsProvider = Provider<List<Expedition>>((ref) {
  return ref.watch(gameStateProvider.select((s) => s.expeditions));
});

/// Available expedition slot definitions.
final expeditionSlotsProvider = Provider<List<ExpeditionSlot>>((ref) {
  return ref.read(gameStateProvider.notifier).expeditionSlots;
});
