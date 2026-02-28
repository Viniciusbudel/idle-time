import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/presentation/ui/pages/loop_chambers_tab.dart';
import 'package:time_factory/presentation/ui/pages/expeditions_screen.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/ui/app_icons.dart';

class ChambersScreen extends ConsumerWidget {
  const ChambersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);

    final allWorkers = gameState.workers.values.toList();
    final idleCount = allWorkers.where((w) => !w.isDeployed).length;
    final activeOps = allWorkers.where((w) => w.isDeployed).length;

    // Logic for expeditions count
    final now = DateTime.now();
    final readyExpeditions = gameState.expeditions
        .where((e) => e.endTime.isBefore(now) && !e.resolved)
        .length;

    return Column(
      children: [
        _ChamberHudHeader(
          idleUnits: idleCount,
          activeOps: activeOps,
          readyExpeditions: readyExpeditions,
          onExpeditionsTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExpeditionsScreen(),
              ),
            );
          },
        ),
        const Expanded(child: LoopChambersTab()),
      ],
    );
  }
}

class _ChamberHudHeader extends StatefulWidget {
  final int idleUnits;
  final int activeOps;
  final int readyExpeditions;
  final VoidCallback onExpeditionsTap;

  const _ChamberHudHeader({
    required this.idleUnits,
    required this.activeOps,
    required this.readyExpeditions,
    required this.onExpeditionsTap,
  });

  @override
  State<_ChamberHudHeader> createState() => _ChamberHudHeaderState();
}

class _ChamberHudHeaderState extends State<_ChamberHudHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const theme = NeonTheme();
    final colors = theme.colors;
    final typography = theme.typography;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        MediaQuery.of(context).padding.top + AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(
            color: colors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line 1: Identity & Ops
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _GlowBreathingIcon(
                    icon: AppHugeIcons.grid_view,
                    color: colors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SYSTEM.CORE',
                        style: typography.bodyMedium.copyWith(
                          fontSize: 10,
                          color: colors.primary.withValues(alpha: 0.6),
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'CHAMBERS',
                        style: typography.titleLarge.copyWith(
                          fontSize: 22,
                          color: colors.primary,
                          letterSpacing: 1.5,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // External Ops Chip (Expeditions)
              _HudLaunchButton(
                label: 'EXTERNAL OPS',
                count: widget.readyExpeditions,
                onTap: widget.onExpeditionsTap,
                color: colors.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Line 2: Telemetry Stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TelemetryBlock(
                  label: 'IDLE UNITS',
                  value: widget.idleUnits.toString(),
                  color: widget.idleUnits > 0 ? colors.primary : Colors.white24,
                ),
                const _VerticalDivider(),
                _TelemetryBlock(
                  label: 'ACTIVE OPS',
                  value: widget.activeOps.toString(),
                  color: widget.activeOps > 0 ? colors.success : Colors.white24,
                ),
                const _VerticalDivider(),
                _TelemetryBlock(
                  label: 'SYS.STATUS',
                  value: 'NOMINAL',
                  color: colors.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Line 3: System Indicators
          Row(
            children: [
              _SystemIndicator(label: 'LOCAL.HUB', color: colors.primary),
              const SizedBox(width: 8),
              _SystemIndicator(label: 'CHB.01', color: colors.primary),
              const Spacer(),
              Text(
                'STB.98.4%',
                style: TextStyle(
                  fontFamily: 'Share Tech Mono',
                  fontSize: 10,
                  color: colors.success.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlowBreathingIcon extends StatelessWidget {
  final AppIconData icon;
  final Color color;

  const _GlowBreathingIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(child: AppIcon(icon, color: color, size: 18)),
    );
  }
}

class _TelemetryBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TelemetryBlock({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const theme = NeonTheme();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.typography.bodyMedium.copyWith(
            fontSize: 8,
            color: color.withValues(alpha: 0.6),
            letterSpacing: 1.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.typography.bodyMedium.copyWith(
            fontSize: 18,
            color: color,
            fontFamily: 'Share Tech Mono',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 20, color: Colors.white10);
  }
}

class _SystemIndicator extends StatelessWidget {
  final String label;
  final Color color;

  const _SystemIndicator({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Share Tech Mono',
          fontSize: 9,
          color: color.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _HudLaunchButton extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onTap;
  final Color color;

  const _HudLaunchButton({
    required this.label,
    required this.count,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final active = count > 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: active ? 0.2 : 0.05),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: color.withValues(alpha: active ? 0.6 : 0.2),
            width: 1.5,
          ),
          boxShadow: active
              ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8)]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 10,
                color: active ? Colors.white : Colors.white38,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            if (active) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
