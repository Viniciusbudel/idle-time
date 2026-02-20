import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/core/constants/tech_data.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/enums.dart';

void main() {
  group('Upgrade Logic Verification', () {
    test('calculateCostReductionMultiplier returns correct values', () {
      // Base case (no tech)
      expect(TechData.calculateCostReductionMultiplier({}), 1.0);

      // Bessemer Process only
      // 1.0 - (1 * 0.05) = 0.95
      expect(
        TechData.calculateCostReductionMultiplier({'bessemer_process': 1}),
        0.95,
      );
      // 1.0 - (5 * 0.05) = 0.75
      expect(
        TechData.calculateCostReductionMultiplier({'bessemer_process': 5}),
        0.75,
      );
    });

    test('Station.getUpgradeCost applies discount correctly', () {
      final station = Station(
        id: 'test',
        type: StationType.basicLoop,
        level: 1,
        gridX: 0,
        gridY: 0,
        workerIds: [],
      );

      // Base upgrade cost logic: 500 * (2.0 ^ level)
      // Level 1: 500 * 2.0 = 1000
      final baseCost = station.getUpgradeCost(discountMultiplier: 1.0);
      expect(baseCost, BigInt.from(1000));

      // With 50% discount
      final discountedCost = station.getUpgradeCost(discountMultiplier: 0.5);
      expect(discountedCost, BigInt.from(500));

      // With 10% discount (0.9 multiplier)
      final discountedCost2 = station.getUpgradeCost(discountMultiplier: 0.9);
      expect(discountedCost2, BigInt.from(900)); // 1000 * 0.9 = 900
    });
  });
}
