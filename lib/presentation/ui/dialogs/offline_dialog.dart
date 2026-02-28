import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/domain/entities/offline_earnings.dart';
import 'package:time_factory/presentation/ui/atoms/animated_number.dart';
import 'package:time_factory/presentation/ui/atoms/game_action_button.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
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
    final theme = const NeonTheme();
    final c = theme.colors;
    final t = theme.typography;

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
            color: const Color(0xFF03070C), // Deep cyber black
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: TimeFactoryColors.acidGreen.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: TimeFactoryColors.acidGreen.withValues(alpha: 0.1),
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
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: TimeFactoryColors.acidGreen.withValues(alpha: 0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: TimeFactoryColors.acidGreen.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.welcomeBack.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        color: TimeFactoryColors.acidGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '> SYS.SYNC',
                          style: t.bodyMedium.copyWith(
                            color: TimeFactoryColors.acidGreen.withValues(
                              alpha: 0.5,
                            ),
                            fontSize: 10,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const AppIcon(
                          AppHugeIcons.satellite_alt_outlined,
                          color: TimeFactoryColors.acidGreen,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasOfflineYield)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: c.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: c.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            AppIcon(
                              AppHugeIcons.timer_off_outlined,
                              color: c.primary.withValues(alpha: 0.7),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n
                                    .awayFor(widget.earnings.formattedDuration)
                                    .toUpperCase(),
                                style: t.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    if (hasOfflineYield) ...[
                      Text(
                        'TOTAL YIELD',
                        style: t.bodyMedium.copyWith(
                          fontSize: 9,
                          color: c.primary.withValues(alpha: 0.5),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: TimeFactoryColors.electricCyan.withValues(
                            alpha: 0.05,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: TimeFactoryColors.electricCyan.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const AppIcon(
                              AppHugeIcons.factory,
                              color: TimeFactoryColors.electricCyan,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedNumber(
                                value: widget.earnings.ceEarned,
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 32,
                                  color: TimeFactoryColors.electricCyan,
                                  fontWeight: FontWeight.bold,
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
                          color: TimeFactoryColors.hotMagenta.withValues(
                            alpha: 0.05,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: TimeFactoryColors.hotMagenta.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EXPEDITION REPORT',
                              style: t.bodyMedium.copyWith(
                                color: TimeFactoryColors.hotMagenta.withValues(
                                  alpha: 0.8,
                                ),
                                fontSize: 9,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 1,
                              color: TimeFactoryColors.hotMagenta.withValues(
                                alpha: 0.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${summary.completedCount} MISSION(S) COMPLETED WHILE AWAY',
                              style: t.bodyMedium.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  'CLAIMABLE: ',
                                  style: t.bodyMedium.copyWith(
                                    color: Colors.white54,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  '+${summary.previewChronoEnergy} CE  //  +${summary.previewTimeShards} TS',
                                  style: t.bodyMedium.copyWith(
                                    color: TimeFactoryColors.voltageYellow,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'OPEN EXPEDITIONS TO COLLECT REWARDS.',
                              style: t.bodyMedium.copyWith(
                                color: TimeFactoryColors.hotMagenta.withValues(
                                  alpha: 0.6,
                                ),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (hasOfflineYield) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'OPERATIONAL EFF:%',
                            style: t.bodyMedium.copyWith(
                              color: c.primary.withValues(alpha: 0.3),
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            '$efficiencyPercent%',
                            style: t.bodyMedium.copyWith(
                              color: TimeFactoryColors.acidGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    GameActionButton(
                      onTap: () {
                        widget.onCollect();
                        Navigator.of(context).pop();
                      },
                      label: l10n.collect.toUpperCase(),
                      icon: AppHugeIcons.monetization_on_outlined,
                      color: TimeFactoryColors.acidGreen,
                      height: 48,
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
