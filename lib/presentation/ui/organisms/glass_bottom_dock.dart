import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/theme/game_theme.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/core/constants/tutorial_keys.dart';
import 'package:time_factory/presentation/state/theme_provider.dart';
import 'package:time_factory/core/ui/app_icons.dart';

class GlassBottomDock extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final GameTheme? themeOverride;

  const GlassBottomDock({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.themeOverride,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = themeOverride ?? ref.watch(themeProvider);
    final colors = theme!.colors;
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 390;
    final dockHeight = compact ? 68.0 : 72.0;
    final horizontalMargin = compact ? AppSpacing.xs : AppSpacing.md;
    final bottomMargin = compact ? AppSpacing.sm : AppSpacing.lg;
    final iconSize = compact ? 22.0 : 26.0;
    final labelSize = compact ? 7.0 : 8.0;

    // Floating Dock Container (Pill Shape)
    return Container(
      margin: EdgeInsets.only(
        left: horizontalMargin,
        right: horizontalMargin,
        bottom: bottomMargin,
      ),
      height: dockHeight,
      decoration: const BoxDecoration(
        // color: colors.dockBackground.withOpacity( 0.9),
        // borderRadius: BorderRadius.circular(24),
        // border: Border.all(
        //   color: colors.glassBorder, // Neon Border
        //   width: 1.0,
        // ),
        // boxShadow: [
        //   // Neon Glow Shadow corresponding to "shadow-neon-sm"
        //   BoxShadow(
        //     color: colors.primary.withOpacity( 0.2), // Bright Cyan glow
        //     blurRadius: 10,
        //     spreadRadius: 1,
        //   ),
        // ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  0,
                  AppHugeIcons.grid_view,
                  AppLocalizations.of(context)!.chambers,
                  colors,
                  theme,
                  iconSize: iconSize,
                  labelSize: labelSize,
                  compact: compact,
                  key: TutorialKeys.chambersTab,
                ),
                _buildNavItem(
                  1,
                  AppHugeIcons.factory,
                  AppLocalizations.of(context)!.factory,
                  colors,
                  theme,
                  iconSize: iconSize,
                  labelSize: labelSize,
                  compact: compact,
                  key: TutorialKeys.factoryTab,
                ),
                _buildNavItem(
                  2,
                  AppHugeIcons.auto_awesome,
                  AppLocalizations.of(context)!.summon,
                  colors,
                  theme,
                  iconSize: iconSize,
                  labelSize: labelSize,
                  compact: compact,
                  key: TutorialKeys.gachaTab,
                ),
                _buildNavItem(
                  3,
                  AppHugeIcons.memory,
                  AppLocalizations.of(context)!.tech,
                  colors,
                  theme,
                  iconSize: iconSize,
                  labelSize: labelSize,
                  compact: compact,
                ),
                _buildNavItem(
                  4,
                  AppHugeIcons.military_tech,
                  AppLocalizations.of(context)!.prestige,
                  colors,
                  theme,
                  iconSize: iconSize,
                  labelSize: labelSize,
                  compact: compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    AppIconData icon,
    String label,
    ThemeColors colors,
    GameTheme theme, {
    required double iconSize,
    required double labelSize,
    required bool compact,
    Key? key,
  }) {
    final isSelected = selectedIndex == index;
    final color = isSelected
        ? colors.primary
        : colors.primary.withValues(alpha: 0.6);

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        child: GestureDetector(
          key: key,
          onTap: () {
            HapticFeedback.lightImpact();
            onItemSelected(index);
          },
          behavior: HitTestBehavior.opaque,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Indicator (Floating Pill Style from HTML)
                if (isSelected)
                  Container(
                    width: compact ? 20 : 24,
                    height: 3,
                    margin: EdgeInsets.only(
                      bottom: compact ? AppSpacing.xxs : AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.8),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: compact ? AppSpacing.xs : 7,
                  ), // Spacer to keep icons aligned
                // Icon with Glow
                AppIcon(
                  icon,
                  size: iconSize,
                  color: color,
                  shadows: isSelected
                      ? [
                          Shadow(
                            color: colors.primary.withValues(alpha: 0.8),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),

                SizedBox(height: compact ? AppSpacing.xxs : AppSpacing.xs / 2),

                // Label
                Text(
                  label,
                  style: TimeFactoryTextStyles.bodySmall.copyWith(
                    fontFamily: theme.typography.fontFamily,
                    fontSize: labelSize,
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.bold,
                    letterSpacing: compact ? 0.6 : 1.0,
                  ),
                ),

                // Bottom Dot (HTML has a bottom dot too)
                if (isSelected)
                  Container(
                    margin: EdgeInsets.only(
                      top: compact ? AppSpacing.xxs : AppSpacing.xs / 2,
                    ),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.8),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(height: compact ? AppSpacing.xs - 1 : 8), // Spacer
              ],
            ),
          ),
        ),
      ),
    );
  }
}
