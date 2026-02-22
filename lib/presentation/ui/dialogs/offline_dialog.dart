import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/domain/entities/offline_earnings.dart';
import 'package:time_factory/presentation/ui/atoms/animated_number.dart';
import 'package:time_factory/l10n/app_localizations.dart';

/// Dialog shown when returning after being offline
/// Features Neo-Retro Brutalism UI principles
class OfflineEarningsDialog extends StatefulWidget {
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
      barrierColor: Colors.black87,
      builder: (_) =>
          OfflineEarningsDialog(earnings: earnings, onCollect: onCollect),
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
                color: TimeFactoryColors.acidGreen.withOpacity(0.3),
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
                    const Icon(
                      Icons.satellite_alt_outlined,
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.timer_off_outlined,
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
                        color: Colors.white.withOpacity(0.05),
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
                            child: Icon(
                              Icons.bolt,
                              color: TimeFactoryColors.electricCyan,
                              size: 32,
                            ),
                          ),
                          Expanded(
                            child: AnimatedNumber(
                              value: widget.earnings.ceEarned,
                              style: TimeFactoryTextStyles.numbersHuge.copyWith(
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

                    // --- Efficiency Indicator ---
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
