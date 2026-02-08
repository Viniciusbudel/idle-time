import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/theme/game_theme.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/presentation/ui/atoms/steampunk_button.dart';
import 'package:time_factory/presentation/ui/atoms/steampunk_card.dart';
import 'package:time_factory/presentation/ui/dialogs/upgrade_confirmation_dialog.dart';

class NeonChamberCard extends ConsumerWidget {
  final Station station;
  final List<Worker> assignedWorkers;
  final BigInt production;
  final VoidCallback? onUpgrade;
  final void Function(int slotIndex)? onAssignSlot;
  final void Function(String workerId)? onRemoveWorker;

  const NeonChamberCard({
    super.key,
    required this.station,
    required this.assignedWorkers,
    required this.production,
    this.onUpgrade,
    this.onAssignSlot,
    this.onRemoveWorker,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Force Neon Theme to align with "Tech Screen" aesthetic which uses NeonTheme
    final theme = const NeonTheme();
    final colors = theme.colors;
    final typography = theme.typography;

    return SteampunkCard(
      themeOverride: theme,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row: Icon + Title + Level
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Box (Matched to TechScreen style)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.2),
                  border: Border.all(color: colors.glassBorder),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  _getStationIcon(station.type),
                  color: colors.primary,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              // Title + Level + Production
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            station.name.toUpperCase(),
                            style: typography.bodyMedium.copyWith(
                              fontSize: 16.0,
                              color: colors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Level Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colors.accent.withValues(alpha: 0.5),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'LVL ${station.level}',
                            style: typography.bodyMedium.copyWith(
                              fontSize: 10.0,
                              color: colors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Production Stat
                    Row(
                      children: [
                        Icon(Icons.bolt, color: colors.success, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${NumberFormatter.format(production)} CE/s',
                          style: typography.bodyMedium.copyWith(
                            color: colors.success,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 2. Liquid Progress Bar (Visualizing Level Progress or Efficiency)
          // For Chambers, maybe visualize progress to next unlock or just decoration?
          // Using it for Level Progress within 10s step like original code
          _buildProgressBar(colors.primary, colors.accent),

          const SizedBox(height: 12),

          // 3. Worker Slots Area
          Text(
            'ASSIGNED WORKERS',
            style: typography.bodyMedium.copyWith(
              fontSize: 9.0,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          _buildWorkerSlots(theme),

          const SizedBox(height: 12),

          // 4. Upgrade Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Cost text
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Text(
                  'UPGRADE: ${NumberFormatter.formatCE(station.upgradeCost)} CE',
                  style: typography.bodyMedium.copyWith(
                    fontSize: 10.0,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              // Button
              SteampunkButton(
                themeOverride: theme,
                label: 'UPGRADE',
                isDestructive: false,
                onPressed: () {
                  if (onUpgrade != null) {
                    showDialog(
                      context: context,
                      builder: (context) => UpgradeConfirmationDialog(
                        station: station,
                        onConfirm: onUpgrade!,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Color primary, Color accent) {
    double progress = (station.level % 10) / 10.0;
    if (progress == 0) progress = 1.0;

    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: primary.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          children: [
            // Liquid Fill
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, accent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerSlots(NeonTheme theme) {
    final totalSlots = station.maxWorkerSlots.clamp(1, 4);
    final unlockedSlots = (station.level + 1).clamp(1, totalSlots);
    final colors = theme.colors;

    return Row(
      children: List.generate(totalSlots, (index) {
        final isUnlocked = index < unlockedSlots;
        if (!isUnlocked) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildLockedSlot(colors),
          );
        }
        if (index < assignedWorkers.length) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildWorkerAvatar(assignedWorkers[index], colors),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _buildEmptySlot(index, colors),
        );
      }),
    );
  }

  Widget _buildWorkerAvatar(Worker worker, ThemeColors colors) {
    return GestureDetector(
      onTap: () => onRemoveWorker?.call(worker.id),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.2),
          border: Border.all(color: colors.primary),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(Icons.person, color: colors.primary, size: 24),
      ),
    );
  }

  Widget _buildEmptySlot(int index, ThemeColors colors) {
    return GestureDetector(
      onTap: () => onAssignSlot?.call(index),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: colors.textSecondary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(Icons.add, size: 20, color: colors.textSecondary),
      ),
    );
  }

  Widget _buildLockedSlot(ThemeColors colors) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black26,
        border: Border.all(color: colors.textSecondary.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.lock,
        size: 16,
        color: colors.textSecondary.withValues(alpha: 0.3),
      ),
    );
  }

  IconData _getStationIcon(StationType type) {
    switch (type) {
      case StationType.basicLoop:
        return Icons.settings_suggest;
      case StationType.dualHelix:
        return Icons.all_inclusive;
      case StationType.paradoxAmplifier:
        return Icons.waves;
      case StationType.timeDistortion:
        return Icons.hourglass_full;
      case StationType.riftGenerator:
        return Icons.bolt;
    }
  }
}
