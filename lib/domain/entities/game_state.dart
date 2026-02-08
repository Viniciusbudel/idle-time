import 'enums.dart';
import 'worker.dart';
import 'station.dart';

/// Main game state containing all player progress
class GameState {
  final BigInt chronoEnergy;
  final int timeShards;
  final BigInt lifetimeChronoEnergy;
  final Map<String, Worker> workers;
  final Map<String, Station> stations;
  final double paradoxLevel;
  final bool paradoxEventActive;
  final DateTime? paradoxEventEndTime;
  final int prestigeLevel;
  final Map<String, int> paradoxPointsSpent;
  final int availableParadoxPoints;
  final Set<String> unlockedEras;
  final String currentEraId; // Track the currently active era
  final Map<String, int> techLevels; // NEW: Track tech ID -> Level
  final DateTime? lastSaveTime;
  final DateTime? lastTickTime;
  final int totalPrestiges;
  final int totalWorkersPulled;

  const GameState({
    required this.chronoEnergy,
    this.timeShards = 0,
    required this.lifetimeChronoEnergy,
    this.workers = const {},
    this.stations = const {},
    this.paradoxLevel = 0.0,
    this.paradoxEventActive = false,
    this.paradoxEventEndTime,
    this.prestigeLevel = 0,
    this.paradoxPointsSpent = const {},
    this.availableParadoxPoints = 0,
    this.unlockedEras = const {'victorian'},
    this.currentEraId = 'victorian',
    this.techLevels = const {}, // Default empty
    this.lastSaveTime,
    this.lastTickTime,
    this.totalPrestiges = 0,
    this.totalWorkersPulled = 0,
  });

  /// Initial game state for new players
  factory GameState.initial() {
    // ... (existing starter code) ...
    // Create starter station
    const starterId = 'starter';
    final starterStation = Station(
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
      level: 1,
      baseProduction: BigInt.from(1),
      rarity: WorkerRarity.common,
      name: 'Victoria',
      isDeployed: true,
      deployedStationId: 'station_$starterId',
    );

    return GameState(
      chronoEnergy: BigInt.zero,
      timeShards: 100,
      lifetimeChronoEnergy: BigInt.zero,
      workers: {'worker_$starterId': starterWorker},
      stations: {'station_$starterId': starterStation},
      unlockedEras: {'victorian'},
      currentEraId: 'victorian',
      techLevels: {}, // Initial empty
      lastSaveTime: DateTime.now(),
      lastTickTime: DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  GameState copyWith({
    BigInt? chronoEnergy,
    int? timeShards,
    BigInt? lifetimeChronoEnergy,
    Map<String, Worker>? workers,
    Map<String, Station>? stations,
    double? paradoxLevel,
    bool? paradoxEventActive,
    DateTime? paradoxEventEndTime,
    int? prestigeLevel,
    Map<String, int>? paradoxPointsSpent,
    int? availableParadoxPoints,
    Set<String>? unlockedEras,
    String? currentEraId,
    Map<String, int>? techLevels, // NEW
    DateTime? lastSaveTime,
    DateTime? lastTickTime,
    int? totalPrestiges,
    int? totalWorkersPulled,
  }) {
    return GameState(
      chronoEnergy: chronoEnergy ?? this.chronoEnergy,
      timeShards: timeShards ?? this.timeShards,
      lifetimeChronoEnergy: lifetimeChronoEnergy ?? this.lifetimeChronoEnergy,
      workers: workers ?? this.workers,
      stations: stations ?? this.stations,
      paradoxLevel: paradoxLevel ?? this.paradoxLevel,
      paradoxEventActive: paradoxEventActive ?? this.paradoxEventActive,
      paradoxEventEndTime: paradoxEventEndTime ?? this.paradoxEventEndTime,
      prestigeLevel: prestigeLevel ?? this.prestigeLevel,
      paradoxPointsSpent: paradoxPointsSpent ?? this.paradoxPointsSpent,
      availableParadoxPoints:
          availableParadoxPoints ?? this.availableParadoxPoints,
      unlockedEras: unlockedEras ?? this.unlockedEras,
      currentEraId: currentEraId ?? this.currentEraId,
      techLevels: techLevels ?? this.techLevels, // NEW
      lastSaveTime: lastSaveTime ?? this.lastSaveTime,
      lastTickTime: lastTickTime ?? this.lastTickTime,
      totalPrestiges: totalPrestiges ?? this.totalPrestiges,
      totalWorkersPulled: totalWorkersPulled ?? this.totalWorkersPulled,
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

      final chronoMasteryLevel = paradoxPointsSpent['chrono_mastery'] ?? 0;
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

    final riftStabilityLevel = paradoxPointsSpent['rift_stability'] ?? 0;
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
      final chronoMasteryLevel = paradoxPointsSpent['chrono_mastery'] ?? 0;
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
    const base = 0.7;
    final offlineBonusLevel = paradoxPointsSpent['offline_bonus'] ?? 0;
    return base + (offlineBonusLevel * 0.1);
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

  Map<String, dynamic> toMap() {
    return {
      'chronoEnergy': chronoEnergy.toString(),
      'timeShards': timeShards,
      'lifetimeChronoEnergy': lifetimeChronoEnergy.toString(),
      'workers': workers.map((k, v) => MapEntry(k, v.toMap())),
      'stations': stations.map((k, v) => MapEntry(k, v.toMap())),
      'paradoxLevel': paradoxLevel,
      'paradoxEventActive': paradoxEventActive,
      'paradoxEventEndTime': paradoxEventEndTime?.toIso8601String(),
      'prestigeLevel': prestigeLevel,
      'paradoxPointsSpent': paradoxPointsSpent,
      'availableParadoxPoints': availableParadoxPoints,
      'unlockedEras': unlockedEras.toList(),
      'currentEraId': currentEraId,
      'techLevels': techLevels,
      'lastSaveTime': lastSaveTime?.toIso8601String(),
      'lastTickTime': lastTickTime?.toIso8601String(),
      'totalPrestiges': totalPrestiges,
      'totalWorkersPulled': totalWorkersPulled,
    };
  }

  factory GameState.fromMap(Map<String, dynamic> map) {
    return GameState(
      chronoEnergy: BigInt.parse(map['chronoEnergy']),
      timeShards: map['timeShards'] ?? 0,
      lifetimeChronoEnergy: BigInt.parse(map['lifetimeChronoEnergy']),
      workers: (map['workers'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, Worker.fromMap(v as Map<String, dynamic>)),
      ),
      stations: (map['stations'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, Station.fromMap(v as Map<String, dynamic>)),
      ),
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
      currentEraId: map['currentEraId'] ?? 'victorian',
      techLevels: Map<String, int>.from(map['techLevels'] ?? {}),
      lastSaveTime: map['lastSaveTime'] != null
          ? DateTime.parse(map['lastSaveTime'])
          : null,
      lastTickTime: map['lastTickTime'] != null
          ? DateTime.parse(map['lastTickTime'])
          : null,
      totalPrestiges: map['totalPrestiges'] ?? 0,
      totalWorkersPulled: map['totalWorkersPulled'] ?? 0,
    );
  }
}
