import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/worker_artifact.dart';

void main() {
  group('Worker Production Scaling Tests (Artifacts)', () {
    test(
      'Base Production without artifacts should match rarity multipliers exactly',
      () {
        final victorianCommon = Worker(
          id: '1',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(10),
          rarity: WorkerRarity.common,
        );

        final victorianRare = Worker(
          id: '2',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(10),
          rarity: WorkerRarity.rare,
        );

        final victorianLegendary = Worker(
          id: '3',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(10),
          rarity: WorkerRarity.legendary,
        );

        final victorianParadox = Worker(
          id: '4',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(10),
          rarity: WorkerRarity.paradox,
        );

        // Common: 10 * 1.0 (multiplier) * 1.0 (victorian) * 1.0 (common) = 10
        expect(victorianCommon.currentProduction, BigInt.from(10));

        // Rare: 10 * 1.0 * 1.0 * 2.0 = 20
        expect(victorianRare.currentProduction, BigInt.from(20));

        // Legendary: 10 * 1.0 * 1.0 * 8.0 = 80
        expect(victorianLegendary.currentProduction, BigInt.from(80));

        // Paradox: 10 * 1.0 * 1.0 * 15.0 = 150
        expect(victorianParadox.currentProduction, BigInt.from(150));
      },
    );

    test('Equipping Artifacts should increase Base Power and Multiplier', () {
      final worker = Worker(
        id: '10',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(10),
        rarity: WorkerRarity.common,
      );

      final artifact1 = WorkerArtifact(
        id: 'art1',
        name: 'Test Artifact',
        rarity: WorkerRarity.rare,
        basePowerBonus: BigInt.from(20), // 10 + 20 = 30 base power
        productionMultiplier: 0.50, // 1.0 + 0.5 = 1.5x multiplier
      );

      final equippedWorker = worker.copyWith(equippedArtifacts: [artifact1]);

      // Total = (10 + 20) * (1.0 + 0.5) * 1.0 (era) * 1.0 (rarity) = 30 * 1.5 = 45
      expect(equippedWorker.currentProduction, BigInt.from(45));
    });

    test('Era Match Artifact Bonus should apply distinct 10% bonus', () {
      final worker = Worker(
        id: '11',
        era: WorkerEra.roaring20s,
        baseProduction: BigInt.from(100),
        rarity: WorkerRarity.common,
      );

      // Exact era match gives +0.1 to artifact multiplier
      final artifact = WorkerArtifact(
        id: 'art2',
        name: 'Era Matched Artifact',
        rarity: WorkerRarity.epic,
        basePowerBonus: BigInt.zero, // Base stays 100
        productionMultiplier:
            0.20, // Base mult = 1.0 + 0.20 + 0.10 (era match bonus) = 1.3
        eraMatch: WorkerEra.roaring20s,
      );

      final equippedWorker = worker.copyWith(equippedArtifacts: [artifact]);

      // Total = 100 * 1.3 (artifact mult) * 2.0 (roaring20s mult) = 260
      expect(equippedWorker.currentProduction, BigInt.from(260));
    });

    test(
      'Roaring 20s Era Multiplier should apply on top of rarity and artifacts',
      () {
        final roaringLegendary = Worker(
          id: 'rl1',
          era: WorkerEra.roaring20s,
          baseProduction: BigInt.from(10),
          rarity: WorkerRarity.legendary,
        );

        // 10 * 1.0 * 2.0 (roaring) * 8.0 (legendary) = 160
        expect(roaringLegendary.currentProduction, BigInt.from(160));
      },
    );
  });
}
