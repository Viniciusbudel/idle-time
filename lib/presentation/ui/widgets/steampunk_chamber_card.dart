import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/presentation/state/theme_provider.dart';
import 'package:time_factory/presentation/ui/atoms/knife_switch_lever.dart';
import 'package:time_factory/presentation/ui/atoms/steampunk_panel.dart';
import 'package:time_factory/presentation/ui/dialogs/upgrade_confirmation_dialog.dart';

class SteampunkChamberCard extends ConsumerStatefulWidget {
  final Station station;
  final List<Worker> assignedWorkers;
  final BigInt production;
  final VoidCallback? onUpgrade;
  final void Function(int slotIndex)? onAssignSlot;
  final void Function(String workerId)? onRemoveWorker;

  const SteampunkChamberCard({
    super.key,
    required this.station,
    required this.assignedWorkers,
    required this.production,
    this.onUpgrade,
    this.onAssignSlot,
    this.onRemoveWorker,
  });

  @override
  ConsumerState<SteampunkChamberCard> createState() =>
      _SteampunkChamberCardState();
}

class _SteampunkChamberCardState extends ConsumerState<SteampunkChamberCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _gearController;

  @override
  void initState() {
    super.initState();
    _gearController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Slow rotation
    )..repeat();
  }

  @override
  void dispose() {
    _gearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final colors = theme.colors;
    final typography = theme.typography;

    return SteampunkPanel(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Rotating Gear Icon
          RepaintBoundary(
            child: RotationTransition(
              turns: _gearController,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black38,
                  border: Border.all(color: const Color(0xFF8B5A2B), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getStationIcon(widget.station.type),
                  color: const Color(0xFFE0C097),
                  size: 36,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // 2. Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Name + Level
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.station.name.toUpperCase(),
                        style: typography.titleLarge.copyWith(
                          fontFamily: 'Rye', // Assuming font or fallback
                          color: const Color(0xFFE0C097),
                          fontSize: 18,
                          shadows: [
                            const Shadow(
                              color: Colors.black,
                              blurRadius: 2,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        'LVL ${widget.station.level}',
                        style: typography.bodyMedium.copyWith(
                          color: const Color(0xFFBCAAA4),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 3. Liquid Gauge Progress Bar
                _buildLiquidGauge(colors.accent),

                const SizedBox(height: 8),

                // Output Stats
                Row(
                  children: [
                    const Icon(Icons.bolt, color: Color(0xFFE0C097), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${NumberFormatter.format(widget.production)} CE/s',
                      style: typography.bodyMedium.copyWith(
                        color: const Color(0xFFE0C097),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Worker Slots
                _buildWorkerSlots(theme),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // 3. Upgrade Lever
          Column(
            children: [
              KnifeSwitchLever(
                label: NumberFormatter.formatCE(widget.station.upgradeCost),
                isEnabled: true, // TODO: Check toggle logic against CE balance?
                onToggle: () {
                  if (widget.onUpgrade != null) {
                    showDialog(
                      context: context,
                      builder: (context) => UpgradeConfirmationDialog(
                        station: widget.station,
                        onConfirm: widget.onUpgrade!,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidGauge(Color color) {
    double progress = (widget.station.level % 10) / 10.0;
    if (progress == 0) progress = 1.0;

    return Container(
      height: 12,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF151515), // Deep dark slot
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Colors.white10,
            offset: Offset(0, 1),
            blurRadius: 0,
          ), // Bottom highlight
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, -1),
            blurRadius: 1,
          ), // Top shadow
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6B8E23), // Sludge Green
                  Color(0xFFB2CF25), // Toxic Green
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Container(
              // Glass shine overlay
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkerSlots(dynamic theme) {
    // Similar to StationCard logic but with Steampunk styling
    final totalSlots = widget.station.maxWorkerSlots.clamp(1, 4);
    final unlockedSlots = (widget.station.level + 1).clamp(1, totalSlots);

    return Row(
      children: List.generate(totalSlots, (index) {
        final isUnlocked = index < unlockedSlots;
        if (!isUnlocked)
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _buildLockedSlot(),
          );
        if (index < widget.assignedWorkers.length) {
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _buildWorkerAvatar(widget.assignedWorkers[index]),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: _buildEmptySlot(index),
        );
      }),
    );
  }

  Widget _buildWorkerAvatar(Worker worker) {
    return GestureDetector(
      onTap: () => widget.onRemoveWorker?.call(worker.id),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF4E342E),
          border: Border.all(color: const Color(0xFF8B5A2B)),
          image: const DecorationImage(
            image: AssetImage(
              'assets/images/worker_placeholder.png',
            ), // Fallback? or Icon
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Icon(Icons.person, size: 20, color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildEmptySlot(int index) {
    return GestureDetector(
      onTap: () => widget.onAssignSlot?.call(index),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black26,
          border: Border.all(color: Colors.white24, style: BorderStyle.solid),
        ),
        child: const Icon(Icons.add, size: 16, color: Colors.white24),
      ),
    );
  }

  Widget _buildLockedSlot() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black45,
        border: Border.all(color: Colors.white10),
      ),
      child: const Icon(Icons.lock, size: 14, color: Colors.white12),
    );
  }

  IconData _getStationIcon(StationType type) {
    switch (type) {
      case StationType.basicLoop:
        return Icons.settings;
      case StationType.dualHelix:
        return Icons.all_inclusive;
      case StationType.paradoxAmplifier:
        return Icons.waves;
      case StationType.timeDistortion:
        return Icons.hourglass_full;
      case StationType.riftGenerator:
        return Icons.bolt;
    }
  }
}
