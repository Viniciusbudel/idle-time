import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:time_factory/core/theme/game_theme.dart';
import 'package:time_factory/core/constants/game_assets.dart';

class RoaringTwentiesTheme implements GameTheme {
  const RoaringTwentiesTheme();

  @override
  String get id => 'roaring_20s';

  @override
  String get displayName => 'Roaring 20s';

  @override
  ThemeColors get colors => const _RoaringColors();

  @override
  ThemeAssets get assets => const _RoaringAssets();

  @override
  ThemeTypography get typography => const _RoaringTypography();

  @override
  ThemeDimens get dimens => const _RoaringDimens();
}

class _RoaringColors implements ThemeColors {
  const _RoaringColors();

  @override
  Color get primary => const Color(0xFFD4AF37); // Art Deco Gold
  @override
  Color get secondary => const Color(0xFF000000); // Black
  @override
  Color get background => const Color(0xFF101010); // Rich Black/Charcoal
  @override
  Color get surface => const Color(0xFF1A1A1A); // Dark Grey
  @override
  Color get accent => const Color(0xFFF2D16B); // Pale Gold
  @override
  Color get textPrimary => const Color(0xFFFFFAFA); // Snow White
  @override
  Color get textSecondary => const Color(0xFFB0B0B0); // Silver
  @override
  Color get glassBorder => const Color(0xFFD4AF37); // Gold Border
  @override
  Color get success => const Color(0xFF43A047); // Emerald Green
  @override
  Color get error => const Color(0xFFB71C1C); // Ruby Red

  @override
  Color get dockBackground => const Color(0xFF000000);
  @override
  Color get chaosButtonStart => const Color(0xFFFFD700); // Gold
  @override
  Color get chaosButtonEnd => const Color(0xFFDAA520); // Goldenrod

  @override
  Color get rarityCommon => const Color(0xFFB0BEC5); // Chrome/Silver
  @override
  Color get rarityRare => const Color(0xFF29B6F6); // Electric Blue
  @override
  Color get rarityEpic => const Color(0xFF9C27B0); // Purple Jazz
  @override
  Color get rarityLegendary => const Color(0xFFFFD700); // Pure Gold
  @override
  Color get rarityParadox => const Color(0xFFFF5252); // Red Alert
}

class _RoaringAssets implements ThemeAssets {
  const _RoaringAssets();

  @override
  String get mainBackground => GameAssets.eraRoaring20s;
  @override
  // Fallback to default icons until 20s specific ones are made
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

class _RoaringTypography implements ThemeTypography {
  const _RoaringTypography();

  @override
  String get fontFamily => 'Rye';

  @override
  TextStyle get titleLarge => GoogleFonts.rye(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: const Color(0xFFD4AF37),
  );

  @override
  TextStyle get titleMedium => GoogleFonts.rye(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: const Color(0xFFD4AF37),
  );

  @override
  TextStyle get bodyMedium =>
      GoogleFonts.josefinSans(fontSize: 14, color: const Color(0xFFE0E0E0));

  @override
  TextStyle get bodySmall =>
      GoogleFonts.josefinSans(fontSize: 12, color: const Color(0xFFB0B0B0));

  @override
  TextStyle get buttonText => GoogleFonts.rye(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.0,
  );
}

class _RoaringDimens implements ThemeDimens {
  const _RoaringDimens();

  @override
  double get cornerRadius => 2.0; // Sharp Art Deco corners
  @override
  double get paddingSmall => 10.0;
  @override
  double get paddingMedium => 20.0;
  @override
  double get iconSizeMedium => 24.0;
}
