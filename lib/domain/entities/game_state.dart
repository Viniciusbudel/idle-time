import 'dart:math' as math;

import 'package:time_factory/core/constants/era_mastery_constants.dart';
import 'package:time_factory/core/constants/game_constants.dart';
import 'enums.dart';
import 'worker.dart';
import 'daily_mission.dart';
import 'expedition.dart';
import 'worker_artifact.dart';
import 'station.dart';
import 'package:time_factory/core/constants/tech_data.dart';
import 'prestige_upgrade.dart';

/// Main game state containing all player progress
class GameState {
  final BigInt chronoEnergy;
  final int timeShards;
  final BigInt lifetimeChronoEnergy;
  final Map<String, Worker> workers;
  final Map<String, Station> stations;
  final List<WorkerArtifact> inventory; // NEW: Artifact Inventory
  final int artifactDust;
  final int artifactCraftStreak;
  final double paradoxLevel;
  final bool paradoxEventActive;
  final DateTime? paradoxEventEndTime;
  final int prestigeLevel;
  final Map<String, int> paradoxPointsSpent; // UpgradeID -> Level
  final int availableParadoxPoints;
  final Set<String> unlockedEras;
  final Set<String> completedEras; // NEW: Eras where all tech is maxed
  final String currentEraId; // Track the currently active era
  final Map<String, int> techLevels; // Track tech ID -> Level
  final Map<String, int> eraHires; // NEW: Track # of cell hires per era
  final Map<String, int> eraMasteryXp; // Era ID -> accumulated mastery XP
  final DateTime? lastSaveTime;
  final DateTime? lastTickTime;
  final int totalPrestiges;
  final int totalWorkersPulled;
  final int totalMerges;
  final Set<String> unlockedAchievements;
  final int tutorialStep; // 0=Welcome, 1=Hire, 2=Assign, 3=Collect, 5=Complete
  final DateTime? lastDailyClaimTime;
  final int dailyLoginStreak;
  final List<DailyMission> dailyMissions;
  final DateTime? lastDailyMissionRefreshTime;
  final List<Expedition> expeditions;

  const GameState({
    required this.chronoEnergy,
    this.timeShards = 0,
    required this.lifetimeChronoEnergy,
    this.workers = const {},
    this.stations = const {},
    this.inventory = const [],
    this.artifactDust = 0,
    this.artifactCraftStreak = 0,
    this.paradoxLevel = 0.0,
    this.paradoxEventActive = false,
    this.paradoxEventEndTime,
    this.prestigeLevel = 0,
    this.paradoxPointsSpent = const {},
    this.availableParadoxPoints = 0,
    this.unlockedEras = const {'victorian'},
    this.completedEras = const {}, // Default empty
    this.currentEraId = 'victorian',
    this.techLevels = const {}, // Default empty
    this.eraHires = const {}, // Default empty
    this.eraMasteryXp = const {},
    this.lastSaveTime,
    this.lastTickTime,
    this.totalPrestiges = 0,
    this.totalWorkersPulled = 0,
    this.totalMerges = 0,
    this.unlockedAchievements = const {},
    this.tutorialStep = 0,
    this.lastDailyClaimTime,
    this.dailyLoginStreak = 0,
    this.dailyMissions = const [],
    this.lastDailyMissionRefreshTime,
    this.expeditions = const [],
  });

  /// Initial game state for new players
  factory GameState.initial() {
    // ... (existing starter code) ...
    // Create starter station
    const starterId = 'starter';
    final starterStation = const Station(
      id: 'station_$starterId',
      type: StationType.basicLoop,
      gridX: 0,
      gridY: 0,
      workerIds: ['worker_$starterId'],
    );

    // Create starter worker (Victorian Era, deployed to station)
    final starterWorker = Worker(
      id: 'worker_$starterId',
      era: WorkerEra.victorian,
      baseProduction: BigInt.from(1),
      rarity: WorkerRarity.common,
      name: 'Victoria',
      isDeployed: true,
      deployedStationId: 'station_$starterId',
    );

    return GameState(
      chronoEnergy: BigInt.from(500), // Start with some CE for tutorial
      timeShards: 10,
      lifetimeChronoEnergy: BigInt.zero,
      workers: {'worker_$starterId': starterWorker},
      stations: {'station_$starterId': starterStation},
      inventory: [],
      artifactDust: 0,
      artifactCraftStreak: 0,
      unlockedEras: {'victorian'},
      completedEras: {},
      currentEraId: 'victorian',
      techLevels: {},
      eraHires: {},
      eraMasteryXp: {},
      lastSaveTime: DateTime.now(),
      lastTickTime: DateTime.now(),
      totalMerges: 0,
      unlockedAchievements: {},
      tutorialStep: 0,
      lastDailyClaimTime: null,
      dailyLoginStreak: 0,
      dailyMissions: const [],
      lastDailyMissionRefreshTime: null,
      expeditions: const [],
    );
  }

