import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/entities/worker_artifact.dart';
import 'package:time_factory/domain/entities/enums.dart';

void main() {
  group('Worker Production Scaling Tests', () {
    test(
      'Base Production should match rarity multipliers exactly with 1.0 attunement',
      () {
        final victorianCommon = Worker(
          id: '1',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(3), // Rarity-based base prod
          rarity: WorkerRarity.common,
          chronalAttunement: 1.0,
        );

        final victorianRare = Worker(
          id: '2',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(4), // Rarity-based base prod
          rarity: WorkerRarity.rare,
          chronalAttunement: 1.0,
        );

        final victorianLegendary = Worker(
          id: '3',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(15), // Rarity-based base prod
          rarity: WorkerRarity.legendary,
          chronalAttunement: 1.0,
        );

        final victorianParadox = Worker(
          id: '4',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(25), // Rarity-based base prod
          rarity: WorkerRarity.paradox,
          chronalAttunement: 1.0,
        );

        // Common: 3 * 1.0 (Attunement) * 1.0 (Victorian) * 1.0 (Common) = 3
        expect(victorianCommon.currentProduction, BigInt.from(3));

        // Rare: 4 * 1.0 * 1.0 * 3.5 = 14
        expect(victorianRare.currentProduction, BigInt.from(14));

        // Legendary: 15 * 1.0 * 1.0 * 15.0 = 225
        expect(victorianLegendary.currentProduction, BigInt.from(225));

        // Paradox: 25 * 1.0 * 1.0 * 40.0 = 1000
        expect(victorianParadox.currentProduction, BigInt.from(1000));
      },
    );

    test(
      'currentProduction with artifacts era-matching artifact grants +2% bonus',
      () {
        final artifact = WorkerArtifact(
          id: 'a1',
          name: 'test',
          rarity: WorkerRarity.common,
          eraMatch: WorkerEra.victorian,
          basePowerBonus: BigInt.from(2),
          productionMultiplier: 0.02,
        );

        final workerWithArtifact = Worker(
          id: 'w1',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(3), // Rarity-based base prod
          rarity: WorkerRarity.common,
          chronalAttunement: 1.0,
          equippedArtifacts: [artifact],
        );

        // Artifact: basePowerBonus = +2, productionMultiplier = 0.02
        // It matches era, so productionMultiplier bonus = +0.02
        // Worker base = 3
        // Total Base Power = 3 + 2 = 5
        // Base multiplier = 1.0 (Common) * 1.0 (Victorian) = 1.0
        // Artifact multiplier = 1.0 + 0.02 + 0.02 (era match) = 1.04
        // Final = 5 * 1.04 = 5.2 -> 5
        expect(workerWithArtifact.currentProduction, BigInt.from(5));
      },
    );

    test('Chronal Attunement should scale production accurately', () {
      // 1.15x Attunement Common
      final giftedCommon = Worker(
        id: 'c115',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(100),
        rarity: WorkerRarity.common,
        chronalAttunement: 1.15,
      );
      // 100 * 1.15 * 1 * 1 = 115
      expect(giftedCommon.currentProduction, BigInt.from(115));

      // 0.85x Attunement Epic
      final clumsyEpic = Worker(
        id: 'e85',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(100),
        rarity: WorkerRarity.epic,
        chronalAttunement: 0.85,
      );
      // 100 * 0.85 * 1 * 7 = 595
      expect(clumsyEpic.currentProduction, BigInt.from(595));
    });

    test(
      'Roaring 20s Era Multiplier should apply on top of rarity and attunement',
      () {
        final roaringLegendary = Worker(
          id: 'rl1',
          era: WorkerEra.roaring20s,
          baseProduction: BigInt.from(15), // Legendary base
          rarity: WorkerRarity.legendary,
          chronalAttunement: 1.1,
        );

        // 15 * 1.1 (attunement) * 2.0 (roaring) * 15.0 (legendary) = 495
        expect(roaringLegendary.currentProduction, BigInt.from(495));
      },
    );
  });
}
