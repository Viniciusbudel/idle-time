import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/core/ui/app_icons.dart';

class UpgradeConfirmationDialog extends StatelessWidget {
  final Station station;
  final VoidCallback onConfirm;
  final String? title;
  final String? message;
  final BigInt? costOverride;

  const UpgradeConfirmationDialog({
    super.key,
    required this.station,
    required this.onConfirm,
    this.title,
    this.message,
    this.costOverride,
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
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF03070C), // Deep cyber black
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: TimeFactoryColors.electricCyan.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: TimeFactoryColors.electricCyan.withValues(alpha: 0.1),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: TimeFactoryColors.electricCyan.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: TimeFactoryColors.electricCyan.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title?.toUpperCase() ??
                        AppLocalizations.of(
                          context,
                        )!.upgradeStation.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      color: TimeFactoryColors.electricCyan,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '> SYSTEM.UPGRADE',
                        style: TimeFactoryTextStyles.bodySmall.copyWith(
                          color: TimeFactoryColors.electricCyan.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const AppIcon(
                        AppHugeIcons.upgrade,
                        color: TimeFactoryColors.electricCyan,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message ?? station.name,
                    style: TimeFactoryTextStyles.body.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Level Change
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatBox('LEVEL', station.level.toString()),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: AppIcon(
                          AppHugeIcons.arrow_forward,
                          color: TimeFactoryColors.electricCyan,
                        ),
                      ),
                      _buildStatBox(
                        'LEVEL',
                        nextLevel.toString(),
                        highlight: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Bonus Change
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${AppLocalizations.of(context)!.productionBonus.toUpperCase()}: ',
                          style: TimeFactoryTextStyles.bodySmall.copyWith(
                            color: Colors.white54,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '$currentBonus%',
                          style: TimeFactoryTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const AppIcon(
                          AppHugeIcons.arrow_right_alt,
                          color: Colors.white54,
                          size: 16,
                        ),
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
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Cost
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'COST:',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          color: Colors.white54,
                          fontSize: 14,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${NumberFormatter.format(costOverride ?? station.getUpgradeCost())} CE',
                        style: TimeFactoryTextStyles.numbers.copyWith(
                          color: TimeFactoryColors.hotMagenta,
                          fontSize: 20,
                          shadows: [
                            Shadow(
                              color: TimeFactoryColors.hotMagenta.withValues(
                                alpha: 0.5,
                              ),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.cancel.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            onConfirm();
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: TimeFactoryColors.electricCyan.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: TimeFactoryColors.electricCyan,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: TimeFactoryColors.electricCyan
                                      .withValues(alpha: 0.3),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const AppIcon(
                                  AppHugeIcons.upgrade,
                                  color: TimeFactoryColors.electricCyan,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.confirm.toUpperCase(),
                                  style: const TextStyle(
                                    color: TimeFactoryColors.electricCyan,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: highlight
            ? TimeFactoryColors.electricCyan.withOpacity(0.1)
            : Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: highlight
            ? Border.all(color: TimeFactoryColors.electricCyan.withOpacity(0.5))
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
