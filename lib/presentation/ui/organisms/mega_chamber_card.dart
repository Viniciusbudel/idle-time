import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/constants/tech_data.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/core/utils/worker_icon_helper.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/ui/dialogs/upgrade_confirmation_dialog.dart';
import 'package:time_factory/presentation/ui/dialogs/worker_detail_dialog.dart';
import 'package:time_factory/presentation/ui/organisms/worker_management_sheet.dart';
import 'package:time_factory/core/ui/app_icons.dart';
import 'package:time_factory/presentation/ui/atoms/game_action_button.dart';
import 'package:time_factory/presentation/utils/worker_era_extensions.dart';

class MegaChamberCard extends ConsumerStatefulWidget {
  final Station station;
  final List<Worker> assignedWorkers;
  final BigInt production;
  final VoidCallback? onUpgrade;
  final void Function(int slotIndex)? onAssignSlot;
  final void Function(String workerId)? onRemoveWorker;
  final bool highlightFirstEmptySlot;

  const MegaChamberCard({
    super.key,
    required this.station,
    required this.assignedWorkers,
    required this.production,
    this.onUpgrade,
    this.onAssignSlot,
    this.onRemoveWorker,
    this.highlightFirstEmptySlot = false,
  });

  @override
  ConsumerState<MegaChamberCard> createState() => _MegaChamberCardState();
}

