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
        vertical: AppSpacing.md,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.bottomSafe),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (stations.length > 1)
              _buildMigrationNotice(context, theme, stations.length),
            _buildMegaChamber(
              context,
              ref,
              theme,
              activeStation,
              gameState,
              isFirstCard: true,
            ),
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
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.10),
        border: Border.all(color: colors.accent.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(8),
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
    return production; // Per second
  }
}
