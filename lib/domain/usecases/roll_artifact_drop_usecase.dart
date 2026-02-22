import 'dart:math';
import 'package:time_factory/domain/entities/enums.dart';

class RollArtifactDropUseCase {
  final Random _random = Random();

  /// Calculates rarity based on current paradoxLevel (0.0 to 1.0).
  /// Higher paradox = much better drop chances.
  WorkerRarity execute(double paradoxLevel) {
    // Base clamp for safety
    final pLevel = paradoxLevel.clamp(0.0, 1.0);

    // Normal Weights (pLevel = 0.0) -> Common: 55, Rare: 30, Epic: 10, Leg: 4.5, Par: 0.5
    // Max Paradox (pLevel = 1.0) -> Common: 20, Rare: 30, Epic: 30, Leg: 15, Par: 5

    final commonWeight = 55.0 - (35.0 * pLevel);
    final rareWeight = 30.0;
    final epicWeight = 10.0 + (20.0 * pLevel);
    final legWeight = 4.5 + (10.5 * pLevel);
    final paradoxWeight = 0.5 + (4.5 * pLevel);

    final totalWeight =
        commonWeight + rareWeight + epicWeight + legWeight + paradoxWeight;
    double roll = _random.nextDouble() * totalWeight;

    if (roll < paradoxWeight) return WorkerRarity.paradox;
    roll -= paradoxWeight;

    if (roll < legWeight) return WorkerRarity.legendary;
    roll -= legWeight;

    if (roll < epicWeight) return WorkerRarity.epic;
    roll -= epicWeight;

    if (roll < rareWeight) return WorkerRarity.rare;

    return WorkerRarity.common;
  }
}
