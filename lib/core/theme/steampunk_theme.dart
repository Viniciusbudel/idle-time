import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:time_factory/core/theme/game_theme.dart';

class SteampunkTheme implements GameTheme {
  @override
  String get id => 'victorian';

  @override
  String get displayName => 'Victorian Era';

  @override
  ThemeColors get colors => const _SteampunkColors();

  @override
  ThemeAssets get assets => const _SteampunkAssets();

  @override
  ThemeTypography get typography => const _SteampunkTypography();

  @override
  ThemeDimens get dimens => const _SteampunkDimens();
}

class _SteampunkColors implements ThemeColors {
  const _SteampunkColors();

  @override
  Color get primary => const Color(0xFFC19A6B); // Brass
  @override
  Color get secondary => const Color(0xFF5D4037); // Dark Wood
  @override
  Color get background => const Color(0xFF1B1811); // Deep Soot
  @override
  Color get surface => const Color(0xFF2C241B); // Leather Brown
  @override
  Color get accent => const Color(0xFFE0C097); // Polished Brass
  @override
  Color get textPrimary => const Color(0xFFF5E6D3); // Parchment White
  @override
  Color get textSecondary => const Color(0xFFA69B8F); // Faded Ink
  @override
  Color get glassBorder => const Color(0xFF8B6B4E); // Bronze Border
  @override
  Color get success => const Color(0xFF6B8E23); // Olive Green
  @override
  Color get error => const Color(0xFF8B0000); // Crimson Red

  @override
  Color get dockBackground => const Color(0xFF1B1610);
  @override
  Color get chaosButtonStart => const Color(0xFFB8860B); // Dark Goldenrod
  @override
  Color get chaosButtonEnd => const Color(0xFF8B4513); // Saddle Brown
}

class _SteampunkAssets implements ThemeAssets {
  const _SteampunkAssets();

  @override
  String get mainBackground =>
      'assets/images/backgrounds/victorian_factory.png';
  @override
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
  String get overlayTexture => 'assets/images/overlays/paper_texture.png';
}

class _SteampunkTypography implements ThemeTypography {
  const _SteampunkTypography();

  @override
  String get fontFamily => 'Rye';

  @override
  TextStyle get titleLarge => GoogleFonts.rye(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: const Color(0xFFF5E6D3),
  );

  @override
  TextStyle get bodyMedium =>
      GoogleFonts.courierPrime(fontSize: 14, color: const Color(0xFFA69B8F));

  @override
  TextStyle get buttonText => GoogleFonts.rye(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
  );
}

class _SteampunkDimens implements ThemeDimens {
  const _SteampunkDimens();

  @override
  double get cornerRadius => 12.0; // Slightly uniform, machined look
  @override
  double get paddingSmall => 8.0;
  @override
  double get paddingMedium => 16.0;
  @override
  double get iconSizeMedium => 24.0;
}
