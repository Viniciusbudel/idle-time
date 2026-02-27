import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/core/constants/tech_data.dart';
import 'package:time_factory/domain/entities/expedition.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/prestige_upgrade.dart';
import 'package:time_factory/domain/entities/worker_artifact.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/usecases/prestige_usecase.dart';

void main() {
  group('PrestigeUseCase', () {
    late PrestigeUseCase useCase;

    setUp(() {
      useCase = PrestigeUseCase();
    });

    test('should not prestige if lifetimeChronoEnergy < 1,000,000', () {
      final state = GameState.initial().copyWith(
        lifetimeChronoEnergy: BigInt.from(999999),
      );

      final result = useCase.execute(state);

      expect(result, state);
      expect(result.prestigeLevel, 0);
    });

    test(
      'should reset game state while preserving specific persistence items',
      () {
        final dummyArtifact = WorkerArtifact.generate(
          WorkerRarity.epic,
          WorkerEra.atomicAge,
        );

        final state = GameState.initial().copyWith(
          lifetimeChronoEnergy: BigInt.from(2500000), // Gives 1 prestige point
          chronoEnergy: BigInt.from(50000),
          timeShards: 450,
          inventory: [dummyArtifact],
          eraMasteryXp: {'victorian': 123, 'atomic_age': 45},
          techLevels: const {'steam_turbine': 2, 'assembly_line': 1},
          completedEras: const {'victorian'},
          currentEraId: 'roaring_20s',
          prestigeLevel: 1,
          availableParadoxPoints: 5,
          totalPrestiges: 1,
          unlockedEras: {'victorian', 'roaring_20s', 'atomic_age'},
        );

        // Act
        final result = useCase.execute(state);

        // Assert: Progression should be reset to initial state
        expect(result.chronoEnergy, BigInt.from(500)); // Starter CE
        expect(result.workers.length, 1); // Only starter worker
        expect(result.stations.length, 1); // Only starter station

        // Assert: Prestige stats should update
        expect(result.prestigeLevel, 2);
        expect(result.totalPrestiges, 2);
        expect(result.availableParadoxPoints, 6); // 5 previous + 1 new

        // Assert: Preserved metadata
        expect(result.timeShards, 450); // Should keep time shards
        expect(result.inventory.length, 1); // Should keep artifacts
        expect(result.inventory.first.id, dummyArtifact.id);
        expect(result.eraMasteryXp, {'victorian': 123, 'atomic_age': 45});

        // Assert: Tech progression should reset completely
        expect(result.techLevels, isEmpty);
        expect(result.completedEras, isEmpty);
        expect(result.currentEraId, 'victorian');

        // Assert: Eras should reset to only victorian (since no era_insight upgrade)
        expect(result.unlockedEras, {'victorian'});
      },
    );

    test(
      'should clear tech progression from a fully maxed tree on prestige',
      () {
        final fullyMaxedTechs = {
          for (final tech in TechData.initialTechs) tech.id: tech.maxLevel,
        };

        final state = GameState.initial().copyWith(
          lifetimeChronoEnergy: BigInt.from(1500000),
          techLevels: fullyMaxedTechs,
          completedEras: {
            for (final era in WorkerEra.values) era.id,
          },
          currentEraId: WorkerEra.farFuture.id,
          unlockedEras: {
            for (final era in WorkerEra.values) era.id,
          },
        );

        final result = useCase.execute(state);
        final loaded = GameState.fromMap(result.toMap());

        expect(result.techLevels, isEmpty);
        expect(result.completedEras, isEmpty);
        expect(result.currentEraId, WorkerEra.victorian.id);
        expect(loaded.techLevels, isEmpty);
        expect(loaded.completedEras, isEmpty);
      },
    );

    test(
      'should return equipped artifacts to inventory when workers are reset by prestige',
      () {
        final equippedArtifact = WorkerArtifact(
          id: 'artifact_equipped_reset_case',
          name: 'Reset Relic',
          rarity: WorkerRarity.epic,
          eraMatch: WorkerEra.atomicAge,
          basePowerBonus: BigInt.from(5),
          productionMultiplier: 0.08,
        );
        final inventoryArtifact = WorkerArtifact(
          id: 'artifact_inventory_keep_case',
          name: 'Stored Relic',
          rarity: WorkerRarity.rare,
          eraMatch: null,
          basePowerBonus: BigInt.from(2),
          productionMultiplier: 0.05,
        );

        final worker = Worker(
          id: 'worker_reset_target',
          era: WorkerEra.atomicAge,
          baseProduction: BigInt.from(10),
          rarity: WorkerRarity.rare,
          equippedArtifacts: [equippedArtifact],
        );

        final state = GameState.initial().copyWith(
          lifetimeChronoEnergy: BigInt.from(1200000),
          workers: {'worker_reset_target': worker},
          stations: const {},
          inventory: [inventoryArtifact],
        );

        final afterPrestige = useCase.execute(state);
        final reconciled = afterPrestige.reconcileArtifactsAfterPrestige(state);
        final loaded = GameState.fromMap(reconciled.toMap());

        final inventoryIds = reconciled.inventory.map((a) => a.id).toSet();
        expect(
          inventoryIds,
          containsAll(
            const ['artifact_equipped_reset_case', 'artifact_inventory_keep_case'],
          ),
        );
        expect(reconciled.inventory.length, inventoryIds.length);
        expect(
          reconciled.workers.values.any(
            (w) => w.equippedArtifacts.any(
              (a) => a.id == 'artifact_equipped_reset_case',
            ),
          ),
          isFalse,
        );
        expect(loaded.inventory.map((a) => a.id).toSet(), inventoryIds);
      },
    );

    test(
      'should keep equipped artifacts attached when worker id persists across prestige',
      () {
        final equippedArtifact = WorkerArtifact(
          id: 'artifact_equipped_persist_case',
          name: 'Timeline Anchor',
          rarity: WorkerRarity.legendary,
          eraMatch: WorkerEra.victorian,
          basePowerBonus: BigInt.from(10),
          productionMultiplier: 0.12,
        );

        final starterWorker = GameState.initial().workers['worker_starter']!
            .copyWith(equippedArtifacts: [equippedArtifact]);

        final state = GameState.initial().copyWith(
          lifetimeChronoEnergy: BigInt.from(1200000),
          workers: {'worker_starter': starterWorker},
          inventory: const [],
        );

        final afterPrestige = useCase.execute(state);
        final reconciled = afterPrestige.reconcileArtifactsAfterPrestige(state);
        final loaded = GameState.fromMap(reconciled.toMap());
        final persistedWorker = reconciled.workers['worker_starter'];

        expect(persistedWorker, isNotNull);
        expect(
          persistedWorker!.equippedArtifacts
              .map((a) => a.id)
              .contains('artifact_equipped_persist_case'),
          isTrue,
        );
        expect(
          reconciled.inventory
              .map((a) => a.id)
              .contains('artifact_equipped_persist_case'),
          isFalse,
        );
        expect(
          loaded.workers['worker_starter']!.equippedArtifacts
              .map((a) => a.id)
              .contains('artifact_equipped_persist_case'),
          isTrue,
        );
      },
    );

    test('should normalize removed prestige upgrades when loading a save', () {
      final saveMap = GameState.initial().toMap();
      saveMap['paradoxPointsSpent'] = {
        PrestigeUpgradeType.chronoMastery.id: 2,
        PrestigeUpgradeType.eraInsight.id: 3,
        PrestigeUpgradeType.riftStability.id: 4,
      };

      final loaded = GameState.fromMap(saveMap);

      expect(
        loaded.paradoxPointsSpent,
        {PrestigeUpgradeType.chronoMastery.id: 2},
      );
    });

    test('should ignore legacy era_insight levels after load normalization', () {
      final saveMap = GameState.initial().toMap();
      saveMap['lifetimeChronoEnergy'] = BigInt.from(1000000).toString();
      saveMap['paradoxPointsSpent'] = {PrestigeUpgradeType.eraInsight.id: 4};

      final loaded = GameState.fromMap(saveMap);
      final result = useCase.execute(loaded);

      expect(result.unlockedEras, {'victorian'});
    });

    test('should return zero paradox click bonus at zero paradox balance', () {
      final state = GameState.initial().copyWith(paradoxLevel: 0.0);

      expect(state.paradoxClickBonusSteps, 0);
      expect(state.paradoxClickBonusMultiplier, 1.0);
      expect(state.paradoxClickBonusPercent, 0);
    });

    test('should return one paradox click bonus step at 10% paradox balance', () {
      final state = GameState.initial().copyWith(paradoxLevel: 0.1);

      expect(state.paradoxClickBonusSteps, 1);
      expect(state.paradoxClickBonusMultiplier, 1.1);
      expect(state.paradoxClickBonusPercent, 10);
    });

    test('should return multiple paradox click bonus steps at higher balance', () {
      final state = GameState.initial().copyWith(paradoxLevel: 0.36);

      expect(state.paradoxClickBonusSteps, 3);
      expect(state.paradoxClickBonusMultiplier, 1.3);
      expect(state.paradoxClickBonusPercent, 30);
    });

    test('should keep production formula unchanged by paradox click bonus', () {
      final base = GameState.initial().copyWith(
        paradoxLevel: 0.0,
        paradoxPointsSpent: {PrestigeUpgradeType.chronoMastery.id: 4},
      );
      final highParadox = base.copyWith(paradoxLevel: 0.95);

      expect(highParadox.productionPerSecond, base.productionPerSecond);
    });

    test('should apply prestige luck bonus to expedition success chance', () {
      final baseState = GameState.initial();
      final upgradedState = GameState.initial().copyWith(
        paradoxPointsSpent: {PrestigeUpgradeType.timekeepersFavor.id: 3},
      );

      final baseChance = GameState.baseExpeditionSuccessChanceForRisk(
        ExpeditionRisk.risky,
      );
      final adjustedBase = baseState.adjustedExpeditionSuccessProbability(
        risk: ExpeditionRisk.risky,
        baseSuccessProbability: baseChance,
      );
      final adjustedUpgraded =
          upgradedState.adjustedExpeditionSuccessProbability(
            risk: ExpeditionRisk.risky,
            baseSuccessProbability: baseChance,
          );

      expect(adjustedBase, closeTo(baseChance, 1e-9));
      expect(adjustedUpgraded, greaterThan(adjustedBase));
    });

    test('should increase simulated expedition success distribution by risk', () {
      final baseState = GameState.initial();
      final upgradedState = GameState.initial().copyWith(
        paradoxPointsSpent: {PrestigeUpgradeType.timekeepersFavor.id: 4},
      );
      final rolls = List<double>.generate(1000, (i) => (i % 100) / 100.0);

      for (final risk in ExpeditionRisk.values) {
        final baseChance = GameState.baseExpeditionSuccessChanceForRisk(risk);
        final upgradedChance = upgradedState.adjustedExpeditionSuccessProbability(
          risk: risk,
          baseSuccessProbability: baseChance,
        );

        final baseSuccesses = rolls.where((roll) => roll <= baseChance).length;
        final upgradedSuccesses = rolls
            .where((roll) => roll <= upgradedChance)
            .length;

        expect(
          upgradedSuccesses,
          greaterThan(baseSuccesses),
          reason: 'Expected upgraded success distribution to be higher for $risk',
        );
        expect(
          upgradedChance,
          greaterThan(
            baseState.adjustedExpeditionSuccessProbability(
              risk: risk,
              baseSuccessProbability: baseChance,
            ),
          ),
        );
      }
    });

    test(
      'should calculate correct prestigePointsToGain based on lifetimeChronoEnergy',
      () {
        final cases = {
          BigInt.from(999999): 0, // Below threshold
          BigInt.from(1000000): 1, // Exact threshold
          BigInt.from(1500000): 1, // Smooth curve early game
          BigInt.from(2000000): 1, // Smooth curve early game
          BigInt.from(10000000): 6,
        };

        for (var entry in cases.entries) {
          final state = GameState.initial().copyWith(
            lifetimeChronoEnergy: entry.key,
          );
          expect(
            state.prestigePointsToGain,
            entry.value,
            reason: 'Failed for ${entry.key} CE',
          );
        }
      },
    );
  });
}
