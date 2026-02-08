import 'dart:math';
import '../entities/game_state.dart';
import '../entities/worker.dart';
import '../entities/enums.dart';

/// Use case for summoning new workers using the Temporal Rift Gacha system.
class SummonWorkerUseCase {
  static final _random = Random();

  /// Rarity weights (higher = more common)
  static const Map<WorkerRarity, double> _rarityWeights = {
    WorkerRarity.common: 60.0,
    WorkerRarity.rare: 25.0,
    WorkerRarity.epic: 10.0,
    WorkerRarity.legendary: 4.0,
    WorkerRarity.paradox: 1.0,
  };

  /// Summon a single worker from the Temporal Rift.
  /// Returns the updated [GameState] and the summoned [Worker].
  ({GameState state, Worker worker}) execute(
    GameState state, {
    WorkerEra? targetEra,
  }) {
    final rarity = _rollRarity();
    final era = targetEra ?? _rollEra(state.unlockedEraEnums);

    final worker = Worker(
      id: 'worker_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}',
      name: _generateName(era, rarity),
      era: era,
      rarity: rarity,
      level: 1,
      baseProduction: _calculateBaseProduction(era, rarity),
    );

    final newWorkers = Map<String, Worker>.from(state.workers);
    newWorkers[worker.id] = worker;

    final newState = state.copyWith(
      workers: newWorkers,
      totalWorkersPulled: state.totalWorkersPulled + 1,
    );

    return (state: newState, worker: worker);
  }

  /// Roll for rarity using weighted random
  WorkerRarity _rollRarity() {
    final totalWeight = _rarityWeights.values.fold(0.0, (a, b) => a + b);
    double roll = _random.nextDouble() * totalWeight;

    for (final entry in _rarityWeights.entries) {
      roll -= entry.value;
      if (roll <= 0) {
        return entry.key;
      }
    }
    return WorkerRarity.common;
  }

  /// Roll for era from unlocked eras
  WorkerEra _rollEra(List<WorkerEra> unlockedEras) {
    if (unlockedEras.isEmpty) return WorkerEra.victorian;
    return unlockedEras[_random.nextInt(unlockedEras.length)];
  }

  /// Generate a thematic worker name
  String _generateName(WorkerEra era, WorkerRarity rarity) {
    const prefixes = {
      WorkerRarity.common: ['Novice', 'Trainee', 'Cadet'],
      WorkerRarity.rare: ['Skilled', 'Adept', 'Specialist'],
      WorkerRarity.epic: ['Expert', 'Master', 'Elite'],
      WorkerRarity.legendary: ['Chrono', 'Temporal', 'Legendary'],
      WorkerRarity.paradox: ['Paradox', 'Anomaly', 'Singularity'],
    };

    const suffixes = {
      WorkerEra.victorian: ['Clocksmith', 'Engineer', 'Tinkerer'],
      WorkerEra.roaring20s: ['Bootlegger', 'Industrialist', 'Inventor'],
      WorkerEra.atomicAge: ['Scientist', 'Physicist', 'Technician'],
      WorkerEra.cyberpunk80s: ['Hacker', 'Runner', 'Synth'],
      WorkerEra.neoTokyo: ['Operator', 'Ghost', 'Netrunner'],
      WorkerEra.postSingularity: ['AI-7', 'Unit-X', 'CORE'],
      WorkerEra.ancientRome: ['Gladiator', 'Senator', 'Legionnaire'],
      WorkerEra.farFuture: ['Archon', 'Watcher', 'Prime'],
    };

    final prefix = prefixes[rarity]![_random.nextInt(prefixes[rarity]!.length)];
    final suffix = suffixes[era]![_random.nextInt(suffixes[era]!.length)];

    return '$prefix $suffix';
  }

  /// Calculate base production based on era and rarity
  BigInt _calculateBaseProduction(WorkerEra era, WorkerRarity rarity) {
    // Base from era
    final eraBase = era.multiplier * 10;
    // Multiplied by rarity
    final rarityMult = rarity.productionMultiplier;
    return BigInt.from((eraBase * rarityMult).toInt());
  }
}
