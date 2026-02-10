import 'enums.dart';
import 'worker_name_registry.dart';

/// Represents a temporal worker from a specific era
class Worker {
  final String id;
  final WorkerEra era;
  final int level;
  final BigInt baseProduction;
  final WorkerRarity rarity;
  final String? name;
  final String? specialAbility;
  final bool isDeployed;
  final String? deployedStationId;

  const Worker({
    required this.id,
    required this.era,
    this.level = 1,
    required this.baseProduction,
    this.rarity = WorkerRarity.common,
    this.name,
    this.specialAbility,
    this.isDeployed = false,
    this.deployedStationId,
  });

  /// Create a copy with updated fields
  Worker copyWith({
    String? id,
    WorkerEra? era,
    int? level,
    BigInt? baseProduction,
    WorkerRarity? rarity,
    String? name,
    String? specialAbility,
    bool? isDeployed,
    String? deployedStationId,
  }) {
    return Worker(
      id: id ?? this.id,
      era: era ?? this.era,
      level: level ?? this.level,
      baseProduction: baseProduction ?? this.baseProduction,
      rarity: rarity ?? this.rarity,
      name: name ?? this.name,
      specialAbility: specialAbility ?? this.specialAbility,
      isDeployed: isDeployed ?? this.isDeployed,
      deployedStationId: deployedStationId,
    );
  }

  /// Calculate current production rate
  BigInt get currentProduction {
    // 1. Determine level growth and multiplier based on Rarity
    double growthPerLevel;
    switch (rarity) {
      case WorkerRarity.common:
        growthPerLevel = 0.05;
        break;
      case WorkerRarity.rare:
        growthPerLevel = 0.10;
        break;
      case WorkerRarity.epic:
        growthPerLevel = 0.20;
        break;
      case WorkerRarity.legendary:
        growthPerLevel = 0.35;
        break;
      case WorkerRarity.paradox:
        growthPerLevel = 0.60;
        break;
    }

    // multiplier = 1.0 + (level - 1) * growth
    final levelGrowthMultiplier = 1.0 + (level - 1) * growthPerLevel;

    // Total = base × levelGrowthMultiplier × eraMultiplier × rarityMultiplier
    final baseValue = baseProduction.toDouble();
    final eraMult = era.multiplier;
    final rarityMult = rarity.productionMultiplier;

    final total = baseValue * levelGrowthMultiplier * eraMult * rarityMult;

    return BigInt.from(total.round());
  }

  /// Calculate upgrade cost
  BigInt get upgradeCost {
    final baseCost = BigInt.from(50);
    final multiplier = BigInt.from((1.2 * 100).toInt());
    BigInt cost = baseCost;

    for (int i = 0; i < level; i++) {
      cost = cost * multiplier ~/ BigInt.from(100);
    }

    return cost;
  }

  /// Get display name
  String get displayName => name ?? '${era.displayName} Worker';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'era': era.id,
      'level': level,
      'baseProduction': baseProduction.toString(),
      'rarity': rarity.id,
      'name': name,
      'specialAbility': specialAbility,
      'isDeployed': isDeployed,
      'deployedStationId': deployedStationId,
    };
  }

  factory Worker.fromMap(Map<String, dynamic> map) {
    return Worker(
      id: map['id'],
      era: WorkerEra.values.firstWhere((e) => e.id == map['era']),
      level: map['level'],
      baseProduction: BigInt.parse(map['baseProduction']),
      rarity: WorkerRarity.values.firstWhere((e) => e.id == map['rarity']),
      name: map['name'],
      specialAbility: map['specialAbility'],
      isDeployed: map['isDeployed'] ?? false,
      deployedStationId: map['deployedStationId'],
    );
  }
}

/// Factory methods for creating workers
class WorkerFactory {
  WorkerFactory._();

  static int _idCounter = 0;

  /// Create a new worker of specified era and rarity
  static Worker create({
    required WorkerEra era,
    WorkerRarity rarity = WorkerRarity.common,
    String? name,
    String? specialAbility,
  }) {
    _idCounter++;
    return Worker(
      id: 'worker_${_idCounter}_${DateTime.now().millisecondsSinceEpoch}',
      era: era,
      baseProduction: BigInt.from(10), // Unified base production
      rarity: rarity,
      name: name ?? WorkerNameRegistry.getName(era, rarity),
      specialAbility: specialAbility,
    );
  }

  /// Create a random worker from a gacha pull
  static Worker createRandom({required List<WorkerEra> unlockedEras}) {
    if (unlockedEras.isEmpty) {
      unlockedEras = [WorkerEra.victorian];
    }

    // Random era from unlocked
    final era =
        unlockedEras[DateTime.now().millisecondsSinceEpoch %
            unlockedEras.length];

    // Random rarity based on drop rates
    final roll = (DateTime.now().microsecondsSinceEpoch % 1000) / 1000.0;
    WorkerRarity rarity;
    if (roll < 0.001) {
      rarity = WorkerRarity.paradox;
    } else if (roll < 0.03) {
      rarity = WorkerRarity.legendary;
    } else if (roll < 0.15) {
      rarity = WorkerRarity.epic;
    } else if (roll < 0.40) {
      rarity = WorkerRarity.rare;
    } else {
      rarity = WorkerRarity.common;
    }

    return create(era: era, rarity: rarity);
  }
}
