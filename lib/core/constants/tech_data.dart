import 'package:time_factory/domain/entities/tech_upgrade.dart';

class TechData {
  static List<TechUpgrade> get initialTechs => [
    // Tier 1
    TechUpgrade(
      id: 'steam_boilers',
      name: 'Pressurized Boilers',
      description: 'Higher pressure means more power.',
      type: TechType.efficiency,
      baseCost: BigInt.from(2000), // REBALANCED: 1000 -> 3000
      costMultiplier: 2.5, // REBALANCED: 2.1 -> 3.5
      eraId: 'victorian',
      maxLevel: 10,
    ),
    TechUpgrade(
      id: 'centrifugal_governor',
      name: 'Centrifugal Governor',
      description: 'The spinning balls of industry. Stabilizes steam flow.',
      type: TechType.timeWarp,
      baseCost: BigInt.from(3500), // REBALANCED: 2500 -> 7500
      costMultiplier: 2.5, // REBALANCED: 2.5 -> 4.0
      eraId: 'victorian',
      maxLevel: 5,
    ),
    // Tier 2
    TechUpgrade(
      id: 'bessemer_process',
      name: 'Bessemer Process',
      description: 'The age of steel begins. Massive cost savings.',
      type: TechType.costReduction,
      baseCost: BigInt.from(8000), // REBALANCED: 5000 -> 15000
      costMultiplier: 2.5, // REBALANCED: 2.0 -> 3.0
      eraId: 'victorian',
      maxLevel: 5,
    ),
    TechUpgrade(
      id: 'jacquard_punchcards',
      name: 'Jacquard Punch-Cards',
      description: 'The original industrial programming via looms.',
      type: TechType.automation,
      baseCost: BigInt.from(24000), // REBALANCED: 8000 -> 24000
      costMultiplier: 4.0, // REBALANCED: 2.5 -> 4.0
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
      baseCost: BigInt.from(40000), // REBALANCED: 8000 -> 40000
      costMultiplier: 3.5, // REBALANCED: 2.0 -> 3.5
      eraId: 'victorian',
      maxLevel: 5,
    ),
    TechUpgrade(
      id: 'pneumatic_hammer',
      name: 'Pneumatic Hammer',
      description: 'Compressed air for maximum impact.',
      type: TechType.clickPower,
      baseCost: BigInt.from(30000), // REBALANCED: 7500 -> 30000
      costMultiplier: 3.5, // REBALANCED: 2.5 -> 3.5
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
      baseCost: BigInt.from(1500000), // REBALANCED: 47k -> 150k
      costMultiplier: 1.75, // REBALANCED: 1.5 -> 2.5
      eraId: 'roaring_20s',
      maxLevel: 15,
    ),
    TechUpgrade(
      id: 'assembly_line',
      name: 'Assembly Line Protocol',
      description:
          'Fordist efficiency. Standardized parts reduce costs massively.',
      type: TechType.costReduction,
      baseCost: BigInt.from(5000000), // REBALANCED: 150k -> 500k
      costMultiplier: 2.0, // REBALANCED: 1.6 -> 2.8
      eraId: 'roaring_20s',
      maxLevel: 5,
    ),
    // Tier 2
    TechUpgrade(
      id: 'radio_broadcast',
      name: 'Radio Broadcasting',
      description:
          'Reaching workers in their homes. Productivity never sleeps.',
      type: TechType.offline,
      baseCost: BigInt.from(800000), // REBALANCED: 200k -> 800k
      costMultiplier: 2.5, // REBALANCED: 1.7 -> 2.5
      eraId: 'roaring_20s',
      maxLevel: 5,
    ),
    TechUpgrade(
      id: 'jazz_improvisation',
      name: 'Jazz Improvisation',
      description: 'Chaotic rhythm increases manual input efficiency.',
      type: TechType.clickPower,
      baseCost: BigInt.from(1000000), // REBALANCED: 200k -> 1M
      costMultiplier: 3.0, // REBALANCED: 1.5 -> 3.0
      eraId: 'roaring_20s',
      maxLevel: 10,
    ),
    // Capstone
    TechUpgrade(
      id: 'manhattan_project',
      name: 'The Manhattan Project',
      description: 'Splitting the atom... and time. Unlocks Atomic Age.',
      type: TechType.manhattan,
      baseCost: BigInt.from(600000000), // REBALANCED: 50M -> 500M
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
      baseCost: BigInt.from(120000000), // REBALANCED: 50M -> 120M
      costMultiplier: 2.05, // REBALANCED: 1.6 -> 2.05
      eraId: 'atomic_age',
      maxLevel: 8, // REBALANCED: 10 -> 8
    ),
    TechUpgrade(
      id: 'transistors',
      name: 'Transistors',
      description: 'Tiny switches that revolutionize computing.',
      type: TechType.automation,
      baseCost: BigInt.from(220000000), // REBALANCED: 100M -> 220M
      costMultiplier: 2.15, // REBALANCED: 1.8 -> 2.15
      eraId: 'atomic_age',
      maxLevel: 8, // REBALANCED: 10 -> 8
    ),
    // Tier 2
    TechUpgrade(
      id: 'plastic_molding',
      name: 'Plastic Molding',
      description: 'Cheap, durable materials for mass production.',
      type: TechType.costReduction,
      baseCost: BigInt.from(650000000), // REBALANCED: 250M -> 650M
      costMultiplier: 2.35, // REBALANCED: 2.0 -> 2.35
      eraId: 'atomic_age',
      maxLevel: 5,
    ),
    TechUpgrade(
      id: 'space_race',
      name: 'Space Race',
      description: 'Pushing the boundaries of technology for national pride.',
      type: TechType.efficiency,
      baseCost: BigInt.from(1800000000), // REBALANCED: 500M -> 1.8B
      costMultiplier: 2.45, // REBALANCED: 2.2 -> 2.45
      eraId: 'atomic_age',
      maxLevel: 4, // REBALANCED: 5 -> 4
    ),
    // Tier 3
    TechUpgrade(
      id: 'arpanet',
      name: 'ARPANET',
      description: 'Decentralized networks ensure production never stops.',
      type: TechType.offline,
      baseCost: BigInt.from(4200000000), // REBALANCED: 1B -> 4.2B
      costMultiplier: 2.9, // REBALANCED: 2.5 -> 2.9
      eraId: 'atomic_age',
      maxLevel: 5,
    ),
    // Capstone
    TechUpgrade(
      id: 'microchip_revolution',
      name: 'Microchip Revolution',
      description: 'The digital age dawns. Unlocks Cyberpunk Era.',
      type: TechType.eraUnlock,
      baseCost: BigInt.from(450000000000), // REBALANCED: 100B -> 450B
      costMultiplier: 3.4, // REBALANCED: 3.0 -> 3.4
      eraId: 'atomic_age',
      maxLevel: 1,
    ),

    // ================= CYBERPUNK 80s (1980s) =================

    // Tier 1
    TechUpgrade(
      id: 'cybernetics',
      name: 'Cybernetics',
      description: 'Mechanical upgrades for flesh bodies. Flawless output.',
      type: TechType.efficiency,
      baseCost: BigInt.from(2200000000000), // REBALANCED: 500B -> 2.2T
      costMultiplier: 2.35, // REBALANCED: 2.0 -> 2.35
      eraId: 'cyberpunk_80s',
      maxLevel: 8, // REBALANCED: 10 -> 8
    ),
    TechUpgrade(
      id: 'neural_net',
      name: 'Neural Net Processing',
      description: 'Algorithms that think. Complete automation.',
      type: TechType.automation,
      baseCost: BigInt.from(4000000000000), // REBALANCED: 1T -> 4T
      costMultiplier: 2.5, // REBALANCED: 2.2 -> 2.5
      eraId: 'cyberpunk_80s',
      maxLevel: 8, // REBALANCED: 10 -> 8
    ),
    // Tier 2
    TechUpgrade(
      id: 'synth_alloys',
      name: 'Synth-Alloys',
      description: 'Stronger, lighter, cheaper material for stations.',
      type: TechType.costReduction,
      baseCost: BigInt.from(9000000000000), // REBALANCED: 2.5T -> 9T
      costMultiplier: 2.9, // REBALANCED: 2.5 -> 2.9
      eraId: 'cyberpunk_80s',
      maxLevel: 5,
    ),
    TechUpgrade(
      id: 'neon_overdrive',
      name: 'Neon Overdrive',
      description: 'Overclocking the system to bend time itself.',
      type: TechType.timeWarp,
      baseCost: BigInt.from(18000000000000), // REBALANCED: 5T -> 18T
      costMultiplier: 3.0, // REBALANCED: 2.5 -> 3.0
      eraId: 'cyberpunk_80s',
      maxLevel: 5,
    ),
    // Capstone
    TechUpgrade(
      id: 'virtual_reality',
      name: 'Virtual Reality Matrix',
      description:
          'The ultimate escape to digital realms. Unlocks Singularity.',
      type: TechType.eraUnlock,
      baseCost: BigInt.from(600000000000000), // REBALANCED: 100T -> 600T
      costMultiplier: 3.9, // REBALANCED: 3.5 -> 3.9
      eraId: 'cyberpunk_80s',
      maxLevel: 1,
    ),

    // ================= SINGULARITY (2400s) =================

    // Tier 1
    TechUpgrade(
      id: 'neural_mesh',
      name: 'Neural Mesh',
      description: 'Distributed cognition links every worker into one mind.',
      type: TechType.efficiency,
      baseCost: BigInt.from(1500000000000000), // 1.5Qa
      costMultiplier: 2.2,
      eraId: 'post_singularity',
      maxLevel: 6,
    ),
    TechUpgrade(
      id: 'probability_compiler',
      name: 'Probability Compiler',
      description: 'Compiles future branches into deterministic throughput.',
      type: TechType.timeWarp,
      baseCost: BigInt.from(2200000000000000), // 2.2Qa
      costMultiplier: 2.25,
      eraId: 'post_singularity',
      maxLevel: 5,
    ),
    // Tier 2
    TechUpgrade(
      id: 'nanoforge_cells',
      name: 'Nanoforge Cells',
      description: 'Self-assembling infrastructure slashes upgrade overhead.',
      type: TechType.costReduction,
      baseCost: BigInt.from(3000000000000000), // 3Qa
      costMultiplier: 2.4,
      eraId: 'post_singularity',
      maxLevel: 4,
    ),
    TechUpgrade(
      id: 'swarm_autonomy',
      name: 'Swarm Autonomy',
      description: 'Autonomous worker swarms maintain full-cycle operations.',
      type: TechType.automation,
      baseCost: BigInt.from(4200000000000000), // 4.2Qa
      costMultiplier: 2.4,
      eraId: 'post_singularity',
      maxLevel: 4,
    ),
    // Tier 3
    TechUpgrade(
      id: 'quantum_hibernation',
      name: 'Quantum Hibernation',
      description:
          'Workloads continue across suspended timelines while offline.',
      type: TechType.offline,
      baseCost: BigInt.from(3600000000000000), // 3.6Qa
      costMultiplier: 2.35,
      eraId: 'post_singularity',
      maxLevel: 4,
    ),
    // Capstone
    TechUpgrade(
      id: 'exo_mind_uplink',
      name: 'Exo-Mind Uplink',
      description: 'Crown protocol of Singularity. Unlocks next era.',
      type: TechType.eraUnlock,
      baseCost: BigInt.from(22000000000000000), // 22Qa
      costMultiplier: 3.6,
      eraId: 'post_singularity',
      maxLevel: 1,
    ),
  ];