class _MegaChamberCardState extends ConsumerState<MegaChamberCard> {
  @override
  Widget build(BuildContext context) {
    const theme = NeonTheme();
    final accentColor = widget.station.type.era.color;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            // Background Grid Overlay for technical feel
            _GridOverlay(color: accentColor),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ChamberHeader(
                    station: widget.station,
                    assignedCount: widget.assignedWorkers.length,
                    maxSlots: widget.station.maxWorkerSlots,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ChamberVisualArea(
                    production: widget.production,
                    accentColor: accentColor,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ChamberTelemetryHUD(
                    station: widget.station,
                    accentColor: accentColor,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _WorkforceSection(
                    assigned: widget.assignedWorkers,
                    maxSlots: widget.station.maxWorkerSlots,
                    onAssign: widget.onAssignSlot,
                    highlightFirst: widget.highlightFirstEmptySlot,
                    color: accentColor,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _UpgradeAction(
                    station: widget.station,
                    onUpgrade: widget.onUpgrade,
                    accentColor: accentColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChamberHeader extends StatelessWidget {
  final Station station;
  final int assignedCount;
  final int maxSlots;

  const _ChamberHeader({
    required this.station,
    required this.assignedCount,
    required this.maxSlots,
  });

  @override
  Widget build(BuildContext context) {
    const theme = NeonTheme();
    final typography = theme.typography;
    final accentColor = station.type.era.color;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModuleIdBadge(
          id: 'CHB-${station.id.split('_').last.padLeft(2, '0')}',
          color: accentColor,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRODUCTION CORE',
                style: typography.bodyMedium.copyWith(
                  fontSize: 9,
                  color: accentColor.withValues(alpha: 0.6),
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                station.name.toUpperCase(),
                style: typography.titleMedium.copyWith(
                  fontSize: 18,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _LevelBadge(level: station.level, color: accentColor),
            const SizedBox(height: 8),
            _ManageUnitsChip(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => const WorkerManagementSheet(),
                );
              },
              color: accentColor,
            ),
          ],
        ),
      ],
    );
  }
}

class _ModuleIdBadge extends StatelessWidget {
  final String id;
  final Color color;

  const _ModuleIdBadge({required this.id, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        id,
        style: const TextStyle(
          fontFamily: 'Share Tech Mono',
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  final Color color;

  const _LevelBadge({required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4),
        ],
      ),
      child: Text(
        'LVL $level',
        style: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ManageUnitsChip extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;

  const _ManageUnitsChip({required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(AppHugeIcons.person, color: color, size: 10),
              const SizedBox(width: 4),
              const Text(
                'MANAGE',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChamberVisualArea extends StatelessWidget {
  final BigInt production;
  final Color accentColor;

  const _ChamberVisualArea({
    required this.production,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    const theme = NeonTheme();
    final typography = theme.typography;

    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hologram Glow Effect
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'CURRENT OUTPUT',
                style: typography.bodyMedium.copyWith(
                  fontSize: 10,
                  color: accentColor.withValues(alpha: 0.5),
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  AppIcon(AppHugeIcons.bolt, color: accentColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    NumberFormatter.format(production),
                    style: typography.titleLarge.copyWith(
                      fontFamily: 'Share Tech Mono',
                      fontSize: 40,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: accentColor.withValues(alpha: 0.6),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'CE/S',
                    style: typography.bodyMedium.copyWith(
                      fontSize: 12,
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Technical corner marks
          ..._buildCornerMarks(accentColor.withValues(alpha: 0.4)),
        ],
      ),
    );
  }

  List<Widget> _buildCornerMarks(Color color) {
    return [
      Positioned(
        top: 8,
        left: 8,
        child: _CornerMark(color: color, quadrant: 0),
      ),
      Positioned(
        top: 8,
        right: 8,
        child: _CornerMark(color: color, quadrant: 1),
      ),
      Positioned(
        bottom: 8,
        left: 8,
        child: _CornerMark(color: color, quadrant: 2),
      ),
      Positioned(
        bottom: 8,
        right: 8,
        child: _CornerMark(color: color, quadrant: 3),
      ),
    ];
  }
}

class _CornerMark extends StatelessWidget {
  final Color color;
  final int quadrant;

  const _CornerMark({required this.color, required this.quadrant});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(12, 12),
      painter: _CornerPainter(color: color, quadrant: quadrant),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final int quadrant;

  _CornerPainter({required this.color, required this.quadrant});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (quadrant == 0) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (quadrant == 1) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (quadrant == 2) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChamberTelemetryHUD extends StatelessWidget {
  final Station station;
  final Color accentColor;

  const _ChamberTelemetryHUD({
    required this.station,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final efficiency = (station.productionBonus * 100).round();
    final stability = 98.4 + (station.level * 0.1);

    return Row(
      children: [
        Expanded(
          child: _TelemetryItem(
            label: 'EFFICIENCY',
            value: '$efficiency%',
            color: accentColor,
            icon: AppHugeIcons.speed,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _TelemetryItem(
            label: 'STABILITY',
            value: '${stability.toStringAsFixed(1)}%',
            color: const Color(0xFF00FF9F), // Success Bio-Green
            icon: AppHugeIcons.shield,
          ),
        ),
      ],
    );
  }
}

class _TelemetryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final AppIconData icon;

  const _TelemetryItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const theme = NeonTheme();
    final typography = theme.typography;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(icon, color: color, size: 12),
              const SizedBox(width: 4),
              Text(
                label,
                style: typography.bodyMedium.copyWith(
                  fontSize: 8,
                  color: color.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Share Tech Mono',
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkforceSection extends StatelessWidget {
  final List<Worker> assigned;
  final int maxSlots;
  final void Function(int slotIndex)? onAssign;
  final bool highlightFirst;
  final Color color;

  const _WorkforceSection({
    required this.assigned,
    required this.maxSlots,
    this.onAssign,
    required this.highlightFirst,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const theme = NeonTheme();
    final typography = theme.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'WORKFORCE PROTOCOL',
              style: typography.bodyMedium.copyWith(
                fontSize: 10,
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '${assigned.length} / $maxSlots UNITS LOADED',
              style: const TextStyle(
                fontFamily: 'Share Tech Mono',
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(maxSlots, (index) {
            if (index < assigned.length) {
              return _WorkerSlot(worker: assigned[index], color: color);
            } else {
              final isHighlighted =
                  highlightFirst && (index == assigned.length);
              return _EmptySlot(
                onTap: () => onAssign?.call(index),
                isHighlighted: isHighlighted,
                color: color,
              );
            }
          }),
        ),
      ],
    );
  }
}

class _WorkerSlot extends StatelessWidget {
  final Worker worker;
  final Color color;

  const _WorkerSlot({required this.worker, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => WorkerDetailDialog.show(context, worker),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(8),
        child: Center(
          child: WorkerIconHelper.buildIcon(
            worker.era,
            worker.rarity,
            width: 32,
            height: 32,
          ),
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final VoidCallback onTap;
  final bool isHighlighted;
  final Color color;

  const _EmptySlot({
    required this.onTap,
    required this.isHighlighted,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color.withValues(alpha: isHighlighted ? 0.1 : 0.05),
          border: Border.all(
            color: color.withValues(alpha: isHighlighted ? 0.8 : 0.2),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: AppIcon(
            AppHugeIcons.add,
            color: color.withAlpha(isHighlighted ? 255 : 76),
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _UpgradeAction extends ConsumerWidget {
  final Station station;
  final VoidCallback? onUpgrade;
  final Color accentColor;

  const _UpgradeAction({
    required this.station,
    this.onUpgrade,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final discount = TechData.calculateCostReductionMultiplier(
      gameState.techLevels,
    );
    final cost = station.getUpgradeCost(discountMultiplier: discount);
    final canAfford = gameState.chronoEnergy >= cost;

    return GameActionButton(
      label: 'INITIALIZE UPGRADE [${NumberFormatter.formatCE(cost)}]',
      icon: AppHugeIcons.upgrade,
      color: accentColor,
      onTap: onUpgrade != null
          ? () {
              if (!canAfford) {
                HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('INSUFFICIENT CURRENCY ENERGY')),
                );
                return;
              }
              showDialog(
                context: context,
                builder: (context) => UpgradeConfirmationDialog(
                  station: station,
                  onConfirm: onUpgrade!,
                  title: 'SYSTEM UPGRADE',
                  message:
                      'CONFIRM CHAMBER EXPANSION\n\nCOST: ${NumberFormatter.formatCE(cost)} CE',
                  costOverride: cost,
                ),
              );
            }
          : null,
      enabled: onUpgrade != null,
      isMaxed: false, // Potentially add max level logic
    );
  }
}

class _GridOverlay extends StatelessWidget {
  final Color color;
  const _GridOverlay({required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _GridPainter(color: color.withValues(alpha: 0.05)),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 20.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
