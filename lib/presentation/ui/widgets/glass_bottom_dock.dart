import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/theme/game_theme.dart';
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

    // Floating Dock Container
    return Container(
      margin: const EdgeInsets.fromLTRB(
        24,
        0,
        24,
        16,
      ), // Lifted off bottom, increased side margins
      height: 76, // Increased to prevent overflow
      decoration: BoxDecoration(
        color: colors.dockBackground.withValues(
          alpha: 0.8,
        ), // Semi-transparent based on theme
        borderRadius: BorderRadius.circular(theme.dimens.cornerRadius * 2),
        border: Border.all(
          color: colors.glassBorder.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          // Outer Glow
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          ),
          // Inner Bevel (simulated with inset shadow workaround or just border)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Glass effect
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _DockIcon(
                  icon: Icons.grid_view,
                  label: 'CHAMBERS',
                  isSelected: selectedIndex == 0,
                  onTap: () => onItemSelected(0),
                  activeColor: colors.accent,
                  inactiveColor: colors.textSecondary,
                  fontFamily: theme?.typography.fontFamily,
                ),
              ),
              Expanded(
                child: _DockIcon(
                  icon: Icons.factory,
                  label: 'FACTORY',
                  isSelected: selectedIndex == 1,
                  onTap: () => onItemSelected(1),
                  activeColor: colors.accent,
                  inactiveColor: colors.textSecondary,
                  fontFamily: theme?.typography.fontFamily,
                ),
              ),
              Expanded(
                child: _DockIcon(
                  icon: Icons.nights_stay,
                  label: 'SUMMON',
                  isSelected: selectedIndex == 2,
                  onTap: () => onItemSelected(2),
                  activeColor: colors.chaosButtonStart, // Special highlight
                  inactiveColor: colors.textSecondary,
                  fontFamily: theme?.typography.fontFamily,
                ),
              ),
              Expanded(
                child: _DockIcon(
                  icon: Icons.memory,
                  label: 'TECH',
                  isSelected: selectedIndex == 3,
                  onTap: () => onItemSelected(3),
                  activeColor: colors.accent,
                  inactiveColor: colors.textSecondary,
                  fontFamily: theme?.typography.fontFamily,
                ),
              ),
              Expanded(
                child: _DockIcon(
                  icon: Icons.military_tech,
                  label: 'PRESTIGE',
                  isSelected: selectedIndex == 4,
                  onTap: () => onItemSelected(4),
                  activeColor: colors.accent,
                  inactiveColor: colors.textSecondary,
                  fontFamily: theme?.typography.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;
  final String? fontFamily;

  const _DockIcon({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        transform: Matrix4.diagonal3Values(
          isSelected ? 1.1 : 1.0,
          isSelected ? 1.1 : 1.0,
          1.0,
        ), // Scale Animation
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with Glow
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.6),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                size: 26,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 4),
            // Label
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TimeFactoryTextStyles.bodySmall.copyWith(
                  fontFamily: fontFamily,
                  fontSize: 9,
                  color: isSelected ? activeColor : inactiveColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // Active Dot
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 4 : 0,
              height: isSelected ? 4 : 0,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
