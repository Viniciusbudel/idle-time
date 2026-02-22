import 'enums.dart';
import 'dart:math';

class ArtifactNameRegistry {
  static final _random = Random();

  static final Map<WorkerRarity, List<String>> _names = {
    WorkerRarity.common: [
      'Rusty Gear',
      'Leaky Valve',
      'Frayed Wire',
      'Bent Spring',
      'Dull Needle',
      'Cracked Lens',
    ],
    WorkerRarity.rare: [
      'Polished Piston',
      'Copper Coil',
      'Bronze Bearing',
      'Brass Bolt',
      'Silver Sprocket',
      'Iron Ingot',
    ],
    WorkerRarity.epic: [
      'Gold Gasket',
      'Emerald Emitter',
      'Ruby Relay',
      'Sapphire Sensor',
      'Quartz Crystal',
      'Cobalt Core',
    ],
    WorkerRarity.legendary: [
      'Chrono-Lens',
      'Temporal Gear',
      'Paradox Piston',
      'Infinity Ingot',
      'Void Valve',
      'Aeon Anchor',
    ],
    WorkerRarity.paradox: [
      'The Singularity',
      'Entropy\'s Edge',
      'Timeline Tethers',
      'Universal Constant',
      'Omega Orb',
      'Alpha Atom',
    ],
  };

  static String getName(WorkerRarity rarity) {
    final list = _names[rarity] ?? _names[WorkerRarity.common]!;
    return list[_random.nextInt(list.length)];
  }
}
