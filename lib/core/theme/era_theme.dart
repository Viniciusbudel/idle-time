import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';

/// Defines the visual style for a specific Era
class EraTheme {
  final String id;
  final String displayName;

  // Color Palette
  final Color primaryColor; // Main accent (Buttons, Energy)
  final Color secondaryColor; // Secondary accent (Highlights)
  final Color backgroundColor; // Main background
  final Color surfaceColor; // Panels, cards
  final Color textColor; // Main text
  final Color successColor; // Production rates, upgrades
  final Color warningColor; // Alerts, paradox

  // Visual Effects
  final bool useScanlines; // Cyberpunk scanlines vs Victorian grain
  final double
  particleGlow; // Intensity of glows (high for neon, low for steam)
  final String fontFamily; // Font to use (if different)
  final EraAnimationType animationType; // Background animation style

  const EraTheme({
    required this.id,
    required this.displayName,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.successColor,
    required this.warningColor,
    this.useScanlines = false,
    this.particleGlow = 1.0,
    this.fontFamily = 'Orbitron', // Default
    this.animationType = EraAnimationType.none,
  });

  // ==================== PRE-DEFINED THEMES ====================

  /// 1. Victorian Era (1890s)
  static const victorian = EraTheme(
    id: 'victorian',
    displayName: 'LONDON (1893)',
    primaryColor: TimeFactoryColors.victorianBrass,
    secondaryColor: TimeFactoryColors.victorianGold,
    backgroundColor: TimeFactoryColors.victorianSepia,
    surfaceColor: TimeFactoryColors.victorianLeather,
    textColor: TimeFactoryColors.victorianCream,
    successColor: TimeFactoryColors.victorianOlive,
    warningColor: TimeFactoryColors.victorianCrimson,
    useScanlines: false,
    particleGlow: 0.3,
    animationType: EraAnimationType.fogDrift,
  );

  /// 2. Roaring 20s (1920s)
  static const roaring20s = EraTheme(
    id: 'roaring_20s',
    displayName: 'NEW YORK (1924)',
    primaryColor: Color(0xFFD4AF37), // Art Deco Gold
    secondaryColor: Color(0xFF000000), // Black
    backgroundColor: Color(0xFF0F0F0F), // Dark rich background
    surfaceColor: Color(0xFF1A1A1A), // Charcoal
    textColor: Color(0xFFF5F5F5), // White smoke
    successColor: Color(0xFF4CAF50), // Green
    warningColor: Color(0xFFB71C1C), // Deep Red
    useScanlines: false,
    particleGlow: 0.5,
    fontFamily: 'Rye',
    animationType: EraAnimationType.sparkle,
  );

  /// 3. Atomic Age (1950s)
  static const atomicAge = EraTheme(
    id: 'atomic_age',
    displayName: 'SUBURBIA (1955)',
    primaryColor: Color(0xFF00E5FF), // Atomic Cyan
    secondaryColor: Color(0xFFFF4081), // Diner Pink
    backgroundColor: Color(0xFFE0F7FA), // Light Blue tint
    surfaceColor: Color(0xFFFFFFFF), // Chrome/White
    textColor: Color(0xFF263238), // Dark Grey
    successColor: Color(0xFF00C853), // Bright Green
    warningColor: Color(0xFFFFAB40), // Atomic Orange
    useScanlines: false,
    particleGlow: 0.4,
    animationType: EraAnimationType.radarPulse,
  );

  /// 4. Cyberpunk 80s (1980s)
  static const cyberpunk80s = EraTheme(
    id: 'cyberpunk_80s',
    displayName: 'MIAMI (1984)',
    primaryColor: Color(0xFFFF00FF), // Magenta
    secondaryColor: Color(0xFF00FFFF), // Cyan
    backgroundColor: Color(0xFF0A0014), // Deep Purple Black
    surfaceColor: Color(0xFF240046), // Dark Indigo
    textColor: Color(0xFFE0AAFF), // Light Purple
    successColor: Color(0xFF39FF14), // Neon Green
    warningColor: Color(0xFFFF3131), // Neon Red
    useScanlines: true,
    particleGlow: 1.5, // High glow
    animationType: EraAnimationType.cyberScan,
  );

