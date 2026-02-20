import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/constants/tutorial_keys.dart';
import 'package:time_factory/core/constants/tech_data.dart';
import 'package:time_factory/core/theme/game_theme.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/core/utils/worker_icon_helper.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/utils/localization_extensions.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/ui/dialogs/upgrade_confirmation_dialog.dart';
import 'package:time_factory/presentation/ui/dialogs/worker_detail_dialog.dart';
import 'package:time_factory/presentation/ui/organisms/worker_management_sheet.dart';

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

class _MegaChamberCardState extends ConsumerState<MegaChamberCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Force Neon Theme
    const theme = NeonTheme();
    final colors = theme.colors;
    final typography = theme.typography;

    // "Cyber Void" Background
    final cyberDark = const Color(0xFF050A10);
    final neonCyan = colors.primary;
    // final neonPurple = colors.secondary; // Unused

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cyberDark,
        borderRadius: BorderRadius.circular(16),
        // Double border effect
        border: Border.all(color: neonCyan.withOpacity(0.5), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: neonCyan.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Grid Animation
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _CyberGridPainter(
                      color: neonCyan.withOpacity(0.5),
                      offset: _controller.value * 20,
                    ),
                  );
                },
              ),
            ),

            // Corner Accents
            Positioned.fill(
              child: CustomPaint(painter: _TechCornerPainter(color: neonCyan)),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header
                  _buildHeader(context, theme, colors, typography),

                  const SizedBox(height: 20),

                  // 2. Visual Monitor
                  _buildVisualArea(colors, typography),

                  const SizedBox(height: 20),

                  // 3. Stats Grid (HUD Style)
                  _buildStatsHUD(colors, typography),

                  const SizedBox(height: 24),

                  // 4. Active Workforce
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.workerProtocols,
                        style: typography.bodyMedium.copyWith(
                          fontSize: 10.0,
                          color: neonCyan.withOpacity(0.5),
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: neonCyan.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: neonCyan.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          '${widget.assignedWorkers.length} / ${widget.station.maxWorkerSlots} ${AppLocalizations.of(context)!.online}',
                          style: typography.bodyMedium.copyWith(
                            fontSize: 10,
                            color: neonCyan,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildWorkerGrid(theme),

                  const SizedBox(height: 24),

                  // 5. Expand Button
                  _buildUpgradeButton(context, ref, theme, colors, typography),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    NeonTheme theme,
    ThemeColors colors,
    ThemeTypography typography,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.station.type.era.localizedName(context).toUpperCase(),
                style: typography.bodyMedium.copyWith(
                  fontSize: 10,
                  color: colors.primary.withOpacity(0.5),
                  letterSpacing: 3.0,
                  shadows: [
                    Shadow(
                      color: colors.primary.withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.white, colors.primary],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                child: Text(
                  widget.station.name.toUpperCase().replaceAll(' ', '\n'),
                  style: typography.titleLarge.copyWith(
                    fontFamily: 'Orbitron',
                    fontSize: 26,
                    height: 1.0,
                    color: Colors.white, // Required for shader
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Level & Manage Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Level Badge (Power Cell Style)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: colors.primary),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, color: colors.primary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${AppLocalizations.of(context)!.lvl} ${widget.station.level}',
                    style: typography.bodyMedium.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Manage Button (Hollow)
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context, // Context is available in State
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => const WorkerManagementSheet(),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colors.secondary.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  AppLocalizations.of(context)!.manageUnits,
                  style: typography.buttonText.copyWith(
                    fontSize: 10,
                    color: colors.secondary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVisualArea(ThemeColors colors, ThemeTypography typography) {
    return Container(
      height: 160, // Slightly taller
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.primary.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Grid Floor
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/images/bg_neon.png', // Fallback
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => const SizedBox(),
              ),
            ),
          ),

          // 2. Central Hologram Icon (Faded)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  math.sin(_controller.value * math.pi * 2) * 5,
                ),
                child: child,
              );
            },
            child: Opacity(
              opacity: 0.4, // Reduced opacity to let text pop
              child: Icon(
                Icons.precision_manufacturing,
                size: 80,
                color: colors.primary.withOpacity(0.5),
              ),
            ),
          ),

          // 3. Scanline Overlay
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ScanlinePainter(
                    color: colors.primary.withOpacity(0.5),
                    activeLineColor: colors.primary.withOpacity(0.5),
                    progress: _controller.value,
                  ),
                );
              },
            ),
          ),

          // 4. BIG OUTPUT DISPLAY (Hero Stat)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.currentOutput,
                style: typography.bodyMedium.copyWith(
                  fontSize: 10,
                  color: colors.success.withOpacity(0.5),
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Icon(Icons.bolt, color: colors.success, size: 24),
                  const SizedBox(width: 4),
                  Text(
                    NumberFormatter.format(widget.production),
                    style: typography.titleLarge.copyWith(
                      fontFamily: 'Orbitron',
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: colors.success,
                      shadows: [
                        Shadow(
                          color: colors.success.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/ SEC',
                    style: typography.bodyMedium.copyWith(
                      fontSize: 12,
                      color: colors.success.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 5. System Status Badge
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: colors.primary.withOpacity(0.5),
                ),
              ),
              child: Text(
                'SYS :: ONLINE',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  color: colors.primary,
                  fontSize: 8,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHUD(ThemeColors colors, ThemeTypography typography) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.primary.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Efficiency
          _buildWideStat(
            'EFFICIENCY',
            '${(widget.station.productionBonus * 100).toInt()}%',
            colors.primary,
            Icons.speed,
            typography,
          ),

          Container(
            width: 1,
            height: 30,
            color: colors.primary.withOpacity(0.5),
          ),

          _buildWideStat(
            'STABILITY',
            '99.9%', // Placeholder
            colors.secondary,
            Icons.shield,
            typography,
          ),
        ],
      ),
    );
  }

  Widget _buildWideStat(
    String label,
    String value,
    Color color,
    IconData icon,
    ThemeTypography typography,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: typography.bodyMedium.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'monospace',
              ),
            ),
            Text(
              label,
              style: typography.bodyMedium.copyWith(
                fontSize: 9,
                color: Colors.grey[400],
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkerGrid(NeonTheme theme) {
    final colors = theme.colors;
    final totalSlots = widget.station.maxWorkerSlots;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.start,
      children: List.generate(totalSlots, (index) {
        if (index < widget.assignedWorkers.length) {
          return _buildHoloWorker(widget.assignedWorkers[index], colors);
        }
        final isFirstEmpty =
            widget.highlightFirstEmptySlot &&
            index == widget.assignedWorkers.length;
        return _buildEmptySocket(index, colors, isFirstEmpty: isFirstEmpty);
      }),
    );
  }

  Widget _buildHoloWorker(Worker worker, ThemeColors colors) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        WorkerDetailDialog.show(context, worker);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: colors.primary.withOpacity(0.5),
          border: Border.all(color: colors.primary.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withOpacity(0.5),
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Worker Avatar Icon
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: WorkerIconHelper.buildIcon(worker.era, worker.rarity),
            ),
            // Holo Scanline Overlay
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ScanlinePainter(
                    color: colors.primary.withOpacity(0.5),
                    activeLineColor: Colors.transparent,
                    progress: 0,
                    lineCount: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySocket(
    int index,
    ThemeColors colors, {
    bool isFirstEmpty = false,
  }) {
    return GestureDetector(
      key: isFirstEmpty ? TutorialKeys.chamberSlot : null,
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onAssignSlot?.call(index);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          border: Border.all(
            color: colors.primary.withOpacity(0.5),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            Icons.add,
            color: colors.primary.withOpacity(0.5),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradeButton(
    BuildContext context,
    WidgetRef ref,
    NeonTheme theme,
    ThemeColors colors,
    ThemeTypography typography,
  ) {
    final gameState = ref.watch(gameStateProvider);
    final discount = TechData.calculateCostReductionMultiplier(
      gameState.techLevels,
    );
    final cost = widget.station.getUpgradeCost(discountMultiplier: discount);

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.5),
        border: Border.all(color: colors.primary),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            if (widget.onUpgrade != null) {
              showDialog(
                context: context,
                builder: (context) => UpgradeConfirmationDialog(
                  station: widget.station,
                  onConfirm: widget.onUpgrade!,
                  title: "SYSTEM UPGRADE",
                  message:
                      "Initialize expansion protocol?\n\nCost: ${NumberFormatter.formatCE(cost)} CE",
                  costOverride: cost,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.upgrade, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  'INIT UPGRADE',
                  style: typography.buttonText.copyWith(
                    color: colors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Text(
                  '[ ${NumberFormatter.formatCE(cost)} ]',
                  style: typography.bodyMedium.copyWith(
                    color: colors.primary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getWorkerColor(Worker worker, ThemeColors colors) {
    switch (worker.rarity) {
      case WorkerRarity.common:
        return colors.rarityCommon;
      case WorkerRarity.rare:
        return colors.rarityRare;
      case WorkerRarity.epic:
        return colors.rarityEpic;
      case WorkerRarity.legendary:
        return colors.rarityLegendary;
      case WorkerRarity.paradox:
        return colors.rarityParadox;
    }
  }
}

// --- Custom Painters ---

class _CyberGridPainter extends CustomPainter {
  final Color color;
  final double offset;

  _CyberGridPainter({required this.color, required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const gridSize = 30.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines (moving)
    for (
      double y = (offset % gridSize) - gridSize;
      y < size.height;
      y += gridSize
    ) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_CyberGridPainter oldDelegate) =>
      offset != oldDelegate.offset || color != oldDelegate.color;
}

class _TechCornerPainter extends CustomPainter {
  final Color color;

  _TechCornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const cornerSize = 15.0;

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerSize)
        ..lineTo(0, 0)
        ..lineTo(cornerSize, 0),
      paint,
    );

    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerSize, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, cornerSize),
      paint,
    );

    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - cornerSize)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width - cornerSize, size.height),
      paint,
    );

    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(cornerSize, size.height)
        ..lineTo(0, size.height)
        ..lineTo(0, size.height - cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(_TechCornerPainter oldDelegate) =>
      color != oldDelegate.color;
}

class _ScanlinePainter extends CustomPainter {
  final Color color;
  final Color activeLineColor;
  final double progress;
  final int lineCount;

  _ScanlinePainter({
    required this.color,
    required this.activeLineColor,
    required this.progress,
    this.lineCount = 40,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final activePaint = Paint()
      ..color = activeLineColor
      ..strokeWidth = 2.0;

    final lineHeight = size.height / lineCount;

    // Static lines
    for (int i = 0; i < lineCount; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(0, i * lineHeight, size.width, lineHeight),
          paint,
        );
      }
    }

    // Moving scanline
    final y = progress * size.height;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), activePaint);
  }

  @override
  bool shouldRepaint(_ScanlinePainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}
