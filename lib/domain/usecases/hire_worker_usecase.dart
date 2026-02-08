import 'dart:math';
import '../entities/worker.dart';
import '../entities/enums.dart';

class HireWorkerUseCase {
  Worker execute(WorkerEra era) {
    // Generate unique ID
    final id = 'worker_${era.id}_${DateTime.now().millisecondsSinceEpoch}';

    // Create new worker
    return Worker(
      id: id,
      era: era,
      level: 1,
      baseProduction: BigInt.from(era.multiplier.toInt().clamp(1, 128)),
      rarity: WorkerRarity.common,
      name: _generateWorkerName(era),
    );
  }

  String _generateWorkerName(WorkerEra era) {
    const names = {
      'victorian': ['Ada', 'Victoria', 'Charles', 'Isambard', 'Florence'],
      'roaring_20s': ['Gatsby', 'Zelda', 'Duke', 'Josephine', 'Louis'],
      'atomic_age': ['Buzz', 'Werner', 'Rosie', 'Albert', 'Marie'],
      'cyberpunk_80s': ['Neon', 'Chrome', 'Blade', 'Synth', 'Grid'],
      'neo_tokyo': ['Akira', 'Motoko', 'Zero', 'Cipher', 'Nova'],
      'post_singularity': ['Alpha', 'Omega', 'Entity', 'Vertex', 'Nexus'],
      'ancient_rome': ['Marcus', 'Julius', 'Livia', 'Brutus', 'Claudia'],
      'far_future': ['Zephyr', 'Cosmo', 'Stellar', 'Void', 'Quantum'],
    };
    final eraNames = names[era.id] ?? ['Worker'];
    return eraNames[Random().nextInt(eraNames.length)];
  }
}
