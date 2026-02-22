import 'package:time_factory/domain/entities/expedition.dart';
import 'package:time_factory/domain/entities/game_state.dart';

class ClaimExpeditionRewardsResult {
  final GameState newState;
  final ExpeditionReward reward;

  const ClaimExpeditionRewardsResult({
    required this.newState,
    required this.reward,
  });
}

class ClaimExpeditionRewardsUseCase {
  ClaimExpeditionRewardsResult? execute(
    GameState currentState,
    String expeditionId,
  ) {
    final index = currentState.expeditions.indexWhere(
      (e) => e.id == expeditionId,
    );
    if (index < 0) return null;

    final expedition = currentState.expeditions[index];
    if (!expedition.resolved) return null;

    final reward = expedition.resolvedReward ?? ExpeditionReward.zero;
    final updatedExpeditions = List<Expedition>.from(currentState.expeditions)
      ..removeAt(index);

    final newState = currentState.copyWith(
      expeditions: updatedExpeditions,
      chronoEnergy: currentState.chronoEnergy + reward.chronoEnergy,
      lifetimeChronoEnergy:
          currentState.lifetimeChronoEnergy + reward.chronoEnergy,
      timeShards: currentState.timeShards + reward.timeShards,
    );

    return ClaimExpeditionRewardsResult(newState: newState, reward: reward);
  }
}
