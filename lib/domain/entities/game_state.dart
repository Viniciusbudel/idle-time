import 'enums.dart';
import 'worker.dart';
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
  final DateTime? lastSaveTime;
  final DateTime? lastTickTime;
  final int totalPrestiges;
  final int totalWorkersPulled;
  final int totalMerges;
  final Set<String> unlockedAchievements;
  final int tutorialStep; // 0=Welcome, 1=Hire, 2=Assign, 3=Collect, 5=Complete
  final DateTime? lastDailyClaimTime;
  final int dailyLoginStreak;

  const GameState({
    required this.chronoEnergy,
    this.timeShards = 0,
    required this.lifetimeChronoEnergy,
    this.workers = const {},
    this.stations = const {},
    this.inventory = const [],
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
    this.lastSaveTime,
    this.lastTickTime,
    this.totalPrestiges = 0,
    this.totalWorkersPulled = 0,
    this.totalMerges = 0,
    this.unlockedAchievements = const {},
    this.tutorialStep = 0,
    this.lastDailyClaimTime,
    this.dailyLoginStreak = 0,
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
      unlockedEras: {'victorian'},
      completedEras: {},
      currentEraId: 'victorian',
      techLevels: {},
      eraHires: {},
      lastSaveTime: DateTime.now(),
      lastTickTime: DateTime.now(),
      totalMerges: 0,
      unlockedAchievements: {},
      tutorialStep: 0,
      lastDailyClaimTime: null,
      dailyLoginStreak: 0,
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
    DateTime? lastSaveTime,
    DateTime? lastTickTime,
    int? totalPrestiges,
    int? totalWorkersPulled,
    int? totalMerges,
    Set<String>? unlockedAchievements,
    int? tutorialStep,
    DateTime? lastDailyClaimTime,
    int? dailyLoginStreak,
  }) {
    return GameState(
      chronoEnergy: chronoEnergy ?? this.chronoEnergy,
      timeShards: timeShards ?? this.timeShards,
      lifetimeChronoEnergy: lifetimeChronoEnergy ?? this.lifetimeChronoEnergy,
      workers: workers ?? this.workers,
      stations: stations ?? this.stations,
      inventory: inventory ?? this.inventory,
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
      lastSaveTime: lastSaveTime ?? this.lastSaveTime,
      lastTickTime: lastTickTime ?? this.lastTickTime,
      totalPrestiges: totalPrestiges ?? this.totalPrestiges,
      totalWorkersPulled: totalWorkersPulled ?? this.totalWorkersPulled,
      totalMerges: totalMerges ?? this.totalMerges,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      tutorialStep: tutorialStep ?? this.tutorialStep,
      lastDailyClaimTime: lastDailyClaimTime ?? this.lastDailyClaimTime,
      dailyLoginStreak: dailyLoginStreak ?? this.dailyLoginStreak,
    );
  }

  // ===== COMPUTED PROPERTIES =====

  /// Get all active (deployed) workers
  List<Worker> get activeWorkers =>
      workers.values.where((w) => w.isDeployed).toList();

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

      final chronoMasteryLevel =
          paradoxPointsSpent[PrestigeUpgradeType.chronoMastery.id] ?? 0;
      if (chronoMasteryLevel > 0) {
        final bonus = 1.0 + (chronoMasteryLevel * 0.1);
        production =
            production * BigInt.from((bonus * 100).toInt()) ~/ BigInt.from(100);
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

    final riftStabilityLevel =
        paradoxPointsSpent[PrestigeUpgradeType.riftStability.id] ?? 0;
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

      // Chrono Mastery
      final chronoMasteryLevel =
          paradoxPointsSpent[PrestigeUpgradeType.chronoMastery.id] ?? 0;
      if (chronoMasteryLevel > 0) {
        final bonus = 1.0 + (chronoMasteryLevel * 0.1);
        production =
            production * BigInt.from((bonus * 100).toInt()) ~/ BigInt.from(100);
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
    final offlineBonusLevel =
        paradoxPointsSpent[PrestigeUpgradeType.temporalMemory.id] ?? 0;
    // Tech Upgrade (all offline techs: clockwork_arithmometer, radio_broadcast, etc.)
    final techMultiplier = TechData.calculateOfflineEfficiencyMultiplier(
      techLevels,
    );
    // TechData returns 1.0 + bonus, subtract 1.0 to get just the bonus portion
    return base + (offlineBonusLevel * 0.1) + (techMultiplier - 1.0);
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
    if (lifetimeChronoEnergy < BigInt.from(1000000)) return 0;
    final ratio = lifetimeChronoEnergy.toDouble() / 1000000.0;
    return ratio.isFinite ? ratio.toInt().clamp(0, 1000000) : 0;
  }

  /// Check if can prestige
  bool get canPrestige => lifetimeChronoEnergy >= BigInt.from(1000000);

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
      'lastSaveTime': lastSaveTime?.toIso8601String(),
      'lastTickTime': lastTickTime?.toIso8601String(),
      'totalPrestiges': totalPrestiges,
      'totalWorkersPulled': totalWorkersPulled,
      'totalMerges': totalMerges,
      'unlockedAchievements': unlockedAchievements.toList(),
      'tutorialStep': tutorialStep,
      'lastDailyClaimTime': lastDailyClaimTime?.toIso8601String(),
      'dailyLoginStreak': dailyLoginStreak,
    };
  }

  factory GameState.fromMap(Map<String, dynamic> map) {
    final parsedWorkers = (map['workers'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, Worker.fromMap(v as Map<String, dynamic>)),
    );

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
      paradoxLevel: (map['paradoxLevel'] as num).toDouble(),
      paradoxEventActive: map['paradoxEventActive'] ?? false,
      paradoxEventEndTime: map['paradoxEventEndTime'] != null
          ? DateTime.parse(map['paradoxEventEndTime'])
          : null,
      prestigeLevel: map['prestigeLevel'] ?? 0,
      paradoxPointsSpent: Map<String, int>.from(
        map['paradoxPointsSpent'] ?? {},
      ),
      availableParadoxPoints: map['availableParadoxPoints'] ?? 0,
      unlockedEras: Set<String>.from(map['unlockedEras'] ?? {'victorian'}),
      completedEras: Set<String>.from(map['completedEras'] ?? {}),
      currentEraId: map['currentEraId'] ?? 'victorian',
      techLevels: Map<String, int>.from(map['techLevels'] ?? {}),
      eraHires: Map<String, int>.from(map['eraHires'] ?? {}),
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
    );
  }
}
