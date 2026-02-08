import 'package:flutter/material.dart';

/// Cyberpunk color palette for Time Factory
class TimeFactoryColors {
  TimeFactoryColors._();

  // ===== PRIMARY COLORS (HTML Cyberpunk) =====
  /// Electric Cyan - Time energy, UI accents (#0de3f2)
  static const electricCyan = Color(0xFF0DE3F2);

  /// Neon Blue - Tech automation, cooling (#00f3ff) - close to cyan but distinct
  static const neonBlue = Color(0xFF00BFFF);

  /// Hot Magenta - Danger, paradox warnings, errors (#ff00ff)
  static const hotMagenta = Color(0xFFFF00FF);

  /// Voltage Yellow - Alerts, timekeepers (#facc15)
  static const voltageYellow = Color(0xFFFACC15);

  /// Acid Green - Success states, production (Legacy, keeping for now)
  static const acidGreen = Color(0xFF39FF14);

  /// Deep Purple - Premium currency, rare items
  static const deepPurple = Color(0xFF8B00FF);

  // ===== BACKGROUND/ATMOSPHERE =====
  /// Void Black - Base background (#050b14)
  static const voidBlack = Color(0xFF050B14);

  /// Surface Glass - Panels / Cards (#0d1b22)
  static const surfaceGlass = Color(0xFF0D1B22);

  /// Midnight Blue - Secondary panels (Legacy)
  static const midnightBlue = Color(0xFF1A1F3A);

  /// Smoke Gray - Inactive elements
  static const smokeGray = Color(0xFF2D2D44);

  // ===== REDESIGN COLORS (HTML Reference) =====
  static const backgroundDark = voidBlack;
  static const surfaceDark = surfaceGlass;

  // ===== ERA COLORS =====
  static const neoTokyoEra = electricCyan;
  static const postSingularityEra = deepPurple;

  // Legacy Eras (Keep for compatibility if needed, but UI is changing)
  static const victorianEra = Color(0xFFB8860B);
  static const roaring20sEra = Color(0xFFFFD700);
  static const atomicAgeEra = Color(0xFF00CED1);
  static const cyberpunk80sEra = Color(0xFFFF1493);
  static const ancientRomeEra = Color(0xFFDC143C);
  static const farFutureEra = Color(0xFF00FFFF);

  // ===== VICTORIAN ERA PALETTE =====
  static const victorianBrass = Color(0xFFB8860B); // Dark Goldenrod
  static const victorianGold = Color(0xFFDAA520); // Goldenrod
  static const victorianSepia = Color(0xFF2B1B17); // Dark Oil/Sepia
  static const victorianLeather = Color(0xFF3E2723); // Dark Brown
  static const victorianCream = Color(0xFFF5F5DC); // Beige
  static const victorianOlive = Color(0xFF556B2F); // Dark Olive Green
  static const victorianCrimson = Color(0xFF8B0000); // Dark Red

  // ===== GRADIENTS =====
  static const neonGradient = LinearGradient(
    colors: [electricCyan, deepPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const paradoxGradient = LinearGradient(
    colors: [hotMagenta, deepPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const productionGradient = LinearGradient(
    colors: [acidGreen, electricCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== HELPER METHODS =====
  /// Creates a neon glow box shadow for UI elements
  static List<BoxShadow> neonGlow(Color color, {double intensity = 1.0}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.5 * intensity),
        blurRadius: 20 * intensity,
        spreadRadius: 2 * intensity,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.3 * intensity),
        blurRadius: 40 * intensity,
        spreadRadius: 4 * intensity,
      ),
    ];
  }

  /// Creates the cyberpunk dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: voidBlack,
      primaryColor: electricCyan,
      colorScheme: const ColorScheme.dark(
        primary: electricCyan,
        secondary: hotMagenta,
        surface: midnightBlue,
        error: hotMagenta,
      ),
      cardColor: midnightBlue,
      dividerColor: smokeGray,
    );
  }
}
