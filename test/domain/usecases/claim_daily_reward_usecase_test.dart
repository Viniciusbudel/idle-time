import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/usecases/claim_daily_reward_usecase.dart';
import 'package:time_factory/domain/usecases/hire_worker_usecase.dart';

// Manual Mock
class FakeHireWorkerUseCase implements HireWorkerUseCase {
  Worker? _lastExecutedWorker;
  WorkerRarity? _lastForceRarity;

  WorkerRarity? get lastForceRarity => _lastForceRarity;

  @override
  Worker execute(WorkerEra era, {WorkerRarity? forceRarity}) {
    _lastForceRarity = forceRarity;
    return _lastExecutedWorker ??
        Worker(
          id: 'test_worker',
          name: 'Test',
          rarity: forceRarity ?? WorkerRarity.common,
          baseProduction: BigInt.one,
          era: era,
        );
  }
}

void main() {
  late ClaimDailyRewardUseCase useCase;
  late FakeHireWorkerUseCase fakeHireWorkerUseCase;

  setUp(() {
    fakeHireWorkerUseCase = FakeHireWorkerUseCase();
    useCase = ClaimDailyRewardUseCase(fakeHireWorkerUseCase);
  });

  group('ClaimDailyRewardUseCase', () {
    test('First claim (no history) starts streak at 1', () {
      final state = GameState.initial();

      final result = useCase.execute(state);

      expect(result, isNotNull);
      expect(result!.newState.dailyLoginStreak, 1);
      expect(result.newState.lastDailyClaimTime, isNotNull);
      // Day 1 reward is CE
      expect(result.reward.day, 1);
      expect(result.newState.chronoEnergy > state.chronoEnergy, true);
    });

    test('Claim strictly < 24h same day returns null', () {
      // Setup state where last claim was today
      final now = DateTime.now();
      final state = GameState.initial().copyWith(
        lastDailyClaimTime: now.subtract(const Duration(hours: 1)),
        dailyLoginStreak: 1,
      );

      final result = useCase.execute(state);

      expect(result, isNull);
    });

    test('Claim > 48h resets streak to 1', () {
      // Last claim was 3 days ago
      final state = GameState.initial().copyWith(
        lastDailyClaimTime: DateTime.now().subtract(const Duration(days: 3)),
        dailyLoginStreak: 5,
      );

      final result = useCase.execute(state);

      expect(result, isNotNull);
      expect(result!.newState.dailyLoginStreak, 1);
      // Should be Day 1 reward again
      expect(result.reward.day, 1);
    });

    test('Claim next day (25h later) increments streak', () {
      // Last claim was yesterday
      final state = GameState.initial().copyWith(
        lastDailyClaimTime: DateTime.now().subtract(const Duration(hours: 25)),
        dailyLoginStreak: 1,
      );

      final result = useCase.execute(state);

      expect(result, isNotNull);
      expect(result!.newState.dailyLoginStreak, 2);
      expect(result.reward.day, 2);
    });

    test('Day 7 grants Worker', () {
      // Streak 6, claiming for Day 7
      final state = GameState.initial().copyWith(
        lastDailyClaimTime: DateTime.now().subtract(const Duration(hours: 25)),
        dailyLoginStreak: 6,
      );

      final result = useCase.execute(state);

      expect(result, isNotNull);
      expect(result!.newState.dailyLoginStreak, 7);
      expect(result.reward.day, 7);
      expect(result.unlockedWorker, isNotNull);
      expect(result.unlockedWorker!.rarity, WorkerRarity.paradox);

      // Verify forced rarity was used
      expect(fakeHireWorkerUseCase.lastForceRarity, WorkerRarity.paradox);
    });
  });
}
