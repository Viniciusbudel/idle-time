import 'package:time_factory/domain/entities/enums.dart';
import 'artifact_name_registry.dart';

/// Represents an equippable artifact that drops from Temporal Anomalies
class WorkerArtifact {
  final String id;
  final String name;
  final WorkerRarity rarity;
  final WorkerEra? eraMatch;
  final BigInt basePowerBonus;
  final double productionMultiplier; // e.g., 0.1 for +10%

  const WorkerArtifact({
    required this.id,
    required this.name,
    required this.rarity,
    this.eraMatch,
    required this.basePowerBonus,
    required this.productionMultiplier,
  });

  /// Create a powerful artifact based on rarity
  static WorkerArtifact generate(WorkerRarity rarity, WorkerEra currentEra) {
    final id = 'art_${DateTime.now().millisecondsSinceEpoch}';
    final String name = ArtifactNameRegistry.getName(rarity);
    BigInt basePower = BigInt.zero;
    double prodMult = 0.0;
    WorkerEra? eraMatch;

    switch (rarity) {
      case WorkerRarity.common:
        basePower = BigInt.from(1); // REBALANCED: 5 -> 2
        prodMult = 0.02; // REBALANCED: 0.0 -> 0.02
        break;
      case WorkerRarity.rare:
        basePower = BigInt.from(2); // REBALANCED: 25 -> 10
        prodMult = 0.05; // REBALANCED: 0.05
        break;
      case WorkerRarity.epic:
        basePower = BigInt.from(5); // REBALANCED: 100 -> 40
        prodMult = 0.08; // REBALANCED: 0.15 -> 0.08
        eraMatch = currentEra;
        break;
      case WorkerRarity.legendary:
        basePower = BigInt.from(10); // REBALANCED: 500 -> 150
        prodMult = 0.12; // REBALANCED: 0.30 -> 0.12
        eraMatch = currentEra;
        break;
      case WorkerRarity.paradox:
        basePower = BigInt.from(15); // REBALANCED: 2000 -> 500
        prodMult = 0.20; // REBALANCED: 1.0 (100%) -> 0.20 (20%)
        break;
    }

    return WorkerArtifact(
      id: id,
      name: name,
      rarity: rarity,
      eraMatch: eraMatch,
      basePowerBonus: basePower,
      productionMultiplier: prodMult,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rarity': rarity.id,
      'eraMatch': eraMatch?.id,
      'basePowerBonus': basePowerBonus.toString(),
      'productionMultiplier': productionMultiplier,
    };
  }

  factory WorkerArtifact.fromMap(Map<String, dynamic> map) {
    return WorkerArtifact(
      id: map['id'],
      name: map['name'],
      rarity: WorkerRarity.values.firstWhere((e) => e.id == map['rarity']),
      eraMatch: map['eraMatch'] != null
          ? WorkerEra.values.firstWhere((e) => e.id == map['eraMatch'])
          : null,
      basePowerBonus: BigInt.parse(map['basePowerBonus'].toString()),
      productionMultiplier: (map['productionMultiplier'] as num).toDouble(),
    );
  }

  /// Override equality
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkerArtifact &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