  /// Create a copy with updated fields
  GameState copyWith({
    BigInt? chronoEnergy,
    int? timeShards,
    BigInt? lifetimeChronoEnergy,
    Map<String, Worker>? workers,
    Map<String, Station>? stations,
    List<WorkerArtifact>? inventory,
    int? artifactDust,
    int? artifactCraftStreak,
    double? paradoxLevel,
    bool? paradoxEventActive,
    DateTime? paradoxEventEndTime,
    int? prestigeLevel,
    Map<String, int>? paradoxPointsSpent,
    int? availableParadoxPoints,
    Set<String>? unlockedEras,
    Set<String>? completedEras, // NEW
    String? currentEraId,
    Map<String, int>? techLevels, // NEW
    Map<String, int>? eraHires, // NEW
    Map<String, int>? eraMasteryXp,
    DateTime? lastSaveTime,
    DateTime? lastTickTime,
    int? totalPrestiges,
    int? totalWorkersPulled,
    int? totalMerges,
    Set<String>? unlockedAchievements,
    int? tutorialStep,
    DateTime? lastDailyClaimTime,
    int? dailyLoginStreak,
    List<DailyMission>? dailyMissions,
    DateTime? lastDailyMissionRefreshTime,
    List<Expedition>? expeditions,
  }) {
    return GameState(
      chronoEnergy: chronoEnergy ?? this.chronoEnergy,
      timeShards: timeShards ?? this.timeShards,
      lifetimeChronoEnergy: lifetimeChronoEnergy ?? this.lifetimeChronoEnergy,
      workers: workers ?? this.workers,
      stations: stations ?? this.stations,
      inventory: inventory ?? this.inventory,
      artifactDust: artifactDust ?? this.artifactDust,
      artifactCraftStreak: artifactCraftStreak ?? this.artifactCraftStreak,
      paradoxLevel: paradoxLevel ?? this.paradoxLevel,
      paradoxEventActive: paradoxEventActive ?? this.paradoxEventActive,
      paradoxEventEndTime: paradoxEventEndTime ?? this.paradoxEventEndTime,
      prestigeLevel: prestigeLevel ?? this.prestigeLevel,
      paradoxPointsSpent: paradoxPointsSpent ?? this.paradoxPointsSpent,
      availableParadoxPoints:
          availableParadoxPoints ?? this.availableParadoxPoints,
      unlockedEras: unlockedEras ?? this.unlockedEras,
      completedEras: completedEras ?? this.completedEras,
      currentEraId: currentEraId ?? this.currentEraId,
      techLevels: techLevels ?? this.techLevels, // NEW
      eraHires: eraHires ?? this.eraHires, // NEW
      eraMasteryXp: eraMasteryXp ?? this.eraMasteryXp,
      lastSaveTime: lastSaveTime ?? this.lastSaveTime,
      lastTickTime: lastTickTime ?? this.lastTickTime,
      totalPrestiges: totalPrestiges ?? this.totalPrestiges,
      totalWorkersPulled: totalWorkersPulled ?? this.totalWorkersPulled,
      totalMerges: totalMerges ?? this.totalMerges,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      tutorialStep: tutorialStep ?? this.tutorialStep,
      lastDailyClaimTime: lastDailyClaimTime ?? this.lastDailyClaimTime,
      dailyLoginStreak: dailyLoginStreak ?? this.dailyLoginStreak,
      dailyMissions: dailyMissions ?? this.dailyMissions,
      lastDailyMissionRefreshTime:
          lastDailyMissionRefreshTime ?? this.lastDailyMissionRefreshTime,
      expeditions: expeditions ?? this.expeditions,
    );
  }

  // ===== COMPUTED PROPERTIES =====

