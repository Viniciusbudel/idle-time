import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/prestige_upgrade.dart';
import 'package:time_factory/domain/entities/worker_artifact.dart';
import 'package:time_factory/domain/entities/enums.dart';
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

        // Assert: Eras should reset to only victorian (since no era_insight upgrade)
        expect(result.unlockedEras, {'victorian'});
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
