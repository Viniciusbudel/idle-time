import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/utils/localization_extensions.dart';
import 'package:time_factory/core/ui/app_icons.dart';
import 'package:time_factory/presentation/ui/atoms/game_action_button.dart';

/// Dialog to deploy a worker to a station
class DeployWorkerDialog extends ConsumerWidget {
  final Worker worker;

  const DeployWorkerDialog({super.key, required this.worker});

  static Future<void> show(BuildContext context, Worker worker) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DeployWorkerDialog(worker: worker),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    Station? chamber;
    for (final station in gameState.stations.values) {
      if (station.type.era.id == gameState.currentEraId) {
        chamber = station;
        break;
      }
    }
    chamber ??= gameState.stations.isNotEmpty
        ? gameState.stations.values.first
        : null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF03070C),
        border: Border(
          top: BorderSide(
            color: TimeFactoryColors.electricCyan.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Removed handle bar for neon UI

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: worker.era.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: worker.era.color, width: 1),
                  ),
                  child: AppIcon(AppHugeIcons.person, color: worker.era.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker.displayName.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        worker.era.localizedName(context),
                        style: TimeFactoryTextStyles.bodyMono.copyWith(
                          fontSize: 11,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                if (worker.isDeployed)
                  _buildStatusBadge(
                    AppLocalizations.of(context)!.statusDeployed,
                    TimeFactoryColors.acidGreen,
                  )
                else
                  _buildStatusBadge(
                    AppLocalizations.of(context)!.statusIdle,
                    TimeFactoryColors.voltageYellow,
                  ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          // Single chamber assignment
          Flexible(
            child: chamber == null
                ? _buildNoStations(context)
                : ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    children: [_buildStationTile(context, ref, chamber)],
                  ),
          ),

          // Undeploy button if deployed
          if (worker.isDeployed)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: GameActionButton(
                  onTap: () {
                    final bool success = ref
                        .read(gameStateProvider.notifier)
                        .undeployWorker(worker.id);
                    if (success) {
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Worker is on an active expedition.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  label: AppLocalizations.of(
                    context,
                  )!.recallWorker.toUpperCase(),
                  color: TimeFactoryColors.hotMagenta,
                  icon: AppHugeIcons.person_off,
                  height: 48,
                ),
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TimeFactoryTextStyles.bodyMono.copyWith(
          fontSize: 10,
          color: color,
        ),
      ),
    );
  }

  Widget _buildNoStations(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon(
            AppHugeIcons.factory_outlined,
            size: 48,
            color: Colors.white24,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.noChambersYet,
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.buildStationsToStart,
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              fontSize: 11,
              color: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationTile(
    BuildContext context,
    WidgetRef ref,
    Station station,
  ) {
    final isCurrentStation = worker.deployedStationId == station.id;
    final canDeploy = station.canAddWorker && !isCurrentStation;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentStation
            ? TimeFactoryColors.acidGreen.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isCurrentStation
              ? TimeFactoryColors.acidGreen
              : TimeFactoryColors.electricCyan.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: TimeFactoryColors.electricCyan.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const AppIcon(
            AppHugeIcons.settings_input_component,
            color: TimeFactoryColors.electricCyan,
          ),
        ),
        title: Text(
          station.name.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        subtitle: Text(
          '${station.workerIds.length}/${station.maxWorkerSlots} workers • +${(station.productionBonus * 100).toInt()}% bonus',
          style: TimeFactoryTextStyles.bodyMono.copyWith(
            fontSize: 11,
            color: Colors.white54,
          ),
        ),
        trailing: isCurrentStation
            ? const AppIcon(
                AppHugeIcons.check_circle,
                color: TimeFactoryColors.acidGreen,
              )
            : canDeploy
            ? GestureDetector(
                onTap: () {
                  ref
                      .read(gameStateProvider.notifier)
                      .deployWorker(worker.id, station.id);
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: TimeFactoryColors.electricCyan.withValues(
                      alpha: 0.2,
                    ),
                    border: Border.all(
                      color: TimeFactoryColors.electricCyan.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.deploy.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      color: TimeFactoryColors.electricCyan,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              )
            : Text(
                AppLocalizations.of(context)!.full,
                style: TimeFactoryTextStyles.bodyMono.copyWith(
                  fontSize: 11,
                  color: TimeFactoryColors.hotMagenta,
                ),
              ),
      ),
    );
  }
}
