import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/entities/enums.dart';

void main() {
  group('Worker Production Scaling Tests', () {
    test(
      'Base Production at Level 1 should match rarity multipliers exactly',
      () {
        final victorianCommon = Worker(
          id: '1',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(10),
          rarity: WorkerRarity.common,
          level: 1,
        );

        final victorianRare = Worker(
          id: '2',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(10),
          rarity: WorkerRarity.rare,
          level: 1,
        );

        final victorianLegendary = Worker(
          id: '3',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(10),
          rarity: WorkerRarity.legendary,
          level: 1,
        );

        final victorianParadox = Worker(
          id: '4',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(10),
          rarity: WorkerRarity.paradox,
          level: 1,
        );

        // Common: 10 * 1.0 (growth) * 1.0 (victorian) * 1.0 (common) = 10
        expect(victorianCommon.currentProduction, BigInt.from(10));

        // Rare: 10 * 1.0 * 1.0 * 2.0 = 20
        expect(victorianRare.currentProduction, BigInt.from(20));

        // Legendary: 10 * 1.0 * 1.0 * 8.0 = 80
        expect(victorianLegendary.currentProduction, BigInt.from(80));

        // Paradox: 10 * 1.0 * 1.0 * 15.0 = 150
        expect(victorianParadox.currentProduction, BigInt.from(150));
      },
    );

    test('Production Growth at higher levels should vary by rarity', () {
      // Level 10 Common: 1 + (9 * 0.05) = 1.45x
      final commonLvl10 = Worker(
        id: 'c10',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(10),
        rarity: WorkerRarity.common,
        level: 10,
      );
      // 10 * 1.45 * 1 * 1 = 14.5 -> 15
      expect(commonLvl10.currentProduction, BigInt.from(15));

      // Level 10 Epic: 1 + (9 * 0.20) = 2.8x
      final epicLvl10 = Worker(
        id: 'e10',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(10),
        rarity: WorkerRarity.epic,
        level: 10,
      );
      // 10 * 2.8 * 1 * 4 = 112
      expect(epicLvl10.currentProduction, BigInt.from(112));

      // Level 10 Paradox: 1 + (9 * 0.60) = 6.4x
      final paradoxLvl10 = Worker(
        id: 'p10',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(10),
        rarity: WorkerRarity.paradox,
        level: 10,
      );
      // 10 * 6.4 * 1 * 15 = 960
      expect(paradoxLvl10.currentProduction, BigInt.from(960));
    });

    test('Roaring 20s Era Multiplier should apply on top of rarity', () {
      final roaringLegendary = Worker(
        id: 'rl1',
        era: WorkerEra.roaring20s,
        baseProduction: BigInt.from(10),
        rarity: WorkerRarity.legendary,
        level: 1,
      );

      // 10 * 1.0 * 2.0 (roaring) * 8.0 (legendary) = 160
      expect(roaringLegendary.currentProduction, BigInt.from(160));
    });
  });
}
