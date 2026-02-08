import 'package:time_factory/domain/entities/tech_upgrade.dart';

class TechData {
  static List<TechUpgrade> get initialTechs => [
    // Tier 1
    TechUpgrade(
      id: 'steam_boilers',
      name: 'Pressurized Boilers',
      description: 'Higher pressure means more power.',
      type: TechType.efficiency,
      baseCost: BigInt.from(100),
      costMultiplier: 1.5,
      eraId: 'victorian',
      maxLevel: 10,
    ),
    TechUpgrade(
      id: 'lubricated_gears',
      name: 'Lubricated Gears',
      description: 'A drop of oil saves an hour of toil.',
      type: TechType.timeWarp, // Using timeWarp for speed
      baseCost: BigInt.from(250),
      costMultiplier: 1.6,
      eraId: 'victorian',
      maxLevel: 5,
    ),
    // Tier 2
    TechUpgrade(
      id: 'brass_standardization',
      name: 'Brass Standardization',
      description: 'Interchangeable parts reduce costs.',
      type: TechType.costReduction,
      baseCost: BigInt.from(500),
      costMultiplier: 1.4,
      eraId: 'victorian',
      maxLevel: 5,
    ),
    TechUpgrade(
      id: 'clockwork_metronome',
      name: 'Clockwork Metronome',
      description: 'Rhythm improves automation.',
      type: TechType.automation,
      baseCost: BigInt.from(1000),
      costMultiplier: 1.5,
      eraId: 'victorian',
      maxLevel: 3,
    ),
    // Tier 3
    TechUpgrade(
      id: 'analytical_engine',
      name: 'Analytical Engine',
      description: 'Calculating profits while you sleep.',
      type: TechType.offline,
      baseCost: BigInt.from(5000),
      costMultiplier: 1.8,
      eraId: 'victorian',
      maxLevel: 5,
    ),
    // Capstone
    TechUpgrade(
      id: 'difference_engine',
      name: 'Difference Engine',
      description: 'The future is automatic. Unlocks next Era.',
      type: TechType.eraUnlock,
      baseCost: BigInt.from(10000),
      costMultiplier: 2.0,
      eraId: 'victorian',
      maxLevel: 1,
    ),
    // Tier 2 - New add
    TechUpgrade(
      id: 'steam_piston',
      name: 'Steam-Powered Piston',
      description: 'Why push when steam can shove?',
      type: TechType.clickPower,
      baseCost: BigInt.from(750),
      costMultiplier: 1.5,
      eraId: 'victorian',
      maxLevel: 5,
    ),
  ];

  static double calculateEfficiencyMultiplier(Map<String, int> techLevels) {
    double multiplier = 1.0;

    // Pressurized Boilers (Efficiency)
    final boilerLevel = techLevels['steam_boilers'] ?? 0;
    multiplier += boilerLevel * 0.1; // +10% per level

    // Clockwork Metronome (Efficiency/Automation) - Adding small passive boost?
    // The design said "Rhythm Bonus", maybe just raw efficiency for now
    final metronomeLevel = techLevels['clockwork_metronome'] ?? 0;
    multiplier += metronomeLevel * 0.05; // +5% per level

    return multiplier;
  }

  static double calculateTimeWarpMultiplier(Map<String, int> techLevels) {
    double multiplier = 1.0;
    // Lubricated Gears - +5% per level (changed from 10% in description to balance)
    final gearsLevel = techLevels['lubricated_gears'] ?? 0;
    multiplier += gearsLevel * 0.05;
    return multiplier;
  }

  static double calculateCostReductionMultiplier(Map<String, int> techLevels) {
    double multiplier = 1.0;
    // Brass Standardization - Cost becomes (1.0 - (level * 0.05))
    final brassLevel = techLevels['brass_standardization'] ?? 0;
    multiplier -= brassLevel * 0.05;
    return multiplier.clamp(0.1, 1.0); // Cap at 90% reduction
  }

  static double calculateOfflineEfficiencyMultiplier(
    Map<String, int> techLevels,
  ) {
    double multiplier = 1.0;
    // Analytical Engine - +10% per level
    final engineLevel = techLevels['analytical_engine'] ?? 0;
    multiplier += engineLevel * 0.1;
    return multiplier;
  }
}
