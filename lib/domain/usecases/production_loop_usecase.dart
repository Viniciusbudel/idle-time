import 'package:time_factory/domain/entities/game_state.dart';

/// Result of a single production loop tick
class ProductionLoopResult {
  final GameState newState;
  final BigInt ceAdded;
  final double fractionalRemainder;
  final double paradoxAdded;

  const ProductionLoopResult({
    required this.newState,
    required this.ceAdded,
    required this.fractionalRemainder,
    required this.paradoxAdded,
  });
}

/// Use case to calculate resource production over a time delta.
/// Handles fractional accumulation and state updates.
class ProductionLoopUseCase {
  ProductionLoopResult execute({
    required GameState currentState,
    required double dt,
    required BigInt productionRate, // Base production (CE/sec)
    required double techMultiplier, // Efficiency multiplier
    required double currentFractionalAccumulator,
    BigInt?
    additionalProduction, // NEW: For auto-clicks or other instant bonuses
  }) {
    // 1. Calculate effective production for this delta
    // productionRate is BigInt, so we need to be careful with precision if we convert to double
    // But for "per second", double is usually fine for the fractional part

    // Effective Rate = Base * Multiplier
    // scale production to double for frame-based calculation
    // limitation: if production is > 1e308, double loses precision.
    // But this is an idle game, numbers get big.
    // However, dt is small (~0.033).

    // Better approach:
    // Calculate BigInt part separate from fractional part?
    // Let's stick to the current logic which uses double for the "production per second" * dt
    // If production is massive, _fractionalAccumulator approach might lose precision.

    // safeProductionRate = productionRate * techMultiplier
    double safeProductionRate = productionRate.toDouble() * techMultiplier;

    // If production is extremely large, double might not be precise enough.
    // But for now, let's assume it fits.

    final rawProduction = safeProductionRate * dt;
    final totalAccumulated =
        currentFractionalAccumulator +
        rawProduction +
        (additionalProduction?.toDouble() ?? 0.0);

    final amountToAdd = BigInt.from(totalAccumulated.floor());
    final newFractional = totalAccumulated - amountToAdd.toDouble();

    // 2. Paradox Accumulation
    // Paradox rate is usually small (< 1.0 per second)
    final paradoxRate = currentState.paradoxPerSecond;
    final paradoxAdded = paradoxRate * dt;

    // 3. Apply to state
    GameState newState = currentState;

    if (amountToAdd > BigInt.zero) {
      final newCe = currentState.chronoEnergy + amountToAdd;
      final newLifetime = currentState.lifetimeChronoEnergy + amountToAdd;
      newState = newState.copyWith(
        chronoEnergy: newCe,
        lifetimeChronoEnergy: newLifetime,
      );
    }

    if (paradoxAdded > 0) {
      final newParadox = (currentState.paradoxLevel + paradoxAdded).clamp(
        0.0,
        1.0,
      );
      newState = newState.copyWith(paradoxLevel: newParadox);
    }

    return ProductionLoopResult(
      newState: newState,
      ceAdded: amountToAdd,
      fractionalRemainder: newFractional,
      paradoxAdded: paradoxAdded,
    );
  }
}
