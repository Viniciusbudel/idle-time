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
        return 'Auto-Clicker: ${(level * 0.5).toStringAsFixed(1)} /sec';
      case TechType.efficiency:
        // Boilers: +5%/lvl, Ticker Tape: +7.5%/lvl
        final pct = id == 'ticker_tape' ? level * 7.5 : level * 5.0;
        return 'Production: +${pct.toStringAsFixed(pct == pct.roundToDouble() ? 0 : 1)}%';
      case TechType.timeWarp:
        return 'Game Speed: +${level * 5}%';
      case TechType.costReduction:
        // Bessemer: -3%/lvl, Assembly Line: -5%/lvl
        final reduction = id == 'bessemer_process' ? level * 3 : level * 5;
        return 'Upgrade Cost: −$reduction%';
      case TechType.offline:
        // Clockwork: +10%/lvl, Radio: +15%/lvl
        final pct = id == 'radio_broadcast' ? level * 5 : level * 5;
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
