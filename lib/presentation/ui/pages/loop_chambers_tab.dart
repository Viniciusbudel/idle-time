import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/constants/tech_data.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
// import 'package:time_factory/presentation/state/theme_provider.dart'; // Unused
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

    // Find the single station for the current Era
    final currentEraId = gameState.currentEraId;
    final stations = gameState.stations.values
        .where((s) => s.type.era.id == currentEraId)
        .toList();

    final activeStation = stations.isNotEmpty ? stations.first : null;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child:  _buildMegaChamber(context, ref, theme, activeStation!, gameState),
    );
  }


  Widget _buildMegaChamber(
    BuildContext context,
    WidgetRef ref,
    NeonTheme theme,
    Station station,
    GameState gameState,
  ) {
    final allWorkers = gameState.workers.values.toList();
    final assigned = allWorkers
        .where((w) => station.workerIds.contains(w.id))
        .toList();

    final production = _calculateStationProduction(station, assigned);

    // Use ListView just to allow scrolling if screen is short
    return ListView(
      children: [
        MegaChamberCard(
          station: station,
          assignedWorkers: assigned,
          production: production,
          onUpgrade: () => _upgradeStation(ref, context, station),
          onAssignSlot: (slot) =>
              _assignWorkerToSlot(ref, context, station, slot),
          onRemoveWorker: (id) => _removeWorkerFromStation(ref, station, id),
        ),

        // Bottom Padding
        const SizedBox(height: 100),
      ],
    );
  }

  void _upgradeStation(WidgetRef ref, BuildContext context, Station station) {
    final success = ref
        .read(gameStateProvider.notifier)
        .upgradeStation(station.id);
    if (!success) {
      _showError(context, AppLocalizations.of(context)!.insufficientCE);
    }
  }

  void _purchaseStation(WidgetRef ref, BuildContext context) {
    final gameState = ref.read(gameStateProvider);
    final currentEraId = gameState.currentEraId;

    // Determine station type for current era
    // We assume 1 station type per era for now as per design
    final stationType = StationType.values.firstWhere(
      (type) => type.era.id == currentEraId,
      orElse: () => StationType.basicLoop,
    );

    // Check limit before trying purchase (for better error msg)
    if (gameState.getStationCountForEra(currentEraId) >= 5) {
      _showError(context, AppLocalizations.of(context)!.factoryFloorFull);
      return;
    }

    final success = ref
        .read(gameStateProvider.notifier)
        .purchaseStation(stationType);

    if (!success) {
      // Calculate cost for error message
      final discount = TechData.calculateCostReductionMultiplier(
        gameState.techLevels,
      );
      final ownedCount = gameState.stations.values
          .where((s) => s.type == stationType)
          .length;

      final cost = StationFactory.getPurchaseCost(
        stationType,
        ownedCount,
        discountMultiplier: discount,
      );
      _showError(
        context,
        AppLocalizations.of(
          context,
        )!.needCEToConstruct(NumberFormatter.formatCE(cost)),
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
