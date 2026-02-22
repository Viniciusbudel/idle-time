import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/core/constants/game_constants.dart';

void main() {
  group('GameConstants era progression', () {
    test('getNextEraId follows the configured era order', () {
      for (var i = 0; i < GameConstants.eraOrder.length - 1; i++) {
        final current = GameConstants.eraOrder[i];
        final expectedNext = GameConstants.eraOrder[i + 1];
        expect(GameConstants.getNextEraId(current), expectedNext);
      }
    });

    test('getNextEraId returns null for final or unknown era', () {
      expect(GameConstants.getNextEraId('far_future'), isNull);
      expect(GameConstants.getNextEraId('unknown_era'), isNull);
    });

    test('all configured era unlock costs parse as non-negative BigInt', () {
      for (final eraId in GameConstants.eraOrder) {
        final cost = GameConstants.getEraUnlockCost(eraId);
        expect(cost, isNotNull, reason: 'Missing cost for era: $eraId');
        expect(
          cost! >= BigInt.zero,
          isTrue,
          reason: 'Negative cost for $eraId',
        );
      }
    });

    test('far future unlock cost is greater than ancient rome cost', () {
      final ancientRomeCost = GameConstants.getEraUnlockCost('ancient_rome')!;
      final farFutureCost = GameConstants.getEraUnlockCost('far_future')!;
      expect(farFutureCost > ancientRomeCost, isTrue);
    });
  });
}
