import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/theme/era_theme_provider.dart';
import 'package:time_factory/core/theme/era_theme.dart';
import 'package:time_factory/core/constants/text_styles.dart';

/// Minimal icon-only navigation dock
/// Replaces bulky CyberpunkNavBar with compact floating icons
/// Redesigned to match HTML reference: Floating glass dock with pop-out active icons.
class MinimalNavDock extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const MinimalNavDock({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(eraThemeProvider);

    return Container(
      // Height increased to accommodate the popped-out icon and shadows
      height: 90,
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      alignment: Alignment.bottomCenter,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Glass Dock Background
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: theme.surfaceColor.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border(
                    top: BorderSide(
                      color: theme.primaryColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                    // Top glow line effect
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Icons Row
          SizedBox(
            height: 90, // Full height to allow pop-up
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _NavPopIcon(
                  label: "Workers",
                  icon: Icons.engineering,
                  isSelected: selectedIndex == 0,
                  onTap: () => onItemSelected(0),
                  theme: theme,
                ),
                _NavPopIcon(
                  label: "Factory",
                  icon: Icons.factory,
                  isSelected: selectedIndex == 1,
                  onTap: () => onItemSelected(1),
                  theme: theme,
                ),
                _NavPopIcon(
                  label: "Tech",
                  icon: Icons.memory,
                  isSelected: selectedIndex == 2,
                  onTap: () => onItemSelected(2),
                  theme: theme,
                ),
                _NavPopIcon(
                  label: "Prestige",
                  icon: Icons.all_inclusive,
                  isSelected: selectedIndex == 3,
                  onTap: () => onItemSelected(3),
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavPopIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final EraTheme theme;

  const _NavPopIcon({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Active state uses primary color (Cyan usually)
    // Inactive state uses Gray

    // Using simple layout:
    // Container that animates its margin/translation

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Icon Container
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            width: isSelected ? 48 : 40,
            height: isSelected ? 48 : 40,
            transform: isSelected
                ? Matrix4.translationValues(0, -10, 0) // Pop up
                : Matrix4.translationValues(0, 0, 0),
            decoration: BoxDecoration(
              color: isSelected ? theme.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: Colors.white.withValues(alpha: 0.2))
                  : Border.all(color: Colors.transparent),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.black : Colors.grey,
              size: isSelected ? 28 : 24,
            ),
          ),

          const SizedBox(height: 4),

          // Label
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TimeFactoryTextStyles.bodySmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? theme.primaryColor : Colors.grey,
              letterSpacing: 1.0,
              shadows: isSelected
                  ? [
                      Shadow(
                        color: theme.primaryColor.withValues(alpha: 0.6),
                        blurRadius: 5,
                      ),
                    ]
                  : [],
            ),
            child: Text(label.toUpperCase()),
          ),

          const SizedBox(height: 12), // Bottom padding spacing
        ],
      ),
    );
  }
}
