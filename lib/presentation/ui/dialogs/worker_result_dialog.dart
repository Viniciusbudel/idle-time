import 'package:flutter/material.dart';
import '../../../../core/theme/neon_theme.dart';
import '../../../../core/theme/game_theme.dart';
import '../../../../domain/entities/worker.dart';
import '../../../../domain/entities/enums.dart';

class WorkerResultDialog extends StatelessWidget {
  final Worker worker;
  final String title;
  final String buttonLabel;

  const WorkerResultDialog({
    super.key,
    required this.worker,
    this.title = 'SUCCESS!',
    this.buttonLabel = 'EXCELLENT',
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
              title,
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
              child: Icon(Icons.person, color: rarityColor, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              worker.displayName.toUpperCase(),
              style: typography.titleLarge.copyWith(color: rarityColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${worker.rarity.displayName} Unit',
              style: typography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'PROD: ${worker.baseProduction}',
              style: typography.bodyMedium.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: rarityColor,
                foregroundColor: Colors.black, // Contrast
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(buttonLabel),
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
