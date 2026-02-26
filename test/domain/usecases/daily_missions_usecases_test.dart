import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/daily_mission.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/usecases/claim_daily_mission_usecase.dart';
import 'package:time_factory/domain/usecases/generate_daily_missions_usecase.dart';
import 'package:time_factory/domain/usecases/update_mission_progress_usecase.dart';

void main() {
  group('Daily mission use cases', () {
    test('GenerateDailyMissionsUseCase is deterministic for the same day', () {
      final useCase = GenerateDailyMissionsUseCase();
      final day = DateTime(2026, 2, 22, 10, 30);

      final first = useCase.execute(day);
      final second = useCase.execute(DateTime(2026, 2, 22, 21, 10));

      expect(first.length, 3);
      expect(second.length, 3);
      expect(first.map((m) => m.id).toList(), second.map((m) => m.id).toList());
      expect(
        first.map((m) => m.target).toList(),
        second.map((m) => m.target).toList(),
      );
    });

    test('GenerateDailyMissionsUseCase rotates mission IDs on a new day', () {
      final useCase = GenerateDailyMissionsUseCase();
      final dayOne = useCase.execute(DateTime(2026, 2, 22, 8, 0));
      final dayTwo = useCase.execute(DateTime(2026, 2, 23, 8, 0));

      expect(
        dayOne.map((m) => m.id).toList(),
        isNot(dayTwo.map((m) => m.id).toList()),
      );
    });

    test('UpdateMissionProgressUseCase increments and caps progress', () {
      final useCase = UpdateMissionProgressUseCase();
      final missions = [
        DailyMission(
          id: 'hire',
          type: MissionType.hireWorkers,
          target: 3,
          progress: 2,
        ),
      ];

      final updated = useCase.execute(
        missions,
        MissionProgressEvent.hireWorker,
        amount: 5,
      );

      expect(updated.first.progress, 3);
      expect(updated.first.isCompleted, isTrue);
    });

    test('ClaimDailyMissionUseCase claims once and is idempotent', () {
      final claimUseCase = ClaimDailyMissionUseCase();
      final completedMission = DailyMission(
        id: 'mission_1',
        type: MissionType.mergeWorkers,
        target: 1,
        progress: 1,
        claimed: false,
        rewardCE: BigInt.from(5000),
        rewardShards: 4,
      );

      final state = GameState.initial().copyWith(
        chronoEnergy: BigInt.zero,
        lifetimeChronoEnergy: BigInt.zero,
        timeShards: 0,
        dailyMissions: [completedMission],
      );

      final firstClaim = claimUseCase.execute(state, 'mission_1');
      expect(firstClaim, isNotNull);
      expect(firstClaim!.newState.dailyMissions.first.claimed, isTrue);
      expect(firstClaim.newState.chronoEnergy, BigInt.from(5000));
      expect(firstClaim.newState.lifetimeChronoEnergy, BigInt.from(5000));
      expect(firstClaim.newState.timeShards, 4);

      final secondClaim = claimUseCase.execute(
        firstClaim.newState,
        'mission_1',
      );
      expect(secondClaim, isNull);
    });

    test('ClaimDailyMissionUseCase rejects incomplete mission', () {
      final claimUseCase = ClaimDailyMissionUseCase();
      final mission = DailyMission(
        id: 'mission_2',
        type: MissionType.buyTechUpgrades,
        target: 2,
        progress: 1,
      );

      final state = GameState.initial().copyWith(dailyMissions: [mission]);
      final result = claimUseCase.execute(state, 'mission_2');

      expect(result, isNull);
    });
  });
}
