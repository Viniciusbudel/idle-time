import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/theme/game_theme.dart';

class CyberpunkTheme implements GameTheme {
  const CyberpunkTheme();

  @override
  String get id => 'cyberpunk_80s';

  @override
  String get displayName => 'MIAMI 1984';

  @override
  ThemeColors get colors => const _CyberpunkColors();

  @override
  ThemeAssets get assets => const _CyberpunkAssets();

  @override
  ThemeTypography get typography => const _CyberpunkTypography();

  @override
  ThemeDimens get dimens => const _CyberpunkDimens();
}

class _CyberpunkColors implements ThemeColors {
  const _CyberpunkColors();

  @override
  Color get primary => const Color(0xFFFF00FF); // Hot Magenta

  @override
  Color get secondary => const Color(0xFF00FFFF); // Electric Cyan

  @override
  Color get background => const Color(0xFF0A0014); // Deep Purple Black

  @override
  Color get surface => const Color(0xFF240046); // Dark Indigo

  @override
  Color get accent => const Color(0xFF39FF14); // Neon Green

  @override
  Color get textPrimary => const Color(0xFFE0AAFF); // Light Purple

  @override
  Color get textSecondary => const Color(0xFFFF00FF).withOpacity(0.7);

  @override
  Color get glassBorder => const Color(0xFF00FFFF).withOpacity(0.5);

  @override
  Color get success => const Color(0xFF39FF14); // Neon Green

  @override
  Color get error => const Color(0xFFFF3131); // Neon Red

  @override
  Color get dockBackground => const Color(0xFF240046).withOpacity(0.9);

  @override
  Color get chaosButtonStart => const Color(0xFFFF00FF);

  @override
  Color get chaosButtonEnd => const Color(0xFF00FFFF);

  @override
  Color get rarityCommon => const Color(0xFFB0BEC5);

  @override
  Color get rarityRare => const Color(0xFF00FFFF);

  @override
  Color get rarityEpic => const Color(0xFFFF00FF);

  @override
  Color get rarityLegendary => const Color(0xFFFFD740);

  @override
  Color get rarityParadox => const Color(0xFF39FF14);
}

class _CyberpunkAssets implements ThemeAssets {
  const _CyberpunkAssets();

  @override
  String get mainBackground =>
      'assets/images/backgrounds/era_cyberpunk_80s.png';

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
  String get overlayTexture => 'assets/images/effects/scanlines.png';
}

class _CyberpunkTypography implements ThemeTypography {
  const _CyberpunkTypography();

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

class _CyberpunkDimens implements ThemeDimens {
  const _CyberpunkDimens();

  @override
  double get cornerRadius => 12.0;

  @override
  double get paddingSmall => 8.0;

  @override
  double get paddingMedium => 16.0;

  @override
  double get iconSizeMedium => 24.0;
}
