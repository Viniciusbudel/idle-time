import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/domain/entities/tech_upgrade.dart';
import 'package:time_factory/core/constants/tech_data.dart';
import 'package:time_factory/core/constants/game_constants.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/domain/entities/enums.dart';

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

    // 1. Calculate cost with discount
    final gameState = ref.read(gameStateProvider);
    final discount = TechData.calculateCostReductionMultiplier(
      gameState.techLevels,
    );
    final cost = tech.getCost(discountMultiplier: discount);

    // Check affordablity
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

      // Handle Era Unlock Techs
      if (tech.type == TechType.eraUnlock || tech.type == TechType.manhattan) {
        final eraOrder = GameConstants.eraOrder;
        final currentEraIndex = eraOrder.indexOf(tech.eraId);
        if (currentEraIndex != -1 && currentEraIndex < eraOrder.length - 1) {
          final nextEraId = eraOrder[currentEraIndex + 1];
          try {
            final nextEra = WorkerEra.values.firstWhere(
              (e) => e.id == nextEraId,
            );
            ref.read(gameStateProvider.notifier).unlockEra(nextEra);
          } catch (e) {
            // Era not found in enum
          }
        }
      }

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
// optimized to only rebuild when era changes or tech list changes
final currentEraTechsProvider = Provider<List<TechUpgrade>>((ref) {
  final techs = ref.watch(techProvider);
  final currentEraId = ref.watch(
    gameStateProvider.select((s) => s.currentEraId),
  );
  return techs.where((t) => t.eraId == currentEraId).toList();
});

// NEW: Check if current era is complete
// Optimized to not rebuild on every tick
final isEraCompleteProvider = Provider<bool>((ref) {
  // We can just check if all techs in currentEraTechsProvider are maxed.
  final currentEraTechs = ref.watch(currentEraTechsProvider);
  if (currentEraTechs.isEmpty) return true;

  for (final tech in currentEraTechs) {
    if (tech.level < tech.maxLevel) {
      return false;
    }
  }
  return true;
});

// Provider for the next era ID
final nextEraIdProvider = Provider<String?>((ref) {
  final currentEraId = ref.watch(
    gameStateProvider.select((s) => s.currentEraId),
  );
  final eraOrder = GameConstants.eraOrder;
  final currentIndex = eraOrder.indexOf(currentEraId);
  if (currentIndex == -1 || currentIndex >= eraOrder.length - 1) {
    return null;
  }
  return eraOrder[currentIndex + 1];
});

// Provider for the cost of the next era
final nextEraCostProvider = Provider<BigInt>((ref) {
  final nextEraId = ref.watch(nextEraIdProvider);
  if (nextEraId == null) return BigInt.zero;

  final threshold = GameConstants.eraUnlockThresholds[nextEraId] ?? 0;
  return BigInt.from(threshold);
});

// Provider to check if we can afford the next era
// This ONE will update frequently, but only the button will listen to it
final canAffordNextEraProvider = Provider<bool>((ref) {
  final cost = ref.watch(nextEraCostProvider);
  final chronoEnergy = ref.watch(
    gameStateProvider.select((s) => s.chronoEnergy),
  );
  return chronoEnergy >= cost;
});
