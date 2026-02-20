import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/domain/entities/game_state.dart';

/// Floating HUD with resource pills - uses main cyberpunk colors
class FloatingResourcePills extends StatelessWidget {
  final GameState gameState;

  const FloatingResourcePills({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // CE/sec Pill
        Expanded(
          child: _ResourcePill(
            label: 'CE/SEC',
            value: NumberFormatter.formatCE(gameState.productionPerSecond),
            icon: Icons.bolt,
            color: TimeFactoryColors.electricCyan,
          ),
        ),
        const SizedBox(width: 12),
        // Shards Pill
        Expanded(
          child: _ResourcePill(
            label: 'SHARDS',
            value: gameState.timeShards.toString(),
            icon: Icons.diamond_outlined,
            color: TimeFactoryColors.deepPurple,
          ),
        ),
      ],
    );
  }
}

class _ResourcePill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ResourcePill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: TimeFactoryColors.surfaceDark.withOpacity( 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity( 0.3)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity( 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),

          // Text Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TimeFactoryTextStyles.bodyMono.copyWith(
                    fontSize: 9,
                    color: Colors.white54,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  value,
                  style: TimeFactoryTextStyles.numbers.copyWith(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
