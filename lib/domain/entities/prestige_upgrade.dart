import 'package:flutter/material.dart';

enum PrestigeUpgradeType {
  chronoMastery(
    'chrono_mastery',
    'Chrono Mastery',
    'Global production +10%',
    Icons.bolt,
  ),
  eraInsight(
    'era_insight',
    'Era Insight',
    '+1 Starting Era unlocked',
    Icons.remove_red_eye,
  ),
  riftStability(
    'rift_stability',
    'Rift Stability',
    '-5% Paradox accumulation',
    Icons.shield,
  ),
  timekeepersFavor(
    'timekeepers_favor',
    'Timekeeper\'s Favor',
    '+5% Better Gacha luck',
    Icons.star,
  ),
  temporalMemory(
    'temporal_memory',
    'Temporal Memory',
    '+10% Offline earnings',
    Icons.hourglass_top,
  );

  final String id;
  final String displayName;
  final String description;
  final IconData icon;

  const PrestigeUpgradeType(
    this.id,
    this.displayName,
    this.description,
    this.icon,
  );

  /// Calculate cost for the NEXT level (currentLevel + 1)
  int getCost(int currentLevel) {
    switch (this) {
      case PrestigeUpgradeType.chronoMastery:
        // Linear: 1, 2, 3...
        return 1 + currentLevel;
      case PrestigeUpgradeType.eraInsight:
        // Exponential: 5, 10, 20...
        return (5 * (1 << currentLevel)); // 1 << level is 2^level
      case PrestigeUpgradeType.riftStability:
        // Arithmetic: 3, 5, 7...
        return 3 + (currentLevel * 2);
      case PrestigeUpgradeType.timekeepersFavor:
        // Expensive Exponential: 10, 20, 40...
        return (10 * (1 << currentLevel));
      case PrestigeUpgradeType.temporalMemory:
        // Linear: 2, 3, 4...
        return 2 + currentLevel;
    }
  }

  /// Get maximum level cap (null for infinite)
  int? get maxLevel {
    switch (this) {
      case PrestigeUpgradeType.chronoMastery:
        return null; // Infinite
      case PrestigeUpgradeType.eraInsight:
        return 8; // Max eras
      case PrestigeUpgradeType.riftStability:
        return 10; // -50% total
      case PrestigeUpgradeType.timekeepersFavor:
        return 5; // +25% luck total
      case PrestigeUpgradeType.temporalMemory:
        return 10; // +100% total
    }
  }

  /// Get effect description for a specific level
  String getEffectDescription(int level) {
    switch (this) {
      case PrestigeUpgradeType.chronoMastery:
        return '+${level * 10}% Production';
      case PrestigeUpgradeType.eraInsight:
        return 'Start at Era ${level + 1}';
      case PrestigeUpgradeType.riftStability:
        return '-${level * 5}% Paradox';
      case PrestigeUpgradeType.timekeepersFavor:
        return '+${level * 5}% Luck';
      case PrestigeUpgradeType.temporalMemory:
        return '+${level * 10}% Offline';
    }
  }
}
