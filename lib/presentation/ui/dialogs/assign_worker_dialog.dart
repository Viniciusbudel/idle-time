import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/utils/worker_icon_helper.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/utils/localization_extensions.dart';
import 'package:time_factory/core/ui/app_icons.dart';

/// Dialog for selecting an idle worker to assign to a station slot
class AssignWorkerDialog extends StatelessWidget {
  final Station station;
  final int slotIndex;
  final List<Worker> idleWorkers;
  final void Function(Worker worker) onAssign;

  const AssignWorkerDialog({
    super.key,
    required this.station,
    required this.slotIndex,
    required this.idleWorkers,
    required this.onAssign,
  });

  /// Show the dialog
  static Future<void> show(
    BuildContext context, {
    required Station station,
    required int slotIndex,
    required List<Worker> idleWorkers,
    required void Function(Worker worker) onAssign,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AssignWorkerDialog(
        station: station,
        slotIndex: slotIndex,
        idleWorkers: idleWorkers,
        onAssign: onAssign,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1520),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: TimeFactoryColors.electricCyan.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
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
                const AppIcon(
                  AppHugeIcons.person_add,
                  color: TimeFactoryColors.electricCyan,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.assignWorker,
                        style: TimeFactoryTextStyles.header.copyWith(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.selectUnitFor(station.name),
                        style: TimeFactoryTextStyles.bodyMono.copyWith(
                          fontSize: 11,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const AppIcon(
                    AppHugeIcons.close,
                    color: Colors.white54,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 1, color: Colors.white12),

          // Worker list
          if (idleWorkers.isEmpty)
            _buildEmptyState(context)
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: idleWorkers.length,
                itemBuilder: (context, index) {
                  return _buildWorkerItem(context, idleWorkers[index]);
                },
              ),
            ),

          // Bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const AppIcon(
            AppHugeIcons.group_off,
            color: Colors.white24,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.noIdleWorkers,
            style: TimeFactoryTextStyles.header.copyWith(
              fontSize: 14,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.hireMoreToAssign,
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              fontSize: 12,
              color: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerItem(BuildContext context, Worker worker) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onAssign(worker);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: TimeFactoryColors.electricCyan.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // Worker portrait
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    TimeFactoryColors.deepPurple.withOpacity(0.5),
                    const Color(0xFF0A1520),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: TimeFactoryColors.electricCyan.withOpacity(0.3),
                ),
              ),
              child: WorkerIconHelper.buildIcon(worker.era, worker.rarity),
            ),

            const SizedBox(width: 12),

            // Worker info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.displayName.toUpperCase(),
                    style: TimeFactoryTextStyles.body.copyWith(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 6),
                      _buildTag(
                        worker.rarity.localizedName(context).toUpperCase(),
                        worker.rarity.color,
                      ),
                      const SizedBox(width: 6),
                      _buildTag(
                        worker.era.localizedName(context).toUpperCase(),
                        TimeFactoryColors.voltageYellow,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Assign icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TimeFactoryColors.electricCyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const AppIcon(
                AppHugeIcons.arrow_forward,
                color: TimeFactoryColors.electricCyan,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TimeFactoryTextStyles.bodyMono.copyWith(
          fontSize: 9,
          color: color,
        ),
      ),
    );
  }
}
