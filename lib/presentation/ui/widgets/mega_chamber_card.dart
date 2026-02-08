import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/theme/game_theme.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/presentation/ui/dialogs/upgrade_confirmation_dialog.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/core/constants/tech_data.dart';

import 'package:time_factory/presentation/ui/widgets/worker_management_sheet.dart';

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

    return Container(
      // The "card-dark" background from HTML
      decoration: BoxDecoration(
        color: colors.dockBackground.withValues(
          alpha: 0.8,
        ), // Using dock bg as it matches card-dark
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.primary, // Bright Cyan border
          width: 1.0,
        ),
        boxShadow: [
          // shadow-neon-sm
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Stack(
        children: [
          // Inner Border (simulate double border effect or just padding)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header (Icon, Era Name, Title, Level)
                _buildHeader(context, theme, colors, typography),

                const SizedBox(height: 24),

                // 2. Visual Monitor Area
                _buildVisualArea(colors, typography),

                const SizedBox(height: 24),

                // 3. Stats Grid (3 Columns)
                _buildStatsGrid(colors, typography),

                const SizedBox(height: 24),

                // 4. Active Workforce Section
                Text(
                  'ACTIVE WORKFORCE',
                  style: typography.bodyMedium.copyWith(
                    fontSize: 10.0,
                    color: colors.primary.withValues(alpha: 0.7),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildWorkerGrid(theme),

                // Spacer to push button to bottom if card expands
                const SizedBox(height: 24),

                // 5. Expand Button
                _buildUpgradeButton(context, ref, theme, colors, typography),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    NeonTheme theme,
    ThemeColors colors,
    ThemeTypography typography,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Icon + Text Group
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Circle with Pulse Effect (Static for now)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.2),
                      blurRadius: 5,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  _getStationIcon(station.type),
                  color: colors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.type.era.displayName.toUpperCase(),
                      style: typography.bodyMedium.copyWith(
                        fontSize: 10,
                        color: colors.primary.withValues(alpha: 0.7),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      station.name.toUpperCase().replaceAll(
                        ' ',
                        '\n',
                      ), // Multi-line title check
                      style: typography.titleLarge.copyWith(
                        fontFamily: 'Orbitron', // Explicit
                        fontSize: 24,
                        height: 1.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Level Badge
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                border: Border.all(color: colors.primary),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Text(
                'LEVEL ${station.level}',
                style: typography.bodyMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Manage Button
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: theme.dimens is BuildContext
                      ? theme.dimens as BuildContext
                      : (colors is BuildContext
                            ? colors as BuildContext
                            : (typography is BuildContext
                                  ? typography as BuildContext
                                  : (context))), // Hacky context access? No, I have context in build method. But this is separate method.
                  // Wait, I don't have context here easily unless I pass it.
                  // _buildHeader signature: Widget _buildHeader(NeonTheme theme, ThemeColors colors, ThemeTypography typography)
                  // I need context.
                  // I will check if I can pass context or if I should refactor.
                  // Refactor: Pass context to _buildHeader.
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => const WorkerManagementSheet(),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.secondary.withValues(alpha: 0.2),
                  border: Border.all(color: colors.secondary),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people, size: 14, color: colors.secondary),
                    const SizedBox(width: 6),
                    Text(
                      'MANAGE',
                      style: typography.buttonText.copyWith(
                        fontSize: 10,
                        color: colors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVisualArea(ThemeColors colors, ThemeTypography typography) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Pattern (Placeholder)
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/scanlines.png', // Reusing existing asset
                repeat: ImageRepeat.repeat,
                errorBuilder: (c, o, s) => const SizedBox(),
              ),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.precision_manufacturing,
                size: 64,
                color: colors.secondary, // Accent Purple
                shadows: [
                  Shadow(
                    color: colors.secondary.withValues(alpha: 0.8),
                    blurRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'SYSTEM ONLINE',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  color: colors.success, // Green
                  fontSize: 12,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      color: colors.success.withValues(alpha: 0.7),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ThemeColors colors, ThemeTypography typography) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.primary.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn(
            'OUTPUT',
            '${NumberFormatter.format(production)}/s',
            colors.success,
            Icons.bolt,
            true,
            colors,
            typography,
          ),
          _buildStatColumn(
            'EFFICIENCY',
            '${(station.productionBonus * 100).toInt()}%',
            colors.primary,
            Icons.speed,
            true,
            colors,
            typography,
          ),
          _buildStatColumn(
            'CAPACITY',
            '${assignedWorkers.length}/${station.maxWorkerSlots}',
            Colors.white,
            Icons.groups,
            false,
            colors,
            typography,
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    Color color,
    IconData icon,
    bool glow,
    ThemeColors colors,
    ThemeTypography typography,
  ) {
    return Column(
      children: [
        Icon(icon, color: color.withValues(alpha: 0.9), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: typography.bodyMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
            shadows: glow
                ? [Shadow(color: color.withValues(alpha: 0.7), blurRadius: 5)]
                : [],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: typography.bodyMedium.copyWith(
            fontSize: 10,
            color: Colors.grey[400],
            letterSpacing: 1.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkerGrid(NeonTheme theme) {
    final colors = theme.colors;
    final totalSlots = station.maxWorkerSlots;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
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
        width: 50, // aspect-square roughly
        height: 50,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.05),
          border: Border.all(color: colors.primary),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.2),
              blurRadius: 5,
            ),
          ],
        ),
        child: Icon(Icons.account_circle, color: colors.primary, size: 32),
      ),
    );
  }

  Widget _buildEmptySlot(int index, ThemeColors colors) {
    return GestureDetector(
      onTap: () => onAssignSlot?.call(index),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.05),
          border: Border.all(color: colors.primary),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.2),
              blurRadius: 5,
            ),
          ],
        ),
        // Empty slot is also an account circle in the HTML example but maybe dimmer?
        // HTML shows empty slots as same structure. Let's make them slightly dimmer or same.
        // Wait, HTML: "3/3 Capacity" implies all full.
        // Let's use an "Add" icon or empty circle for empty slots.
        child: Icon(
          Icons.add_circle_outline,
          color: colors.primary.withValues(alpha: 0.3),
          size: 28,
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
    final gameState = ref.watch(gameStateProvider);
    final discount = TechData.calculateCostReductionMultiplier(
      gameState.techLevels,
    );
    final cost = station.getUpgradeCost(discountMultiplier: discount);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [Colors.cyan.shade500, Colors.blue.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (onUpgrade != null) {
              showDialog(
                context: context,
                builder: (context) => UpgradeConfirmationDialog(
                  station: station,
                  onConfirm: onUpgrade!,
                  title: "EXPAND CHAMBER?",
                  message:
                      "Expanding will increase configuration efficiency.\n\nCost: ${NumberFormatter.formatCE(cost)} CE",
                  costOverride: cost,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.upgrade, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'EXPAND CHAMBER',
                  style: typography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '[${NumberFormatter.formatCE(cost)}]',
                    style: typography.bodyMedium.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Rajdhani',
                      // Fallback to default mono-ish if need be, but Rajdhani is in body
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getStationIcon(StationType type) {
    return Icons.settings; // Standard icon from design
  }
}
