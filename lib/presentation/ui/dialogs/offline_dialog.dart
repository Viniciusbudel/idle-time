import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/domain/entities/offline_earnings.dart';
import 'package:time_factory/presentation/ui/atoms/animated_number.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/core/ui/app_icons.dart';

class OfflineExpeditionSummary {
  final int completedCount;
  final BigInt previewChronoEnergy;
  final int previewTimeShards;

  const OfflineExpeditionSummary({
    required this.completedCount,
    required this.previewChronoEnergy,
    required this.previewTimeShards,
  });
}

/// Dialog shown when returning after being offline
/// Features Neo-Retro Brutalism UI principles
class OfflineEarningsDialog extends StatefulWidget {
  final OfflineEarnings earnings;
  final VoidCallback onCollect;
  final OfflineExpeditionSummary? expeditionSummary;

  const OfflineEarningsDialog({
    super.key,
    required this.earnings,
    required this.onCollect,
    this.expeditionSummary,
  });

  static Future<void> show(
    BuildContext context,
    OfflineEarnings earnings,
    VoidCallback onCollect, {
    OfflineExpeditionSummary? expeditionSummary,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (_) => OfflineEarningsDialog(
        earnings: earnings,
        onCollect: onCollect,
        expeditionSummary: expeditionSummary,
      ),
    );
  }

  @override
  State<OfflineEarningsDialog> createState() => _OfflineEarningsDialogState();
}

class _OfflineEarningsDialogState extends State<OfflineEarningsDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Spring-like scale entrance
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final int efficiencyPercent = (widget.earnings.efficiency * 100).toInt();
    final hasOfflineYield =
        widget.earnings.ceEarned > BigInt.zero ||
        widget.earnings.offlineDuration > Duration.zero;
    final summary = widget.expeditionSummary;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(opacity: _fadeAnimation.value, child: child),
          );
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black, // Brutalist Solid Black
            border: Border.all(
              color: TimeFactoryColors.acidGreen,
              width: 2, // Sharp raw border
            ),
            // NO border radius (0px) to force sharp geometry
            boxShadow: [
              // Hard drop shadow, no blur
              BoxShadow(
                color: TimeFactoryColors.acidGreen.withValues(alpha: 0.3),
                offset: const Offset(8, 8),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Header (Sharp industrial header) ---
              Container(
                color: TimeFactoryColors.acidGreen,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.welcomeBack.toUpperCase(),
                      style: TimeFactoryTextStyles.header.copyWith(
                        color: Colors.black,
                        fontSize: 18,
                        letterSpacing: 4,
                      ),
                    ),
                    const AppIcon(
                      AppHugeIcons.satellite_alt_outlined,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Time Away Block ---
                    if (hasOfflineYield)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: Row(
                          children: [
                            const AppIcon(
                              AppHugeIcons.timer_off_outlined,
                              color: Colors.white54,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n
                                    .awayFor(widget.earnings.formattedDuration)
                                    .toUpperCase(),
                                style: TimeFactoryTextStyles.bodyMono.copyWith(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // --- CE Earned Block (Brutalist Data Display) ---
                    if (hasOfflineYield) ...[
                      Text(
                        'TOTAL YIELD:',
                        style: TimeFactoryTextStyles.bodyMono.copyWith(
                          color: TimeFactoryColors.electricCyan,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          border: const Border(
                            left: BorderSide(
                              color: TimeFactoryColors.electricCyan,
                              width: 4,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 6),
                              child: AppIcon(
                                AppHugeIcons.bolt,
                                color: TimeFactoryColors.electricCyan,
                                size: 32,
                              ),
                            ),
                            Expanded(
                              child: AnimatedNumber(
                                value: widget.earnings.ceEarned,
                                style: TimeFactoryTextStyles.numbersHuge
                                    .copyWith(
                                      fontSize: 42, // Massive type
                                      color: TimeFactoryColors.electricCyan,
                                      height: 1.0,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (summary != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          border: Border.all(
                            color: TimeFactoryColors.hotMagenta.withValues(
                              alpha: 0.5,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EXPEDITION REPORT',
                              style: TimeFactoryTextStyles.bodyMono.copyWith(
                                color: TimeFactoryColors.hotMagenta,
                                fontSize: 10,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${summary.completedCount} mission(s) completed while away',
                              style: TimeFactoryTextStyles.bodyMono.copyWith(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Claimable now: +${summary.previewChronoEnergy} CE • +${summary.previewTimeShards} TS',
                              style: TimeFactoryTextStyles.bodyMono.copyWith(
                                color: TimeFactoryColors.voltageYellow,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Open EXPEDITIONS to collect rewards.',
                              style: TimeFactoryTextStyles.bodyMono.copyWith(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // --- Efficiency Indicator ---
                    if (hasOfflineYield) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'EFF: ',
                            style: TimeFactoryTextStyles.bodyMono.copyWith(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            '$efficiencyPercent%',
                            style: TimeFactoryTextStyles.bodyMono.copyWith(
                              color: TimeFactoryColors.acidGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],

                    // --- Collect Button (Neo-Retro Action) ---
                    GestureDetector(
                      onTap: () {
                        widget.onCollect();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: TimeFactoryColors.acidGreen,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            l10n.collect.toUpperCase(),
                            style: TimeFactoryTextStyles.header.copyWith(
                              color: Colors.black,
                              fontSize: 16,
                              letterSpacing: 6,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
