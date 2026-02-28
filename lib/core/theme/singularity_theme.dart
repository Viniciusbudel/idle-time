import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/game_assets.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/theme/game_theme.dart';

class SingularityTheme implements GameTheme {
  const SingularityTheme();

  @override
  String get id => 'post_singularity';

  @override
  String get displayName => 'SINGULARITY';

  @override
  ThemeColors get colors => const _SingularityColors();

  @override
  ThemeAssets get assets => const _SingularityAssets();

  @override
  ThemeTypography get typography => const _SingularityTypography();

  @override
  ThemeDimens get dimens => const _SingularityDimens();
}

class _SingularityColors implements ThemeColors {
  const _SingularityColors();

  @override
  Color get primary => const Color(0xFFE1F5FE);

  @override
  Color get secondary => const Color(0xFFB39DDB);

  @override
  Color get background => const Color(0xFF000000);

  @override
  Color get surface => const Color(0x221E1E2A);

  @override
  Color get accent => const Color(0xFF69F0AE);

  @override
  Color get textPrimary => const Color(0xFFE1F5FE);

  @override
  Color get textSecondary => const Color(0xFFB0BEC5);

  @override
  Color get glassBorder => const Color(0x66E1F5FE);

  @override
  Color get success => const Color(0xFF69F0AE);

  @override
  Color get error => const Color(0xFFFF5252);

  @override
  Color get dockBackground => const Color(0xCC0A0A14);

  @override
  Color get chaosButtonStart => const Color(0xFFB39DDB);

  @override
  Color get chaosButtonEnd => const Color(0xFF69F0AE);

  @override
  Color get rarityCommon => const Color(0xFFCFD8DC);

  @override
  Color get rarityRare => const Color(0xFF00E5FF);

  @override
  Color get rarityEpic => const Color(0xFFB388FF);

  @override
  Color get rarityLegendary => const Color(0xFFFFD740);

  @override
  Color get rarityParadox => const Color(0xFF69F0AE);
}

class _SingularityAssets implements ThemeAssets {
  const _SingularityAssets();

  @override
  String get mainBackground => GameAssets.eraSingularityWhitelabel;

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

class _SingularityTypography implements ThemeTypography {
  const _SingularityTypography();

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

class _SingularityDimens implements ThemeDimens {
  const _SingularityDimens();

  @override
  double get cornerRadius => 12.0;

  @override
  double get paddingSmall => 8.0;

  @override
  double get paddingMedium => 16.0;

  @override
  double get iconSizeMedium => 24.0;
}
