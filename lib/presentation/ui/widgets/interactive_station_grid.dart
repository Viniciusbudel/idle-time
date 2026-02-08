import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';

/// Interactive Station Grid - Visual grid layout for factory floor
class InteractiveStationGrid extends ConsumerWidget {
  const InteractiveStationGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stations = ref.watch(
      gameStateProvider.select((s) => s.stations.values.toList()),
    );

    if (stations.isEmpty) {
      return _buildEmptyFactory(ref);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final gridSize = _calculateGridSize(stations.length);
        final cellWidth = (constraints.maxWidth - 32) / gridSize;
        final cellHeight = cellWidth * 0.8;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...stations.map(
                (station) => _StationTile(
                  station: station,
                  width: cellWidth - 8,
                  height: cellHeight,
                ),
              ),
              // Add Station Button
              _AddStationTile(
                width: cellWidth - 8,
                height: cellHeight,
                onTap: () => _purchaseStation(ref),
              ),
            ],
          ),
        );
      },
    );
  }

  int _calculateGridSize(int stationCount) {
    if (stationCount <= 2) return 2;
    if (stationCount <= 4) return 2;
    if (stationCount <= 6) return 3;
    return 3;
  }

  void _purchaseStation(WidgetRef ref) {
    ref.read(gameStateProvider.notifier).purchaseStation(StationType.basicLoop);
  }

  Widget _buildEmptyFactory(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.grid_3x3,
            size: 64,
            color: TimeFactoryColors.electricCyan.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'NO STATIONS DEPLOYED',
            style: TimeFactoryTextStyles.headerSmall.copyWith(
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Build your first station to start production',
            style: TimeFactoryTextStyles.bodySmall.copyWith(
              color: Colors.white24,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _purchaseStation(ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: TimeFactoryColors.electricCyan),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: TimeFactoryColors.electricCyan,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'BUILD FIRST STATION',
                    style: TimeFactoryTextStyles.headerSmall.copyWith(
                      fontSize: 12,
                      color: TimeFactoryColors.electricCyan,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual station tile in the grid
class _StationTile extends ConsumerWidget {
  final Station station;
  final double width;
  final double height;

  const _StationTile({
    required this.station,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workers = ref.watch(
      gameStateProvider.select(
        (s) => s.workers.values
            .where((w) => station.workerIds.contains(w.id))
            .toList(),
      ),
    );

    final production = _calculateProduction(workers);
    final isActive = workers.isNotEmpty;

    return GestureDetector(
      onTap: () => _showStationDetails(context, ref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isActive
                  ? TimeFactoryColors.electricCyan.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              Colors.transparent,
            ],
          ),
          border: Border.all(
            color: isActive
                ? TimeFactoryColors.electricCyan.withValues(alpha: 0.5)
                : Colors.white24,
            width: isActive ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: TimeFactoryColors.electricCyan.withValues(
                      alpha: 0.2,
                    ),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon + Level
              Row(
                children: [
                  Icon(
                    _getStationIcon(station.type),
                    color: isActive
                        ? TimeFactoryColors.electricCyan
                        : Colors.white38,
                    size: 18,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: TimeFactoryColors.electricCyan.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'L${station.level}',
                      style: TimeFactoryTextStyles.bodyMono.copyWith(
                        fontSize: 9,
                        color: TimeFactoryColors.electricCyan,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Station Name
              Text(
                station.name.toUpperCase(),
                style: TimeFactoryTextStyles.headerSmall.copyWith(
                  fontSize: 10,
                  color: isActive ? Colors.white : Colors.white54,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Worker Slots + Production
              Row(
                children: [
                  // Mini worker indicators
                  ...List.generate(
                    station.maxWorkerSlots.clamp(0, 3),
                    (i) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < workers.length
                            ? TimeFactoryColors.electricCyan
                            : Colors.white24,
                        border: Border.all(
                          color: i < workers.length
                              ? TimeFactoryColors.electricCyan
                              : Colors.white24,
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Production
                  Text(
                    NumberFormatter.formatCompact(production),
                    style: TimeFactoryTextStyles.numbers.copyWith(
                      fontSize: 10,
                      color: TimeFactoryColors.voltageYellow,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  BigInt _calculateProduction(List workers) {
    BigInt total = BigInt.zero;
    for (final worker in workers) {
      total +=
          worker.currentProduction *
          BigInt.from((station.productionBonus * 100).toInt()) ~/
          BigInt.from(100);
    }
    return total * BigInt.from(60);
  }

  void _showStationDetails(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _StationActionsSheet(station: station, ref: ref),
    );
  }

  IconData _getStationIcon(StationType type) {
    switch (type) {
      case StationType.basicLoop:
        return Icons.loop;
      case StationType.dualHelix:
        return Icons.all_inclusive;
      case StationType.paradoxAmplifier:
        return Icons.waves;
      case StationType.timeDistortion:
        return Icons.access_time;
      case StationType.riftGenerator:
        return Icons.offline_bolt;
    }
  }
}

/// Add new station tile
class _AddStationTile extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback onTap;

  const _AddStationTile({
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(
            color: TimeFactoryColors.electricCyan.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: TimeFactoryColors.electricCyan.withValues(alpha: 0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              'BUILD',
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                fontSize: 9,
                color: TimeFactoryColors.electricCyan.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet with station actions (Upgrade, Merge)
class _StationActionsSheet extends StatelessWidget {
  final Station station;
  final WidgetRef ref;

  const _StationActionsSheet({required this.station, required this.ref});

  @override
  Widget build(BuildContext context) {
    final state = ref.read(gameStateProvider);
    final currentCE = state.chronoEnergy;
    final upgradeCost = station.upgradeCost;
    final canUpgrade = currentCE >= upgradeCost;

    // Find mergeable stations (same type, same level, different id)
    final mergeableStations = state.stations.values
        .where(
          (s) =>
              s.id != station.id &&
              s.type == station.type &&
              s.level == station.level,
        )
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1520),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(
          color: TimeFactoryColors.electricCyan.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Station header
          Row(
            children: [
              Icon(
                _getStationIcon(station.type),
                color: TimeFactoryColors.electricCyan,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                station.name.toUpperCase(),
                style: TimeFactoryTextStyles.headerSmall,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: TimeFactoryColors.electricCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'LVL ${station.level}',
                  style: TimeFactoryTextStyles.bodyMono.copyWith(
                    color: TimeFactoryColors.electricCyan,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Upgrade button
          GestureDetector(
            onTap: canUpgrade
                ? () {
                    ref
                        .read(gameStateProvider.notifier)
                        .upgradeStation(station.id);
                    Navigator.pop(context);
                  }
                : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: canUpgrade
                    ? TimeFactoryColors.electricCyan.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: canUpgrade
                      ? TimeFactoryColors.electricCyan
                      : Colors.white24,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.upgrade,
                    color: canUpgrade
                        ? TimeFactoryColors.electricCyan
                        : Colors.white38,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'UPGRADE',
                    style: TimeFactoryTextStyles.button.copyWith(
                      color: canUpgrade
                          ? TimeFactoryColors.electricCyan
                          : Colors.white38,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${NumberFormatter.formatCE(upgradeCost)} CE',
                    style: TimeFactoryTextStyles.bodyMono.copyWith(
                      color: canUpgrade
                          ? TimeFactoryColors.voltageYellow
                          : Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Merge section (if mergeable stations exist)
          if (mergeableStations.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'MERGE WITH',
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                fontSize: 10,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            ...mergeableStations.map(
              (target) => GestureDetector(
                onTap: () {
                  ref
                      .read(gameStateProvider.notifier)
                      .mergeStations(station.id, target.id);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: TimeFactoryColors.hotMagenta.withValues(alpha: 0.1),
                    border: Border.all(
                      color: TimeFactoryColors.hotMagenta.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.merge_type,
                        color: TimeFactoryColors.hotMagenta,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${target.name} (LVL ${target.level})',
                          style: TimeFactoryTextStyles.button.copyWith(
                            color: TimeFactoryColors.hotMagenta,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: TimeFactoryColors.hotMagenta,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LVL ${station.level + 1}',
                        style: TimeFactoryTextStyles.bodyMono.copyWith(
                          color: TimeFactoryColors.hotMagenta,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  IconData _getStationIcon(StationType type) {
    switch (type) {
      case StationType.basicLoop:
        return Icons.loop;
      case StationType.dualHelix:
        return Icons.all_inclusive;
      case StationType.paradoxAmplifier:
        return Icons.waves;
      case StationType.timeDistortion:
        return Icons.access_time;
      case StationType.riftGenerator:
        return Icons.offline_bolt;
    }
  }
}
