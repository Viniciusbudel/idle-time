import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/core/constants/game_constants.dart';
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
    test('slot catalog includes one expedition per configured era', () {
      final useCase = StartExpeditionUseCase();

      expect(useCase.availableSlots.length, GameConstants.eraOrder.length);
      expect(
        useCase.availableSlots.map((slot) => slot.eraId).toList(),
        GameConstants.eraOrder,
      );
    });

    test('slot catalog keeps identity metadata populated and stable', () {
      final useCase = StartExpeditionUseCase();
      final Set<String> seenIds = <String>{};

      for (final ExpeditionSlot slot in useCase.availableSlots) {
        expect(slot.id.isNotEmpty, isTrue);
        expect(slot.headline.isNotEmpty, isTrue);
        expect(slot.layoutPreset.isNotEmpty, isTrue);
        expect(slot.unlockEraId, slot.eraId);
        expect(seenIds.add(slot.id), isTrue);
      }
    });

    test('new save exposes only victorian expedition slot', () {
      final useCase = StartExpeditionUseCase();
      final state = GameState.initial();

      final available = useCase.getAvailableExpeditionSlots(state);

      expect(available.length, 1);
      expect(available.first.eraId, 'victorian');
      expect(available.first.id, 'salvage_run');
    });

    test('unlocking roaring_20s exposes two expedition slots', () {
      final useCase = StartExpeditionUseCase();
      final state = GameState.initial().copyWith(
        unlockedEras: {'victorian', 'roaring_20s'},
        currentEraId: 'roaring_20s',
      );

      final available = useCase.getAvailableExpeditionSlots(state);

      expect(available.length, 2);
      expect(available.map((slot) => slot.eraId).toList(), const <String>[
        'victorian',
        'roaring_20s',
      ]);
    });

    test('unlocking atomic_age exposes three expedition slots', () {
      final useCase = StartExpeditionUseCase();
      final state = GameState.initial().copyWith(
        unlockedEras: {'victorian', 'roaring_20s', 'atomic_age'},
        currentEraId: 'atomic_age',
      );

      final available = useCase.getAvailableExpeditionSlots(state);

      expect(available.length, 3);
      expect(available.map((slot) => slot.eraId).toList(), const <String>[
        'victorian',
        'roaring_20s',
        'atomic_age',
      ]);
    });

    test('autoSelectCrew prioritizes rarity order and avoids duplicates', () {
      final useCase = StartExpeditionUseCase();
      final ExpeditionSlot slot = useCase.getSlotById('rift_probe')!;

      final Worker commonWorker = Worker(
        id: 'crew_common',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(8),
        rarity: WorkerRarity.common,
      );
      final Worker duplicateCommonWorker = Worker(
        id: 'crew_common',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(20),
        rarity: WorkerRarity.common,
      );
      final Worker rareWorker = Worker(
        id: 'crew_rare',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(12),
        rarity: WorkerRarity.rare,
      );
      final Worker paradoxWorker = Worker(
        id: 'crew_paradox',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(40),
        rarity: WorkerRarity.paradox,
      );
      final Worker deployedCommonWorker = Worker(
        id: 'crew_deployed',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(9),
        rarity: WorkerRarity.common,
        isDeployed: true,
      );

      final List<String> selected = useCase.autoSelectCrew(slot, <Worker>[
        paradoxWorker,
        rareWorker,
        commonWorker,
        duplicateCommonWorker,
        deployedCommonWorker,
      ]);

      expect(selected.length, slot.requiredWorkers);
      expect(selected.toSet().length, selected.length);
      expect(selected, const <String>['crew_common', 'crew_rare']);
    });

    test(
      'quickHireForCrewGap plans hires to fill crew gap when affordable',
      () {
        final useCase = StartExpeditionUseCase();
        final ExpeditionSlot slot = useCase.getSlotById('rift_probe')!;

        final Worker idleWorker = Worker(
          id: 'idle_gap_worker',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(10),
        );
        final GameState state = GameState.initial().copyWith(
          chronoEnergy: BigInt.from(200000),
          workers: {'idle_gap_worker': idleWorker},
          stations: const {},
          expeditions: const [],
          unlockedEras: const {'victorian', 'roaring_20s'},
          currentEraId: 'roaring_20s',
        );

        final QuickHirePlan plan = useCase.quickHireForCrewGap(slot, state);

        expect(plan.era, WorkerEra.roaring20s);
        expect(plan.missingWorkers, 1);
        expect(plan.affordableWorkers, 1);
        expect(plan.canHireAny, isTrue);
        expect(plan.fillsCrewGap, isTrue);
        expect(plan.totalCost, greaterThan(BigInt.zero));
      },
    );

    test(
      'quickHireForCrewGap reports no affordable hires when CE is insufficient',
      () {
        final useCase = StartExpeditionUseCase();
        final ExpeditionSlot slot = useCase.getSlotById('rift_probe')!;

        final Worker idleWorker = Worker(
          id: 'idle_low_ce',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(10),
        );
        final GameState state = GameState.initial().copyWith(
          chronoEnergy: BigInt.from(50000),
          workers: {'idle_low_ce': idleWorker},
          stations: const {},
          expeditions: const [],
          unlockedEras: const {'victorian', 'roaring_20s'},
          currentEraId: 'roaring_20s',
        );

        final QuickHirePlan plan = useCase.quickHireForCrewGap(slot, state);

        expect(plan.missingWorkers, 1);
        expect(plan.affordableWorkers, 0);
        expect(plan.canHireAny, isFalse);
        expect(plan.totalCost, BigInt.zero);
      },
    );

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

    test('StartExpeditionUseCase allows deployed workers', () {
      final useCase = StartExpeditionUseCase();
      final state = GameState.initial();

      final result = useCase.execute(
        state,
        slotId: 'salvage_run',
        risk: ExpeditionRisk.safe,
        workerIds: const ['worker_starter'],
        now: DateTime(2026, 2, 22, 12, 0),
      );

      expect(result, isNotNull);
      expect(result!.newState.workers['worker_starter']?.isDeployed, isTrue);
      expect(
        result.newState.stations['station_starter']?.workerIds,
        contains('worker_starter'),
      );
    });

    test(
      'workers on active expedition keep chamber production while keeping assignment',
      () {
        final useCase = StartExpeditionUseCase();
        final DateTime now = DateTime(2026, 2, 22, 12, 0);
        final GameState state = GameState.initial();

        final BigInt baselineProduction = state.productionPerSecond;
        expect(baselineProduction, greaterThan(BigInt.zero));

        final StartExpeditionResult? started = useCase.execute(
          state,
          slotId: 'salvage_run',
          risk: ExpeditionRisk.safe,
          workerIds: const ['worker_starter'],
          now: now,
        );
        expect(started, isNotNull);

        expect(started!.newState.workers['worker_starter']?.isDeployed, isTrue);
        expect(
          started.newState.stations['station_starter']?.workerIds,
          contains('worker_starter'),
        );
        expect(started.newState.productionPerSecond, baselineProduction);
      },
    );

    test('start returns null when slot era is still locked', () {
      final useCase = StartExpeditionUseCase();
      final now = DateTime(2026, 2, 26, 10, 0);

      final idleWorkerA = Worker(
        id: 'idle_lock_a',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(10),
      );
      final idleWorkerB = Worker(
        id: 'idle_lock_b',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(10),
      );

      final state = GameState.initial().copyWith(
        workers: {'idle_lock_a': idleWorkerA, 'idle_lock_b': idleWorkerB},
        stations: const {},
        expeditions: const [],
        unlockedEras: const {'victorian'},
      );

      final result = useCase.execute(
        state,
        slotId: 'rift_probe',
        risk: ExpeditionRisk.risky,
        workerIds: const ['idle_lock_a', 'idle_lock_b'],
        now: now,
      );

      expect(result, isNull);
    });

    test('start succeeds for slot after unlocking its era', () {
      final useCase = StartExpeditionUseCase();
      final now = DateTime(2026, 2, 26, 10, 5);

      final idleWorkerA = Worker(
        id: 'idle_unlock_a',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(10),
      );
      final idleWorkerB = Worker(
        id: 'idle_unlock_b',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(10),
      );

      final state = GameState.initial().copyWith(
        workers: {'idle_unlock_a': idleWorkerA, 'idle_unlock_b': idleWorkerB},
        stations: const {},
        expeditions: const [],
        unlockedEras: const {'victorian', 'roaring_20s'},
        currentEraId: 'roaring_20s',
      );

      final result = useCase.execute(
        state,
        slotId: 'rift_probe',
        risk: ExpeditionRisk.risky,
        workerIds: const ['idle_unlock_a', 'idle_unlock_b'],
        now: now,
      );

      expect(result, isNotNull);
      expect(result!.expedition.slotId, 'rift_probe');
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

    test(
      'save/load preserves stable expedition slotId and catalog metadata',
      () {
        final start = StartExpeditionUseCase();
        final now = DateTime(2026, 2, 26, 16, 0);

        final idleWorker = Worker(
          id: 'idle_save_load',
          era: WorkerEra.victorian,
          baseProduction: BigInt.from(14),
        );

        final baseState = GameState.initial().copyWith(
          workers: {'idle_save_load': idleWorker},
          stations: const {},
          expeditions: const [],
          unlockedEras: const {'victorian'},
        );

        final started = start.execute(
          baseState,
          slotId: 'salvage_run',
          risk: ExpeditionRisk.safe,
          workerIds: const ['idle_save_load'],
          now: now,
        );
        expect(started, isNotNull);

        final restored = GameState.fromMap(started!.newState.toMap());
        expect(restored.expeditions.length, 1);

        final String restoredSlotId = restored.expeditions.first.slotId;
        expect(restoredSlotId, 'salvage_run');

        final ExpeditionSlot? restoredSlot = ExpeditionSlot.byId(
          restoredSlotId,
        );
        expect(restoredSlot, isNotNull);
        expect(restoredSlot!.eraId, 'victorian');
        expect(restoredSlot.headline.isNotEmpty, isTrue);
        expect(restoredSlot.layoutPreset.isNotEmpty, isTrue);
      },
    );

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

    test('same expedition slot cannot have two active runs at once', () {
      final useCase = StartExpeditionUseCase();
      final now = DateTime(2026, 2, 22, 13, 0);

      final workerA = Worker(
        id: 'slot_guard_a',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(10),
      );
      final workerB = Worker(
        id: 'slot_guard_b',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(12),
      );

      final state = GameState.initial().copyWith(
        workers: {'slot_guard_a': workerA, 'slot_guard_b': workerB},
        stations: const {},
        expeditions: const [],
        unlockedEras: const {'victorian'},
      );

      final first = useCase.execute(
        state,
        slotId: 'salvage_run',
        risk: ExpeditionRisk.safe,
        workerIds: const ['slot_guard_a'],
        now: now,
      );
      expect(first, isNotNull);

      final second = useCase.execute(
        first!.newState,
        slotId: 'salvage_run',
        risk: ExpeditionRisk.safe,
        workerIds: const ['slot_guard_b'],
        now: now.add(const Duration(minutes: 1)),
      );
      expect(second, isNull);
    });

    test('different expedition slots can run in parallel', () {
      final useCase = StartExpeditionUseCase();
      final now = DateTime(2026, 2, 22, 14, 0);

      final workerA = Worker(
        id: 'parallel_a',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(10),
      );
      final workerB = Worker(
        id: 'parallel_b',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(11),
      );
      final workerC = Worker(
        id: 'parallel_c',
        era: WorkerEra.victorian,
        baseProduction: BigInt.from(12),
      );

      final state = GameState.initial().copyWith(
        workers: {
          'parallel_a': workerA,
          'parallel_b': workerB,
          'parallel_c': workerC,
        },
        stations: const {},
        expeditions: const [],
        unlockedEras: const {'victorian', 'roaring_20s'},
        currentEraId: 'roaring_20s',
      );

      final first = useCase.execute(
        state,
        slotId: 'salvage_run',
        risk: ExpeditionRisk.safe,
        workerIds: const ['parallel_a'],
        now: now,
      );
      expect(first, isNotNull);

      final second = useCase.execute(
        first!.newState,
        slotId: 'rift_probe',
        risk: ExpeditionRisk.risky,
        workerIds: const ['parallel_b', 'parallel_c'],
        now: now.add(const Duration(minutes: 1)),
      );
      expect(second, isNotNull);
      expect(second!.newState.expeditions.length, 2);
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

    test(
      '2h paradox + legendary crew yields strong CE and buffed relic odds',
      () {
        final start = StartExpeditionUseCase();
        final resolve = ResolveExpeditionsUseCase();
        final now = DateTime(2026, 2, 26, 18, 0);

        final paradoxWorker = Worker(
          id: 'paradox_2h',
          era: WorkerEra.roaring20s,
          baseProduction: BigInt.from(25),
          rarity: WorkerRarity.paradox,
          chronalAttunement: 1.0,
        );
        final legendaryWorker = Worker(
          id: 'legendary_2h',
          era: WorkerEra.roaring20s,
          baseProduction: BigInt.from(15),
          rarity: WorkerRarity.legendary,
          chronalAttunement: 1.0,
        );

        final state = GameState.initial().copyWith(
          workers: {
            paradoxWorker.id: paradoxWorker,
            legendaryWorker.id: legendaryWorker,
          },
          stations: const {},
          techLevels: const {},
          expeditions: const [],
          unlockedEras: const {'victorian', 'roaring_20s'},
          currentEraId: 'roaring_20s',
        );

        final started = start.execute(
          state,
          slotId: 'rift_probe',
          risk: ExpeditionRisk.risky,
          workerIds: const ['paradox_2h', 'legendary_2h'],
          now: now,
        );
        expect(started, isNotNull);

        final resolved = resolve.execute(
          started!.newState,
          now: now.add(const Duration(hours: 2, minutes: 1)),
          randomRoll: () => 0.0,
        );
        final ExpeditionReward reward =
            resolved.newlyResolved.first.resolvedReward!;
        final chronoEnergy = reward.chronoEnergy;

        expect(chronoEnergy, greaterThan(BigInt.from(350000000)));
        expect(reward.artifactDropChance, greaterThan(0.30));
      },
    );

    test('preview estimator matches resolved success reward formula', () {
      final start = StartExpeditionUseCase();
      final resolve = ResolveExpeditionsUseCase();
      final now = DateTime(2026, 2, 26, 20, 0);

      final paradoxWorker = Worker(
        id: 'paradox_preview',
        era: WorkerEra.roaring20s,
        baseProduction: BigInt.from(25),
        rarity: WorkerRarity.paradox,
        chronalAttunement: 1.0,
      );
      final legendaryWorker = Worker(
        id: 'legendary_preview',
        era: WorkerEra.roaring20s,
        baseProduction: BigInt.from(15),
        rarity: WorkerRarity.legendary,
        chronalAttunement: 1.0,
      );

      final state = GameState.initial().copyWith(
        workers: {
          paradoxWorker.id: paradoxWorker,
          legendaryWorker.id: legendaryWorker,
        },
        stations: const {},
        techLevels: const {},
        expeditions: const [],
        unlockedEras: const {'victorian', 'roaring_20s'},
        currentEraId: 'roaring_20s',
      );

      final ExpeditionReward preview = resolve.estimateRewardPreview(
        state,
        workers: [paradoxWorker, legendaryWorker],
        duration: const Duration(hours: 2),
        risk: ExpeditionRisk.risky,
        succeeded: true,
      );

      final started = start.execute(
        state,
        slotId: 'rift_probe',
        risk: ExpeditionRisk.risky,
        workerIds: const ['paradox_preview', 'legendary_preview'],
        now: now,
      );
      expect(started, isNotNull);

      final resolved = resolve.execute(
        started!.newState,
        now: now.add(const Duration(hours: 2, minutes: 1)),
        randomRoll: () => 0.0,
      );
      final ExpeditionReward resolvedReward =
          resolved.newlyResolved.first.resolvedReward!;

      expect(preview.chronoEnergy, resolvedReward.chronoEnergy);
      expect(preview.timeShards, resolvedReward.timeShards);
      expect(preview.artifactDropChance, resolvedReward.artifactDropChance);
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
