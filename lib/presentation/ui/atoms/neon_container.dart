import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';

/// A container with neon glow effect for cyberpunk aesthetic.
/// Wrap any widget to give it the signature Time Factory glow.
class NeonContainer extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double glowIntensity;
  final double borderRadius;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const NeonContainer({
    super.key,
    required this.child,
    this.glowColor = TimeFactoryColors.electricCyan,
    this.glowIntensity = 0.4,
    this.borderRadius = 12.0,
    this.borderWidth = 1.5,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: glowColor.withValues(alpha: 0.8),
          width: borderWidth,
        ),
        boxShadow: [
          // Inner glow
          BoxShadow(
            color: glowColor.withValues(alpha: glowIntensity * 0.5),
            blurRadius: 8,
            spreadRadius: -2,
          ),
          // Outer glow
          BoxShadow(
            color: glowColor.withValues(alpha: glowIntensity),
            blurRadius: 16,
            spreadRadius: 0,
          ),
          // Bloom effect
          BoxShadow(
            color: glowColor.withValues(alpha: glowIntensity * 0.3),
            blurRadius: 32,
            spreadRadius: 4,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Preset neon containers for common use cases
class NeonContainerPresets {
  /// Cyan glow for time/energy elements
  static Widget cyan({required Widget child, EdgeInsetsGeometry? padding}) {
    return NeonContainer(
      glowColor: TimeFactoryColors.electricCyan,
      padding: padding,
      child: child,
    );
  }

  /// Magenta glow for paradox/warning elements
  static Widget magenta({required Widget child, EdgeInsetsGeometry? padding}) {
    return NeonContainer(
      glowColor: TimeFactoryColors.hotMagenta,
      glowIntensity: 0.5,
      padding: padding,
      child: child,
    );
  }

  /// Green glow for production/success elements
  static Widget green({required Widget child, EdgeInsetsGeometry? padding}) {
    return NeonContainer(
      glowColor: TimeFactoryColors.acidGreen,
      glowIntensity: 0.35,
      padding: padding,
      child: child,
    );
  }

  /// Purple glow for premium/shard elements
  static Widget purple({required Widget child, EdgeInsetsGeometry? padding}) {
    return NeonContainer(
      glowColor: TimeFactoryColors.deepPurple,
      glowIntensity: 0.45,
      padding: padding,
      child: child,
    );
  }
}
