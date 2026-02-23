import 'dart:math' as math;

/// Global tuning values for Era Mastery progression and perks.
class EraMasteryConstants {
  static const int mergeXp = 12;
  static const int expeditionSuccessXpPerWorker = 8;
  static const int eraTechCompletionXp = 100;

  static const double productionBonusPerLevel = 0.03;
  static const double victorianOfflineBonusPerLevel = 0.02;
  static const double atomicAutomationBonusPerLevel = 0.05;

  static const int baseXpPerLevel = 40;
  static const double xpGrowthPerLevel = 1.35;
  static const int maxLevel = 50;

  static int xpRequiredForLevel(int level) {
    if (level <= 0) return 0;
    return (baseXpPerLevel * math.pow(xpGrowthPerLevel, level - 1)).round();
  }

  static int levelFromXp(int xp) {
    if (xp <= 0) return 0;

    var remaining = xp;
    var level = 0;
    while (level < maxLevel) {
      final required = xpRequiredForLevel(level + 1);
      if (remaining < required) break;
      remaining -= required;
      level++;
    }
    return level;
  }
}
