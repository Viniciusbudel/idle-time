import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/theme/game_theme.dart';
import 'package:time_factory/presentation/state/theme_provider.dart';

class SteampunkCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final GameTheme? themeOverride;

  const SteampunkCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.themeOverride,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = themeOverride ?? ref.watch(themeProvider);
    final colors = theme?.colors;
    final dimens = theme?.dimens;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: colors?.surface,
        borderRadius: BorderRadius.circular(dimens!.cornerRadius),
        border: Border.all(color: colors!.glassBorder, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
          // Inner highlight for metallic look
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.1),
            offset: const Offset(-1, -1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(dimens.cornerRadius),
          child: Padding(
            padding: padding ?? EdgeInsets.all(dimens.paddingMedium),
            child: child,
          ),
        ),
      ),
    );
  }
}
