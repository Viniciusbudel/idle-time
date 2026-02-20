import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/entities/enums.dart';

class ValidateToFitResult {
  final bool canFit;
  final String? reason;
  final BigInt cost;

  ValidateToFitResult({required this.canFit, this.reason, required this.cost});
}

class FitWorkerToEraUseCase {
  /// Calculate the cost to fit a worker to the current era
  /// Cost formula: Base Hire Cost of Current Era * 5 * (Era Gap + 1) * Rarity Multiplier / 2
  BigInt calculateCost(Worker worker, WorkerEra currentEra) {
    if (worker.era == currentEra) return BigInt.zero;

    // Era Gap: How many eras behind is the worker?
    final gap = _calculateEraGap(worker.era, currentEra);
    if (gap <= 0)
      return BigInt.zero; // Should not happen if eras are ordered correctly

    final baseCost = currentEra.hireCost;
    final rarityMult = worker.rarity.productionMultiplier;

    // Expensive operation: Bringing a relic to modern standards
    // Formula designed to be very pricey but worth it for high rarity/level workers
    final rawCost = baseCost.toDouble() * 5.0 * (gap + 1) * (rarityMult / 2.0);

    return BigInt.from(rawCost);
  }

  /// Validate if a worker can be fitted
  ValidateToFitResult validate(Worker worker, GameState state) {
    final currentEraId = state.currentEraId;
    final currentEra = WorkerEra.values.firstWhere((e) => e.id == currentEraId);

    // 1. Must be from a previous era
    if (worker.era == currentEra) {
      return ValidateToFitResult(
        canFit: false,
        reason: 'Worker is already in the current era.',
        cost: BigInt.zero,
      );
    }

    // Check if worker is from a future era (shouldn't happen but safe guard)
    if (_calculateEraGap(worker.era, currentEra) < 0) {
      return ValidateToFitResult(
        canFit: false,
        reason: 'Worker is from a future era.',
        cost: BigInt.zero,
      );
    }

    // 2. Must afford cost
    final cost = calculateCost(worker, currentEra);
    if (state.chronoEnergy < cost) {
      return ValidateToFitResult(
        canFit: false,
        reason: 'Insufficient Chrono-Energy.',
        cost: cost,
      );
    }

    // 3. Must not be deployed?
    // Actually, we can fit deployed workers, their stats just update in place.
    // So no restriction there.

    return ValidateToFitResult(canFit: true, cost: cost);
  }

  /// Execute the fitting
  /// Returns updated GameState (with spent CE and updated worker)
  GameState execute(Worker worker, GameState state) {
    final currentEraId = state.currentEraId;
    final currentEra = WorkerEra.values.firstWhere((e) => e.id == currentEraId);

    final validation = validate(worker, state);
    if (!validation.canFit) {
      throw Exception(validation.reason ?? 'Cannot fit worker');
    }

    // Deduct cost
    final newCe = state.chronoEnergy - validation.cost;

    // Create updated worker
    // We keep level, rarity, name. We update Era and Base Production logic.
    // Note: The `Worker` class calculates `currentProduction` based on its properties.
    // When we change the Era, the `currentProduction` getter automatically uses the new era's multiplier.
    // However, `baseProduction` might need a bump?
    // Actually, `baseProduction` is usually constant (e.g. 5 or 10) and scaling comes from multipliers.
    // So usually just switching the Era is enough to massively boost stats due to `era.multiplier`.

    final updatedWorker = worker.copyWith(era: currentEra);

    // Update worker in map
    final newWorkers = Map<String, Worker>.from(state.workers);
    newWorkers[worker.id] = updatedWorker;

    return state.copyWith(chronoEnergy: newCe, workers: newWorkers);
  }

  int _calculateEraGap(WorkerEra source, WorkerEra target) {
    return target.index - source.index;
  }
}
