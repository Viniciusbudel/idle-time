import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/entities/enums.dart';

void main() {
  group('Worker Production Scaling Tests', () {
    test(
      'Base Production should match rarity multipliers exactly with 1.0 attunement',
      () {
        final victorianCommon = Worker(
          id: '1',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(10),
          rarity: WorkerRarity.common,
          chronalAttunement: 1.0,
        );

        final victorianRare = Worker(
          id: '2',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(10),
          rarity: WorkerRarity.rare,
          chronalAttunement: 1.0,
        );

        final victorianLegendary = Worker(
          id: '3',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(10),
          rarity: WorkerRarity.legendary,
          chronalAttunement: 1.0,
        );

        final victorianParadox = Worker(
          id: '4',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(10),
          rarity: WorkerRarity.paradox,
          chronalAttunement: 1.0,
        );

        // Common: 10 * 1.0 (Attunement) * 1.0 (Victorian) * 1.0 (Common) = 10
        expect(victorianCommon.currentProduction, BigInt.from(10));

        // Rare: 10 * 1.0 * 1.0 * 2.0 = 20
        expect(victorianRare.currentProduction, BigInt.from(20));

        // Legendary: 10 * 1.0 * 1.0 * 8.0 = 80
        expect(victorianLegendary.currentProduction, BigInt.from(80));

        // Paradox: 10 * 1.0 * 1.0 * 15.0 = 150
        expect(victorianParadox.currentProduction, BigInt.from(150));
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
      // 100 * 0.85 * 1 * 4 = 340
      expect(clumsyEpic.currentProduction, BigInt.from(340));
    });

    test(
      'Roaring 20s Era Multiplier should apply on top of rarity and attunement',
      () {
        final roaringLegendary = Worker(
          id: 'rl1',
          era: WorkerEra.roaring20s,
          baseProduction: BigInt.from(10),
          rarity: WorkerRarity.legendary,
          chronalAttunement: 1.1,
        );

        // 10 * 1.1 (attunement) * 2.0 (roaring) * 8.0 (legendary) = 176
        expect(roaringLegendary.currentProduction, BigInt.from(176));
      },
    );
  });
}
