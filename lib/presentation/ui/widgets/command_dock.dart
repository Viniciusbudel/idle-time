import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/presentation/ui/widgets/glass_card.dart';

/// The main bottom navigation dock
/// HTML Reference:
/// <nav class="shrink-0 glass-card mx-2 mb-2 rounded-b-lg clip-corner-sm h-20 px-2 relative z-50">
class CommandDock extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CommandDock({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: GlassCard(
        height: 80,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _DockItem(
              icon: Icons.grid_view,
              label: 'CHAMBERS',
              isSelected: selectedIndex == 0,
              onTap: () => onItemSelected(0),
            ),
            _DockItem(
              icon: Icons.factory,
              label: 'FACTORY',
              isSelected: selectedIndex == 1,
              onTap: () => onItemSelected(1),
            ),
            _DockItem(
              icon: Icons.nights_stay,
              label: 'SUMMON',
              isSelected: selectedIndex == 2,
              onTap: () => onItemSelected(2),
              accentColor: TimeFactoryColors.hotMagenta,
            ),
            _DockItem(
              icon: Icons.memory,
              label: 'TECH',
              isSelected: selectedIndex == 3,
              onTap: () => onItemSelected(3),
            ),
            _DockItem(
              icon: Icons.military_tech,
              label: 'PRESTIGE',
              isSelected: selectedIndex == 4,
              onTap: () => onItemSelected(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? accentColor;

  const _DockItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Active Indicator (Top Bar)
            if (isSelected)
              Container(
                width: 40,
                height: 2,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: TimeFactoryColors.electricCyan,
                  boxShadow: [
                    BoxShadow(
                      color: TimeFactoryColors.electricCyan,
                      blurRadius: 8,
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 6),

            // Icon Container
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? TimeFactoryColors.electricCyan.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? TimeFactoryColors.electricCyan.withValues(alpha: 0.3)
                      : Colors.transparent,
                ),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? (accentColor ?? TimeFactoryColors.electricCyan)
                    : Colors.white54,
              ),
            ),

            const SizedBox(height: 4),

            // Label
            Text(
              label,
              style: TimeFactoryTextStyles.button.copyWith(
                fontSize: 10,
                color: isSelected
                    ? TimeFactoryColors.electricCyan
                    : Colors.white54,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
