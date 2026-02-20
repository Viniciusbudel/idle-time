import 'package:flutter/material.dart';
import 'package:time_factory/core/theme/game_theme.dart';
import 'package:time_factory/core/utils/worker_icon_helper.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/worker.dart';

/// Compact worker thumbnail for the management grid.
/// Shows avatar, rarity border, selection state, and optional legacy badge.
class WorkerTile extends StatelessWidget {
  final Worker worker;
  final bool isSelected;
  final bool isLegacy;
  final VoidCallback? onTap;
  final ThemeColors colors;

  const WorkerTile({
    super.key,
    required this.worker,
    required this.colors,
    this.isSelected = false,
    this.isLegacy = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor(worker.rarity);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? rarityColor.withOpacity( 0.2)
              : colors.surface,
          border: Border.all(
            color: isSelected
                ? rarityColor
                : rarityColor.withOpacity( 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: rarityColor.withOpacity( 0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: rarityColor.withOpacity( 0.15),
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: WorkerIconHelper.buildIcon(
                            worker.era,
                            worker.rarity,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Name
                  Text(
                    worker.displayName,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: rarityColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  // Era
                  Text(
                    worker.era.displayName,
                    style: TextStyle(
                      fontSize: 7,
                      color: colors.textSecondary.withOpacity( 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Selection checkmark
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: rarityColor,
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.black),
                ),
              ),

            // Legacy badge
            if (isLegacy)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'OLD',
                    style: TextStyle(
                      fontSize: 6,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(WorkerRarity rarity) {
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
