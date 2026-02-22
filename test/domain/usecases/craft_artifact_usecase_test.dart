import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/core/constants/artifact_forge_balance.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/usecases/craft_artifact_usecase.dart';

class _FixedRandom implements Random {
  final double _value;

  _FixedRandom(this._value);

  @override
  bool nextBool() => _value >= 0.5;

  @override
  double nextDouble() => _value;

  @override
  int nextInt(int max) {
    if (max <= 0) return 0;
    final raw = (_value * max).floor();
    return raw.clamp(0, max - 1);
  }
}

void main() {
  group('CraftArtifactUseCase', () {
    test('returns null when dust is insufficient', () {
      final useCase = CraftArtifactUseCase();
      final state = GameState.initial().copyWith(artifactDust: 0);

      final result = useCase.execute(state, minimumRarity: WorkerRarity.rare);

      expect(result, isNull);
    });

    test('craft spends dust and adds one artifact to inventory', () {
      final useCase = CraftArtifactUseCase();
      final cost = useCase.getCraftCost(WorkerRarity.rare);
      final state = GameState.initial().copyWith(artifactDust: cost);

      final result = useCase.execute(state, minimumRarity: WorkerRarity.rare);

      expect(result, isNotNull);
      expect(result!.newState.artifactDust, 0);
      expect(result.newState.inventory.length, 1);
    });

    test('minimum rarity filter is respected', () {
      final useCase = CraftArtifactUseCase();
      final cost = useCase.getCraftCost(WorkerRarity.epic);
      final state = GameState.initial().copyWith(artifactDust: cost);

      final result = useCase.execute(state, minimumRarity: WorkerRarity.epic);

      expect(result, isNotNull);
      expect(
        result!.artifact.rarity.index,
        greaterThanOrEqualTo(WorkerRarity.epic.index),
      );
    });

    test('pity triggers after threshold and resets streak on high rarity', () {
      final useCase = CraftArtifactUseCase();
      final cost = useCase.getCraftCost(WorkerRarity.common);
      final threshold = ArtifactForgeBalance.pityThreshold;

      final state = GameState.initial().copyWith(
        artifactDust: cost * (threshold + 1),
        artifactCraftStreak: threshold - 1,
      );

      final result = useCase.execute(state, minimumRarity: WorkerRarity.common);

      expect(result, isNotNull);
      expect(result!.pityTriggered, isTrue);
      expect(
        result.artifact.rarity.index,
        greaterThanOrEqualTo(WorkerRarity.legendary.index),
      );
      expect(result.newState.artifactCraftStreak, 0);
    });

    test(
      'target era crafting propagates selected era into crafted artifact',
      () {
        final useCase = CraftArtifactUseCase(random: _FixedRandom(0.0));
        final cost = useCase.getCraftCost(WorkerRarity.legendary);
        final state = GameState.initial().copyWith(artifactDust: cost);

        final result = useCase.execute(
          state,
          minimumRarity: WorkerRarity.legendary,
          targetEra: WorkerEra.atomicAge,
        );

        expect(result, isNotNull);
        expect(result!.artifact.rarity, WorkerRarity.legendary);
        expect(result.artifact.eraMatch, WorkerEra.atomicAge);
      },
    );
  });
}
