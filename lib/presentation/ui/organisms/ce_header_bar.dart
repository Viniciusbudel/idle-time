import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/state/production_provider.dart';
import 'package:time_factory/presentation/ui/pages/settings_screen.dart';
import 'package:time_factory/core/ui/app_icons.dart';

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
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.95),
            Colors.black.withOpacity(0.8),
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
                  '${AppLocalizations.of(context)!.base}: ${NumberFormatter.formatCompactDouble(breakdown.base)}\n'
                  '${AppLocalizations.of(context)!.techBonus}: x${breakdown.techMultiplier.toStringAsFixed(2)}',
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
                label: AppLocalizations.of(context)!.ceSec,
                value: NumberFormatter.formatCompactDouble(productionPerSecond),
                icon: AppHugeIcons.bolt,
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

          // Right: Shards + Settings
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: _SideStat(
                    label: AppLocalizations.of(context)!.shards,
                    value: timeShards.toString(),
                    icon: AppHugeIcons.diamond_outlined,
                    iconColor: TimeFactoryColors.hotMagenta.withValues(
                      alpha: 0.7,
                    ),
                    iconFirst: false,
                    alignment: CrossAxisAlignment.end,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  child: AppIcon(
                    AppHugeIcons.settings,
                    size: 18,
                    color: TimeFactoryColors.electricCyan.withValues(
                      alpha: 0.5,
                    ),
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
                color: Colors.black.withOpacity(0.4),
                border: Border.all(
                  color: TimeFactoryColors.electricCyan.withOpacity(0.5),
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
              child: const Icon(
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
                color: TimeFactoryColors.electricCyan.withOpacity(0.8),
                blurRadius: 10,
              ),
              Shadow(
                color: TimeFactoryColors.electricCyan.withOpacity(0.4),
                blurRadius: 20,
              ),
            ],
          ),
        ),

        const SizedBox(height: 2),

        // Label
        Text(
          AppLocalizations.of(context)!.chronoEnergy.toUpperCase(),
          style: TimeFactoryTextStyles.label.copyWith(
            color: TimeFactoryColors.electricCyan.withOpacity(0.8),
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
  final AppIconData icon;
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
                AppIcon(icon, size: 12, color: iconColor),
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
                AppIcon(icon, size: 12, color: iconColor),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
