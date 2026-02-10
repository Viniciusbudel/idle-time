import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/presentation/ui/molecules/paradox_meter.dart';
import 'package:time_factory/core/utils/number_formatter.dart';

class ResourceHUD extends StatelessWidget {
  final GameState gameState;

  const ResourceHUD({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: TimeFactoryColors.midnightBlue.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: TimeFactoryColors.electricCyan.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1: Main Energy
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/icons/chrono_energy_icon.png',
                        width: 24,
                        height: 24,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.bolt,
                          color: TimeFactoryColors.electricCyan,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedNumberDisplay(
                              amount: gameState.chronoEnergy,
                              style: TimeFactoryTextStyles.numbers.copyWith(
                                fontSize: 20,
                                shadows: [
                                  Shadow(
                                    color: TimeFactoryColors.electricCyan
                                        .withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '+${NumberFormatter.formatCE(gameState.productionPerSecond)}/s',
                              style: TimeFactoryTextStyles.bodySmall.copyWith(
                                color: TimeFactoryColors.acidGreen,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Paradox Meter (Compact)
                      SizedBox(
                        width: 80,
                        child: ParadoxMeter(
                          level: gameState.paradoxLevel,
                          compact: true,
                          showLabel: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Row 2: Secondary Resources
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ResourceChip(
                        icon: Icons.auto_awesome,
                        label: '${gameState.timeShards} TS',
                        color: TimeFactoryColors.deepPurple,
                      ),
                      if (gameState.availableParadoxPoints > 0)
                        _ResourceChip(
                          icon: Icons.stars,
                          label: '${gameState.availableParadoxPoints} PP',
                          color: TimeFactoryColors.hotMagenta,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedNumberDisplay extends StatelessWidget {
  final BigInt amount;
  final TextStyle style;

  const AnimatedNumberDisplay({
    super.key,
    required this.amount,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(NumberFormatter.formatCE(amount), style: style);
  }
}

class _ResourceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ResourceChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TimeFactoryTextStyles.numbersSmall.copyWith(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
