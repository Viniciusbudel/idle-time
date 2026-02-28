import 'package:flutter/material.dart';

import '../../../../core/theme/neon_theme.dart';
import '../../../../core/theme/game_theme.dart';
import '../../../../core/constants/colors.dart';
import 'package:time_factory/presentation/ui/atoms/game_action_button.dart';
import '../../../../domain/entities/worker.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../core/utils/worker_icon_helper.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/utils/localization_extensions.dart';
import 'package:time_factory/core/ui/app_icons.dart';

class WorkerResultDialog extends StatelessWidget {
  final Worker worker;
  final String? title;
  final String? buttonLabel;
  final VoidCallback? onSharePressed;
  final bool showShareCta;

  const WorkerResultDialog({
    super.key,
    required this.worker,
    this.title,
    this.buttonLabel,
    this.onSharePressed,
    this.showShareCta = false,
  });

  @override
  Widget build(BuildContext context) {
    const theme = NeonTheme();
    final colors = theme.colors;
    final typography = theme.typography;

    final rarityColor = _getRarityColor(worker.rarity, colors);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF03070C), // Deep cyber black
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: rarityColor.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: rarityColor.withValues(alpha: 0.1),
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
                color: rarityColor.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(color: rarityColor.withValues(alpha: 0.3)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title?.toUpperCase() ??
                        AppLocalizations.of(
                          context,
                        )!.mergeSuccessful.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      color: rarityColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '> NEW.ASSET',
                        style: typography.bodyMedium.copyWith(
                          color: rarityColor.withValues(alpha: 0.5),
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppIcon(
                        AppHugeIcons.person_add,
                        color: rarityColor,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: rarityColor.withValues(alpha: 0.1),
                      border: Border.all(color: rarityColor, width: 2),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: rarityColor.withValues(alpha: 0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: WorkerIconHelper.buildIcon(
                        worker.era,
                        worker.rarity,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    worker.displayName.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: rarityColor.withValues(alpha: 0.1),
                      border: Border.all(
                        color: rarityColor.withValues(alpha: 0.5),
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!
                          .unit(worker.rarity.localizedName(context))
                          .toUpperCase(),
                      style: typography.bodyMedium.copyWith(
                        color: rarityColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${AppLocalizations.of(context)!.production.toUpperCase()}: ',
                        style: typography.bodyMedium.copyWith(
                          color: Colors.white54,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        '${worker.currentProduction} CE/s',
                        style: typography.bodyMedium.copyWith(
                          color: TimeFactoryColors.electricCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (showShareCta && onSharePressed != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: onSharePressed,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: rarityColor.withValues(alpha: 0.5),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppIcon(
                                AppHugeIcons.public,
                                color: rarityColor,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SHARE LOG',
                                style: typography.bodyMedium.copyWith(
                                  color: rarityColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  GameActionButton(
                    onTap: () => Navigator.pop(context),
                    label:
                        buttonLabel?.toUpperCase() ??
                        AppLocalizations.of(context)!.excellent.toUpperCase(),
                    icon: AppHugeIcons.check,
                    color: rarityColor,
                    height: 48,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(WorkerRarity rarity, ThemeColors colors) {
    switch (rarity) {
      case WorkerRarity.common:
        return colors.rarityCommon;
      case WorkerRarity.rare:
        return colors.rarityRare;
      case WorkerRarity.epic:
        return colors.rarityEpic;
      case WorkerRarity.legendary:
        return colors.rarityLegendary;
      case WorkerRarity.paradox:
        return colors.rarityParadox;
    }
  }
}
