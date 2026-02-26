import 'package:time_factory/domain/entities/game_state.dart';

class ClaimDailyMissionResult {
  final GameState newState;
  final String missionId;

  const ClaimDailyMissionResult({
    required this.newState,
    required this.missionId,
  });
}

class ClaimDailyMissionUseCase {
  ClaimDailyMissionResult? execute(GameState state, String missionId) {
    final missionIndex = state.dailyMissions.indexWhere(
      (m) => m.id == missionId,
    );
    if (missionIndex == -1) return null;

    final mission = state.dailyMissions[missionIndex];
    if (!mission.isCompleted || mission.claimed) return null;

    final updatedMissions = [...state.dailyMissions];
    updatedMissions[missionIndex] = mission.copyWith(claimed: true);

    final rewardCE = mission.rewardCE;
    final rewardShards = mission.rewardShards;

    return ClaimDailyMissionResult(
      missionId: missionId,
      newState: state.copyWith(
        dailyMissions: updatedMissions,
        chronoEnergy: state.chronoEnergy + rewardCE,
        lifetimeChronoEnergy: state.lifetimeChronoEnergy + rewardCE,
        timeShards: state.timeShards + rewardShards,
      ),
    );
  }
}
