import 'dart:math';
import 'package:time_factory/domain/entities/enums.dart';

/// Provides lore-appropriate names for Temporal Artifacts based on rarity.
class ArtifactNameRegistry {
  ArtifactNameRegistry._();

  static final _random = Random();

  static const _names = {
    WorkerRarity.common: [
      'Rusted Cog',
      'Cracked Lens',
      'Worn Sprocket',
      'Tarnished Dial',
      'Bent Valve',
      'Faded Capacitor',
      'Corroded Coil',
      'Dull Filament',
    ],
    WorkerRarity.rare: [
      'Resonance Coil',
      'Phase Lens',
      'Flux Amplifier',
      'Chron-o-Spring',
      'Calibrated Gyroscope',
      'Signal Condenser',
      'Arc Stabilizer',
      'Precision Regulator',
    ],
    WorkerRarity.epic: [
      'Temporal Regulator',
      'Paradox Filter',
      'Quantum Gyroscope',
      'Void Resonator',
      'Fractal Actuator',
      'Phase Inverter Mk II',
      'Entropy Suppressor',
      'Waveform Anchor',
    ],
    WorkerRarity.legendary: [
      'Tachyon DriveCore',
      'Void Capacitor',
      'Chrono Sigil',
      'Temporal Crown',
      'Infinite Regressor',
      'Epoch Catalyst',
      'Reality Stabilizer Alpha',
      'The Ouroboros Coil',
    ],
    WorkerRarity.paradox: [
      'Singularity Engine',
      'Reality Anchor',
      'The Unbound Clock',
      'Omega Convergence',
    ],
  };

  /// Returns a random lore-appropriate name for the given rarity.
  static String getName(WorkerRarity rarity) {
    final pool = _names[rarity] ?? _names[WorkerRarity.common]!;
    return pool[_random.nextInt(pool.length)];
  }
}
