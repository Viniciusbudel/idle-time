import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/state/production_provider.dart';

/// Premium header following the HTML prototype:
/// CE/sec (left) | Large CE icon + number (center) | Shards (right)
class ResourceAppBar extends ConsumerWidget {
  const ResourceAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productionPerSecond = ref.watch(productionPerSecondProvider);
    final breakdown = ref.watch(productionBreakdownProvider);
    final timeShards = ref.watch(timeShardsProvider);

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.sm,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.95),
            Colors.black.withValues(alpha: 0.8),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: CE/sec
          Expanded(
            child: Tooltip(
              message:
                  'Base: ${NumberFormatter.formatCompactDouble(breakdown.base)}\n'
                  'Tech Bonus: x${breakdown.techMultiplier.toStringAsFixed(2)}',
              preferBelow: true,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: TimeFactoryColors.surfaceGlass,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: TimeFactoryColors.electricCyan,
                  width: 1,
                ),
              ),
              textStyle: TimeFactoryTextStyles.bodySmall.copyWith(
                color: Colors.white,
              ),
              child: _SideStat(
                label: 'CE/SEC',
                value: NumberFormatter.formatCompactDouble(productionPerSecond),
                icon: Icons.bolt,
                iconColor: TimeFactoryColors.electricCyan.withValues(
                  alpha: 0.7,
                ),
                alignment: CrossAxisAlignment.start,
              ),
            ),
          ),

          // Center: Main CE display with icon
          Expanded(
            flex: 2,
            child: Consumer(
              builder: (context, ref, child) {
                final chronoEnergy = ref.watch(chronoEnergyProvider);
                return _CenterDisplay(
                  value: NumberFormatter.formatCE(chronoEnergy),
                );
              },
            ),
          ),

          // Right: Shards
          Expanded(
            child: _SideStat(
              label: 'SHARDS',
              value: timeShards.toString(),
              icon: Icons.diamond_outlined,
              iconColor: TimeFactoryColors.hotMagenta.withValues(alpha: 0.7),
              iconFirst: false,
              alignment: CrossAxisAlignment.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterDisplay extends StatelessWidget {
  final String value;

  const _CenterDisplay({required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glowing icon container
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: TimeFactoryColors.electricCyan.withValues(
                      alpha: 0.4,
                    ),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.4),
                border: Border.all(
                  color: TimeFactoryColors.electricCyan.withValues(alpha: 0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: TimeFactoryColors.electricCyan.withValues(
                      alpha: 0.4,
                    ),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Icon(
                Icons.energy_savings_leaf,
                size: 24,
                color: TimeFactoryColors.electricCyan,
                shadows: [
                  Shadow(color: TimeFactoryColors.electricCyan, blurRadius: 10),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xs),

        // Large CE number with glow
        Text(
          value,
          style: TimeFactoryTextStyles.ceDisplay.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: TimeFactoryColors.electricCyan.withValues(alpha: 0.8),
                blurRadius: 10,
              ),
              Shadow(
                color: TimeFactoryColors.electricCyan.withValues(alpha: 0.4),
                blurRadius: 20,
              ),
            ],
          ),
        ),

        const SizedBox(height: 2),

        // Label
        Text(
          'CHRONO ENERGY',
          style: TimeFactoryTextStyles.label.copyWith(
            color: TimeFactoryColors.electricCyan.withValues(alpha: 0.8),
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

class _SideStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool iconFirst;
  final CrossAxisAlignment alignment;

  const _SideStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.iconFirst = true,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.8,
      child: Column(
        crossAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Text(
            label,
            style: TimeFactoryTextStyles.label.copyWith(
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: AppSpacing.xxs),

          // Value with icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconFirst) ...[
                Icon(icon, size: 12, color: iconColor),
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: TimeFactoryTextStyles.numbersSmall.copyWith(
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              if (!iconFirst) ...[
                const SizedBox(width: 4),
                Icon(icon, size: 12, color: iconColor),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
