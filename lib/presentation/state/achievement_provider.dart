import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/achievement.dart';
import 'game_state_provider.dart';

/// Provider that exposes the list of newly unlocked achievements
/// Watches game state and checks all achievement triggers
final achievementCheckerProvider = Provider<List<AchievementType>>((ref) {
  final state = ref.watch(gameStateProvider);
  final unlocked = state.unlockedAchievements;

  // Find achievements that are triggered but not yet persisted
  return AchievementType.values
      .where((a) => !unlocked.contains(a.id) && a.checkUnlocked(state))
      .toList();
});

/// Provider that returns all achievements with their unlock status
final allAchievementsProvider =
    Provider<List<({AchievementType type, bool unlocked, double progress})>>((
      ref,
    ) {
      final state = ref.watch(gameStateProvider);
      return AchievementType.values.map((a) {
        return (
          type: a,
          unlocked: state.unlockedAchievements.contains(a.id),
          progress: a.getProgress(state),
        );
      }).toList();
    });
