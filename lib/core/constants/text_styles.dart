import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Typography styles for Time Factory's cyberpunk aesthetic
class TimeFactoryTextStyles {
  TimeFactoryTextStyles._();

  // ===== HEADERS =====
  /// Main headers - Futuristic, geometric (Orbitron)
  // ===== HEADERS =====
  /// Main headers - Futuristic, geometric (Orbitron)
  static TextStyle get header => GoogleFonts.orbitron(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: TimeFactoryColors.electricCyan,
    letterSpacing: 2.0,
  );

  static TextStyle get headerSmall => GoogleFonts.orbitron(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: TimeFactoryColors.electricCyan,
    letterSpacing: 1.5,
  );

  static TextStyle get headerLarge => GoogleFonts.orbitron(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: TimeFactoryColors.electricCyan,
    letterSpacing: 3.0,
  );

  // ===== BODY TEXT =====
  /// Body text - Tech/Industrial (Rajdhani)
  static TextStyle get body => GoogleFonts.rajdhani(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white70,
  );

  static TextStyle get bodySmall => GoogleFonts.rajdhani(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white54,
  );

  static TextStyle get bodyLarge => GoogleFonts.rajdhani(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white70,
  );

  /// Monospace fallback for technical data
  static TextStyle get bodyMono =>
      GoogleFonts.spaceGrotesk(fontSize: 14, color: Colors.white70);

  // ===== NUMBERS =====
  /// Numbers - Display (Orbitron or Rajdhani)
  static TextStyle get numbers => GoogleFonts.rajdhani(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: TimeFactoryColors.electricCyan, // Updated to Cyan defaults
  );

  static TextStyle get numbersSmall => GoogleFonts.rajdhani(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: TimeFactoryColors.electricCyan,
  );

  static TextStyle get numbersLarge => GoogleFonts.orbitron(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: TimeFactoryColors.electricCyan,
    letterSpacing: 1.0,
  );

  static TextStyle get numbersHuge => GoogleFonts.orbitron(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: TimeFactoryColors.electricCyan,
    shadows: [
      Shadow(
        color: TimeFactoryColors.electricCyan.withOpacity( 0.5),
        blurRadius: 20,
      ),
    ],
  );

  // ===== GLITCH TEXT =====
  /// Glitch text - Terminal style
  static TextStyle get glitch => GoogleFonts.vt323(
    fontSize: 18,
    color: TimeFactoryColors.hotMagenta,
    letterSpacing: 1.5,
  );

  static TextStyle get glitchLarge => GoogleFonts.vt323(
    fontSize: 26,
    color: TimeFactoryColors.hotMagenta,
    letterSpacing: 2.0,
  );

  // ===== BUTTON TEXT =====
  static TextStyle get button => const TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );
  // ===== CAPTIONS & LABELS =====
  /// Caption - Small secondary text
  static TextStyle get caption => GoogleFonts.rajdhani(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.white38,
  );

  /// Label - All caps, tracking
  static TextStyle get label => GoogleFonts.orbitron(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: Colors.white54,
    letterSpacing: 1.5,
  );

  // ===== RESOURCE-SPECIFIC STYLES =====
  /// CE Display - Acid green with glow
  static TextStyle get ceDisplay => GoogleFonts.orbitron(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: TimeFactoryColors.acidGreen,
    shadows: [
      Shadow(
        color: TimeFactoryColors.acidGreen.withOpacity( 0.6),
        blurRadius: 12,
      ),
    ],
  );

  /// Shard Display - Deep purple
  static TextStyle get shardDisplay => GoogleFonts.orbitron(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: TimeFactoryColors.deepPurple,
    shadows: [
      Shadow(
        color: TimeFactoryColors.deepPurple.withOpacity( 0.5),
        blurRadius: 10,
      ),
    ],
  );

  /// Production rate - Smaller cyan
  static TextStyle get productionRate => GoogleFonts.rajdhani(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: TimeFactoryColors.electricCyan,
  );

  // ===== HELPER METHODS =====
  /// Apply color to any text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply glow effect to text (for important elements)
  static TextStyle withGlow(TextStyle style, Color glowColor) {
    return style.copyWith(
      shadows: [
        Shadow(color: glowColor.withOpacity( 0.8), blurRadius: 10),
        Shadow(color: glowColor.withOpacity( 0.5), blurRadius: 20),
      ],
    );
  }
}
