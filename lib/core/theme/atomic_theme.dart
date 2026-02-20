import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:time_factory/core/theme/game_theme.dart';

class AtomicTheme implements GameTheme {
  @override
  String get id => 'atomic_age';

  @override
  String get displayName => 'Atomic Age';

  @override
  ThemeColors get colors => const _AtomicColors();

  @override
  ThemeAssets get assets => const _AtomicAssets();

  @override
  ThemeTypography get typography => const _AtomicTypography();

  @override
  ThemeDimens get dimens => const _AtomicDimens();
}

class _AtomicColors implements ThemeColors {
  const _AtomicColors();

  @override
  Color get primary => const Color(0xFF00E5FF); // Atomic Cyan
  @override
  Color get secondary => const Color(0xFFFF4081); // Diner Pink
  @override
  Color get background => const Color(0xFFE0F7FA); // Light Blue tint (Screen BG)
  // Making surface darker for contrast against light BG or keeping it light?
  // EraTheme says surface is White. Let's stick to EraTheme but ensure readability.
  // Actually, for a game interface, a light theme might be blinding if not careful.
  // Converting to a "Dark Atomic" or sticking to "Retrofuturism Light"?
  // EraTheme says: backgroundColor: Color(0xFFE0F7FA), surfaceColor: Color(0xFFFFFFFF)
  // Let's trust the EraTheme definition for now.
  @override
  Color get surface => const Color(0xFFFFFFFF);
  @override
  Color get accent => const Color(0xFFFFAB40); // Atomic Orange
  @override
  Color get textPrimary => const Color(0xFF263238); // Dark Grey
  @override
  Color get textSecondary => const Color(0xFF546E7A); // Blue Grey
  @override
  Color get glassBorder => const Color(0xFF00E5FF); // Cyan Border
  @override
  Color get success => const Color(0xFF00C853); // Bright Green
  @override
  Color get error => const Color(0xFFD50000); // Red

  @override
  Color get dockBackground => const Color(0xFFB2EBF2); // Cyan 100
  @override
  Color get chaosButtonStart => const Color(0xFFFF4081); // Pink
  @override
  Color get chaosButtonEnd => const Color(0xFFF50057); // Deep Pink

  @override
  Color get rarityCommon => const Color(0xFF90A4AE); // Blue Grey
  @override
  Color get rarityRare => const Color(0xFF00E5FF); // Cyan
  @override
  Color get rarityEpic => const Color(0xFFAA00FF); // Purple
  @override
  Color get rarityLegendary => const Color(0xFFFFAB40); // Orange
  @override
  Color get rarityParadox => const Color(0xFF212121); // Black matter
}

class _AtomicAssets implements ThemeAssets {
  const _AtomicAssets();

  @override
  String get mainBackground =>
      'assets/images/backgrounds/atomic/atomic-age-background.png';
  @override
  // Fallback to default icons until Atomic specific ones are made
  String get iconChambers => 'assets/icons/steampunk/chambers.png';
  @override
  String get iconFactory => 'assets/icons/steampunk/factory.png';
  @override
  String get iconSummon => 'assets/icons/steampunk/summon.png';
  @override
  String get iconTech => 'assets/icons/steampunk/tech.png';
  @override
  String get iconPrestige => 'assets/icons/steampunk/prestige.png';
  @override
  String get overlayTexture => ''; // No heavy texture, clean look
}

class _AtomicTypography implements ThemeTypography {
  const _AtomicTypography();

  @override
  String get fontFamily => 'Orbitron';

  @override
  TextStyle get titleLarge => GoogleFonts.orbitron(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF263238),
  );

  @override
  TextStyle get titleMedium => GoogleFonts.orbitron(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF263238),
  );

  @override
  TextStyle get bodyMedium =>
      GoogleFonts.roboto(fontSize: 14, color: const Color(0xFF37474F));

  @override
  TextStyle get bodySmall =>
      GoogleFonts.roboto(fontSize: 12, color: const Color(0xFF546E7A));

  @override
  TextStyle get buttonText => GoogleFonts.orbitron(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
  );
}

class _AtomicDimens implements ThemeDimens {
  const _AtomicDimens();

  @override
  double get cornerRadius => 20.0; // Rounded, organic/aerodynamic 50s look
  @override
  double get paddingSmall => 8.0;
  @override
  double get paddingMedium => 16.0;
  @override
  double get iconSizeMedium => 24.0;
}
