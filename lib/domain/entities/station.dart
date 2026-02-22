import 'enums.dart';

/// Represents a temporal station in the factory grid
class Station {
  final String id;
  final StationType type;
  final int level;
  final int gridX;
  final int gridY;
  final List<String> workerIds;

  const Station({
    required this.id,
    required this.type,
    this.level = 1,
    required this.gridX,
    required this.gridY,
    this.workerIds = const [],
  });

  String get name => type.displayName;

  /// Create a copy with updated fields
  Station copyWith({
    String? id,
    StationType? type,
    int? level,
    int? gridX,
    int? gridY,
    List<String>? workerIds,
  }) {
    return Station(
      id: id ?? this.id,
      type: type ?? this.type,
      level: level ?? this.level,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      workerIds: workerIds ?? this.workerIds,
    );
  }

  /// Number of worker slots available
  /// Base slots + 1 per additional level, capped per station type
  int get maxWorkerSlots {
    final cap = type.maxSlotsCap;
    final slots = type.workerSlots + (level - 1);
    return slots.clamp(1, cap);
  }

  /// Check if station can accept more workers
  bool get canAddWorker => workerIds.length < maxWorkerSlots;

  /// Production bonus from this station - PHASE 2: All bonuses halved
  double get productionBonus {
    switch (type) {
      case StationType.basicLoop:
        return 1.0 + (level - 1) * 0.05; // NERFED from 0.1
      case StationType.dualHelix:
        return 1.2 + (level - 1) * 0.075; // NERFED from 0.15
      case StationType.nuclearReactor:
        return 1.5 + (level - 1) * 0.1;
      case StationType.paradoxAmplifier:
        return 0.0;
      case StationType.timeDistortion:
        return 2.0 + (level - 1) * 0.125; // NERFED from 0.25
      case StationType.dataNode:
        return 2.5 + (level - 1) * 0.15;
      case StationType.synthLab:
        return 3.5 + (level - 1) * 0.20;
      case StationType.neonCore:
        return 5.0 + (level - 1) * 0.25;
      case StationType.riftGenerator:
        return 8.0 + (level - 1) * 0.5; // Re-scaled to NeoTokyo
    }
  }

  /// Adjacency bonus multiplier
  double get adjacencyBonus {
    switch (type) {
      case StationType.paradoxAmplifier:
        return 0.5 * level;
      default:
        return 0.0;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.id,
      'level': level,
      'gridX': gridX,
      'gridY': gridY,
      'workerIds': workerIds,
    };
  }

  factory Station.fromMap(Map<String, dynamic> map) {
    return Station(
      id: map['id'],
      type: StationType.values.firstWhere((e) => e.id == map['type']),
      level: map['level'],
      gridX: map['gridX'],
      gridY: map['gridY'],
      workerIds: List<String>.from(map['workerIds']),
    );
  }

  /// Upgrade cost with optional discount
  /// REBALANCED: Growth changed from 2.0 to 2.8 per level
  BigInt getUpgradeCost({double discountMultiplier = 1.0}) {
    final baseCost = _getBaseCost();
    final multiplier = BigInt.from(
      (2.8 * 100).toInt(),
    ); // CHANGED from 2.0 to 2.8
    BigInt cost = baseCost;

    for (int i = 0; i < level; i++) {
      cost = cost * multiplier ~/ BigInt.from(100);
    }

    if (discountMultiplier < 1.0) {
      final discount = BigInt.from((discountMultiplier * 100).toInt());
      cost = cost * discount ~/ BigInt.from(100);
    }

    return cost;
  }

  BigInt _getBaseCost() {
    switch (type) {
      case StationType.basicLoop:
        return BigInt.from(500);
      case StationType.dualHelix:
        return BigInt.from(2000);
      case StationType.nuclearReactor:
        return BigInt.from(3500);
      case StationType.paradoxAmplifier:
        return BigInt.from(5000);
      case StationType.timeDistortion:
        return BigInt.from(10000);
      case StationType.dataNode:
        return BigInt.from(40000);
      case StationType.synthLab:
        return BigInt.from(150000);
      case StationType.neonCore:
        return BigInt.from(500000);
      case StationType.riftGenerator:
        return BigInt.from(2000000);
    }
  }

  /// Paradox rate contribution
  double get paradoxRate {
    switch (type) {
      case StationType.riftGenerator:
        return 0.005 * level;
      case StationType.neonCore:
        return 0.003 * level;
      case StationType.synthLab:
        return 0.002 * level;
      case StationType.dataNode:
      case StationType.timeDistortion:
        return 0.001 * level;
      default:
        return 0.0005 * level;
    }
  }
}

/// Factory methods for creating stations
class StationFactory {
  StationFactory._();

  static int _idCounter = 0;

  /// Create a new station
  static Station create({
    required StationType type,
    required int gridX,
    required int gridY,
  }) {
    _idCounter++;
    return Station(
      id: 'station_${_idCounter}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      gridX: gridX,
      gridY: gridY,
    );
  }

  /// Get purchase cost for a station type
  static BigInt getPurchaseCost(
    StationType type,
    int ownedCount, {
    double discountMultiplier = 1.0,
  }) {
    BigInt baseCost;
    switch (type) {
      case StationType.basicLoop:
        baseCost = BigInt.from(500);
      case StationType.dualHelix:
        baseCost = BigInt.from(2000);
      case StationType.nuclearReactor:
        baseCost = BigInt.from(3500);
      case StationType.paradoxAmplifier:
        baseCost = BigInt.from(5000);
      case StationType.timeDistortion:
        baseCost = BigInt.from(10000);
      case StationType.dataNode:
        baseCost = BigInt.from(40000);
      case StationType.synthLab:
        baseCost = BigInt.from(150000);
      case StationType.neonCore:
        baseCost = BigInt.from(500000);
      case StationType.riftGenerator:
        baseCost = BigInt.from(2000000);
    }

    final multiplier = BigInt.from((1.8 * 100).toInt());
    for (int i = 0; i < ownedCount; i++) {
      baseCost = baseCost * multiplier ~/ BigInt.from(100);
    }

    // Apply discount
    if (discountMultiplier < 1.0) {
      final discount = BigInt.from((discountMultiplier * 100).toInt());
      baseCost = baseCost * discount ~/ BigInt.from(100);
    }

    return baseCost;
  }
}
