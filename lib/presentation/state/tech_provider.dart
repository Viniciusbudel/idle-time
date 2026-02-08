import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/domain/entities/tech_upgrade.dart';
import 'package:time_factory/core/constants/tech_data.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/domain/usecases/check_tech_completion_usecase.dart';

/// Provider for the list of all tech upgrades
final techProvider = StateNotifierProvider<TechNotifier, List<TechUpgrade>>((
  ref,
) {
  return TechNotifier(ref);
});

class TechNotifier extends StateNotifier<List<TechUpgrade>> {
  final Ref ref;

  TechNotifier(this.ref) : super(_initialTechs()) {
    _syncWithGameState();
  }

  void _syncWithGameState() {
    final gameState = ref.read(gameStateProvider);
    if (gameState.techLevels.isEmpty) return;

    final newState = [...state];
    for (int i = 0; i < newState.length; i++) {
      final techId = newState[i].id;
      if (gameState.techLevels.containsKey(techId)) {
        newState[i] = newState[i].copyWith(
          level: gameState.techLevels[techId]!,
        );
      }
    }
    state = newState;
  }

  static List<TechUpgrade> _initialTechs() {
    return TechData.initialTechs;
  }

  /// Try to purchase an upgrade
  bool purchaseUpgrade(String id) {
    final index = state.indexWhere((t) => t.id == id);
    if (index == -1) return false;

    final tech = state[index];
    final cost = tech.nextCost;

    // Check affordablity
    final gameState = ref.read(gameStateProvider);
    if (gameState.chronoEnergy < cost) return false;

    // Spend CE
    if (ref.read(gameStateProvider.notifier).spendChronoEnergy(cost)) {
      final newLevel = tech.level + 1;
      final newTech = tech.copyWith(level: newLevel);
      final newState = [...state];
      newState[index] = newTech;
      state = newState;

      // Update GameState for persistence
      ref.read(gameStateProvider.notifier).updateTechLevel(id, newLevel);

      return true;
    }

    return false;
  }

  // Calculate total bonuses
  double get efficiencyMultiplier {
    final gameState = ref.read(gameStateProvider);
    return TechData.calculateEfficiencyMultiplier(gameState.techLevels);
  }

  double get timeWarpMultiplier {
    final gameState = ref.read(gameStateProvider);
    return TechData.calculateTimeWarpMultiplier(gameState.techLevels);
  }

  int get automationLevel {
    // For now, mapping clockwork_metronome level to automation logic
    final gameState = ref.read(gameStateProvider);
    return gameState.techLevels['clockwork_metronome'] ?? 0;
  }
}

// Helper providers for specific boosts
final efficiencyMultiplierProvider = Provider<double>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return TechData.calculateEfficiencyMultiplier(gameState.techLevels);
});

final timeWarpMultiplierProvider = Provider<double>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return TechData.calculateTimeWarpMultiplier(gameState.techLevels);
});

final automationLevelProvider = Provider<int>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return gameState.techLevels['clockwork_metronome'] ?? 0;
});

// NEW: Filtered list for the current era
final currentEraTechsProvider = Provider<List<TechUpgrade>>((ref) {
  final techs = ref.watch(techProvider);
  final gameState = ref.watch(gameStateProvider);
  return techs.where((t) => t.eraId == gameState.currentEraId).toList();
});

// NEW: Check if current era is complete

final isEraCompleteProvider = Provider<bool>((ref) {
  final gameState = ref.watch(gameStateProvider);
  final useCase = CheckTechCompletionUseCase();
  return useCase.execute(gameState, gameState.currentEraId);
});
