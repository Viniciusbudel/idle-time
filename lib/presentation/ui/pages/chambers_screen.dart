import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/core/theme/game_theme.dart';
import 'package:time_factory/presentation/ui/pages/loop_chambers_tab.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/ui/app_icons.dart';

/// Chambers Screen — Temporal Production Console.
class ChambersScreen extends ConsumerStatefulWidget {
  const ChambersScreen({super.key});

  @override
  ConsumerState<ChambersScreen> createState() => _ChambersScreenState();
}

class _ChambersScreenState extends ConsumerState<ChambersScreen> {
  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    const theme = NeonTheme();

    final allWorkers = gameState.workers.values.toList();
    final idleCount = allWorkers.where((w) => !w.isDeployed).length;
    final deployedCount = allWorkers.where((w) => w.isDeployed).length;
    final activeExpeditions = gameState.expeditions
        .where((expedition) => !expedition.resolved)
        .length;

    return Container(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. System HUD Header (3-line structure)
          _ChamberHudHeader(
            colors: theme.colors,
            typography: theme.typography,
            idleCount: idleCount,
            deployedCount: deployedCount,
            activeExpeditions: activeExpeditions,
          ),

          const SizedBox(height: AppSpacing.sm),

          // 2–6. Chamber Hero Module + Sub-sections via LoopChambersTab
          const Expanded(child: LoopChambersTab()),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ChamberHudHeader — System HUD with 3-line telemetry structure
// ---------------------------------------------------------------------------
class _ChamberHudHeader extends StatefulWidget {
  final ThemeColors colors;
  final ThemeTypography typography;
  final int idleCount;
  final int deployedCount;
  final int activeExpeditions;

  const _ChamberHudHeader({
    required this.colors,
    required this.typography,
    required this.idleCount,
    required this.deployedCount,
    required this.activeExpeditions,
  });

  @override
  State<_ChamberHudHeader> createState() => _ChamberHudHeaderState();
}

class _ChamberHudHeaderState extends State<_ChamberHudHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final typography = widget.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 8,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.40),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: colors.primary.withValues(alpha: 0.30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LINE 1 — System Identity
            _buildLine1(colors, typography),

            // Thin divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                height: 1,
                color: colors.primary.withValues(alpha: 0.15),
              ),
            ),

            // LINE 2 — Telemetry Row
            _buildLine2(context, colors, typography),

            const SizedBox(height: 8),

            // LINE 3 — Operational Chips
            _buildLine3(colors, typography),
          ],
        ),
      ),
    );
  }

  /// Line 1 — System Identity: icon + title + system ID
  Widget _buildLine1(ThemeColors colors, ThemeTypography typography) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Breathing glow icon
        _GlowBreathingIcon(color: colors.primary),
        const SizedBox(width: 8),

        // Title block
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LOOP SYSTEM',
                style: typography.bodyMedium.copyWith(
                  fontSize: 9,
                  color: colors.primary.withValues(alpha: 0.60),
                  letterSpacing: 2.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'CHAMBER',
                style: typography.titleLarge.copyWith(
                  height: 1.0,
                  fontSize: 22,
                  color: colors.primary,
                  letterSpacing: 1.8,
                  shadows: [
                    Shadow(
                      color: colors.primary.withValues(alpha: 0.60),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // System ID badge
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.40),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon(
                    AppHugeIcons.grid_view,
                    color: colors.primary,
                    size: 11,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ACTIVE',
                    style: typography.bodyMedium.copyWith(
                      fontSize: 9,
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'SYS.LC1',
              style: typography.bodyMedium.copyWith(
                fontSize: 10,
                color: colors.primary.withValues(alpha: 0.55),
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Line 2 — Telemetry: Expeditions + System Status
  Widget _buildLine2(
    BuildContext context,
    ThemeColors colors,
    ThemeTypography typography,
  ) {
    return Row(
      children: [
        // Expedition status
        Text(
          'EXPEDITIONS: ${widget.activeExpeditions} ACTIVE',
          style: typography.bodyMedium.copyWith(
            fontSize: 10,
            color: colors.secondary.withValues(alpha: 0.80),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const Spacer(),

        // System status with animated online dot
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SYS STATUS:',
              style: typography.bodyMedium.copyWith(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.50),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'ONLINE',
              style: typography.bodyMedium.copyWith(
                fontSize: 10,
                color: colors.success,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(width: 4),
            // Pulsing online dot
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colors.success.withValues(
                      alpha: _pulseAnimation.value,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.success.withValues(
                          alpha: 0.4 * _pulseAnimation.value,
                        ),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Line 3 — Operational Chips
  Widget _buildLine3(ThemeColors colors, ThemeTypography typography) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _buildSystemChip(
          label: '${widget.idleCount} IDLE',
          color: colors.primary,
          icon: AppHugeIcons.person,
          typography: typography,
        ),
        _buildSystemChip(
          label: '${widget.deployedCount} DEPLOYED',
          color: colors.accent,
          icon: AppHugeIcons.bolt,
          typography: typography,
        ),
        _buildSystemChip(
          label: '${widget.activeExpeditions} ACTIVE',
          color: colors.secondary,
          icon: AppHugeIcons.rocket_launch,
          typography: typography,
        ),
      ],
    );
  }

  /// System chip — hard-edged, technical, NOT a filter button
  Widget _buildSystemChip({
    required String label,
    required Color color,
    required AppIconData icon,
    required ThemeTypography typography,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon, color: color, size: 10),
          const SizedBox(width: 4),
          Text(
            label,
            style: typography.bodyMedium.copyWith(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _GlowBreathingIcon — Subtle breathing glow on header icon
// ---------------------------------------------------------------------------
class _GlowBreathingIcon extends StatefulWidget {
  final Color color;
  const _GlowBreathingIcon({required this.color});

  @override
  State<_GlowBreathingIcon> createState() => _GlowBreathingIconState();
}

class _GlowBreathingIconState extends State<_GlowBreathingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.50,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: widget.color.withValues(
                alpha: 0.2 + (0.15 * _glowAnimation.value),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(
                  alpha: 0.15 * _glowAnimation.value,
                ),
                blurRadius: 8 * _glowAnimation.value,
                spreadRadius: 1,
              ),
            ],
          ),
          child: AppIcon(
            AppHugeIcons.grid_view,
            color: widget.color.withValues(
              alpha: 0.6 + (0.4 * _glowAnimation.value),
            ),
            size: 22,
          ),
        );
      },
    );
  }
}
