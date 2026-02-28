import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:time_factory/core/constants/tutorial_keys.dart';
import 'package:time_factory/core/constants/tech_data.dart';
import 'package:time_factory/core/theme/game_theme.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/core/utils/worker_icon_helper.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/utils/localization_extensions.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/ui/atoms/hud_segmented_progress_bar.dart';
import 'package:time_factory/presentation/ui/atoms/game_action_button.dart';
import 'package:time_factory/presentation/ui/dialogs/upgrade_confirmation_dialog.dart';
import 'package:time_factory/presentation/ui/dialogs/worker_detail_dialog.dart';
import 'package:time_factory/core/ui/app_icons.dart';

/// Mega Chamber Card — core production module with HUD aesthetic.
/// "Manage Units" has been extracted to a separate UnitControlPanel.
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
  late final AnimationController _prodPulseController;
  late final Animation<double> _prodPulseAnimation;

  @override
  void initState() {
    super.initState();
    // Production value pulse: scale 1.0 → 1.02 → 1.0 over 2.5s
    _prodPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _prodPulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _prodPulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _prodPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const theme = NeonTheme();
    final colors = theme.colors;
    final typography = theme.typography;

    // Era-based accent color
    final eraColor = widget.station.type.era.color;
    final cyberDark = const Color(0xFF050A10);

    return Container(
      decoration: BoxDecoration(
        color: cyberDark,
        borderRadius: BorderRadius.circular(4), // Crisp edges per PRD
        border: Border.all(color: eraColor.withValues(alpha: 0.30), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: eraColor.withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            // Static Background Grid
            Positioned.fill(
              child: CustomPaint(
                painter: _CyberGridPainter(
                  color: eraColor.withValues(alpha: 0.08),
                  offset: 0,
                ),
              ),
            ),

            // Corner Accents
            Positioned.fill(
              child: CustomPaint(painter: _TechCornerPainter(color: eraColor)),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Module Header
                  _buildModuleHeader(context, colors, typography, eraColor),

                  const SizedBox(height: 16),

                  // 2. Production Monitor (Hero Element)
                  _buildProductionMonitor(colors, typography),

                  const SizedBox(height: 16),

                  // 3. Telemetry Stats Bars
                  _buildTelemetryBars(colors, typography),

                  const SizedBox(height: 20),

                  // 4. Protocol Matrix (Worker Grid)
                  _buildProtocolMatrixHeader(eraColor, typography),
                  const SizedBox(height: 10),
                  _buildWorkerGrid(colors),

                  const SizedBox(height: 20),

                  // 5. Upgrade Button (GameActionButton)
                  _buildUpgradeAction(context, ref, colors, typography),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Module Header — ID, Category, Name, Level Badge
  // ---------------------------------------------------------------------------
  Widget _buildModuleHeader(
    BuildContext context,
    ThemeColors colors,
    ThemeTypography typography,
    Color eraColor,
  ) {
    final stationIndex = widget.station.type.index;
    final moduleId = 'CHB-${(stationIndex + 1).toString().padLeft(2, '0')}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Module ID + Category
              Row(
                children: [
                  Text(
                    moduleId,
                    style: typography.bodyMedium.copyWith(
                      fontSize: 9,
                      color: colors.primary.withValues(alpha: 0.55),
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      'PRODUCTION',
                      style: typography.bodyMedium.copyWith(
                        fontSize: 7,
                        color: colors.primary.withValues(alpha: 0.65),
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Era subtitle
              Text(
                'ERA: ${widget.station.type.era.localizedName(context).toUpperCase()}',
                style: typography.bodyMedium.copyWith(
                  fontSize: 9,
                  color: eraColor.withValues(alpha: 0.60),
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              // Station Name (ShaderMask gradient — original design)
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
                    fontSize: 24,
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

        // Level Badge (Power Cell Style)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: colors.primary),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.40),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(AppHugeIcons.bolt, color: colors.primary, size: 13),
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
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Production Monitor — Hero output display with pulse animation
  // ---------------------------------------------------------------------------
  Widget _buildProductionMonitor(
    ThemeColors colors,
    ThemeTypography typography,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.50), blurRadius: 8),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Faint hologram icon behind
          Opacity(
            opacity: 0.08,
            child: AppIcon(
              AppHugeIcons.precision_manufacturing,
              size: 70,
              color: colors.primary,
            ),
          ),

          // Production readout
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.currentOutput,
                style: typography.bodyMedium.copyWith(
                  fontSize: 9,
                  color: colors.success.withValues(alpha: 0.55),
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),

              // Pulsing production value (hero element)
              AnimatedBuilder(
                animation: _prodPulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _prodPulseAnimation.value,
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AppIcon(AppHugeIcons.bolt, color: colors.success, size: 22),
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
                            color: colors.success.withValues(alpha: 0.50),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)!.perSecond,
                      style: typography.bodyMedium.copyWith(
                        fontSize: 12,
                        color: colors.success.withValues(alpha: 0.55),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // System status badge
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.60),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.40),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.sysOnline,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  color: colors.primary,
                  fontSize: 7,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Telemetry Stats — Segmented bars (Efficiency / Stability)
  // ---------------------------------------------------------------------------
  Widget _buildTelemetryBars(ThemeColors colors, ThemeTypography typography) {
    final efficiencyPercent = (widget.station.productionBonus * 100).toInt();
    final efficiencyValue = (efficiencyPercent / 200).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          // Efficiency bar
          _buildTelemetryRow(
            icon: AppHugeIcons.speed,
            label: AppLocalizations.of(context)!.efficiency,
            value: efficiencyValue,
            valueText: '$efficiencyPercent%',
            color: colors.primary,
            typography: typography,
          ),
          const SizedBox(height: 10),
          // Stability bar
          _buildTelemetryRow(
            icon: AppHugeIcons.shield,
            label: AppLocalizations.of(context)!.stability,
            value: 0.999,
            valueText: '99.9%',
            color: colors.secondary,
            typography: typography,
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryRow({
    required AppIconData icon,
    required String label,
    required double value,
    required String valueText,
    required Color color,
    required ThemeTypography typography,
  }) {
    return Row(
      children: [
        AppIcon(icon, color: color, size: 14),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: typography.bodyMedium.copyWith(
              fontSize: 9,
              color: color.withValues(alpha: 0.70),
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: HudSegmentedProgressBar(
            value: value,
            color: color,
            height: 6,
            segmentCount: 10,
            segmentGap: 2,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          valueText,
          style: typography.bodyMedium.copyWith(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Protocol Matrix — Worker grid with telemetry badge
  // ---------------------------------------------------------------------------
  Widget _buildProtocolMatrixHeader(
    Color eraColor,
    ThemeTypography typography,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PROTOCOL MATRIX',
              style: typography.bodyMedium.copyWith(
                fontSize: 10,
                color: eraColor.withValues(alpha: 0.55),
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Telemetry-style badge (not a pill button)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: eraColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: eraColor.withValues(alpha: 0.35)),
              ),
              child: Text(
                '${widget.assignedWorkers.length}/${widget.station.maxWorkerSlots} ${AppLocalizations.of(context)!.active}',
                style: typography.bodyMedium.copyWith(
                  fontSize: 9,
                  color: eraColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Thin divider
        Container(height: 1, color: eraColor.withValues(alpha: 0.15)),
      ],
    );
  }

  Widget _buildWorkerGrid(ThemeColors colors) {
    final totalSlots = widget.station.maxWorkerSlots;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.start,
      children: List.generate(totalSlots, (index) {
        if (index < widget.assignedWorkers.length) {
          return _buildWorkerSlot(widget.assignedWorkers[index], colors);
        }
        final isFirstEmpty =
            widget.highlightFirstEmptySlot &&
            index == widget.assignedWorkers.length;
        return _buildEmptySlot(index, colors, isFirstEmpty: isFirstEmpty);
      }),
    );
  }

  Widget _buildWorkerSlot(Worker worker, ThemeColors colors) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        WorkerDetailDialog.show(context, worker);
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          border: Border.all(color: colors.primary.withValues(alpha: 0.30)),
          borderRadius: BorderRadius.circular(4), // Sharp per PRD
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: WorkerIconHelper.buildIcon(worker.era, worker.rarity),
        ),
      ),
    );
  }

  Widget _buildEmptySlot(
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
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.40),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.20),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: AppIcon(
            AppHugeIcons.add,
            color: colors.primary.withValues(alpha: 0.35),
            size: 18,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Upgrade Action — GameActionButton atom
  // ---------------------------------------------------------------------------
  Widget _buildUpgradeAction(
    BuildContext context,
    WidgetRef ref,
    ThemeColors colors,
    ThemeTypography typography,
  ) {
    final gameState = ref.watch(gameStateProvider);
    final discount = TechData.calculateCostReductionMultiplier(
      gameState.techLevels,
    );
    final cost = widget.station.getUpgradeCost(discountMultiplier: discount);
    final canAfford = gameState.chronoEnergy >= cost;

    return GameActionButton(
      label:
          '${AppLocalizations.of(context)!.initUpgrade}  [ ${NumberFormatter.formatCE(cost)} ]',
      icon: AppHugeIcons.upgrade,
      color: colors.primary,
      enabled: canAfford,
      onTap: () {
        HapticFeedback.mediumImpact();
        if (widget.onUpgrade != null) {
          showDialog(
            context: context,
            builder: (ctx) => UpgradeConfirmationDialog(
              station: widget.station,
              onConfirm: widget.onUpgrade!,
              title: AppLocalizations.of(ctx)!.systemUpgrade,
              message:
                  '${AppLocalizations.of(ctx)!.initializeExpansion}\n\n${AppLocalizations.of(ctx)!.cost}: ${NumberFormatter.formatCE(cost)} CE',
              costOverride: cost,
            ),
          );
        }
      },
      height: 44,
    );
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
      ..strokeWidth = 0.5;

    const gridSize = 28.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

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
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const cornerSize = 12.0;

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
