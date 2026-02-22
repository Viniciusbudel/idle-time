import 'package:flutter/material.dart';

/// Cyberpunk color palette for Time Factory
class TimeFactoryColors {
  TimeFactoryColors._();

  // ===== CORE TOKENS (HARMONIC SYSTEM) =====
  /// Primary
  static const primary = Color(0xFF1AA3B8);
  static const onPrimary = Color(0xFF04181D);

  /// Secondary
  static const secondary = Color(0xFF5B4BDB);
  static const onSecondary = Color(0xFFF4F1FF);

  /// Base surfaces
  static const background = Color(0xFF0B1020);
  static const surface = Color(0xFF141B2F);

  /// Feedback + accent
  static const error = Color(0xFFD64545);
  static const accent = Color(0xFFF2A93B);
  static const success = Color(0xFF3BCB7A);

  // ===== LEGACY ALIASES (COMPATIBILITY) =====
  static const electricCyan = primary;
  static const neonBlue = Color(0xFF2B8FCA);
  static const hotMagenta = error;
  static const voltageYellow = accent;
  static const acidGreen = success;
  static const deepPurple = secondary;
  static const paradoxPurple = deepPurple;

  // ===== BACKGROUND/ATMOSPHERE =====
  static const voidBlack = background;

  static const surfaceGlass = surface;

  static const midnightBlue = Color(0xFF1B2440);

  static const smokeGray = Color(0xFF2C3550);

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
    colors: [deepPurple, hotMagenta],
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

  /// Global Material dark theme aligned with the harmonic palette.
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: onSecondary,
        tertiary: accent,
        onTertiary: onPrimary,
        surface: surface,
        onSurface: Color(0xFFE8EEF8),
        error: error,
        onError: Color(0xFFFFF1F1),
      ),
      cardColor: surface,
      dividerColor: smokeGray,
    );
  }
}
