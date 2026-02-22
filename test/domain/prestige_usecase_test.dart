import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/game_state.dart';
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
          lifetimeChronoEnergy: BigInt.from(2500000), // Gives 2 prestige points
          chronoEnergy: BigInt.from(50000),
          timeShards: 450,
          inventory: [dummyArtifact],
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
        expect(result.availableParadoxPoints, 7); // 5 previous + 2 new

        // Assert: Preserved metadata
        expect(result.timeShards, 450); // Should keep time shards
        expect(result.inventory.length, 1); // Should keep artifacts
        expect(result.inventory.first.id, dummyArtifact.id);

        // Assert: Eras should reset to only victorian (since no era_insight upgrade)
        expect(result.unlockedEras, {'victorian'});
      },
    );

    test(
      'should calculate starting eras correctly based on era_insight upgrade',
      () {
        final state = GameState.initial().copyWith(
          lifetimeChronoEnergy: BigInt.from(1000000),
          paradoxPointsSpent: {'era_insight': 2}, // +2 starting eras
        );

        final result = useCase.execute(state);

        expect(result.unlockedEras.contains('victorian'), isTrue);
        expect(result.unlockedEras.contains('roaring_20s'), isTrue);
        expect(result.unlockedEras.contains('atomic_age'), isTrue);
        expect(result.unlockedEras.contains('cyberpunk_80s'), isFalse);
      },
    );

    test(
      'should calculate correct prestigePointsToGain based on lifetimeChronoEnergy',
      () {
        final cases = {
          BigInt.from(999999): 0, // Below threshold
          BigInt.from(1000000): 1, // Exact threshold
          BigInt.from(1500000): 1, // Truncated down
          BigInt.from(2000000): 2, // Double
          BigInt.from(10000000): 10, // 10x
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
