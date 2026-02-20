import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/theme/game_theme.dart';

/// The classic Neon/Cyberpunk theme for the user interface
class NeonTheme implements GameTheme {
  const NeonTheme();

  @override
  String get id => 'neon';

  @override
  String get displayName => 'NEON';

  @override
  ThemeColors get colors => const _NeonColors();

  @override
  ThemeAssets get assets => const _NeonAssets();

  @override
  ThemeTypography get typography => const _NeonTypography();

  @override
  ThemeDimens get dimens => const _NeonDimens();
}

class _NeonColors implements ThemeColors {
  const _NeonColors();

  @override
  Color get primary => const Color(0xFF00E5FF); // Bright Cyan

  @override
  Color get secondary => const Color(0xFFBD00FF); // Accent Purple

  @override
  Color get background => const Color(0xFF0A0B1E); // Deep Dark Blue

  @override
  Color get surface => const Color(0xFF13162F); // Card Dark

  @override
  Color get accent => const Color(0xFF00E5FF); // Bright Cyan

  @override
  Color get textPrimary => Colors.white;

  @override
  Color get textSecondary => const Color(0xFF00E5FF).withOpacity( 0.7);

  @override
  Color get glassBorder => const Color(0xFF00E5FF).withOpacity( 0.5); // Neon Border

  @override
  Color get success => const Color(0xFF00FF9D); // Accent Green

  @override
  Color get error => const Color(0xFFBD00FF);

  @override
  Color get dockBackground => const Color(0xFF13162F).withOpacity( 0.9); // Card Dark with opacity

  @override
  Color get chaosButtonStart => const Color(0xFFBD00FF);

  @override
  Color get chaosButtonEnd => const Color(0xFF0A0B1E);

  @override
  Color get rarityCommon => const Color(0xFFB0BEC5); // Silver/Gray

  @override
  Color get rarityRare => const Color(0xFF00BFFF); // Electric Blue

  @override
  Color get rarityEpic => const Color(0xFFE040FB); // Neon Purple

  @override
  Color get rarityLegendary => const Color(0xFFFFD740); // Gold

  @override
  Color get rarityParadox => const Color(0xFFFF1744); // Glitch Red
}

class _NeonAssets implements ThemeAssets {
  const _NeonAssets();

  @override
  String get mainBackground => 'assets/images/bg_neon.png';

  @override
  String get iconChambers => 'assets/icons/icon_chambers_neon.png';

  @override
  String get iconFactory => 'assets/icons/icon_factory_neon.png';

  @override
  String get iconSummon => 'assets/icons/icon_summon_neon.png';

  @override
  String get iconTech => 'assets/icons/icon_tech_neon.png';

  @override
  String get iconPrestige => 'assets/icons/icon_prestige_neon.png';

  @override
  String get overlayTexture => 'assets/images/scanlines.png';
}

class _NeonTypography implements ThemeTypography {
  const _NeonTypography();

  @override
  String get fontFamily => 'Orbitron';

  @override
  TextStyle get titleLarge => TimeFactoryTextStyles.header;

  @override
  TextStyle get titleMedium =>
      TimeFactoryTextStyles.header.copyWith(fontSize: 18);

  @override
  TextStyle get bodyMedium => TimeFactoryTextStyles.body;

  @override
  TextStyle get bodySmall => TimeFactoryTextStyles.body.copyWith(fontSize: 12);

  @override
  TextStyle get buttonText => TimeFactoryTextStyles.button;
}

class _NeonDimens implements ThemeDimens {
  const _NeonDimens();

  @override
  double get cornerRadius => 12.0;

  @override
  double get paddingSmall => 8.0;

  @override
  double get paddingMedium => 16.0;

  @override
  double get iconSizeMedium => 24.0;
}
