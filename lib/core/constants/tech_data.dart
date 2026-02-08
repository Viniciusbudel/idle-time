import 'package:time_factory/domain/entities/tech_upgrade.dart';

class TechData {
  static List<TechUpgrade> get initialTechs => [
    TechUpgrade(
      id: 'neural_sync',
      name: 'Neural Sync',
      description: 'Direct cortex link increases worker efficiency.',
      type: TechType.efficiency,
      baseCost: BigInt.from(100),
      costMultiplier: 1.5,
    ),
    TechUpgrade(
      id: 'flux_capacitor',
      name: 'Flux Capacitor',
      description: 'Stabilizes time flow for faster production ticks.',
      type: TechType.timeWarp,
      baseCost: BigInt.from(500),
      costMultiplier: 1.6,
    ),
    TechUpgrade(
      id: 'quantum_mining',
      name: 'Quantum Mining',
      description: 'Parallel universe mining operations.',
      type: TechType.efficiency,
      baseCost: BigInt.from(2500),
      costMultiplier: 1.8,
    ),
    TechUpgrade(
      id: 'auto_exoskeleton',
      name: 'Auto-Exoskeleton',
      description: 'Automated movement for idle workers.',
      type: TechType.automation,
      baseCost: BigInt.from(1000),
      costMultiplier: 1.4,
    ),
  ];

  static double calculateEfficiencyMultiplier(Map<String, int> techLevels) {
    double multiplier = 1.0;

    // Neural Sync
    final neuralLevel = techLevels['neural_sync'] ?? 0;
    multiplier += neuralLevel * 0.1;

    // Quantum Mining
    final quantumLevel = techLevels['quantum_mining'] ?? 0;
    multiplier += quantumLevel * 0.5; // Assuming Quantum is stronger

    return multiplier;
  }
}
