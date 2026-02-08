import 'package:flutter/material.dart';

/// Abstract contract for Era-based themes
abstract class GameTheme {
  String get id;
  String get displayName;

  // Sub-theme groupings
  ThemeColors get colors;
  ThemeAssets get assets;
  ThemeTypography get typography;
  ThemeDimens get dimens;
}

abstract class ThemeColors {
  Color get primary;
  Color get secondary;
  Color get background;
  Color get surface;
  Color get accent;
  Color get textPrimary;
  Color get textSecondary;
  Color get glassBorder;
  Color get success;
  Color get error;

  // Specific UI elements
  Color get dockBackground;
  Color get chaosButtonStart;
  Color get chaosButtonEnd;
}

abstract class ThemeAssets {
  String get mainBackground;
  // Icons/Images paths
  String get iconChambers;
  String get iconFactory;
  String get iconSummon;
  String get iconTech;
  String get iconPrestige;

  // Effects
  String get overlayTexture; // e.g., scanlines or parchment
}

abstract class ThemeTypography {
  String get fontFamily;
  TextStyle get titleLarge;
  TextStyle get bodyMedium;
  TextStyle get buttonText;
}

abstract class ThemeDimens {
  double get cornerRadius;
  double get paddingSmall;
  double get paddingMedium;
  double get iconSizeMedium;
}
