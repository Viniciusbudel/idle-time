import 'package:time_factory/domain/entities/daily_mission.dart';

class GenerateDailyMissionsUseCase {
  List<DailyMission> execute(DateTime now) {
    final day = DateTime(now.year, now.month, now.day);
    final rotation = day.day % 3;
    final dayKey = '${day.year}${day.month}${day.day}';

    final hireTarget = 3 + rotation;
    final mergeTarget = 1 + (rotation == 2 ? 1 : 0);
    final techTarget = 2 + (rotation == 1 ? 1 : 0);

    return [
      DailyMission(
        id: '${dayKey}_hire',
        type: MissionType.hireWorkers,
        target: hireTarget,
        rewardCE: BigInt.from(1000 * hireTarget),
        rewardShards: 3 + rotation,
      ),
      DailyMission(
        id: '${dayKey}_merge',
        type: MissionType.mergeWorkers,
        target: mergeTarget,
        rewardCE: BigInt.from(3000 * mergeTarget),
        rewardShards: 4 + rotation,
      ),
      DailyMission(
        id: '${dayKey}_tech',
        type: MissionType.buyTechUpgrades,
        target: techTarget,
        rewardCE: BigInt.from(2500 * techTarget),
        rewardShards: 5 + rotation,
      ),
    ];
  }
}