  /// 5. Neo-Tokyo (2247)
  static const neoTokyo = EraTheme(
    id: 'neo_tokyo',
    displayName: 'NEO-TOKYO (2247)',
    primaryColor: TimeFactoryColors.electricCyan,
    secondaryColor: TimeFactoryColors.hotMagenta,
    backgroundColor: TimeFactoryColors.voidBlack,
    surfaceColor: TimeFactoryColors.surfaceGlass,
    textColor: Colors.white,
    successColor: TimeFactoryColors.acidGreen,
    warningColor: TimeFactoryColors.hotMagenta,
    useScanlines: true,
    particleGlow: 1.2,
    animationType: EraAnimationType.cyberScan,
  );

  /// 6. Post-Singularity (2400s)
  static const postSingularity = EraTheme(
    id: 'post_singularity',
    displayName: 'THE CLOUD (2400)',
    primaryColor: Colors.white,
    secondaryColor: Color(0xFFB39DDB), // Deep Purple
    backgroundColor: Colors.black, // Void
    surfaceColor: Color(0x22FFFFFF), // Ethereal
    textColor: Color(0xFFE1F5FE),
    successColor: Color(0xFF69F0AE),
    warningColor: Color(0xFFFF5252),
    useScanlines: false,
    particleGlow: 2.0, // Blinding
    animationType: EraAnimationType.digitalRain,
  );

  /// 7. Ancient Rome (50 BC)
  static const ancientRome = EraTheme(
    id: 'ancient_rome',
    displayName: 'ROME (50 BC)',
    primaryColor: Color(0xFF800020), // Tyrian Purple
    secondaryColor: Color(0xFFFFD700), // Gold
    backgroundColor: Color(0xFFF5F5DC), // Marble/Beige
    surfaceColor: Color(0xFFFFFFFF), // Marble
    textColor: Color(0xFF3E2723), // Dark Brown
    successColor: Color(0xFF2E7D32), // Laurel Green
    warningColor: Color(0xFFB71C1C), // Blood Red
    useScanlines: false,
    particleGlow: 0.2, // Low, mostly for the "LEDs"
    animationType: EraAnimationType.fogDrift,
  );

  /// 8. Far Future (8000s)
  static const farFuture = EraTheme(
    id: 'far_future',
    displayName: 'COSMOS (8000)',
    primaryColor: Color(0xFF00BFA5), // Teal
    secondaryColor: Color(0xFF651FFF), // Deep Violet
    backgroundColor: Color(0xFF000000), // Space
    surfaceColor: Color(0x33651FFF), // Glassy Violet
    textColor: Color(0xFFE0F2F1),
    successColor: Color(0xFF64FFDA),
    warningColor: Color(0xFFFF4081),
    useScanlines: false,
    particleGlow: 1.8,
    animationType: EraAnimationType.starField,
  );

  /// Get theme by ID
  static EraTheme fromId(String id) {
    switch (id) {
      case 'victorian':
        return victorian;
      case 'roaring_20s':
        return roaring20s;
      case 'atomic_age':
        return atomicAge;
      case 'cyberpunk_80s':
        return cyberpunk80s;
      case 'neo_tokyo':
        return neoTokyo;
      case 'post_singularity':
        return postSingularity;
      case 'ancient_rome':
        return ancientRome;
      case 'far_future':
        return farFuture;
      default:
        return victorian;
    }
  }
}

/// Animation styles for era backgrounds
enum EraAnimationType {
  none,
  fogDrift, // Subtle moving clouds/fog (Victorian, Rome)
  sparkle, // Random twinkling (Roaring 20s)
  radarPulse, // Expanding circles (Atomic Age)
  cyberScan, // Scanlines, glitches (Cyberpunk/NeoTokyo)
  digitalRain, // Matrix style falling chars (Singularity)
  starField, // Parallax stars (Far Future)
}
