import 'package:time_factory/domain/entities/tech_upgrade.dart';

class TechData {
  static List<TechUpgrade> get initialTechs => [
    // Tier 1
    TechUpgrade(
      id: 'steam_boilers',
      name: 'Pressurized Boilers',
      description: 'Higher pressure means more power.',
      type: TechType.efficiency,
      baseCost: BigInt.from(1000), // PHASE 2: 100 → 1000 (×10)
      costMultiplier: 2.1, // PHASE 2: 1.5 → 2.5
      eraId: 'victorian',
      maxLevel: 10,
    ),
    TechUpgrade(
      id: 'centrifugal_governor',
      name: 'Centrifugal Governor',
      description: 'The spinning balls of industry. Stabilizes steam flow.',
      type: TechType.timeWarp,
      baseCost: BigInt.from(2500), // PHASE 2: 250 → 2500 (×10)
      costMultiplier: 2.5, // PHASE 2: 1.6 → 2.5
      eraId: 'victorian',
      maxLevel: 5,
    ),
    // Tier 2
    TechUpgrade(
      id: 'bessemer_process',
      name: 'Bessemer Process',
      description: 'The age of steel begins. Massive cost savings.',
      type: TechType.costReduction,
      baseCost: BigInt.from(5000), // PHASE 2: 500 → 5000 (×10)
      costMultiplier: 2.0, // PHASE 2: 1.4 → 2.0
      eraId: 'victorian',
      maxLevel: 5,
    ),
    TechUpgrade(
      id: 'jacquard_punchcards',
      name: 'Jacquard Punch-Cards',
      description: 'The original industrial programming via looms.',
      type: TechType.automation,
      baseCost: BigInt.from(8000), // PHASE 2: 1000 → 10000 (×10)
      costMultiplier: 2.5, // PHASE 2: 1.5 → 2.5
      eraId: 'victorian',
      maxLevel: 5,
    ),
    // Tier 3
    TechUpgrade(
      id: 'clockwork_arithmometer',
      name: 'Clockwork Arithmometer',
      description:
          'A thunderous assembly of brass cogs and perforated cards that automates the ledger, continuing calculations even whilst the operator slumbers.',
      type: TechType.offline,
      baseCost: BigInt.from(8000), // REBALANCED: 50000 → 8000
      costMultiplier: 2.0, // REBALANCED: 3.0 → 2.0
      eraId: 'victorian',
      maxLevel: 5,
    ),
    TechUpgrade(
      id: 'pneumatic_hammer',
      name: 'Pneumatic Hammer',
      description: 'Compressed air for maximum impact.',
      type: TechType.clickPower,
      baseCost: BigInt.from(7500), // PHASE 2: 750 → 7500 (×10)
      costMultiplier: 2.5, // PHASE 2: 1.5 → 2.5
      eraId: 'victorian',
      maxLevel: 5,
    ),
    // Capstone
    // TechUpgrade(
    //   id: 'great_exhibition',
    //   name: 'The Great Exhibition',
    //   description: 'Showcase Victorian might. Unlocks next Era.',
    //   type: TechType.eraUnlock,
    //   baseCost: BigInt.from(10000),
    //   costMultiplier: 2.0,
    //   eraId: 'victorian',
    //   maxLevel: 1,
    // ),

    // ================= ROARING 20s (1920s) =================

    // Tier 1
    TechUpgrade(
      id: 'ticker_tape',
      name: 'Ticker Tape Feed',
      description:
          'Real-time data for real-time profits. Accelerates decision making.',
      type: TechType.efficiency,
      baseCost: BigInt.from(47000), // 50K
      costMultiplier: 1.5,
      eraId: 'roaring_20s',
      maxLevel: 15,
    ),
    TechUpgrade(
      id: 'assembly_line',
      name: 'Assembly Line Protocol',
      description:
          'Fordist efficiency. Standardized parts reduce costs massively.',
      type: TechType.costReduction,
      baseCost: BigInt.from(150000), // 150K
      costMultiplier: 1.6,
      eraId: 'roaring_20s',
      maxLevel: 6,
    ),
    // Tier 2
    TechUpgrade(
      id: 'radio_broadcast',
      name: 'Radio Broadcasting',
      description:
          'Reaching workers in their homes. Productivity never sleeps.',
      type: TechType.offline,
      baseCost: BigInt.from(200000), // REBALANCED: 300000 → 200000
      costMultiplier: 1.7, // REBALANCED: 1.7 → 1.5
      eraId: 'roaring_20s',
      maxLevel: 5,
    ),
    TechUpgrade(
      id: 'jazz_improvisation',
      name: 'Jazz Improvisation',
      description: 'Chaotic rhythm increases manual input efficiency.',
      type: TechType.clickPower,
      baseCost: BigInt.from(200000), // 500K
      costMultiplier: 1.5,
      eraId: 'roaring_20s',
      maxLevel: 10,
    ),
    // Capstone
    TechUpgrade(
      id: 'manhattan_project',
      name: 'The Manhattan Project',
      description: 'Splitting the atom... and time. Unlocks Atomic Age.',
      type: TechType.manhattan,
      baseCost: BigInt.from(50000000), // 50M
      costMultiplier: 2.0,
      eraId: 'roaring_20s',
      maxLevel: 1,
    ),

    // ================= ATOMIC AGE (1950s) =================

    // Tier 1
    TechUpgrade(
      id: 'nuclear_fission',
      name: 'Nuclear Fission',
      description: 'Harnessing the atom for limitless power.',
      type: TechType.efficiency,
      baseCost: BigInt.from(50000000), // 50M
      costMultiplier: 1.6,
      eraId: 'atomic_age',
      maxLevel: 10,
    ),
    TechUpgrade(
      id: 'transistors',
      name: 'Transistors',
      description: 'Tiny switches that revolutionize computing.',
      type: TechType.automation,
      baseCost: BigInt.from(100000000), // 100M
      costMultiplier: 1.8,
      eraId: 'atomic_age',
      maxLevel: 10,
    ),
    // Tier 2
    TechUpgrade(
      id: 'plastic_molding',
      name: 'Plastic Molding',
      description: 'Cheap, durable materials for mass production.',
      type: TechType.costReduction,
      baseCost: BigInt.from(250000000), // 250M
      costMultiplier: 2.0,
      eraId: 'atomic_age',
      maxLevel: 5,
    ),
    TechUpgrade(
      id: 'space_race',
      name: 'Space Race',
      description: 'Pushing the boundaries of technology for national pride.',
      type: TechType.efficiency,
      baseCost: BigInt.from(500000000), // 500M
      costMultiplier: 2.2,
      eraId: 'atomic_age',
      maxLevel: 5,
    ),
    // Tier 3
    TechUpgrade(
      id: 'arpanet',
      name: 'ARPANET',
      description: 'Decentralized networks ensure production never stops.',
      type: TechType.offline,
      baseCost: BigInt.from(1000000000), // 1B
      costMultiplier: 2.5,
      eraId: 'atomic_age',
      maxLevel: 5,
    ),
    // Capstone
    TechUpgrade(
      id: 'microchip_revolution',
      name: 'Microchip Revolution',
      description: 'The digital age dawns. Unlocks Cyberpunk Era.',
      type: TechType.eraUnlock,
      baseCost: BigInt.from(100000000000), // 100B
      costMultiplier: 3.0,
      eraId: 'atomic_age',
      maxLevel: 1,
    ),
  ];

