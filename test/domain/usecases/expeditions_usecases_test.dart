import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/entities/worker_artifact.dart';
import 'package:time_factory/domain/usecases/claim_expedition_rewards_usecase.dart';
import 'package:time_factory/domain/usecases/resolve_expeditions_usecase.dart';
import 'package:time_factory/domain/usecases/start_expedition_usecase.dart';
import 'package:time_factory/domain/entities/expedition.dart';

void main() {
  group('Expedition use cases', () {
    test(
      'success probability scales with worker count, rarity and artifacts',
      () {
        final commonWorker = Worker(
          id: 'common_1',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(8),
          rarity: WorkerRarity.common,
        );
        final commonWorker2 = Worker(
          id: 'common_2',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(8),
          rarity: WorkerRarity.common,
        );

        final epicArtifact = WorkerArtifact(
          id: 'artifact_epic',
          name: 'Paradox Capacitor',
          rarity: WorkerRarity.epic,
          basePowerBonus: BigInt.from(5),
          productionMultiplier: 0.08,
        );
        final legendaryWorker = Worker(
          id: 'legendary_1',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(12),
          rarity: WorkerRarity.legendary,
          equippedArtifacts: <WorkerArtifact>[epicArtifact, epicArtifact],
        );
        final legendaryWorker2 = Worker(
          id: 'legendary_2',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(12),
          rarity: WorkerRarity.legendary,
          equippedArtifacts: <WorkerArtifact>[epicArtifact],
        );

        final chanceUnderAssigned =
            StartExpeditionUseCase.calculateSuccessProbability(
              risk: ExpeditionRisk.risky,
              assignedWorkers: <Worker>[commonWorker],
              requiredWorkers: 2,
            );
        final chanceFilledCommon =
            StartExpeditionUseCase.calculateSuccessProbability(
              risk: ExpeditionRisk.risky,
              assignedWorkers: <Worker>[commonWorker, commonWorker2],
              requiredWorkers: 2,
            );
        final chanceFilledLegendary =
            StartExpeditionUseCase.calculateSuccessProbability(
              risk: ExpeditionRisk.risky,
              assignedWorkers: <Worker>[legendaryWorker, legendaryWorker2],
              requiredWorkers: 2,
            );

        expect(chanceFilledCommon, greaterThan(chanceUnderAssigned));
        expect(chanceFilledLegendary, greaterThan(chanceFilledCommon));
      },
    );

    test('StartExpeditionUseCase rejects deployed workers', () {
      final useCase = StartExpeditionUseCase();
      final state = GameState.initial();

      final result = useCase.execute(
        state,
        slotId: 'salvage_run',
        risk: ExpeditionRisk.safe,
        workerIds: const ['worker_starter'],
        now: DateTime(2026, 2, 22, 12, 0),
      );

      expect(result, isNull);
    });

    test(
      'start then resolve success marks expedition as resolved with rewards',
      () {
        final start = StartExpeditionUseCase();
        final resolve = ResolveExpeditionsUseCase();
        final now = DateTime(2026, 2, 22, 12, 0);

        final idleWorker = Worker(
          id: 'idle_1',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(12),
          rarity: WorkerRarity.rare,
        );

        final state = GameState.initial().copyWith(
          workers: {'idle_1': idleWorker},
          stations: const {},
          expeditions: const [],
        );

        final started = start.execute(
          state,
          slotId: 'salvage_run',
          risk: ExpeditionRisk.risky,
          workerIds: const ['idle_1'],
          now: now,
        );
        expect(started, isNotNull);
        expect(started!.newState.expeditions.length, 1);
        expect(started.expedition.resolved, isFalse);

        final resolved = resolve.execute(
          started.newState,
          now: now.add(const Duration(minutes: 31)),
          randomRoll: () => 0.0,
        );

        expect(resolved.newlyResolved.length, 1);
        expect(resolved.newState.expeditions.first.resolved, isTrue);
        expect(resolved.newState.expeditions.first.wasSuccessful, isTrue);
        expect(
          resolved.newState.expeditions.first.resolvedReward?.chronoEnergy,
          greaterThan(BigInt.zero),
        );
        expect(resolved.newState.workers.containsKey('idle_1'), isTrue);
      },
    );

    test('ClaimExpeditionRewardsUseCase is idempotent', () {
      final start = StartExpeditionUseCase();
      final resolve = ResolveExpeditionsUseCase();
      final claim = ClaimExpeditionRewardsUseCase();
      final now = DateTime(2026, 2, 22, 12, 0);

      final idleWorker = Worker(
        id: 'idle_2',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(15),
        rarity: WorkerRarity.epic,
      );

      final baseState = GameState.initial().copyWith(
        workers: {'idle_2': idleWorker},
        stations: const {},
        expeditions: const [],
      );

      final started = start.execute(
        baseState,
        slotId: 'salvage_run',
        risk: ExpeditionRisk.safe,
        workerIds: const ['idle_2'],
        now: now,
      );
      expect(started, isNotNull);

      final resolved = resolve.execute(
        started!.newState,
        now: now.add(const Duration(minutes: 31)),
        randomRoll: () => 0.0,
      );
      final expeditionId = resolved.newState.expeditions.first.id;

      final firstClaim = claim.execute(resolved.newState, expeditionId);
      expect(firstClaim, isNotNull);
      expect(firstClaim!.newState.expeditions, isEmpty);
      expect(
        firstClaim.newState.chronoEnergy,
        greaterThan(resolved.newState.chronoEnergy),
      );
      expect(
        firstClaim.newState.timeShards,
        greaterThanOrEqualTo(resolved.newState.timeShards),
      );

      final secondClaim = claim.execute(firstClaim.newState, expeditionId);
      expect(secondClaim, isNull);
    });

    test('worker already on unresolved expedition cannot start another', () {
      final useCase = StartExpeditionUseCase();
      final now = DateTime(2026, 2, 22, 12, 0);

      final idleWorker = Worker(
        id: 'idle_3',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(10),
      );
      final state = GameState.initial().copyWith(
        workers: {'idle_3': idleWorker},
        stations: const {},
        expeditions: const [],
      );

      final first = useCase.execute(
        state,
        slotId: 'salvage_run',
        risk: ExpeditionRisk.safe,
        workerIds: const ['idle_3'],
        now: now,
      );
      expect(first, isNotNull);

      final second = useCase.execute(
        first!.newState,
        slotId: 'salvage_run',
        risk: ExpeditionRisk.safe,
        workerIds: const ['idle_3'],
        now: now.add(const Duration(minutes: 1)),
      );
      expect(second, isNull);
    });

    test('reward compensates chamber multipliers for high-power workers', () {
      final start = StartExpeditionUseCase();
      final resolve = ResolveExpeditionsUseCase();
      final now = DateTime(2026, 2, 22, 12, 0);

      final idleWorker = Worker(
        id: 'idle_comp',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(20),
        rarity: WorkerRarity.legendary,
      );

      final baselineState = GameState.initial().copyWith(
        workers: {'idle_comp': idleWorker},
        stations: const {},
        techLevels: const {},
        expeditions: const [],
      );

      final boostedStation = const Station(
        id: 'station_boost',
        type: StationType.neonCore,
        level: 5,
        gridX: 0,
        gridY: 0,
        workerIds: [],
      );
      final boostedState = baselineState.copyWith(
        stations: {'station_boost': boostedStation},
        techLevels: const {'virtual_reality': 1},
      );

      final baselineStarted = start.execute(
        baselineState,
        slotId: 'salvage_run',
        risk: ExpeditionRisk.safe,
        workerIds: const ['idle_comp'],
        now: now,
      );
      final boostedStarted = start.execute(
        boostedState,
        slotId: 'salvage_run',
        risk: ExpeditionRisk.safe,
        workerIds: const ['idle_comp'],
        now: now,
      );
      expect(baselineStarted, isNotNull);
      expect(boostedStarted, isNotNull);

      final baselineResolved = resolve.execute(
        baselineStarted!.newState,
        now: now.add(const Duration(minutes: 31)),
        randomRoll: () => 0.0,
      );
      final boostedResolved = resolve.execute(
        boostedStarted!.newState,
        now: now.add(const Duration(minutes: 31)),
        randomRoll: () => 0.0,
      );

      final baselineReward =
          baselineResolved.newlyResolved.first.resolvedReward!.chronoEnergy;
      final boostedReward =
          boostedResolved.newlyResolved.first.resolvedReward!.chronoEnergy;

      expect(boostedReward, greaterThan(baselineReward));
      expect(boostedReward > baselineReward * BigInt.from(3), isTrue);
    });

    test('failed expedition removes workers and their equipped artifacts', () {
      final start = StartExpeditionUseCase();
      final resolve = ResolveExpeditionsUseCase();
      final claim = ClaimExpeditionRewardsUseCase();
      final now = DateTime(2026, 2, 22, 12, 0);

      final artifactA = WorkerArtifact(
        id: 'art_a',
        name: 'Chronal Lens',
        rarity: WorkerRarity.rare,
        basePowerBonus: BigInt.from(2),
        productionMultiplier: 0.04,
      );
      final artifactB = WorkerArtifact(
        id: 'art_b',
        name: 'Rift Core',
        rarity: WorkerRarity.epic,
        basePowerBonus: BigInt.from(5),
        productionMultiplier: 0.08,
      );

      final doomedWorker = Worker(
        id: 'idle_fail',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(10),
        rarity: WorkerRarity.common,
        equippedArtifacts: <WorkerArtifact>[artifactA, artifactB],
      );

      final state = GameState.initial().copyWith(
        workers: {'idle_fail': doomedWorker},
        stations: const {},
        inventory: <WorkerArtifact>[artifactA],
        expeditions: const [],
      );

      final started = start.execute(
        state,
        slotId: 'salvage_run',
        risk: ExpeditionRisk.volatile,
        workerIds: const ['idle_fail'],
        now: now,
      );
      expect(started, isNotNull);
      expect(started!.expedition.successProbability, lessThan(0.70));

      final resolved = resolve.execute(
        started.newState,
        now: now.add(const Duration(minutes: 31)),
        randomRoll: () => 0.999,
      );

      expect(resolved.newlyResolved.length, 1);
      final failedExpedition = resolved.newlyResolved.first;
      expect(failedExpedition.resolved, isTrue);
      expect(failedExpedition.wasSuccessful, isFalse);
      expect(failedExpedition.lostWorkerIds, contains('idle_fail'));
      expect(failedExpedition.lostArtifactCount, 2);
      expect(resolved.newState.workers.containsKey('idle_fail'), isFalse);
      expect(resolved.newState.inventory.length, 1);

      final claimResult = claim.execute(resolved.newState, failedExpedition.id);
      expect(claimResult, isNotNull);
      expect(
        claimResult!.newState.chronoEnergy,
        greaterThan(resolved.newState.chronoEnergy),
      );
      expect(
        claimResult.newState.timeShards,
        equals(resolved.newState.timeShards),
      );
    });
  });
}
