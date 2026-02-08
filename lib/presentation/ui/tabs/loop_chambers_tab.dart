import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
// import 'package:time_factory/presentation/state/theme_provider.dart'; // Unused
import 'package:time_factory/presentation/ui/widgets/cyberpunk_button.dart';
import 'package:time_factory/presentation/ui/dialogs/assign_worker_dialog.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/presentation/ui/widgets/neon_chamber_card.dart';

class LoopChambersTab extends ConsumerWidget {
  const LoopChambersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    // Force Neon Theme for this tab
    final theme = NeonTheme();

    final stations = gameState.stations.values.toList();
    final allWorkers = gameState.workers.values.toList();

    // Sort stations by index/creation order theoretically, or just list
    // Ensure scrollable area
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      children: [
        // 1. List of Chambers
        if (stations.isEmpty) _buildEmptyState(context, theme),

        ...stations.map((station) {
          final assigned = allWorkers
              .where((w) => station.workerIds.contains(w.id))
              .toList();

          final production = _calculateStationProduction(station, assigned);

          return NeonChamberCard(
            station: station,
            assignedWorkers: assigned,
            production: production,
            onUpgrade: () => _upgradeStation(ref, context, station),
            onAssignSlot: (slot) =>
                _assignWorkerToSlot(ref, context, station, slot),
            onRemoveWorker: (id) => _removeWorkerFromStation(ref, station, id),
          );
        }),

        const SizedBox(height: AppSpacing.lg),

        // 2. New Chamber Button (Cyberpunk)
        CyberpunkButton(
          label: 'CONSTRUCT NEW CHAMBER',
          icon: Icons.add_circle_outline,
          onPressed: () => _purchaseStation(ref, context),
          isPrimary: true,
          width: double.infinity,
          height: 56,
        ),

        // Bottom Padding for Dock
        const SizedBox(height: 120),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, dynamic theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          'NO CHAMBERS DETECTED',
          style: theme.typography.titleLarge.copyWith(color: Colors.white54),
        ),
      ),
    );
  }

  void _upgradeStation(WidgetRef ref, BuildContext context, Station station) {
    final success = ref
        .read(gameStateProvider.notifier)
        .upgradeStation(station.id);
    if (!success) {
      _showError(context, 'Insufficient CE for upgrade!');
    }
  }

  void _purchaseStation(WidgetRef ref, BuildContext context) {
    // Default to basic loop for now or show selection dialog?
    // Using basic loop as default action for button
    final success = ref
        .read(gameStateProvider.notifier)
        .purchaseStation(StationType.basicLoop);
    if (!success) {
      final cost = StationFactory.getPurchaseCost(
        StationType.basicLoop,
        ref.read(gameStateProvider).stations.length,
      );
      _showError(
        context,
        'Need ${NumberFormatter.formatCE(cost)} CE to construct!',
      );
    }
  }

  void _assignWorkerToSlot(
    WidgetRef ref,
    BuildContext context,
    Station station,
    int slotIndex,
  ) {
    final idleWorkers = ref
        .read(gameStateProvider)
        .workers
        .values
        .where((w) => !w.isDeployed)
        .toList();

    AssignWorkerDialog.show(
      context,
      station: station,
      slotIndex: slotIndex,
      idleWorkers: idleWorkers,
      onAssign: (worker) {
        ref
            .read(gameStateProvider.notifier)
            .assignWorkerToStation(worker.id, station.id);
      },
    );
  }

  void _removeWorkerFromStation(
    WidgetRef ref,
    Station station,
    String workerId,
  ) {
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
    return production; // Per second
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[900],
      ),
    );
  }
}
