import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/utils/expedition_utils.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/domain/entities/expedition.dart';
import 'package:time_factory/l10n/app_localizations.dart';

class ExpeditionRewardDialog extends StatefulWidget {
  final String slotName;
  final ExpeditionRisk risk;
  final ExpeditionReward reward;

  const ExpeditionRewardDialog({
    super.key,
    required this.slotName,
    required this.risk,
    required this.reward,
  });

  @override
  State<ExpeditionRewardDialog> createState() => _ExpeditionRewardDialogState();
}

class _ExpeditionRewardDialogState extends State<ExpeditionRewardDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flameController;

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = expeditionRiskColor(widget.risk);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[
              TimeFactoryColors.surface,
              TimeFactoryColors.background,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent, width: 1.2),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accent.withValues(alpha: 0.35),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedBuilder(
              animation: _flameController,
              builder: (BuildContext context, Widget? child) {
                final double t = _flameController.value;
                final double pulse = 0.9 + (t * 0.3);
                return SizedBox(
                  height: 84,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Transform.scale(
                        scale: 1.2 + (t * 0.35),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: pulse,
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          color: TimeFactoryColors.voltageYellow,
                          size: 42,
                        ),
                      ),
                      Positioned(
                        left: 12,
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          color: accent.withValues(alpha: 0.75),
                          size: 22,
                        ),
                      ),
                      Positioned(
                        right: 12,
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          color: TimeFactoryColors.hotMagenta.withValues(
                            alpha: 0.75,
                          ),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              AppLocalizations.of(context)!.expeditionReward,
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                color: accent,
                fontSize: 11,
                letterSpacing: 1.8,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              widget.slotName.toUpperCase(),
              style: TimeFactoryTextStyles.header.copyWith(
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm + 2),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: <Widget>[
                  _rewardRow(
                    label: AppLocalizations.of(context)!.chronoEnergyUpper,
                    value:
                        '+${NumberFormatter.formatCE(widget.reward.chronoEnergy)}',
                    color: TimeFactoryColors.electricCyan,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _rewardRow(
                    label: AppLocalizations.of(context)!.timeShardsUpper,
                    value: '+${widget.reward.timeShards}',
                    color: TimeFactoryColors.voltageYellow,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm + 2),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.awesome),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rewardRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              color: Colors.white70,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Text(
          value,
          style: TimeFactoryTextStyles.bodyMono.copyWith(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
