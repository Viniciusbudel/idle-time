import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/core/constants/era_mastery_constants.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/worker.dart';

int _totalXpForLevel(int level) {
  var total = 0;
  for (var current = 1; current <= level; current++) {
    total += EraMasteryConstants.xpRequiredForLevel(current);
  }
  return total;
}

void main() {
  group('GameState era mastery', () {
    test('productionPerSecond applies era mastery multiplier', () {
      final worker = Worker(
        id: 'worker_1',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(100),
        rarity: WorkerRarity.common,
        isDeployed: true,
        deployedStationId: 'station_1',
      );
      const station = Station(
        id: 'station_1',
        type: StationType.basicLoop,
        gridX: 0,
        gridY: 0,
        workerIds: ['worker_1'],
      );

      final baseState = GameState(
        chronoEnergy: BigInt.zero,
        lifetimeChronoEnergy: BigInt.zero,
        workers: {'worker_1': worker},
        stations: {'station_1': station},
      );
      expect(baseState.productionPerSecond, BigInt.from(100));

      final masteryState = baseState.copyWith(
        eraMasteryXp: {'victorian': _totalXpForLevel(2)},
      );

      expect(masteryState.getEraMasteryLevel('victorian'), 2);
      expect(masteryState.productionPerSecond, BigInt.from(106));
    });

    test('offlineEfficiency includes victorian mastery bonus', () {
      final state = GameState(
        chronoEnergy: BigInt.zero,
        lifetimeChronoEnergy: BigInt.zero,
        eraMasteryXp: {'victorian': _totalXpForLevel(3)},
      );

      expect(state.offlineEfficiency, closeTo(0.16, 1e-9));
    });

    test('serialization preserves eraMasteryXp', () {
      final state = GameState(
        chronoEnergy: BigInt.from(123),
        lifetimeChronoEnergy: BigInt.from(456),
        eraMasteryXp: {'victorian': 42, 'atomic_age': 77},
      );

      final restored = GameState.fromMap(state.toMap());
      expect(restored.eraMasteryXp['victorian'], 42);
      expect(restored.eraMasteryXp['atomic_age'], 77);
    });
  });
}
