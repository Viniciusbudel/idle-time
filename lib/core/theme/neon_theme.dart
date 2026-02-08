import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/theme/game_theme.dart';

/// The classic Neon/Cyberpunk theme for the user interface
class NeonTheme implements GameTheme {
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
  Color get primary => TimeFactoryColors.electricCyan;

  @override
  Color get secondary => TimeFactoryColors.hotMagenta;

  @override
  Color get background => TimeFactoryColors.voidBlack;

  @override
  Color get surface => TimeFactoryColors.surfaceGlass;

  @override
  Color get accent => TimeFactoryColors.electricCyan;

  @override
  Color get textPrimary => Colors.white;

  @override
  Color get textSecondary =>
      TimeFactoryColors.electricCyan.withValues(alpha: 0.7);

  @override
  Color get glassBorder =>
      TimeFactoryColors.electricCyan.withValues(alpha: 0.3);

  @override
  Color get success => TimeFactoryColors.acidGreen;

  @override
  Color get error => TimeFactoryColors.hotMagenta;

  @override
  Color get dockBackground =>
      TimeFactoryColors.voidBlack.withValues(alpha: 0.8);

  @override
  Color get chaosButtonStart => TimeFactoryColors.hotMagenta;

  @override
  Color get chaosButtonEnd => TimeFactoryColors.deepPurple;
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
  TextStyle get bodyMedium => TimeFactoryTextStyles.body;

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
