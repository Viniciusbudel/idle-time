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
      // 1.0 - (1 * 0.03) = 0.97
      expect(
        TechData.calculateCostReductionMultiplier({'bessemer_process': 1}),
        0.97,
      );
      // 1.0 - (5 * 0.03) = 0.85
      expect(
        TechData.calculateCostReductionMultiplier({'bessemer_process': 5}),
        0.85,
      );
    });

    test('Station.getUpgradeCost applies discount correctly', () {
      final station = const Station(
        id: 'test',
        type: StationType.basicLoop,
        level: 1,
        gridX: 0,
        gridY: 0,
        workerIds: [],
      );

      // Base upgrade cost logic: 500 * (2.8 ^ level)
      // Level 1: 500 * 2.8 = 1400
      final baseCost = station.getUpgradeCost(discountMultiplier: 1.0);
      expect(baseCost, BigInt.from(1400));

      // With 50% discount
      final discountedCost = station.getUpgradeCost(discountMultiplier: 0.5);
      expect(discountedCost, BigInt.from(700));

      // With 10% discount (0.9 multiplier)
      final discountedCost2 = station.getUpgradeCost(discountMultiplier: 0.9);
      expect(discountedCost2, BigInt.from(1260)); // 1400 * 0.9 = 1260
    });
  });
}