  static double calculateEfficiencyMultiplier(Map<String, int> techLevels) {
    double multiplier = 1.0;

    // Pressurized Boilers (Efficiency) - PHASE 2: +10% → +5%
    final boilerLevel = techLevels['steam_boilers'] ?? 0;
    multiplier += boilerLevel * 0.05; // NERFED from 0.1

    // Jacquard Punch-Cards (Efficiency/Automation) - PHASE 2: +5% → +2.5%
    final jacquardLevel = techLevels['jacquard_punchcards'] ?? 0;
    multiplier += jacquardLevel * 0.025; // NERFED from 0.05

    // ROARING 20s - PHASE 2: +15% → +7.5%
    // Ticker Tape Feed
    final tickerLevel = techLevels['ticker_tape'] ?? 0;
    multiplier += tickerLevel * 0.075; // NERFED from 0.15

    // Hybrid Era Unlock: Manhattan Project (x20 Global Multiplier)
    if ((techLevels['manhattan_project'] ?? 0) > 0) {
      multiplier *= 20.0;
    }

    // ATOMIC AGE
    // Nuclear Fission: +25% per level
    final fissionLevel = techLevels['nuclear_fission'] ?? 0;
    multiplier += fissionLevel * 0.25;

    // Space Race: +50% per level
    final spaceLevel = techLevels['space_race'] ?? 0;
    multiplier += spaceLevel * 0.5;

    // Microchip Revolution (x100 Global Multiplier)
    if ((techLevels['microchip_revolution'] ?? 0) > 0) {
      multiplier *= 100.0;
    }

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
    // Bessemer Process - PHASE 2: -5% → -3% per level
    final bessemerLevel = techLevels['bessemer_process'] ?? 0;
    multiplier -= bessemerLevel * 0.03; // NERFED from 0.05

    // ROARING 20s - PHASE 2: -8% → -5% per level
    // Assembly Line
    final assemblyLevel = techLevels['assembly_line'] ?? 0;
    multiplier -= assemblyLevel * 0.05; // NERFED from 0.08

    // ATOMIC AGE
    // Plastic Molding: -5% per level
    final plasticLevel = techLevels['plastic_molding'] ?? 0;
    multiplier -= plasticLevel * 0.05;

    return multiplier.clamp(0.5, 1.0); // PHASE 2: Cap at 50% min (was 10%)
  }

  static double calculateOfflineEfficiencyMultiplier(
    Map<String, int> techLevels,
  ) {
    double multiplier = 1.0;
    // Analytical Engine - +10% per level
    final engineLevel =
        techLevels['analytical_engine'] ??
        0; // Note: accessing undefined ID if not added, but safe with ?? 0
    multiplier += engineLevel * 0.05;

    // Clockwork Arithmometer
    final clockworkLevel = techLevels['clockwork_arithmometer'] ?? 0;
    multiplier += clockworkLevel * 0.05;

    // ROARING 20s
    // Radio Broadcasting - +15% per level
    final radioLevel = techLevels['radio_broadcast'] ?? 0;
    multiplier += radioLevel * 0.05;

    // ATOMIC AGE
    // ARPANET: +20% per level
    final arpanetLevel = techLevels['arpanet'] ?? 0;
    multiplier += arpanetLevel * 0.20;

    return multiplier;
  }

  static double calculateAutomationLevel(Map<String, int> techLevels) {
    double clicksPerSecond = 0.0;

    // Jacquard Punch-Cards (Victorian)
    // 0.5 clicks/sec per level
    final jacquard = techLevels['jacquard_punchcards'] ?? 0;
    clicksPerSecond += jacquard * 0.5;

    // ATOMIC AGE
    // Transistors: +5.0 clicks/sec per level
    final transistors = techLevels['transistors'] ?? 0;
    clicksPerSecond += transistors * 5.0;

    // TODO: Add future automation techs here

    return clicksPerSecond;
  }
}