  /// Get all active (deployed) workers
  List<Worker> get activeWorkers =>
      workers.values.where((w) => w.isDeployed).toList();

  int get paradoxClickBonusSteps =>
      PrestigeUpgradeType.paradoxClickBonusSteps(paradoxLevel);

  double get paradoxClickBonusMultiplier =>
      PrestigeUpgradeType.paradoxClickBonusMultiplier(paradoxLevel);

  int get paradoxClickBonusPercent =>
      ((paradoxClickBonusMultiplier - 1.0) * 100).round();

  /// Derived mastery levels by era from cumulative XP.
  Map<String, int> get eraMasteryLevels => {
    for (final era in WorkerEra.values) era.id: getEraMasteryLevel(era.id),
  };

  int getEraMasteryLevel(String eraId) {
    final xp = eraMasteryXp[eraId] ?? 0;
    return EraMasteryConstants.levelFromXp(xp);
  }

  double getEraMasteryProductionMultiplier(String eraId) {
    final level = getEraMasteryLevel(eraId);
    if (level <= 0) return 1.0;
    return 1.0 + (level * EraMasteryConstants.productionBonusPerLevel);
  }

  /// Calculate total production per second
  BigInt get productionPerSecond {
    BigInt total = BigInt.zero;

    for (final worker in activeWorkers) {
      final station = stations[worker.deployedStationId];
      if (station == null) continue;

      var production = worker.currentProduction;
      production =
          production *
          BigInt.from((station.productionBonus * 100).toInt()) ~/
          BigInt.from(100);

      production = _applyMultiplier(
        production,
        getEraMasteryProductionMultiplier(worker.era.id),
      );

      final chronoMasteryLevel = PrestigeUpgradeType.chronoMastery.clampLevel(
        paradoxPointsSpent[PrestigeUpgradeType.chronoMastery.id] ?? 0,
      );
      if (chronoMasteryLevel > 0) {
        production = _applyMultiplier(
          production,
          1.0 + (chronoMasteryLevel * 0.1),
        );
      }

      if (paradoxEventActive) {
        production = production * BigInt.from(200) ~/ BigInt.from(100);
      }

      total += production;
    }

    return total;
  }

  /// Calculate paradox accumulation rate per second
  double get paradoxPerSecond {
    double rate = 0.0;
    rate += activeWorkers.length * 0.001;

    for (final station in stations.values) {
      rate += station.paradoxRate;
    }

    final eraVariety = activeWorkers.map((w) => w.era).toSet().length;
    if (eraVariety > 1) {
      rate += (eraVariety - 1) * 0.002;
    }

    final riftStabilityLevel = PrestigeUpgradeType.riftStability.clampLevel(
      paradoxPointsSpent[PrestigeUpgradeType.riftStability.id] ?? 0,
    );
    if (riftStabilityLevel > 0) {
      rate *= (1.0 - riftStabilityLevel * 0.05);
    }

    return rate;
  }

  /// Calculate specific station production per second
  BigInt getStationProduction(String stationId) {
    final station = stations[stationId];
    if (station == null) return BigInt.zero;

    BigInt total = BigInt.zero;
    final stationWorkers = activeWorkers.where(
      (w) => w.deployedStationId == stationId,
    );

    for (final worker in stationWorkers) {
      var production = worker.currentProduction;

      // Station bonus
      production =
          production *
          BigInt.from((station.productionBonus * 100).toInt()) ~/
          BigInt.from(100);

      production = _applyMultiplier(
        production,
        getEraMasteryProductionMultiplier(worker.era.id),
      );

      // Chrono Mastery
      final chronoMasteryLevel = PrestigeUpgradeType.chronoMastery.clampLevel(
        paradoxPointsSpent[PrestigeUpgradeType.chronoMastery.id] ?? 0,
      );
      if (chronoMasteryLevel > 0) {
        production = _applyMultiplier(
          production,
          1.0 + (chronoMasteryLevel * 0.1),
        );
      }

      // Paradox Event
      if (paradoxEventActive) {
        production = production * BigInt.from(200) ~/ BigInt.from(100);
      }

      total += production;
    }
    return total;
  }

