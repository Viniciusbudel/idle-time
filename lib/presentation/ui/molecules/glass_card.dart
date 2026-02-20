import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/theme/era_theme_provider.dart';

/// A reusable glassmorphism card component based on HTML reference
/// CSS:
/// background: rgba(6, 18, 30, 0.4);
/// backdrop-filter: blur(8px);
/// border: 1px solid rgba(13, 227, 242, 0.3);
/// box-shadow: 0 4px 30px rgba(0, 0, 0, 0.5);
class GlassCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool borderGlow;
  final Color? borderColor;
  final Color? backgroundColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.onTap,
    this.borderGlow = false,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(eraThemeProvider);
    final effectiveBorderColor =
        borderColor ?? theme.primaryColor.withOpacity( 0.3);
    final effectiveRadius = borderRadius ?? BorderRadius.circular(12);

    Widget content = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0x6606121E), // 0.4 opacity
        borderRadius: effectiveRadius,
        border: Border.all(color: effectiveBorderColor, width: 1),
        boxShadow: [
          // Base shadow
          BoxShadow(
            color: Colors.black.withOpacity( 0.5),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
          // Optional Neon Glow
          if (borderGlow) ...[
            BoxShadow(
              color: effectiveBorderColor.withOpacity( 0.5),
              blurRadius: 12,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: effectiveBorderColor.withOpacity( 0.3),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ],
      ),
      child: child,
    );

    // Apply Blur
    content = ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: content,
      ),
    );

    // Handle Margin and Taps
    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}
