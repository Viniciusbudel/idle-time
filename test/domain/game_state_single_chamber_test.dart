import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/worker.dart';

void main() {
  group('GameState single chamber normalization', () {
    test(
      'normalizeSingleChamber keeps current-era chamber and undeploys workers from removed chambers',
      () {
        final workerVictorian = Worker(
          id: 'worker_victorian',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(5),
          rarity: WorkerRarity.common,
          isDeployed: true,
          deployedStationId: 'station_victorian',
        );
        final workerRoaring = Worker(
          id: 'worker_roaring',
          era: WorkerEra.roaring20s,
          baseProduction: BigInt.from(7),
          rarity: WorkerRarity.rare,
          isDeployed: true,
          deployedStationId: 'station_roaring',
        );
        final stationVictorian = const Station(
          id: 'station_victorian',
          type: StationType.basicLoop,
          level: 2,
          gridX: 0,
          gridY: 0,
          workerIds: ['worker_victorian'],
        );
        final stationRoaring = const Station(
          id: 'station_roaring',
          type: StationType.dualHelix,
          level: 1,
          gridX: 1,
          gridY: 0,
          workerIds: ['worker_roaring'],
        );

        final state = GameState.initial().copyWith(
          currentEraId: WorkerEra.roaring20s.id,
          unlockedEras: {WorkerEra.victorian.id, WorkerEra.roaring20s.id},
          workers: {
            workerVictorian.id: workerVictorian,
            workerRoaring.id: workerRoaring,
          },
          stations: {
            stationVictorian.id: stationVictorian,
            stationRoaring.id: stationRoaring,
          },
        );

        final normalized = state.normalizeSingleChamber();

        expect(normalized.stations.length, 1);
        expect(normalized.stations.containsKey('station_roaring'), isTrue);
        expect(normalized.stations['station_roaring']!.workerIds, [
          'worker_roaring',
        ]);
        expect(normalized.workers['worker_roaring']!.isDeployed, isTrue);
        expect(
          normalized.workers['worker_roaring']!.deployedStationId,
          'station_roaring',
        );
        expect(normalized.workers['worker_victorian']!.isDeployed, isFalse);
        expect(
          normalized.workers['worker_victorian']!.deployedStationId,
          isNull,
        );
      },
    );

    test(
      'upgradeSingleChamberToEra retargets chamber type while preserving id/level and valid crew',
      () {
        final worker = Worker(
          id: 'worker_kept',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(6),
          rarity: WorkerRarity.common,
          isDeployed: true,
          deployedStationId: 'station_core',
        );
        final station = const Station(
          id: 'station_core',
          type: StationType.basicLoop,
          level: 3,
          gridX: 0,
          gridY: 0,
          workerIds: ['worker_kept'],
        );
        final state = GameState.initial().copyWith(
          currentEraId: WorkerEra.victorian.id,
          workers: {worker.id: worker},
          stations: {station.id: station},
        );

        final upgraded = state.upgradeSingleChamberToEra(
          WorkerEra.roaring20s.id,
        );
        final upgradedStation = upgraded.stations.values.first;

        expect(upgraded.stations.length, 1);
        expect(upgradedStation.id, 'station_core');
        expect(upgradedStation.type, StationType.dualHelix);
        expect(upgradedStation.level, 3);
        expect(upgradedStation.workerIds, ['worker_kept']);
        expect(upgraded.workers['worker_kept']!.isDeployed, isTrue);
        expect(
          upgraded.workers['worker_kept']!.deployedStationId,
          'station_core',
        );
      },
    );

    test('fromMap migrates legacy multi-chamber saves into one chamber', () {
      final workerA = Worker(
        id: 'worker_a',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(4),
        rarity: WorkerRarity.common,
        isDeployed: true,
        deployedStationId: 'station_a',
      );
      final workerB = Worker(
        id: 'worker_b',
        era: WorkerEra.roaring20s,
        baseProduction: BigInt.from(8),
        rarity: WorkerRarity.rare,
        isDeployed: true,
        deployedStationId: 'station_b',
      );
      final stationA = const Station(
        id: 'station_a',
        type: StationType.basicLoop,
        gridX: 0,
        gridY: 0,
        workerIds: ['worker_a'],
      );
      final stationB = const Station(
        id: 'station_b',
        type: StationType.dualHelix,
        gridX: 1,
        gridY: 0,
        workerIds: ['worker_b'],
      );

      final legacyState = GameState.initial().copyWith(
        currentEraId: WorkerEra.roaring20s.id,
        unlockedEras: {WorkerEra.victorian.id, WorkerEra.roaring20s.id},
        workers: {workerA.id: workerA, workerB.id: workerB},
        stations: {stationA.id: stationA, stationB.id: stationB},
      );

      final loaded = GameState.fromMap(legacyState.toMap());

      expect(loaded.stations.length, 1);
      final retainedStationId = loaded.stations.keys.single;
      for (final worker in loaded.workers.values) {
        if (!worker.isDeployed) continue;
        expect(worker.deployedStationId, retainedStationId);
      }
    });
  });
}
