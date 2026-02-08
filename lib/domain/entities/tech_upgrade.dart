import 'dart:math';

enum TechType {
  automation, // Passive income boosts, auto-clickers
  efficiency, // Multipliers for stations/workers
  timeWarp, // Spiel speed, tick rate
  costReduction, // NEW: Reduces station costs
  offline, // NEW: Increases offline eff
  clickPower, // NEW: Increases manual click CE
  eraUnlock, // NEW: Gatekeeper tech
}

class TechUpgrade {
  final String id;
  final String name;
  final String description;
  final TechType type;
  final int maxLevel;
  final BigInt baseCost;
  final double costMultiplier; // e.g., 1.15 for 15% increase per level
  final String eraId;

  // Current state
  final int level;

  const TechUpgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.baseCost,
    this.maxLevel = 100,
    this.costMultiplier = 1.15,
    this.level = 0,
    required this.eraId,
  });

  /// Calculate cost for next level
  BigInt get nextCost {
    if (level >= maxLevel) return BigInt.from(-1); // Maxed out

    // Cost = Base * (Multiplier ^ Level)
    final multiplier = pow(costMultiplier, level);
    return BigInt.from((baseCost.toDouble() * multiplier).round());
  }

  /// Copy with new level
  TechUpgrade copyWith({int? level}) {
    return TechUpgrade(
      id: id,
      name: name,
      description: description,
      type: type,
      baseCost: baseCost,
      maxLevel: maxLevel,
      costMultiplier: costMultiplier,
      level: level ?? this.level,
      eraId: eraId,
    );
  }

  /// Get bonus description based on type and level
  String get bonusDescription {
    switch (type) {
      case TechType.automation:
        return 'Auto-Clicker: ${(level * 1.0).toStringAsFixed(1)} /sec';
      case TechType.efficiency:
        return 'Production: +${(level * 10)}%';
      case TechType.timeWarp:
        return 'Game Speed: +${(level * 5)}%';
      case TechType.costReduction:
        return 'Station Cost: -${(level * 5)}%';
      case TechType.offline:
        return 'Offline Eff: +${(level * 10)}%';
      case TechType.clickPower:
        return 'Click Power: +${(level * 100)}%';
      case TechType.eraUnlock:
        return 'Unlock Next Era';
    }
  }
}