  /// Get offline efficiency multiplier
  double get offlineEfficiency {
    const base = 0.1; // REBALANCED: 0.7 -> 0.1
    // Paradox Upgrade
    final offlineBonusLevel = PrestigeUpgradeType.temporalMemory.clampLevel(
      paradoxPointsSpent[PrestigeUpgradeType.temporalMemory.id] ?? 0,
    );
    // Tech Upgrade (all offline techs: clockwork_arithmometer, radio_broadcast, etc.)
    final techMultiplier = TechData.calculateOfflineEfficiencyMultiplier(
      techLevels,
    );
    final victorianMasteryLevel = getEraMasteryLevel(WorkerEra.victorian.id);
    final victorianMasteryBonus =
        victorianMasteryLevel *
        EraMasteryConstants.victorianOfflineBonusPerLevel;
    // TechData returns 1.0 + bonus, subtract 1.0 to get just the bonus portion
    return base +
        (offlineBonusLevel * 0.1) +
        (techMultiplier - 1.0) +
        victorianMasteryBonus;
  }

  /// Check if can afford purchase
  bool canAfford(BigInt cost) => chronoEnergy >= cost;

  /// Check if can afford shards
  bool canAffordShards(int cost) => timeShards >= cost;

  /// Get list of unlocked era enums
  List<WorkerEra> get unlockedEraEnums {
    return WorkerEra.values
        .where((era) => unlockedEras.contains(era.id))
        .toList();
  }

  /// Calculate prestige points to gain
  int get prestigePointsToGain {
    final minimum = BigInt.from(GameConstants.prestigeMinimumCE);
    if (lifetimeChronoEnergy < minimum) return 0;

    // Log curve to avoid runaway PP in late eras.
    final log10Ce = _log10BigInt(lifetimeChronoEnergy);
    final baseLog =
        math.log(GameConstants.prestigeFormulaBase.toDouble()) / math.ln10;
    final growth = (log10Ce - baseLog).clamp(0.0, 24.0);
    final points = (6.0 * growth * growth).floor();
    return points < 1 ? 1 : points;
  }

  /// Check if can prestige
  bool get canPrestige =>
      lifetimeChronoEnergy >= BigInt.from(GameConstants.prestigeMinimumCE);

  static double _log10BigInt(BigInt value) {
    if (value <= BigInt.zero) return 0.0;

    final text = value.toString();
    const significantDigits = 15;

    if (text.length <= significantDigits) {
      return math.log(value.toDouble()) / math.ln10;
    }

    final lead = double.parse(text.substring(0, significantDigits));
    return (text.length - significantDigits) + (math.log(lead) / math.ln10);
  }

  static BigInt _applyMultiplier(BigInt value, double multiplier) {
    if (multiplier == 1.0) return value;
    const precision = 10000;
    final scaled = (multiplier * precision).round();
    return value * BigInt.from(scaled) ~/ BigInt.from(precision);
  }

  /// Get number of stations owned in a specific era
  int getStationCountForEra(String eraId) {
    return stations.values.where((s) => s.type.era.id == eraId).length;
  }

  Map<String, dynamic> toMap() {
    return {
      'chronoEnergy': chronoEnergy.toString(),
      'timeShards': timeShards,
      'lifetimeChronoEnergy': lifetimeChronoEnergy.toString(),
      'workers': workers.map((k, v) => MapEntry(k, v.toMap())),
      'stations': stations.map((k, v) => MapEntry(k, v.toMap())),
      'inventory': inventory.map((e) => e.toMap()).toList(),
      'artifactDust': artifactDust,
      'artifactCraftStreak': artifactCraftStreak,
      'paradoxLevel': paradoxLevel,
      'paradoxEventActive': paradoxEventActive,
      'paradoxEventEndTime': paradoxEventEndTime?.toIso8601String(),
      'prestigeLevel': prestigeLevel,
      'paradoxPointsSpent': paradoxPointsSpent,
      'availableParadoxPoints': availableParadoxPoints,
      'unlockedEras': unlockedEras.toList(),
      'completedEras': completedEras.toList(),
      'currentEraId': currentEraId,
      'techLevels': techLevels,
      'eraHires': eraHires,
      'eraMasteryXp': eraMasteryXp,
      'lastSaveTime': lastSaveTime?.toIso8601String(),
      'lastTickTime': lastTickTime?.toIso8601String(),
      'totalPrestiges': totalPrestiges,
      'totalWorkersPulled': totalWorkersPulled,
      'totalMerges': totalMerges,
      'unlockedAchievements': unlockedAchievements.toList(),
      'tutorialStep': tutorialStep,
      'lastDailyClaimTime': lastDailyClaimTime?.toIso8601String(),
      'dailyLoginStreak': dailyLoginStreak,
      'dailyMissions': dailyMissions.map((m) => m.toMap()).toList(),
      'lastDailyMissionRefreshTime': lastDailyMissionRefreshTime
          ?.toIso8601String(),
      'expeditions': expeditions.map((e) => e.toMap()).toList(),
    };
  }

