import 'enums.dart';
import 'worker_name_registry.dart';
import 'worker_artifact.dart'; // IMPORT ARTIFACTS
import 'dart:math';

/// Represents a temporal worker from a specific era
class Worker {
  static const Object _copyWithUnset = Object();

  final String id;
  final WorkerEra era;
  final BigInt baseProduction;
  final WorkerRarity rarity;
  final String? name;
  final String? specialAbility;
  final bool isDeployed;
  final String? deployedStationId;
  final List<WorkerArtifact> equippedArtifacts;
  final double chronalAttunement;

  const Worker({
    required this.id,
    required this.era,
    required this.baseProduction,
    this.rarity = WorkerRarity.common,
    this.name,
    this.specialAbility,
    this.isDeployed = false,
    this.deployedStationId,
    this.equippedArtifacts = const [],
    this.chronalAttunement = 1.0,
  });

  /// Create a copy with updated fields
  Worker copyWith({
    String? id,
    WorkerEra? era,
    BigInt? baseProduction,
    WorkerRarity? rarity,
    String? name,
    String? specialAbility,
    bool? isDeployed,
    Object? deployedStationId = _copyWithUnset,
    List<WorkerArtifact>? equippedArtifacts,
    double? chronalAttunement,
  }) {
    return Worker(
      id: id ?? this.id,
      era: era ?? this.era,
      baseProduction: baseProduction ?? this.baseProduction,
      rarity: rarity ?? this.rarity,
      name: name ?? this.name,
      specialAbility: specialAbility ?? this.specialAbility,
      isDeployed: isDeployed ?? this.isDeployed,
      deployedStationId: identical(deployedStationId, _copyWithUnset)
          ? this.deployedStationId
          : deployedStationId as String?,
      equippedArtifacts: equippedArtifacts ?? this.equippedArtifacts,
      chronalAttunement: chronalAttunement ?? this.chronalAttunement,
    );
  }

  /// Number of artifact slots based on rarity
  int get maxArtifactSlots {
    switch (rarity) {
      case WorkerRarity.common:
        return 0;
      case WorkerRarity.rare:
        return 1;
      case WorkerRarity.epic:
        return 2;
      case WorkerRarity.legendary:
        return 3;
      case WorkerRarity.paradox:
        return 5;
    }
  }

  /// Check if the worker can equip another artifact
  bool get canEquipArtifact => equippedArtifacts.length < maxArtifactSlots;

  /// Get the base power (flat sum: base + artifact bonuses) * individual attunement
  double get totalBasePower {
    double total = baseProduction.toDouble();
    for (var artifact in equippedArtifacts) {
      total += artifact.basePowerBonus.toDouble();
    }
    return total * chronalAttunement;
  }

  /// Get the total multiplier (Era * Rarity * Artifact Mults)
  double get totalMultiplier {
    double artifactMult = 1.0;
    for (var artifact in equippedArtifacts) {
      artifactMult += artifact.productionMultiplier;
      if (artifact.eraMatch == era) {
        artifactMult += 0.02; // REBALANCED: +10% -> +2%
      }
    }
    return artifactMult * era.multiplier * rarity.productionMultiplier;
  }

  /// Calculate current production rate based on base stats + artifacts
  BigInt get currentProduction {
    final total = totalBasePower * totalMultiplier;
    return BigInt.from(total.round());
  }

