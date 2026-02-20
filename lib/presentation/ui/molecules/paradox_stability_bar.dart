import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';

/// Paradox Stability Bar - Shows current paradox level with warning states
class ParadoxStabilityBar extends StatelessWidget {
  final double level; // 0.0 to 1.0

  const ParadoxStabilityBar({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final isCritical = level > 0.6;
    final isWarning = level > 0.4;

    // Determine color based on level
    Color barColor = TimeFactoryColors.acidGreen;
    if (isCritical) {
      barColor = TimeFactoryColors.hotMagenta;
    } else if (isWarning) {
      barColor = TimeFactoryColors.voltageYellow;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A0A).withOpacity( 0.9),
        border: Border.all(
          color: isCritical
              ? TimeFactoryColors.hotMagenta.withOpacity( 0.5)
              : Colors.white10,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Warning Icon
          Icon(Icons.warning_amber_rounded, color: barColor, size: 18),
          const SizedBox(width: 8),

          // Label
          Text(
            'PARADOX STABILITY',
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              fontSize: 11,
              color: barColor,
              letterSpacing: 1.0,
            ),
          ),

          const Spacer(),

          // Status Text
          Text(
            isCritical
                ? 'CRITICAL ${(level * 100).toInt()}%'
                : '${(level * 100).toInt()}%',
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              fontSize: 11,
              color: barColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact version for inline use
class ParadoxStabilityIndicator extends StatelessWidget {
  final double level;

  const ParadoxStabilityIndicator({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final isCritical = level > 0.6;

    Color barColor = TimeFactoryColors.acidGreen;
    if (level > 0.6) {
      barColor = TimeFactoryColors.hotMagenta;
    } else if (level > 0.4) {
      barColor = TimeFactoryColors.voltageYellow;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: barColor, size: 16),
              const SizedBox(width: 6),
              Text(
                'PARADOX STABILITY',
                style: TimeFactoryTextStyles.bodyMono.copyWith(
                  fontSize: 10,
                  color: barColor,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                isCritical
                    ? 'CRITICAL ${(level * 100).toInt()}%'
                    : '${(level * 100).toInt()}%',
                style: TimeFactoryTextStyles.bodyMono.copyWith(
                  fontSize: 10,
                  color: barColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Progress Bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: barColor.withOpacity( 0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Stack(
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          TimeFactoryColors.acidGreen.withOpacity( 0.2),
                          TimeFactoryColors.voltageYellow.withValues(
                            alpha: 0.2,
                          ),
                          TimeFactoryColors.hotMagenta.withOpacity( 0.2),
                        ],
                      ),
                    ),
                  ),
                  // Fill
                  FractionallySizedBox(
                    widthFactor: level.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            TimeFactoryColors.acidGreen,
                            level > 0.5
                                ? TimeFactoryColors.voltageYellow
                                : TimeFactoryColors.acidGreen,
                            level > 0.7
                                ? TimeFactoryColors.hotMagenta
                                : TimeFactoryColors.voltageYellow,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        boxShadow: [BoxShadow(color: barColor, blurRadius: 6)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
