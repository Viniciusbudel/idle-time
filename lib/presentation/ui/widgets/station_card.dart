import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/presentation/state/theme_provider.dart';
import 'package:time_factory/presentation/ui/atoms/steampunk_button.dart';
import 'package:time_factory/presentation/ui/atoms/steampunk_card.dart';
import 'package:time_factory/presentation/ui/dialogs/upgrade_confirmation_dialog.dart';

/// Station card using Steampunk Atoms and Theme
class StationCard extends ConsumerWidget {
  final Station station;
  final List<Worker> assignedWorkers;
  final BigInt production;
  final VoidCallback? onUpgrade;
  final void Function(int slotIndex)? onAssignSlot;
  final void Function(String workerId)? onRemoveWorker;
  final bool isLocked;

  const StationCard({
    super.key,
    required this.station,
    required this.assignedWorkers,
    required this.production,
    this.onUpgrade,
    this.onAssignSlot,
    this.onRemoveWorker,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return SteampunkCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      onTap: isLocked ? null : null,
      child: isLocked
          ? _buildLockedContent(theme)
          : _buildUnlockedContent(context, theme),
    );
  }

  Widget _buildLockedContent(dynamic theme) {
    final colors = theme.colors;
    final typography = theme.typography;

    return Row(
      children: [
        // Locked icon box
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            border: Border.all(
              color: colors.textSecondary.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.lock_outline,
            color: colors.textSecondary.withValues(alpha: 0.5),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                station.name.toUpperCase(),
                style: typography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colors.textSecondary.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'LOCKED',
                  style: typography.bodyMedium.copyWith(
                    fontSize: 10.0,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnlockedContent(BuildContext context, dynamic theme) {
    final colors = theme.colors;
    final typography = theme.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row: Icon + Title + Level
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Box (Larger & richer)
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF2C241B), // Darker leather/metal
                border: Border.all(
                  color: const Color(0xFFC19A6B),
                  width: 3,
                ), // Brass ring
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                _getStationIcon(station.type),
                color: const Color(0xFFE0C097), // Polished Brass
                size: 32,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Title + Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Level
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          station.name.toUpperCase(),
                          style: typography.titleLarge.copyWith(
                            fontSize: 18.0,
                            color: colors.accent, // Polished Brass
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 2,
                                offset: const Offset(1, 1),
                              ),
                            ],
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
                          color: colors.primary.withValues(alpha: 0.1),
                        ),
                        child: Text(
                          'LVL ${station.level}',
                          style: typography.bodyMedium.copyWith(
                            fontSize: 10.0,
                            color: colors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Production Output
                  Row(
                    children: [
                      Text(
                        NumberFormatter.formatRate(production.toDouble()),
                        style: typography.bodyMedium.copyWith(
                          fontSize: 15.0,
                          color: colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'CE',
                        style: typography.bodyMedium.copyWith(
                          fontSize: 12.0,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Steam Pressure Gauge (Visual Progress)
                  _buildPressureGauge(theme),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Worker Slots
        _buildWorkerSlots(theme),

        const SizedBox(height: AppSpacing.md),

        // Bottom Row: Upgrade Button (Full width action area)
        SteampunkButton(
          label: 'UPGRADE  •  ${NumberFormatter.formatCE(station.upgradeCost)}',
          icon: Icons.arrow_upward,
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
    );
  }

  Widget _buildPressureGauge(dynamic theme) {
    // Visual representation of level progress (tier)
    double progress = (station.level % 10) / 10.0;
    if (progress == 0) progress = 1.0;

    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6B8E23), // Olive Green
                    Color(0xFFB8860B), // Goldenrod
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStationIcon(StationType type) {
    switch (type) {
      case StationType.basicLoop:
        return Icons.loop;
      case StationType.dualHelix:
        return Icons.all_inclusive;
      case StationType.paradoxAmplifier:
        return Icons.waves;
      case StationType.timeDistortion:
        return Icons.access_time_filled;
      case StationType.riftGenerator:
        return Icons.bolt;
    }
  }

  Widget _buildWorkerSlots(dynamic theme) {
    final totalSlots = station.maxWorkerSlots.clamp(1, 4);
    final unlockedSlots = (station.level + 1).clamp(1, totalSlots);

    return Row(
      children: List.generate(totalSlots, (index) {
        final isUnlocked = index < unlockedSlots;

        if (!isUnlocked) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildLockedSlot(theme),
          );
        }

        if (index < assignedWorkers.length) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildFilledSlot(assignedWorkers[index], theme),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _buildEmptySlot(index, theme),
        );
      }),
    );
  }

  Widget _buildFilledSlot(Worker worker, dynamic theme) {
    final colors = theme.colors;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onRemoveWorker?.call(worker.id);
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.3),
          border: Border.all(color: colors.accent.withValues(alpha: 0.8)),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Worker portrait
            Icon(Icons.person, color: colors.textPrimary, size: 28),
            // Era badge at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                color: Colors.black.withValues(alpha: 0.6),
                child: Text(
                  worker.era.displayName.substring(0, 3).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: theme.typography.bodyMedium.copyWith(
                    fontSize: 8.0,
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySlot(int index, dynamic theme) {
    final colors = theme.colors;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onAssignSlot?.call(index);
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: colors.textSecondary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: colors.textSecondary, size: 20),
            Text(
              'ASSIGN',
              style: theme.typography.bodyMedium.copyWith(
                fontSize: 8.0,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedSlot(dynamic theme) {
    final colors = theme.colors;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        border: Border.all(color: colors.textSecondary.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.lock,
        color: colors.textSecondary.withValues(alpha: 0.3),
        size: 18,
      ),
    );
  }
}
