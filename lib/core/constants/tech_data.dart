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
      id: 'centrifugal_governor',
      name: 'Centrifugal Governor',
      description: 'The spinning balls of industry. Stabilizes steam flow.',
      type: TechType.timeWarp,
      baseCost: BigInt.from(250),
      costMultiplier: 1.6,
      eraId: 'victorian',
      maxLevel: 5,
    ),
    // Tier 2
    TechUpgrade(
      id: 'bessemer_process',
      name: 'Bessemer Process',
      description: 'The age of steel begins. Massive cost savings.',
      type: TechType.costReduction,
      baseCost: BigInt.from(500),
      costMultiplier: 1.4,
      eraId: 'victorian',
      maxLevel: 5,
    ),
    TechUpgrade(
      id: 'jacquard_punchcards',
      name: 'Jacquard Punch-Cards',
      description: 'The original industrial programming via looms.',
      type: TechType.automation,
      baseCost: BigInt.from(1000),
      costMultiplier: 1.5,
      eraId: 'victorian',
      maxLevel: 3,
    ),
    // Tier 3
    TechUpgrade(
      id: 'clockwork_arithmometer',
      name: 'Clockwork Arithmometer',
      description: 'A thunderous assembly of brass cogs and perforated cards that automates the ledger, continuing calculations even whilst the operator slumbers.',
      type: TechType.offline,
      baseCost: BigInt.from(5000),
      costMultiplier: 1.8,
      eraId: 'victorian', // or 'steam_age'
      maxLevel: 5,
    ),
    TechUpgrade(
      id: 'pneumatic_hammer',
      name: 'Pneumatic Hammer',
      description: 'Compressed air for maximum impact.',
      type: TechType.clickPower,
      baseCost: BigInt.from(750),
      costMultiplier: 1.5,
      eraId: 'victorian',
      maxLevel: 5,
    ),
    // Capstone
    TechUpgrade(
      id: 'great_exhibition',
      name: 'The Great Exhibition',
      description: 'Showcase Victorian might. Unlocks next Era.',
      type: TechType.eraUnlock,
      baseCost: BigInt.from(10000),
      costMultiplier: 2.0,
      eraId: 'victorian',
      maxLevel: 1,
    ),
    // Tier 2 - New add

  ];

  static double calculateEfficiencyMultiplier(Map<String, int> techLevels) {
    double multiplier = 1.0;

    // Pressurized Boilers (Efficiency)
    final boilerLevel = techLevels['steam_boilers'] ?? 0;
    multiplier += boilerLevel * 0.1; // +10% per level

    // Jacquard Punch-Cards (Efficiency/Automation)
    final jacquardLevel = techLevels['jacquard_punchcards'] ?? 0;
    multiplier += jacquardLevel * 0.05; // +5% per level

    return multiplier;
  }

  static double calculateTimeWarpMultiplier(Map<String, int> techLevels) {
    double multiplier = 1.0;
    // Centrifugal Governor - +5% per level
    final governorLevel = techLevels['centrifugal_governor'] ?? 0;
    multiplier += governorLevel * 0.05;
    return multiplier;
  }

  static double calculateCostReductionMultiplier(Map<String, int> techLevels) {
    double multiplier = 1.0;
    // Bessemer Process - Cost becomes (1.0 - (level * 0.05))
    final bessemerLevel = techLevels['bessemer_process'] ?? 0;
    multiplier -= bessemerLevel * 0.05;
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