  /// Get display name
  String get displayName => name ?? '${era.displayName} Worker';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'era': era.id,
      'baseProduction': baseProduction.toString(),
      'rarity': rarity.id,
      'name': name,
      'specialAbility': specialAbility,
      'isDeployed': isDeployed,
      'deployedStationId': deployedStationId,
      'equippedArtifacts': equippedArtifacts.map((e) => e.toMap()).toList(),
      'chronalAttunement': chronalAttunement,
    };
  }

  factory Worker.fromMap(Map<String, dynamic> map) {
    return Worker(
      id: map['id'],
      era: WorkerEra.values.firstWhere((e) => e.id == map['era']),
      baseProduction: BigInt.parse(map['baseProduction']),
      rarity: WorkerRarity.values.firstWhere((e) => e.id == map['rarity']),
      name: map['name'],
      specialAbility: map['specialAbility'],
      isDeployed: map['isDeployed'] ?? false,
      deployedStationId: map['deployedStationId'],
      equippedArtifacts:
          (map['equippedArtifacts'] as List<dynamic>?)
              ?.map((e) => WorkerArtifact.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      chronalAttunement: (map['chronalAttunement'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

/// Factory methods for creating workers
class WorkerFactory {
  WorkerFactory._();

  static int _idCounter = 0;
  static final _random = Random();

  /// Rarity weights (higher = more common) - REBALANCED
  /// Common: 55%, Rare: 30%, Epic: 12%, Legendary: 2.5%, Paradox: 0.5%
  static const Map<WorkerRarity, double> rarityWeights = {
    WorkerRarity.common: 55.0,
    WorkerRarity.rare: 31.0,
    WorkerRarity.epic: 12.0,
    WorkerRarity.legendary: 1.8,
    WorkerRarity.paradox: 0.2,
  };

  /// Roll for rarity using weighted random.
  /// [luckFactor] softly shifts weight away from common rarity.
  static WorkerRarity rollRarity({double luckFactor = 0.0}) {
    final adjustedWeights = Map<WorkerRarity, double>.from(rarityWeights);
    final clampedLuck = luckFactor.clamp(0.0, 0.6);

    if (clampedLuck > 0) {
      final commonWeight = adjustedWeights[WorkerRarity.common] ?? 0.0;
      final redistribution = commonWeight * (clampedLuck * 0.55);

      adjustedWeights[WorkerRarity.common] = commonWeight - redistribution;
      adjustedWeights[WorkerRarity.rare] =
          (adjustedWeights[WorkerRarity.rare] ?? 0.0) + (redistribution * 0.52);
      adjustedWeights[WorkerRarity.epic] =
          (adjustedWeights[WorkerRarity.epic] ?? 0.0) + (redistribution * 0.30);
      adjustedWeights[WorkerRarity.legendary] =
          (adjustedWeights[WorkerRarity.legendary] ?? 0.0) +
          (redistribution * 0.13);
      adjustedWeights[WorkerRarity.paradox] =
          (adjustedWeights[WorkerRarity.paradox] ?? 0.0) +
          (redistribution * 0.05);
    }

    final totalWeight = adjustedWeights.values.fold(0.0, (a, b) => a + b);
    double roll = _random.nextDouble() * totalWeight;

    for (final entry in adjustedWeights.entries) {
      roll -= entry.value;
      if (roll <= 0) {
        return entry.key;
      }
    }
    return WorkerRarity.common;
  }

  /// Create a new worker of specified era and rarity
  static Worker create({
    required WorkerEra era,
    WorkerRarity rarity = WorkerRarity.common,
    String? name,
    String? specialAbility,
    double? chronalAttunement,
  }) {
    _idCounter++;
    // Roll attunement if not provided (0.85 to 1.15)
    final rolledAttunement =
        chronalAttunement ?? (0.85 + (_random.nextDouble() * 0.3));

    // Base production scales with rarity to reward merging
    BigInt baseProd = BigInt.from(3);
    switch (rarity) {
      case WorkerRarity.rare:
        baseProd = BigInt.from(4);
        break;
      case WorkerRarity.epic:
        baseProd = BigInt.from(7);
        break;
      case WorkerRarity.legendary:
        baseProd = BigInt.from(15);
        break;
      case WorkerRarity.paradox:
        baseProd = BigInt.from(25);
        break;
      default:
        baseProd = BigInt.from(3);
    }

    return Worker(
      id: 'worker_${_idCounter}_${DateTime.now().millisecondsSinceEpoch}',
      era: era,
      baseProduction: baseProd, // REBALANCED: Scales with rarity
      rarity: rarity,
      name: name ?? WorkerNameRegistry.getName(era, rarity),
      specialAbility: specialAbility,
      chronalAttunement: rolledAttunement,
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
