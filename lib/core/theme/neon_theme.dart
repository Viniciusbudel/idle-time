import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
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
  Color get primary => TimeFactoryColors.primary;

  @override
  Color get secondary => TimeFactoryColors.secondary;

  @override
  Color get background => TimeFactoryColors.background;

  @override
  Color get surface => TimeFactoryColors.surface;

  @override
  Color get accent => TimeFactoryColors.accent;

  @override
  Color get textPrimary => const Color(0xFFE8EEF8);

  @override
  Color get textSecondary => primary.withValues(alpha: 0.78);

  @override
  Color get glassBorder => primary.withValues(alpha: 0.45);

  @override
  Color get success => TimeFactoryColors.success;

  @override
  Color get error => TimeFactoryColors.error;

  @override
  Color get dockBackground => surface.withValues(alpha: 0.92);

  @override
  Color get chaosButtonStart => secondary;

  @override
  Color get chaosButtonEnd => background;

  @override
  Color get rarityCommon => const Color(0xFF8D9CB8);

  @override
  Color get rarityRare => primary;

  @override
  Color get rarityEpic => secondary;

  @override
  Color get rarityLegendary => accent;

  @override
  Color get rarityParadox => error;
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