  static double calculateEfficiencyMultiplier(Map<String, int> techLevels) {
    double multiplier = 1.0;

    // Pressurized Boilers (Efficiency) - PHASE 2: +10% → +5%
    final boilerLevel = techLevels['steam_boilers'] ?? 0;
    multiplier += boilerLevel * 0.075; // NERFED from 0.1

    // Jacquard Punch-Cards (Efficiency/Automation) - PHASE 2: +5% → +2.5%
    final jacquardLevel = techLevels['jacquard_punchcards'] ?? 0;
    multiplier += jacquardLevel * 0.025; // NERFED from 0.05

    // ROARING 20s - PHASE 2: +15% → +7.5%
    // Ticker Tape Feed
    final tickerLevel = techLevels['ticker_tape'] ?? 0;
    multiplier += tickerLevel * 0.075; // NERFED from 0.15

    // Hybrid Era Unlock: Manhattan Project (x2 Global Multiplier)
    if ((techLevels['manhattan_project'] ?? 0) > 0) {
      multiplier *= 2.0;
    }

    // ATOMIC AGE
    // Nuclear Fission: +12% per level
    final fissionLevel = techLevels['nuclear_fission'] ?? 0;
    multiplier += fissionLevel * 0.12;

    // Space Race: +22% per level
    final spaceLevel = techLevels['space_race'] ?? 0;
    multiplier += spaceLevel * 0.22;

    // Microchip Revolution (x25 Global Multiplier)
    if ((techLevels['microchip_revolution'] ?? 0) > 0) {
      multiplier *= 25.0;
    }

    // CYBERPUNK 80s
    // Cybernetics: +35% per level
    final cyberneticsLevel = techLevels['cybernetics'] ?? 0;
    multiplier += cyberneticsLevel * 0.35;

    // Virtual Reality (x120 Global Multiplier)
    if ((techLevels['virtual_reality'] ?? 0) > 0) {
      multiplier *= 120.0;
    }

    // SINGULARITY
    // Neural Mesh: +40% per level
    final neuralMeshLevel = techLevels['neural_mesh'] ?? 0;
    multiplier += neuralMeshLevel * 0.40;

    // Exo-Mind Uplink (x6 Global Multiplier)
    if ((techLevels['exo_mind_uplink'] ?? 0) > 0) {
      multiplier *= 6.0;
    }

    return multiplier;
  }