  factory GameState.fromMap(Map<String, dynamic> map) {
    final parsedWorkers = (map['workers'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, Worker.fromMap(v as Map<String, dynamic>)),
    );
    final rawParadoxSpent = Map<String, int>.from(map['paradoxPointsSpent'] ?? {});
    final normalizedParadoxSpent = <String, int>{};
    for (final entry in rawParadoxSpent.entries) {
      final type = PrestigeUpgradeType.fromId(entry.key);
      if (type == null || type.isRemovedFromShop) {
        continue;
      }
      normalizedParadoxSpent[entry.key] = type.clampLevel(entry.value);
    }

    return GameState(
      chronoEnergy: BigInt.parse(map['chronoEnergy']),
      timeShards: map['timeShards'] ?? 0,
      lifetimeChronoEnergy: BigInt.parse(map['lifetimeChronoEnergy']),
      workers: parsedWorkers,
      stations: (map['stations'] as Map<String, dynamic>).map((k, v) {
        final station = Station.fromMap(v as Map<String, dynamic>);
        // Cleanup ghost workers (e.g. from buggy version saves or merges)
        final validIds = station.workerIds
            .where((id) => parsedWorkers.containsKey(id))
            .toList();
        return MapEntry(k, station.copyWith(workerIds: validIds));
      }),
      inventory:
          (map['inventory'] as List<dynamic>?)
              ?.map((e) => WorkerArtifact.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      artifactDust: map['artifactDust'] ?? 0,
      artifactCraftStreak: map['artifactCraftStreak'] ?? 0,
      paradoxLevel: (map['paradoxLevel'] as num).toDouble(),
      paradoxEventActive: map['paradoxEventActive'] ?? false,
      paradoxEventEndTime: map['paradoxEventEndTime'] != null
          ? DateTime.parse(map['paradoxEventEndTime'])
          : null,
      prestigeLevel: map['prestigeLevel'] ?? 0,
      paradoxPointsSpent: normalizedParadoxSpent,
      availableParadoxPoints: map['availableParadoxPoints'] ?? 0,
      unlockedEras: Set<String>.from(map['unlockedEras'] ?? {'victorian'}),
      completedEras: Set<String>.from(map['completedEras'] ?? {}),
      currentEraId: map['currentEraId'] ?? 'victorian',
      techLevels: Map<String, int>.from(map['techLevels'] ?? {}),
      eraHires: Map<String, int>.from(map['eraHires'] ?? {}),
      eraMasteryXp: Map<String, int>.from(map['eraMasteryXp'] ?? {}),
      lastSaveTime: map['lastSaveTime'] != null
          ? DateTime.parse(map['lastSaveTime'])
          : null,
      lastTickTime: map['lastTickTime'] != null
          ? DateTime.parse(map['lastTickTime'])
          : null,
      totalPrestiges: map['totalPrestiges'] ?? 0,
      totalWorkersPulled: map['totalWorkersPulled'] ?? 0,
      totalMerges: map['totalMerges'] ?? 0,
      unlockedAchievements: Set<String>.from(map['unlockedAchievements'] ?? []),
      tutorialStep: map['tutorialStep'] ?? 0,
      lastDailyClaimTime: map['lastDailyClaimTime'] != null
          ? DateTime.parse(map['lastDailyClaimTime'])
          : null,
      dailyLoginStreak: map['dailyLoginStreak'] ?? 0,
      dailyMissions:
          (map['dailyMissions'] as List<dynamic>?)
              ?.map((e) => DailyMission.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastDailyMissionRefreshTime: map['lastDailyMissionRefreshTime'] != null
          ? DateTime.parse(map['lastDailyMissionRefreshTime'])
          : null,
      expeditions:
          (map['expeditions'] as List<dynamic>?)
              ?.map((e) => Expedition.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
