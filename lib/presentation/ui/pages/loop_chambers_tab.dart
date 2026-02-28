import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/theme/game_theme.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/ui/dialogs/assign_worker_dialog.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/presentation/ui/organisms/mega_chamber_card.dart';
import 'package:time_factory/presentation/ui/organisms/worker_management_sheet.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/core/ui/app_icons.dart';
import 'package:time_factory/presentation/ui/pages/expeditions_screen.dart';

class LoopChambersTab extends ConsumerWidget {
  const LoopChambersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    const theme = NeonTheme();
    final stations = gameState.stations.values.toList(growable: false);
    if (stations.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noChambersYet,
          style: const TextStyle(color: Colors.white38),
        ),
      );
    }
    final activeStation = _selectActiveStation(gameState);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.bottomSafe),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (stations.length > 1)
              _buildMigrationNotice(context, theme, stations.length),

            // 2. Chamber Hero Module
            _buildMegaChamber(
              context,
              ref,
              theme,
              activeStation,
              gameState,
              isFirstCard: true,
            ),

            const SizedBox(height: 16),

            // 4. Command Hub (Manage Units + Expeditions)
            _CommandHub(colors: theme.colors, typography: theme.typography),
          ],
        ),
      ),
    );
  }

  Station _selectActiveStation(GameState gameState) {
    for (final station in gameState.stations.values) {
      if (station.type.era.id == gameState.currentEraId) {
        return station;
      }
    }
    return gameState.stations.values.first;
  }

  Widget _buildMigrationNotice(
    BuildContext context,
    NeonTheme theme,
    int stationCount,
  ) {
    final colors = theme.colors;
    final typography = theme.typography;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.10),
        border: Border.all(color: colors.accent.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Single chamber mode active. Consolidated from $stationCount chambers.',
        style: typography.bodyMedium.copyWith(
          color: colors.accent.withValues(alpha: 0.92),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildMegaChamber(
    BuildContext context,
    WidgetRef ref,
    NeonTheme theme,
    Station station,
    GameState gameState, {
    bool isFirstCard = false,
  }) {
    final allWorkers = gameState.workers.values.toList();
    final assigned = allWorkers
        .where((w) => station.workerIds.contains(w.id))
        .toList();

    final production = _calculateStationProduction(station, assigned);

    return MegaChamberCard(
      station: station,
      assignedWorkers: assigned,
      production: production,
      highlightFirstEmptySlot: isFirstCard,
      onUpgrade: () => _upgradeStation(ref, context, station),
      onAssignSlot: (slot) => _assignWorkerToSlot(ref, context, station, slot),
      onRemoveWorker: (id) =>
          _removeWorkerFromStation(ref, context, station, id),
    );
  }

  void _upgradeStation(WidgetRef ref, BuildContext context, Station station) {
    final success = ref
        .read(gameStateProvider.notifier)
        .upgradeStation(station.id);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.insufficientCE,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[900],
        ),
      );
    }
  }

  void _assignWorkerToSlot(
    WidgetRef ref,
    BuildContext context,
    Station station,
    int slotIndex,
  ) {
    final gameState = ref.read(gameStateProvider);
    final idleWorkers = gameState.workers.values
        .where((w) => !w.isDeployed)
        .toList();

    AssignWorkerDialog.show(
      context,
      station: station,
      slotIndex: slotIndex,
      idleWorkers: idleWorkers,
      onAssign: (worker) {
        return ref
            .read(gameStateProvider.notifier)
            .assignWorkerToStation(worker.id, station.id);
      },
    );
  }

  void _removeWorkerFromStation(
    WidgetRef ref,
    BuildContext context,
    Station station,
    String workerId,
  ) {
    final gameState = ref.read(gameStateProvider);
    final bool onActiveExpedition = gameState.expeditions.any(
      (expedition) =>
          !expedition.resolved && expedition.workerIds.contains(workerId),
    );
    if (onActiveExpedition) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Worker is on an active expedition.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    ref
        .read(gameStateProvider.notifier)
        .removeWorkerFromStation(workerId, station.id);
  }

  BigInt _calculateStationProduction(Station station, List<Worker> workers) {
    BigInt production = BigInt.zero;
    for (final worker in workers) {
      production +=
          worker.currentProduction *
          BigInt.from((station.productionBonus * 100).toInt()) ~/
          BigInt.from(100);
    }
    return production;
  }
}

// ---------------------------------------------------------------------------
// Command Hub — Dual-button panel: Manage Units + Expeditions
// ---------------------------------------------------------------------------
class _CommandHub extends StatefulWidget {
  final ThemeColors colors;
  final ThemeTypography typography;

  const _CommandHub({required this.colors, required this.typography});

  @override
  State<_CommandHub> createState() => _CommandHubState();
}

class _CommandHubState extends State<_CommandHub> {
  int _pressedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final typography = widget.typography;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF050A10),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'COMMAND HUB',
            style: typography.bodyMedium.copyWith(
              fontSize: 9,
              color: colors.primary.withValues(alpha: 0.50),
              letterSpacing: 2.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Container(height: 1, color: colors.primary.withValues(alpha: 0.10)),
          const SizedBox(height: 10),

          // Two-button row
          Row(
            children: [
              // Manage Units button
              Expanded(
                child: _buildHubButton(
                  index: 0,
                  icon: AppHugeIcons.person,
                  label: AppLocalizations.of(context)!.manageUnits,
                  color: colors.secondary,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (ctx) => const WorkerManagementSheet(),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Expeditions button
              Expanded(
                child: _buildHubButton(
                  index: 1,
                  icon: AppHugeIcons.rocket_launch,
                  label: 'EXPEDITIONS',
                  color: colors.accent,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ExpeditionsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHubButton({
    required int index,
    required AppIconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isPressed = _pressedIndex == index;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedIndex = index),
      onTapUp: (_) {
        setState(() => _pressedIndex = -1);
        onTap();
      },
      onTapCancel: () => setState(() => _pressedIndex = -1),
      child: AnimatedScale(
        scale: isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isPressed ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: color.withValues(alpha: isPressed ? 0.65 : 0.40),
              width: 1.0,
            ),
            boxShadow: isPressed
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.20),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(icon, color: color, size: 14),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
