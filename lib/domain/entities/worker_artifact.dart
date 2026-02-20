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
        basePower = BigInt.from(5);
        break;
      case WorkerRarity.rare:
        basePower = BigInt.from(25);
        prodMult = 0.05;
        break;
      case WorkerRarity.epic:
        basePower = BigInt.from(100);
        prodMult = 0.15;
        eraMatch = currentEra;
        break;
      case WorkerRarity.legendary:
        basePower = BigInt.from(500);
        prodMult = 0.30;
        eraMatch = currentEra;
        break;
      case WorkerRarity.paradox:
        basePower = BigInt.from(2000);
        prodMult = 1.0; // +100%
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
