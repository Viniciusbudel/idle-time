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
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/core/constants/tech_data.dart';

class MegaChamberCard extends ConsumerWidget {
  final Station station;
  final List<Worker> assignedWorkers;
  final BigInt production;
  final VoidCallback? onUpgrade;
  final void Function(int slotIndex)? onAssignSlot;
  final void Function(String workerId)? onRemoveWorker;

  const MegaChamberCard({
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
    // Force Neon Theme
    final theme = const NeonTheme();
    final colors = theme.colors;
    final typography = theme.typography;

    return SteampunkCard(
      themeOverride: theme,
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header: Era & Name
          _buildHeader(theme, colors, typography),

          const SizedBox(height: AppSpacing.lg),

          // 2. Main Visual Area (The "Engine")
          _buildVisualArea(colors),

          const SizedBox(height: AppSpacing.lg),

          // 3. Stats Row
          _buildStatsRow(colors, typography),

          const SizedBox(height: AppSpacing.lg),

          // 4. Worker Grid (The Core Mechanics)
          Text(
            'ACTIVE WORKFORCE',
            style: typography.bodyMedium.copyWith(
              fontSize: 10.0,
              color: colors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildWorkerGrid(theme),

          const SizedBox(height: AppSpacing.xl),

          // 5. Expand Button (Upgrade)
          _buildUpgradeButton(context, ref, theme, colors, typography),
        ],
      ),
    );
  }

  Widget _buildHeader(
    NeonTheme theme,
    ThemeColors colors,
    ThemeTypography typography,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            border: Border.all(color: colors.glassBorder),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStationIcon(station.type),
            color: colors.primary,
            size: 32,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                station.type.era.displayName.toUpperCase(),
                style: typography.bodyMedium.copyWith(
                  fontSize: 10,
                  color: colors.textSecondary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                station.name.toUpperCase(),
                style: typography.titleLarge.copyWith(
                  fontSize: 20,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        // Level Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: 0.1),
            border: Border.all(color: colors.accent),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'LEVEL ${station.level}',
            style: typography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.accent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisualArea(ThemeColors colors) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.glassBorder),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.precision_manufacturing,
            size: 48,
            color: colors.secondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'SYSTEM ONLINE',
            style: TextStyle(
              color: colors.success.withValues(alpha: 0.8),
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ThemeColors colors, ThemeTypography typography) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          'OUTPUT',
          '${NumberFormatter.format(production)}/s',
          colors.success,
          Icons.bolt,
          colors,
          typography,
        ),
        _buildStatItem(
          'EFFICIENCY',
          '${(station.productionBonus * 100).toInt()}%',
          colors.accent,
          Icons.speed,
          colors,
          typography,
        ),
        _buildStatItem(
          'CAPACITY',
          '${assignedWorkers.length}/${station.maxWorkerSlots}',
          colors.textPrimary,
          Icons.group,
          colors,
          typography,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color valueColor,
    IconData icon,
    ThemeColors colors,
    ThemeTypography typography,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: valueColor.withValues(alpha: 0.8)),
        const SizedBox(height: 4),
        Text(
          value,
          style: typography.bodyMedium.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        Text(
          label,
          style: typography.bodyMedium.copyWith(
            fontSize: 9,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkerGrid(NeonTheme theme) {
    final colors = theme.colors;
    final totalSlots = station.maxWorkerSlots; // No clamp, let it grow!

    // Grid layout needs to handle many slots gracefully
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      children: List.generate(totalSlots, (index) {
        if (index < assignedWorkers.length) {
          return _buildWorkerAvatar(assignedWorkers[index], colors);
        }
        return _buildEmptySlot(index, colors);
      }),
    );
  }

  Widget _buildWorkerAvatar(Worker worker, ThemeColors colors) {
    return GestureDetector(
      onTap: () => onRemoveWorker?.call(worker.id),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.15),
          border: Border.all(color: colors.primary),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(Icons.person, color: colors.primary, size: 28),
      ),
    );
  }

  Widget _buildEmptySlot(int index, ThemeColors colors) {
    return GestureDetector(
      onTap: () => onAssignSlot?.call(index),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          border: Border.all(
            color: colors.textSecondary.withValues(alpha: 0.2),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.add,
          size: 20,
          color: colors.textSecondary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildUpgradeButton(
    BuildContext context,
    WidgetRef ref,
    NeonTheme theme,
    ThemeColors colors,
    ThemeTypography typography,
  ) {
    // Calculate cost for label
    final gameState = ref.watch(gameStateProvider);
    final discount = TechData.calculateCostReductionMultiplier(
      gameState.techLevels,
    );
    final cost = station.getUpgradeCost(discountMultiplier: discount);

    return SteampunkButton(
      themeOverride: theme,
      label: 'EXPAND CHAMBER (${NumberFormatter.formatCE(cost)})',
      icon: Icons.upgrade,
      isPrimary: true,
      onPressed: () {
        if (onUpgrade != null) {
          // Calculate discount from provider state
          final gameState = ref.read(gameStateProvider);
          final discount = TechData.calculateCostReductionMultiplier(
            gameState.techLevels,
          );
          final cost = station.getUpgradeCost(discountMultiplier: discount);

          showDialog(
            context: context,
            builder: (context) => UpgradeConfirmationDialog(
              station: station,
              onConfirm: onUpgrade!,
              title: "EXPAND CHAMBER?",
              message:
                  "Expanding will increase worker capacity and efficiency.\n\nCost: ${NumberFormatter.formatCE(cost)} CE",
              costOverride: cost,
            ),
          );
        }
      },
      width: double.infinity,
      height: 64,
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
