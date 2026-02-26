import 'package:time_factory/domain/entities/daily_mission.dart';

enum MissionProgressEvent { hireWorker, mergeWorker, buyTechUpgrade }

class UpdateMissionProgressUseCase {
  List<DailyMission> execute(
    List<DailyMission> missions,
    MissionProgressEvent event, {
    int amount = 1,
  }) {
    if (missions.isEmpty || amount <= 0) return missions;

    final targetType = switch (event) {
      MissionProgressEvent.hireWorker => MissionType.hireWorkers,
      MissionProgressEvent.mergeWorker => MissionType.mergeWorkers,
      MissionProgressEvent.buyTechUpgrade => MissionType.buyTechUpgrades,
    };

    return missions.map((mission) {
      if (mission.type != targetType ||
          mission.claimed ||
          mission.isCompleted) {
        return mission;
      }

      final nextProgress = mission.progress + amount;
      return mission.copyWith(
        progress: nextProgress > mission.target ? mission.target : nextProgress,
      );
    }).toList();
  }
}
