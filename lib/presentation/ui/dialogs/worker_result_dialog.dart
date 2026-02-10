import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/neon_theme.dart';
import '../../../../core/theme/game_theme.dart';
import '../../../../domain/entities/worker.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../core/utils/worker_icon_helper.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/utils/localization_extensions.dart';

class WorkerResultDialog extends StatelessWidget {
  final Worker worker;
  final String? title;
  final String? buttonLabel;

  const WorkerResultDialog({
    super.key,
    required this.worker,
    this.title,
    this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    const theme = NeonTheme();
    final colors = theme.colors;
    final typography = theme.typography;

    final rarityColor = _getRarityColor(worker.rarity, colors);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.background,
          border: Border.all(color: rarityColor, width: 2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: rarityColor.withValues(alpha: 0.4),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title ?? AppLocalizations.of(context)!.mergeSuccessful,
              style: typography.titleLarge.copyWith(color: colors.accent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rarityColor.withValues(alpha: 0.2),
                border: Border.all(color: rarityColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: rarityColor.withValues(alpha: 0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SvgPicture.asset(
                    WorkerIconHelper.getIconPath(worker.era, worker.rarity),
                    //colorFilter: ColorFilter.mode(rarityColor, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              worker.displayName.toUpperCase(),
              style: typography.titleLarge.copyWith(color: rarityColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(
                context,
              )!.unit(worker.rarity.localizedName(context)),
              style: typography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppLocalizations.of(context)!.production}: ${worker.baseProduction}',
              style: typography.bodyMedium.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: rarityColor,
                foregroundColor: Colors.black, // Contrast
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                buttonLabel ?? AppLocalizations.of(context)!.excellent,
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
