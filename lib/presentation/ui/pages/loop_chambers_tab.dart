import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/ui/dialogs/assign_worker_dialog.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/presentation/ui/organisms/mega_chamber_card.dart';
import 'package:time_factory/l10n/app_localizations.dart';

class LoopChambersTab extends ConsumerWidget {
  const LoopChambersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    // Force Neon Theme for this tab
    final theme = const NeonTheme();

    // Show ALL stations across all eras, sorted by era order
    final eraOrder = [
      'victorian',
      'roaring_20s',
      'atomic_age',
      'cyberpunk_80s',
      'neo_tokyo',
      'post_singularity',
      'ancient_rome',
      'far_future',
    ];
    final allStations = gameState.stations.values.toList()
      ..sort((a, b) {
        final aIndex = eraOrder.indexOf(a.type.era.id);
        final bIndex = eraOrder.indexOf(b.type.era.id);
        if (aIndex != bIndex) return aIndex.compareTo(bIndex);
        return b.level.compareTo(a.level);
      });

    if (allStations.isEmpty) {
      return const Center(
        child: Text('No chambers yet', style: TextStyle(color: Colors.white38)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: ListView.builder(
        itemCount: allStations.length + 1, // +1 for bottom padding
        itemBuilder: (context, index) {
          if (index == allStations.length) {
            return const SizedBox(height: 100); // Bottom padding
          }
          final card = _buildMegaChamber(
            context,
            ref,
            theme,
            allStations[index],
            gameState,
            isFirstCard: index == 0,
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: card,
          );
        },
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
      onRemoveWorker: (id) => _removeWorkerFromStation(ref, station, id),
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
}
