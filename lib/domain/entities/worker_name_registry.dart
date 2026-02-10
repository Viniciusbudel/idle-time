import 'enums.dart';

/// Registry of standardized worker names (Role/Job Title style)
class WorkerNameRegistry {
  WorkerNameRegistry._();

  static String getName(WorkerEra era, WorkerRarity rarity) {
    return _names[era]?[rarity] ?? 'Temporal Worker';
  }

  static const Map<WorkerEra, Map<WorkerRarity, String>> _names = {
    WorkerEra.victorian: {
      WorkerRarity.common: 'Soot Sweeper',
      WorkerRarity.rare: 'Steam Fitter',
      WorkerRarity.epic: 'Brass Engineer',
      WorkerRarity.legendary: 'Aether Architect',
      WorkerRarity.paradox: 'Void Tinkerer',
    },
    WorkerEra.roaring20s: {
      WorkerRarity.common: 'Assembly Runner',
      WorkerRarity.rare: 'Jazz Mechanic',
      WorkerRarity.epic: 'Diesel Operator',
      WorkerRarity.legendary: 'Art Deco Designer',
      WorkerRarity.paradox: 'Noir Detective',
    },
    WorkerEra.atomicAge: {
      WorkerRarity.common: 'Lab Assistant',
      WorkerRarity.rare: 'Reactor Tech',
      WorkerRarity.epic: 'Isotope Handler',
      WorkerRarity.legendary: 'Nuclear Physicist',
      WorkerRarity.paradox: 'Quantum Splitter',
    },
    WorkerEra.cyberpunk80s: {
      WorkerRarity.common: 'Grid Hacker',
      WorkerRarity.rare: 'Synth Surgeon',
      WorkerRarity.epic: 'Neon Samurai',
      WorkerRarity.legendary: 'Mainframe Master',
      WorkerRarity.paradox: 'Glitch Runner',
    },
    WorkerEra.neoTokyo: {
      WorkerRarity.common: 'Data Drone',
      WorkerRarity.rare: 'Cyber-Doc',
      WorkerRarity.epic: 'Netrunner Prime',
      WorkerRarity.legendary: 'System Lord',
      WorkerRarity.paradox: 'Ghost in the Shell',
    },
    WorkerEra.postSingularity: {
      WorkerRarity.common: 'Code Fragment',
      WorkerRarity.rare: 'Algorithmic Construct',
      WorkerRarity.epic: 'Digital Consciousness',
      WorkerRarity.legendary: 'AI Overlord',
      WorkerRarity.paradox: 'Singularity Core',
    },
    WorkerEra.ancientRome: {
      WorkerRarity.common: 'Aqueduct Laborer',
      WorkerRarity.rare: 'Legionary Engineer',
      WorkerRarity.epic: 'Marble Sculptor',
      WorkerRarity.legendary: 'High Architect',
      WorkerRarity.paradox: 'Chronos Oracle',
    },
    WorkerEra.farFuture: {
      WorkerRarity.common: 'Stardust Gatherer',
      WorkerRarity.rare: 'Entropy Weaver',
      WorkerRarity.epic: 'Galaxy Shaper',
      WorkerRarity.legendary: 'Time Weaver',
      WorkerRarity.paradox: 'Universal Constant',
    },
  };
}
