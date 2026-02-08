import '../entities/game_state.dart';

class PrestigeUseCase {
  GameState execute(GameState currentState) {
    if (!currentState.canPrestige) return currentState;

    final pointsGained = currentState.prestigePointsToGain;
    final eraInsightLevel = currentState.paradoxPointsSpent['era_insight'] ?? 0;

    // Reset to initial but keep prestige progress
    return GameState.initial().copyWith(
      prestigeLevel: currentState.prestigeLevel + 1,
      availableParadoxPoints:
          currentState.availableParadoxPoints + pointsGained,
      paradoxPointsSpent: currentState.paradoxPointsSpent,
      totalPrestiges: currentState.totalPrestiges + 1,
      unlockedEras: _calculateStartingEras(eraInsightLevel),
    );
  }

  Set<String> _calculateStartingEras(int eraInsightLevel) {
    final allEras = [
      'victorian',
      'roaring_20s',
      'atomic_age',
      'cyberpunk_80s',
      'neo_tokyo',
      'post_singularity',
      'ancient_rome',
      'far_future',
    ];
    final unlockedCount = (1 + eraInsightLevel).clamp(1, allEras.length);
    return allEras.sublist(0, unlockedCount).toSet();
  }
}
