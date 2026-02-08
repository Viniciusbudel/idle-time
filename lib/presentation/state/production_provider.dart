import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/state/tech_provider.dart';

/// Production per second (including Tech bonuses)
/// Avoiding circular dependency by placing this in a separate file
/// Production per second (including Tech bonuses)
/// Returning double to support fractional tech bonuses on low production
final productionPerSecondProvider = Provider<double>((ref) {
  final production = ref
      .watch(gameStateProvider.select((s) => s.productionPerSecond))
      .toDouble();
  final techEfficiency = ref.watch(efficiencyMultiplierProvider);

  // Apply Tech Multiplier (multiplicative)
  return production * techEfficiency;
});

class ProductionBreakdown {
  final double base;
  final double techMultiplier;
  final double total;

  ProductionBreakdown({
    required this.base,
    required this.techMultiplier,
    required this.total,
  });
}

final productionBreakdownProvider = Provider<ProductionBreakdown>((ref) {
  final base = ref
      .watch(gameStateProvider.select((s) => s.productionPerSecond))
      .toDouble();
  final techEfficiency = ref.watch(efficiencyMultiplierProvider);
  return ProductionBreakdown(
    base: base,
    techMultiplier: techEfficiency,
    total: base * techEfficiency,
  );
});

/// Tap strength (10 + 10% of production/sec)
final tapStrengthProvider = Provider<BigInt>((ref) {
  final production = ref.watch(productionPerSecondProvider);
  // Truncate for tap strength, that's fine
  return BigInt.from(10) + BigInt.from((production / 10).toInt());
});
