import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/daily_reward.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/usecases/hire_worker_usecase.dart';

class ClaimDailyRewardResult {
  final GameState newState;
  final DailyReward reward;
  final Worker? unlockedWorker; // If reward was a worker

  ClaimDailyRewardResult(this.newState, this.reward, {this.unlockedWorker});
}

class ClaimDailyRewardUseCase {
  final HireWorkerUseCase _hireWorkerUseCase;

  ClaimDailyRewardUseCase(this._hireWorkerUseCase);

  /// Execute the claim. Returns null if not claimable.
  ClaimDailyRewardResult? execute(GameState state) {
    final now = DateTime.now();
    final lastClaim = state.lastDailyClaimTime;

    // 1. Check if already claimed today
    if (lastClaim != null) {
      final difference = now.difference(lastClaim);
      if (difference.inHours < 24 && now.day == lastClaim.day) {
        // Simple check: if same calendar day, strictly blocked.
        // Or better: 24h cooldown?
        // Let's use calendar day for simplicity in mobile games (reset at midnight local).
        // Actually, simple 24h cooldown is annoying if play times drift.
        // Better: Reset at specific time or just "next calendar day".
        // Let's stick to: If Same Day, Blocked.
        return null;
      }
    }

    // 2. Calculate Streak
    int newStreak = state.dailyLoginStreak;
    if (lastClaim == null) {
      newStreak = 1;
    } else {
      final today = DateTime(now.year, now.month, now.day);
      final lastDay = DateTime(lastClaim.year, lastClaim.month, lastClaim.day);
      final difference = today.difference(lastDay).inDays;

      if (difference >= 2) {
        // Missed a day! Reset.
        newStreak = 1;
      } else if (difference == 1) {
        // Continued streak
        newStreak++;
      } else {
        // Sameday claim attempt - shouldn't happen due to previous check, but safeguard:
        return null;
      }
    }

    // 3. Determine Reward (Cycle 1-7)
    // streak 1 -> day 1 (index 0)
    final dayIndex = (newStreak - 1) % 7;
    final reward = DailyReward.weekRewards[dayIndex];

    // 4. Apply Reward
    var newState = state.copyWith(
      lastDailyClaimTime: now,
      dailyLoginStreak: newStreak,
    );

    Worker? newWorker;

    switch (reward.type) {
      case DailyRewardType.chronoEnergy:
        if (reward.amountCE != null) {
          newState = newState.copyWith(
            chronoEnergy: newState.chronoEnergy + reward.amountCE!,
            lifetimeChronoEnergy:
                newState.lifetimeChronoEnergy + reward.amountCE!,
          );
        }
        break;
      case DailyRewardType.timeShard:
        if (reward.amountShards != null) {
          newState = newState.copyWith(
            timeShards: newState.timeShards + reward.amountShards!,
          );
        }
        break;
      case DailyRewardType.worker:
        if (reward.workerRarity != null) {
          // Hire worker of specific rarity for current era
          final currentEra = WorkerEra.values.firstWhere(
            (e) => e.id == state.currentEraId,
            orElse: () => WorkerEra.victorian,
          );

          final worker = _hireWorkerUseCase.execute(
            currentEra,
            forceRarity: reward.workerRarity,
          );

          newWorker = worker;

          final updatedWorkers = Map<String, Worker>.from(state.workers);
          updatedWorkers[worker.id] = worker;

          newState = newState.copyWith(workers: updatedWorkers);
        }
        break;
    }

    return ClaimDailyRewardResult(newState, reward, unlockedWorker: newWorker);
  }

  /// Check if reward is available without claiming
  bool isRewardAvailable(GameState state) {
    if (state.lastDailyClaimTime == null) return true;

    final now = DateTime.now();
    final last = state.lastDailyClaimTime!;

    // Check if it's a different calendar day based on local time
    if (now.year > last.year) return true;
    if (now.year == last.year && now.month > last.month) return true;
    if (now.year == last.year && now.month == last.month && now.day > last.day)
      return true;

    return false;
  }

  /// Get current streak (calculating reset if needed for display)
  int getCurrentStreak(GameState state) {
    if (state.lastDailyClaimTime == null) return 0;

    final now = DateTime.now();
    final last = state.lastDailyClaimTime!;

    // Calculate days difference by zeroing out time components
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(last.year, last.month, last.day);
    final difference = today.difference(lastDay).inDays;

    if (difference >= 2) {
      return 0;
    }
    return state.dailyLoginStreak;
  }
}
