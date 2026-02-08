/// Consistent spacing scale based on 8px grid.
/// Use these instead of magic numbers for padding/margins.
class AppSpacing {
  AppSpacing._();

  /// 4px - Extra extra small (tight icons, minimal gaps)
  static const double xxs = 4.0;

  /// 8px - Extra small (inline elements, icon gaps)
  static const double xs = 8.0;

  /// 12px - Small (compact cards, list items)
  static const double sm = 12.0;

  /// 16px - Medium (standard padding, card content)
  static const double md = 16.0;

  /// 24px - Large (section gaps, major elements)
  static const double lg = 24.0;

  /// 32px - Extra large (screen margins, major sections)
  static const double xl = 32.0;

  /// 48px - Extra extra large (hero sections, major breaks)
  static const double xxl = 48.0;

  /// 64px - Command dock height allowance
  static const double dockHeight = 64.0;

  /// 80px - Bottom safe area with dock
  static const double bottomSafe = 80.0;
}
