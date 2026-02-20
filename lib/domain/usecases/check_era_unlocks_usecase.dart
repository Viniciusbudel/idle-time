import '../entities/game_state.dart';

class CheckEraUnlocksUseCase {
  GameState execute(GameState state) {
    final thresholds = {
      'roaring_20s': BigInt.from(1000),
      // 'atomic_age': Unlocks via Manhattan Project Tech
      'cyberpunk_80s': BigInt.from(10000000),
      'neo_tokyo': BigInt.from(1000000000),
      'post_singularity': BigInt.from(100000000000),
      'ancient_rome': BigInt.from(10000000000000),
      'far_future': BigInt.from(1000000000000000),
    };

    final newUnlocks = <String>{};
    for (final entry in thresholds.entries) {
      if (!state.unlockedEras.contains(entry.key) &&
          state.lifetimeChronoEnergy >= entry.value) {
        newUnlocks.add(entry.key);
      }
    }

    if (newUnlocks.isNotEmpty) {
      return state.copyWith(
        unlockedEras: {...state.unlockedEras, ...newUnlocks},
      );
    }
    return state;
  }
}
