import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/core/utils/worker_icon_helper.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/worker.dart';

/// Idle worker pool widget - positioned within screen (not overlapping appbar)
/// Matches tech page styling
class IdleWorkerPool extends StatelessWidget {
  final List<Worker> idleWorkers;
  final WorkerEra selectedEra;
  final BigInt hireCost;
  final VoidCallback? onHire;
  final void Function(WorkerEra) onEraChanged;
  final void Function(Worker) onWorkerTap;

  final List<WorkerEra> availableEras;

  const IdleWorkerPool({
    super.key,
    required this.idleWorkers,
    required this.selectedEra,
    required this.availableEras,
    required this.hireCost,
    this.onHire,
    required this.onEraChanged,
    required this.onWorkerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TimeFactoryColors.electricCyan.withOpacity( 0.4),
            TimeFactoryColors.electricCyan.withOpacity( 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1520),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                const Icon(
                  Icons.groups,
                  color: TimeFactoryColors.electricCyan,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'IDLE POOL',
                  style: TimeFactoryTextStyles.headerSmall.copyWith(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: TimeFactoryColors.voltageYellow.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'AVAIL: ${idleWorkers.length}',
                    style: TimeFactoryTextStyles.bodyMono.copyWith(
                      fontSize: 10,
                      color: TimeFactoryColors.voltageYellow,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Worker thumbnails row (if any)
            if (idleWorkers.isNotEmpty) ...[
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: idleWorkers.length.clamp(0, 8), // Max 8 visible
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return _buildWorkerThumb(idleWorkers[index]);
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Hire row
            Row(
              children: [
                // Era selector
                _buildEraDropdown(),
                const SizedBox(width: 12),
                // Hire button
                Expanded(child: _buildHireButton()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerThumb(Worker worker) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onWorkerTap(worker);
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: TimeFactoryColors.deepPurple.withOpacity( 0.3),
          border: Border.all(
            color: TimeFactoryColors.electricCyan.withOpacity( 0.4),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: WorkerIconHelper.buildIcon(
                worker.era,
                worker.rarity,
                colorFilter: WorkerIconHelper.isSvg(worker.era)
                    ? ColorFilter.mode(
                        TimeFactoryColors.electricCyan.withOpacity( 0.8),
                        BlendMode.srcIn,
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 1),
                color: Colors.black54,
                child: Text(
                  worker.era.displayName.substring(0, 3).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TimeFactoryTextStyles.bodyMono.copyWith(
                    fontSize: 6,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEraDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<WorkerEra>(
          value: selectedEra,
          isDense: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white54,
            size: 16,
          ),
          dropdownColor: const Color(0xFF0A1520),
          style: TimeFactoryTextStyles.bodyMono.copyWith(
            fontSize: 11,
            color: Colors.white,
          ),
          items: availableEras.map((era) {
            return DropdownMenuItem(
              value: era,
              child: Text(
                era.displayName,
                style: TimeFactoryTextStyles.bodyMono.copyWith(
                  fontSize: 11,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
          onChanged: (era) {
            if (era != null) onEraChanged(era);
          },
        ),
      ),
    );
  }

  Widget _buildHireButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onHire?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: TimeFactoryColors.electricCyan,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: TimeFactoryColors.electricCyan.withOpacity( 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'HIRE ${NumberFormatter.formatCE(hireCost)} CE',
              style: TimeFactoryTextStyles.headerSmall.copyWith(
                fontSize: 12,
                color: Colors.black,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.person_add, color: Colors.black, size: 16),
          ],
        ),
      ),
    );
  }
}
