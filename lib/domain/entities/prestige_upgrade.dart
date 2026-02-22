import 'package:time_factory/core/ui/app_icons.dart';

enum PrestigeUpgradeType {
  chronoMastery(
    'chrono_mastery',
    'Chrono Mastery',
    'Global production +10%',
    AppHugeIcons.bolt,
  ),
  eraInsight(
    'era_insight',
    'Era Insight',
    '+1 Starting Era unlocked',
    AppHugeIcons.remove_red_eye,
  ),
  riftStability(
    'rift_stability',
    'Rift Stability',
    '-5% Paradox accumulation',
    AppHugeIcons.shield,
  ),
  timekeepersFavor(
    'timekeepers_favor',
    'Timekeeper\'s Favor',
    '+5% Better Gacha luck',
    AppHugeIcons.star,
  ),
  temporalMemory(
    'temporal_memory',
    'Temporal Memory',
    '+10% Offline earnings',
    AppHugeIcons.hourglass_top,
  );

  final String id;
  final String displayName;
  final String description;
  final AppIconData icon;

  const PrestigeUpgradeType(
    this.id,
    this.displayName,
    this.description,
    this.icon,
  );

  /// Calculate cost for the NEXT level (currentLevel + 1)
  int getCost(int currentLevel) {
    final nextLevel = currentLevel + 1;
    switch (this) {
      case PrestigeUpgradeType.chronoMastery:
        // Quadratic: 4, 10, 20, 34...
        return 2 + (nextLevel * nextLevel * 2);
      case PrestigeUpgradeType.eraInsight:
        // Heavy unlock tax: 22, 58, 118, 202...
        return 10 + (nextLevel * nextLevel * 12);
      case PrestigeUpgradeType.riftStability:
        // Mid-high curve: 15, 36, 71, 120...
        return 8 + (nextLevel * nextLevel * 7);
      case PrestigeUpgradeType.timekeepersFavor:
        // Premium utility curve: 21, 48, 93, 156...
        return 12 + (nextLevel * nextLevel * 9);
      case PrestigeUpgradeType.temporalMemory:
        // Mid curve: 12, 30, 60, 102...
        return 6 + (nextLevel * nextLevel * 6);
    }
  }

  /// Get maximum level cap (null for infinite)
  int? get maxLevel {
    switch (this) {
      case PrestigeUpgradeType.chronoMastery:
        return 25;
      case PrestigeUpgradeType.eraInsight:
        return 4;
      case PrestigeUpgradeType.riftStability:
        return 8;
      case PrestigeUpgradeType.timekeepersFavor:
        return 10;
      case PrestigeUpgradeType.temporalMemory:
        return 8;
    }
  }

  int clampLevel(int level) {
    final cap = maxLevel;
    if (cap == null) return level < 0 ? 0 : level;
    return level.clamp(0, cap);
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
