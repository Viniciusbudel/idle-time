import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/domain/entities/tech_upgrade.dart';
import 'package:time_factory/core/constants/tech_data.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';

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
    final tech = state.firstWhere((t) => t.id == 'neural_sync');
    return 1.0 + (tech.level * 0.1); // +10% per level
  }

  double get timeWarpMultiplier {
    final tech = state.firstWhere((t) => t.id == 'flux_capacitor');
    return 1.0 + (tech.level * 0.05); // +5% per level
  }

  int get automationLevel {
    final tech = state.firstWhere((t) => t.id == 'auto_exoskeleton');
    return tech.level;
  }
}

// Helper providers for specific boosts
final efficiencyMultiplierProvider = Provider<double>((ref) {
  final techs = ref.watch(techProvider);
  final tech = techs.firstWhere(
    (t) => t.id == 'neural_sync',
    orElse: () => techs.first,
  );
  // Fallback if not found (shouldn't happen with correct IDs)
  if (tech.id != 'neural_sync') return 1.0;
  return 1.0 + (tech.level * 0.1);
});

final timeWarpMultiplierProvider = Provider<double>((ref) {
  final techs = ref.watch(techProvider);
  final tech = techs.firstWhere(
    (t) => t.id == 'flux_capacitor',
    orElse: () => techs.first,
  );
  if (tech.id != 'flux_capacitor') return 1.0;
  return 1.0 + (tech.level * 0.05);
});

final automationLevelProvider = Provider<int>((ref) {
  final techs = ref.watch(techProvider);
  final tech = techs.firstWhere(
    (t) => t.id == 'auto_exoskeleton',
    orElse: () => techs.first,
  );
  if (tech.id != 'auto_exoskeleton') return 0;
  return tech.level;
});
