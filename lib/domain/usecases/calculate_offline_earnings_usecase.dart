import 'package:time_factory/core/constants/tech_data.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/offline_earnings.dart';

class CalculateOfflineEarningsUseCase {
  OfflineEarnings? execute(GameState state) {
    // Prefer lastTickTime as it represents the actual last moment of simulation
    final lastTime = state.lastTickTime ?? state.lastSaveTime;
    if (lastTime == null) return null;

    // 1. Calculate duration
    final now = DateTime.now();
    final difference = now.difference(lastTime);

    // Minimum 1 minute to count
    if (difference.inMinutes < 1) {
      return null;
    }

    // Cap at 24 hours
    Duration effectiveDuration = difference;
    if (difference.inHours > 24) {
      effectiveDuration = const Duration(hours: 24);
    }

    // 2. Calculate Rate
    // Base Production (without Tech) from GameState
    final baseRate = state.productionPerSecond.toDouble();

    // Tech Multiplier from TechData
    final techMultiplier = TechData.calculateEfficiencyMultiplier(
      state.techLevels,
    );

    // Total Rate per second
    final totalRate = baseRate * techMultiplier;

    // 3. Efficiency (Offline Penalty)
    // GameState has a getter for this which includes 'offline_bonus' from paradox points
    final efficiency = state.offlineEfficiency;

    // 4. Total Earned
    // Rate * Seconds * Efficiency
    final earned = totalRate * effectiveDuration.inSeconds * efficiency;

    return OfflineEarnings(
      ceEarned: BigInt.from(earned),
      offlineDuration: difference, // Show actual time away
      efficiency: efficiency,
    );
  }
}
