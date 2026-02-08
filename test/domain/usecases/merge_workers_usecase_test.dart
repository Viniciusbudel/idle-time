import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/usecases/merge_workers_usecase.dart';

void main() {
  late MergeWorkersUseCase useCase;

  setUp(() {
    useCase = MergeWorkersUseCase();
  });

  // Helper to create dummy workers
  Worker createWorker(String id, WorkerEra era, WorkerRarity rarity) {
    return Worker(
      id: id,
      name: 'Worker $id',
      era: era,
      rarity: rarity,
      level: 1,
      isDeployed: false,
      deployedStationId: null,
      baseProduction: BigInt.from(10),
    );
  }

  group('MergeWorkersUseCase', () {
    test('should fail if less than 3 workers available', () {
      final workers = [
        createWorker('1', WorkerEra.victorian, WorkerRarity.common),
        createWorker('2', WorkerEra.victorian, WorkerRarity.common),
      ];

      final result = useCase.execute(
        availableWorkers: workers,
        targetEra: WorkerEra.victorian,
        targetRarity: WorkerRarity.common,
      );

      expect(result.success, isFalse);
      expect(result.error, contains('Not enough workers'));
      expect(result.newWorker, isNull);
    });

    test('should fail if workers are of different era', () {
      final workers = [
        createWorker('1', WorkerEra.victorian, WorkerRarity.common),
        createWorker('2', WorkerEra.victorian, WorkerRarity.common),
        createWorker('3', WorkerEra.cyberpunk80s, WorkerRarity.common),
      ];

      final result = useCase.execute(
        availableWorkers: workers,
        targetEra: WorkerEra.victorian,
        targetRarity: WorkerRarity.common,
      );

      expect(result.success, isFalse);
    });

    test('should merge 3 common workers into 1 rare worker', () {
      final workers = [
        createWorker('1', WorkerEra.victorian, WorkerRarity.common),
        createWorker('2', WorkerEra.victorian, WorkerRarity.common),
        createWorker('3', WorkerEra.victorian, WorkerRarity.common),
        createWorker(
          '4',
          WorkerEra.victorian,
          WorkerRarity.common,
        ), // Extra one
      ];

      final result = useCase.execute(
        availableWorkers: workers,
        targetEra: WorkerEra.victorian,
        targetRarity: WorkerRarity.common,
      );

      expect(result.success, isTrue);
      expect(result.newWorker, isNotNull);
      expect(result.newWorker!.rarity, WorkerRarity.rare);
      expect(result.newWorker!.era, WorkerEra.victorian);
      expect(result.consumedWorkerIds.length, 3);
      expect(result.consumedWorkerIds, containsAll(['1', '2', '3']));
      expect(result.consumedWorkerIds, isNot(contains('4')));
    });

    test('should fail if trying to merge Paradox rarity (max)', () {
      final workers = [
        createWorker('1', WorkerEra.victorian, WorkerRarity.paradox),
        createWorker('2', WorkerEra.victorian, WorkerRarity.paradox),
        createWorker('3', WorkerEra.victorian, WorkerRarity.paradox),
      ];

      final result = useCase.execute(
        availableWorkers: workers,
        targetEra: WorkerEra.victorian,
        targetRarity: WorkerRarity.paradox,
      );

      expect(result.success, isFalse);
      expect(result.error, contains('Cannot merge'));
    });
  });
}
