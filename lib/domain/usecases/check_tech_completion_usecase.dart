import 'package:time_factory/core/constants/tech_data.dart';
import 'package:time_factory/domain/entities/game_state.dart';

class CheckTechCompletionUseCase {
  /// Checks if all techs in the given era are at max level
  bool execute(GameState state, String eraId) {
    // 1. Get all techs belonging to this era
    final eraTechs = TechData.initialTechs
        .where((t) => t.eraId == eraId)
        .toList();

    if (eraTechs.isEmpty) {
      // If no techs exist for this era, technically it's "complete" or we can default to true/false depending on design.
      // Assuming empty era means nothing to upgrade, so complete.
      return true;
    }

    // 2. Check if every tech is maxed in GameState
    for (final tech in eraTechs) {
      final currentLevel = state.techLevels[tech.id] ?? 0;
      if (currentLevel < tech.maxLevel) {
        return false;
      }
    }

    return true;
  }
}
