import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/entities/worker_artifact.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/enums.dart';

void main() {
  test('CE/sec updates when artifact is equipped', () {
    // 1. Setup initial state with 1 deployed worker
    final worker = Worker(
      id: 'w1',
      era: WorkerEra.victorian,
      baseProduction: BigInt.from(3), // Rarity-based base prod
      isDeployed: true,
      deployedStationId: 's1',
    );

    final station = Station(
      id: 's1',
      type: StationType.basicLoop,
      gridX: 0,
      gridY: 0,
      workerIds: ['w1'],
    );

    final artifact = WorkerArtifact.generate(
      WorkerRarity.common,
      WorkerEra.victorian,
    ); // +1 base power

    var state = GameState.initial().copyWith(
      workers: {'w1': worker},
      stations: {'s1': station},
      inventory: [artifact],
    );

    final initialProd = state.productionPerSecond;
    print('Initial Production: $initialProd');

    // 2. Equip artifact manually as the notifier would
    final newWorker = worker.copyWith(equippedArtifacts: [artifact]);
    state = state.copyWith(workers: {'w1': newWorker}, inventory: []);

    final equippedProd = state.productionPerSecond;
    print('Equipped Production: $equippedProd');

    // Worker Base Prod = 3
    // Artifact Base Power = 1
    // Artifact Prod Mult = +0.02
    // Artifact Era Match = +0.02
    // (3 + 1) * 1.04 = 4.16 -> 4
    expect(
      equippedProd,
      BigInt.from(4),
      reason: 'Production matches the exact 1.04 multiplier and +1 base power',
    );
  });
}
