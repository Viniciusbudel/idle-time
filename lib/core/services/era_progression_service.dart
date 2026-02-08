import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/game_constants.dart';

import 'package:time_factory/presentation/state/game_state_provider.dart';

/// Service to handle era progression logic
class EraProgressionService {
  final Ref ref;

  EraProgressionService(this.ref);

  /// Get the ID of the next era in the sequence
  String? getNextEra(String currentEraId) {
    final currentIndex = GameConstants.eraOrder.indexOf(currentEraId);
    if (currentIndex == -1 ||
        currentIndex >= GameConstants.eraOrder.length - 1) {
      return null; // Last era or invalid
    }
    return GameConstants.eraOrder[currentIndex + 1];
  }

  /// Get the cost to unlock the next era
  BigInt? getNextEraCost(String currentEraId) {
    final nextEraId = getNextEra(currentEraId);
    if (nextEraId == null) return null;

    final cost = GameConstants.eraUnlockThresholds[nextEraId];
    return cost != null ? BigInt.from(cost) : null;
  }

  /// Check if the player can afford to advance to the next era
  bool canAdvance(String currentEraId) {
    final cost = getNextEraCost(currentEraId);
    if (cost == null) return false;

    final currentCE = ref.read(gameStateProvider).chronoEnergy;
    return currentCE >= cost;
  }

  /// Advance to the next era
  /// Returns true if successful, false otherwise
  bool advanceEra() {
    final gameState = ref.read(gameStateProvider);
    final currentEraId = gameState.currentEraId;
    final nextEraId = getNextEra(currentEraId);
    final cost = getNextEraCost(currentEraId);

    if (nextEraId == null || cost == null) return false;

    if (gameState.chronoEnergy < cost) {
      return false; // Not enough CE
    }

    // Deduct CE and update currentEraId + unlockedEras
    ref.read(gameStateProvider.notifier).advanceEra(nextEraId, cost);

    return true;
  }
}

/// Provider for EraProgressionService
final eraProgressionServiceProvider = Provider<EraProgressionService>((ref) {
  return EraProgressionService(ref);
});
