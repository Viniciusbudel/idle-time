import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';

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
    final stations = gameState.stations.values.toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: TimeFactoryColors.voidBlack,
        border: Border(
          top: BorderSide(
            color: TimeFactoryColors.electricCyan.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getEraColor(worker.era).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getEraColor(worker.era),
                      width: 1,
                    ),
                  ),
                  child: Icon(Icons.person, color: _getEraColor(worker.era)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker.displayName,
                        style: TimeFactoryTextStyles.header.copyWith(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${worker.era.displayName} • Lv.${worker.level}',
                        style: TimeFactoryTextStyles.bodyMono.copyWith(
                          fontSize: 11,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                if (worker.isDeployed)
                  _buildStatusBadge('DEPLOYED', TimeFactoryColors.acidGreen)
                else
                  _buildStatusBadge('IDLE', TimeFactoryColors.voltageYellow),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          // Station list
          Flexible(
            child: stations.isEmpty
                ? _buildNoStations()
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: stations.length,
                    itemBuilder: (context, index) {
                      final station = stations[index];
                      return _buildStationTile(context, ref, station);
                    },
                  ),
          ),

          // Undeploy button if deployed
          if (worker.isDeployed)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TimeFactoryColors.hotMagenta.withValues(
                      alpha: 0.2,
                    ),
                    foregroundColor: TimeFactoryColors.hotMagenta,
                    side: const BorderSide(color: TimeFactoryColors.hotMagenta),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    ref
                        .read(gameStateProvider.notifier)
                        .undeployWorker(worker.id);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'RECALL WORKER',
                    style: TimeFactoryTextStyles.button,
                  ),
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

  Widget _buildNoStations() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.factory_outlined, size: 48, color: Colors.white24),
          const SizedBox(height: 12),
          Text(
            'NO STATIONS AVAILABLE',
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Build stations in the Factory tab',
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
            : TimeFactoryColors.surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentStation
              ? TimeFactoryColors.acidGreen
              : Colors.white12,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: TimeFactoryColors.electricCyan.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.settings_input_component,
            color: TimeFactoryColors.electricCyan,
          ),
        ),
        title: Text(
          station.name,
          style: TimeFactoryTextStyles.body.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
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
            ? const Icon(Icons.check_circle, color: TimeFactoryColors.acidGreen)
            : canDeploy
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TimeFactoryColors.electricCyan.withValues(
                    alpha: 0.2,
                  ),
                  foregroundColor: TimeFactoryColors.electricCyan,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: () {
                  ref
                      .read(gameStateProvider.notifier)
                      .deployWorker(worker.id, station.id);
                  Navigator.of(context).pop();
                },
                child: const Text('DEPLOY'),
              )
            : Text(
                'FULL',
                style: TimeFactoryTextStyles.bodyMono.copyWith(
                  fontSize: 11,
                  color: TimeFactoryColors.hotMagenta,
                ),
              ),
      ),
    );
  }

  Color _getEraColor(dynamic era) {
    // Return era-based color
    switch (era.id) {
      case 'victorian':
        return const Color(0xFFD4AF37); // Gold
      case 'roaring_20s':
        return const Color(0xFFFFD700); // Bright gold
      case 'atomic_age':
        return const Color(0xFF00FF00); // Green
      case 'cyberpunk_80s':
        return TimeFactoryColors.hotMagenta;
      case 'neo_tokyo':
        return TimeFactoryColors.electricCyan;
      default:
        return TimeFactoryColors.electricCyan;
    }
  }
}
