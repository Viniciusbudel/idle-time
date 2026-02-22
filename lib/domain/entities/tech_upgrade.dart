import 'dart:math';

enum TechType {
  automation, // Passive income boosts, auto-clickers
  efficiency, // Multipliers for stations/workers
  timeWarp, // Spiel speed, tick rate
  costReduction, // NEW: Reduces station costs
  offline, // NEW: Increases offline eff
  clickPower, // NEW: Increases manual click CE
  eraUnlock, // NEW: Gatekeeper tech
  manhattan, // NEW: Specific type for Manhattan Project (20x boost + Unlock)
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

  /// Calculate cost for next level with optional discount
  BigInt getCost({double discountMultiplier = 1.0}) {
    if (level >= maxLevel) return BigInt.from(-1); // Maxed out

    // Cost = Base * (Multiplier ^ Level)
    final multiplier = pow(costMultiplier, level);
    final rawCost = baseCost.toDouble() * multiplier;

    // Apply discount
    final discountedCost = rawCost * discountMultiplier;

    return BigInt.from(discountedCost.round());
  }

  /// Legacy getter for raw cost (no discount)
  BigInt get nextCost => getCost(discountMultiplier: 1.0);

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

  /// Get bonus description based on type, ID, and level
  String get bonusDescription {
    switch (type) {
      case TechType.automation:
        final amount = id == 'neural_net'
            ? 25.0
            : id == 'transistors'
            ? 5.0
            : 0.5;
        return 'Auto-Clicker: ${(level * amount).toStringAsFixed(1)} /sec';
      case TechType.efficiency:
        double pctChange = 7.5;
        if (id == 'nuclear_fission')
          pctChange = 25.0;
        else if (id == 'space_race')
          pctChange = 50.0;
        else if (id == 'cybernetics')
          pctChange = 100.0;
        final pct = level * pctChange;
        return 'Production: +${pct.toStringAsFixed(pct == pct.roundToDouble() ? 0 : 1)}%';
      case TechType.timeWarp:
        double pctChange = 5.0;
        if (id == 'neon_overdrive') pctChange = 15.0;
        final pct = level * pctChange;
        return 'Game Speed: +${pct.toStringAsFixed(pct == pct.roundToDouble() ? 0 : 1)}%';
      case TechType.costReduction:
        final reduction = id == 'bessemer_process' ? level * 3 : level * 5;
        return 'Upgrade Cost: −$reduction%';
      case TechType.offline:
        final pct = level * 5;
        return 'Offline Gains: +$pct%';
      case TechType.clickPower:
        return 'Click Power: +${level * 100}%';
      case TechType.eraUnlock:
        return 'Unlock Next Era';
      case TechType.manhattan:
        return '20x Atomic Power';
    }
  }
}
