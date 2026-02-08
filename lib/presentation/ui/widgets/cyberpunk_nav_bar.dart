import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';

class CyberpunkNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CyberpunkNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Floating style with glassmorphism
    return Center(
      heightFactor: 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        height: 72,
        decoration: BoxDecoration(
          color: TimeFactoryColors.midnightBlue.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: TimeFactoryColors.electricCyan.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: TimeFactoryColors.electricCyan.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: 1,
            ),
            const BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Stack(
              children: [
                // Nav Items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavBarItem(
                      icon: Icons.people_outline,
                      activeIcon: Icons.people,
                      label: 'WORKERS',
                      isSelected: selectedIndex == 0,
                      onTap: () => onItemSelected(0),
                    ),
                    _NavBarItem(
                      icon: Icons.factory_outlined,
                      activeIcon: Icons.factory,
                      label: 'FACTORY',
                      isSelected: selectedIndex == 1,
                      onTap: () => onItemSelected(1),
                    ),
                    _NavBarItem(
                      icon: Icons.science_outlined,
                      activeIcon: Icons.science,
                      label: 'TECH',
                      isSelected: selectedIndex == 2,
                      onTap: () => onItemSelected(2),
                    ),
                    _NavBarItem(
                      icon: Icons.auto_awesome_outlined,
                      activeIcon: Icons.auto_awesome,
                      label: 'PRESTIGE',
                      isSelected: selectedIndex == 3,
                      onTap: () => onItemSelected(3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    if (widget.isSelected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_NavBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact(); // Game-feel feedback
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon with Glow
            ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: widget.isSelected
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: TimeFactoryColors.electricCyan.withValues(
                              alpha: 0.6,
                            ),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      )
                    : null,
                child: Icon(
                  widget.isSelected ? widget.activeIcon : widget.icon,
                  color: widget.isSelected
                      ? TimeFactoryColors.electricCyan
                      : TimeFactoryColors.smokeGray,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Text Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TimeFactoryTextStyles.bodySmall.copyWith(
                fontSize: 10,
                color: widget.isSelected
                    ? TimeFactoryColors.electricCyan
                    : TimeFactoryColors.smokeGray,
                fontWeight: widget.isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                letterSpacing: 1.0,
              ),
              child: Text(widget.label),
            ),

            // Interaction Indicator (Animated Line/Dot)
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: widget.isSelected ? 20 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: TimeFactoryColors.acidGreen,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  if (widget.isSelected)
                    BoxShadow(
                      color: TimeFactoryColors.acidGreen.withValues(alpha: 0.8),
                      blurRadius: 4,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