  static double calculateTimeWarpMultiplier(Map<String, int> techLevels) {
    double multiplier = 1.0;
    // Centrifugal Governor - +5% per level
    final governorLevel = techLevels['centrifugal_governor'] ?? 0;
    multiplier += governorLevel * 0.05;

    // Neon Overdrive - +10% per level
    final overdriveLevel = techLevels['neon_overdrive'] ?? 0;
    multiplier += overdriveLevel * 0.10;

    // Probability Compiler - +14% per level
    final probabilityCompilerLevel = techLevels['probability_compiler'] ?? 0;
    multiplier += probabilityCompilerLevel * 0.14;

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
    // Plastic Molding: -4% per level
    final plasticLevel = techLevels['plastic_molding'] ?? 0;
    multiplier -= plasticLevel * 0.04;

    // CYBERPUNK 80s
    // Synth-Alloys: -4% per level
    final synthLevel = techLevels['synth_alloys'] ?? 0;
    multiplier -= synthLevel * 0.04;

    final nanoforgeLevel = techLevels['nanoforge_cells'] ?? 0;
    final preSingularityMultiplier = multiplier.clamp(0.5, 1.0);

    if (nanoforgeLevel <= 0) {
      return preSingularityMultiplier;
    }

    // Singularity reduction applies after the base clamp so late-game cost
    // tech still has impact without reopening early-game runaway.
    final lateEraReductionMultiplier = (1.0 - (nanoforgeLevel * 0.05)).clamp(
      0.8,
      1.0,
    );
    final adjusted = preSingularityMultiplier * lateEraReductionMultiplier;
    return adjusted.clamp(0.35, 1.0);
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
    // ARPANET: +4% per level (REBALANCED: from 20%)
    final arpanetLevel = techLevels['arpanet'] ?? 0;
    multiplier += arpanetLevel * 0.04;

    // SINGULARITY
    // Quantum Hibernation: +6% per level
    final quantumHibernationLevel = techLevels['quantum_hibernation'] ?? 0;
    multiplier += quantumHibernationLevel * 0.06;

    return multiplier;
  }

  static double calculateAutomationLevel(Map<String, int> techLevels) {
    double clicksPerSecond = 0.0;

    // Jacquard Punch-Cards (Victorian)
    // 0.5 clicks/sec per level
    final jacquard = techLevels['jacquard_punchcards'] ?? 0;
    clicksPerSecond += jacquard * 0.5;

    // ATOMIC AGE
    // Transistors: +3.0 clicks/sec per level
    final transistors = techLevels['transistors'] ?? 0;
    clicksPerSecond += transistors * 3.0;

    // CYBERPUNK 80s
    // Neural Net: +12.0 clicks/sec per level
    final neuralNet = techLevels['neural_net'] ?? 0;
    clicksPerSecond += neuralNet * 12.0;

    // SINGULARITY
    // Swarm Autonomy: +18.0 clicks/sec per level
    final swarmAutonomy = techLevels['swarm_autonomy'] ?? 0;
    clicksPerSecond += swarmAutonomy * 18.0;

    return clicksPerSecond;
  }
}
