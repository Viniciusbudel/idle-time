import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/domain/entities/offline_earnings.dart';
import 'package:time_factory/presentation/ui/widgets/glass_card.dart';
import 'package:time_factory/presentation/ui/widgets/animated_number.dart';

/// Dialog shown when returning after being offline
/// Shows CE earned while away
class OfflineEarningsDialog extends StatelessWidget {
  final OfflineEarnings earnings;
  final VoidCallback onCollect;

  const OfflineEarningsDialog({
    super.key,
    required this.earnings,
    required this.onCollect,
  });

  static Future<void> show(
    BuildContext context,
    OfflineEarnings earnings,
    VoidCallback onCollect,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          OfflineEarningsDialog(earnings: earnings, onCollect: onCollect),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        borderGlow: true,
        borderColor: TimeFactoryColors.electricCyan,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              'WELCOME BACK',
              style: TimeFactoryTextStyles.headerSmall.copyWith(
                color: TimeFactoryColors.electricCyan,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You were away for ${earnings.formattedDuration}',
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),

            const SizedBox(height: 24),

            // CE Earned
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  const Text(
                    'CHRONO-ENERGY COLLECTED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white38,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.bolt,
                        color: TimeFactoryColors.electricCyan,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      AnimatedNumber(
                        value: earnings.ceEarned,
                        style: TimeFactoryTextStyles.numbersHuge.copyWith(
                          fontSize: 32,
                          color: TimeFactoryColors.electricCyan,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Efficiency note
            Text(
              '${(earnings.efficiency * 100).toInt()}% offline efficiency',
              style: TextStyle(
                fontSize: 11,
                color: TimeFactoryColors.acidGreen.withValues(alpha: 0.8),
              ),
            ),

            const SizedBox(height: 24),

            // Collect button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  onCollect();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TimeFactoryColors.electricCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'COLLECT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
