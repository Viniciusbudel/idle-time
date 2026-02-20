import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/theme/game_theme.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/core/constants/tutorial_keys.dart';
import 'package:time_factory/presentation/state/theme_provider.dart';

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

    // Floating Dock Container (Pill Shape)
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      height: 72,
      decoration: BoxDecoration(
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  0,
                  Icons.grid_view,
                  AppLocalizations.of(context)!.chambers,
                  colors,
                  theme,
                  key: TutorialKeys.chambersTab,
                ),
                _buildNavItem(
                  1,
                  Icons.factory,
                  AppLocalizations.of(context)!.factory,
                  colors,
                  theme,
                  key: TutorialKeys.factoryTab,
                ),
                _buildNavItem(
                  2,
                  Icons.auto_awesome,
                  AppLocalizations.of(context)!.summon,
                  colors,
                  theme,
                  key: TutorialKeys.gachaTab,
                ),
                _buildNavItem(
                  3,
                  Icons.memory,
                  AppLocalizations.of(context)!.tech,
                  colors,
                  theme,
                ),
                _buildNavItem(
                  4,
                  Icons.military_tech,
                  AppLocalizations.of(context)!.prestige,
                  colors,
                  theme,
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
    IconData icon,
    String label,
    ThemeColors colors,
    GameTheme theme, {
    Key? key,
  }) {
    final isSelected = selectedIndex == index;
    final color = isSelected
        ? colors.primary
        : colors.primary.withOpacity( 0.6);

    return Expanded(
      child: GestureDetector(
        key: key,
        onTap: () {
          HapticFeedback.lightImpact();
          onItemSelected(index);
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top Indicator (Floating Pill Style from HTML)
            // HTML has a top bar indicator for active state:
            // <div class="absolute -top-3 w-8 h-1 bg-primary ..."></div>
            // We'll simulate this with a small top container if selected
            if (isSelected)
              Container(
                width: 24,
                height: 3,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withOpacity( 0.8),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 7), // Spacer to keep icons aligned
            // Icon with Glow
            Icon(
              icon,
              size: 26,
              color: color,
              shadows: isSelected
                  ? [
                      Shadow(
                        color: colors.primary.withOpacity( 0.8),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),

            const SizedBox(height: 4),

            // Label
            Text(
              label,
              style: TimeFactoryTextStyles.bodySmall.copyWith(
                fontFamily: theme.typography.fontFamily,
                fontSize: 8,
                color: isSelected
                    ? Colors.white
                    : color, // Active -> White, Inactive -> Dim Cyan
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),

            // Bottom Dot (HTML has a bottom dot too)
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withOpacity( 0.8),
                      blurRadius: 4,
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 8), // Spacer
          ],
        ),
      ),
    );
  }
}
