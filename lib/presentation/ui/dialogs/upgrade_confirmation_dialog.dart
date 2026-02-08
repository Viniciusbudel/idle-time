import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/presentation/ui/widgets/glass_card.dart';

class UpgradeConfirmationDialog extends StatelessWidget {
  final Station station;
  final VoidCallback onConfirm;

  const UpgradeConfirmationDialog({
    super.key,
    required this.station,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final nextLevel = station.level + 1;
    // Calculate potential stats manually or via helper
    // Station entity logic:
    // basicLoop: 1.0 + (level - 1) * 0.1
    // So +0.1 per level for basicLoop.

    // Ideally we'd have a helper "getStatsForLevel(int level)" on Station,
    // but we can just use copyWith for simulation
    final nextStation = station.copyWith(level: nextLevel);

    final currentBonus = (station.productionBonus * 100).toInt();
    final nextBonus = (nextStation.productionBonus * 100).toInt();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        borderColor: TimeFactoryColors.electricCyan,
        borderGlow: true,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'UPGRADE STATION',
                style: TimeFactoryTextStyles.header.copyWith(
                  color: TimeFactoryColors.electricCyan,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Text(
                station.name,
                style: TimeFactoryTextStyles.body.copyWith(
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Level Change
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatBox('LEVEL', station.level.toString()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: TimeFactoryColors.electricCyan,
                    ),
                  ),
                  _buildStatBox('LEVEL', nextLevel.toString(), highlight: true),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Bonus Change
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Production Bonus: ',
                    style: TimeFactoryTextStyles.bodySmall,
                  ),
                  Text(
                    '$currentBonus%',
                    style: TimeFactoryTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(Icons.arrow_right_alt, color: Colors.white54, size: 16),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '$nextBonus%',
                    style: TimeFactoryTextStyles.bodySmall.copyWith(
                      color: TimeFactoryColors.acidGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Cost
              Text(
                'COST: ${NumberFormatter.format(station.upgradeCost)} CE',
                style: TimeFactoryTextStyles.numbers.copyWith(
                  color: TimeFactoryColors.hotMagenta,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'CANCEL',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      onConfirm();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TimeFactoryColors.electricCyan
                          .withValues(alpha: 0.2),
                      foregroundColor: TimeFactoryColors.electricCyan,
                      side: BorderSide(color: TimeFactoryColors.electricCyan),
                    ),
                    child: const Text('CONFIRM'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: highlight
            ? TimeFactoryColors.electricCyan.withValues(alpha: 0.1)
            : Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: highlight
            ? Border.all(
                color: TimeFactoryColors.electricCyan.withValues(alpha: 0.5),
              )
            : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TimeFactoryTextStyles.label.copyWith(fontSize: 10),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: TimeFactoryTextStyles.numbers.copyWith(
              color: highlight ? TimeFactoryColors.electricCyan : Colors.white,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
