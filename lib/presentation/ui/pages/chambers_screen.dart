import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/core/theme/game_theme.dart';
import 'package:time_factory/presentation/ui/pages/loop_chambers_tab.dart';
import 'package:time_factory/presentation/ui/pages/expeditions_screen.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/ui/app_icons.dart';

/// Chambers Screen - Steampunk Themed
class ChambersScreen extends ConsumerStatefulWidget {
  const ChambersScreen({super.key});

  @override
  ConsumerState<ChambersScreen> createState() => _ChambersScreenState();
}

class _ChambersScreenState extends ConsumerState<ChambersScreen> {
  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    // Use Neon Theme explicitly
    final theme = const NeonTheme();

    final allWorkers = gameState.workers.values.toList();
    final idleCount = allWorkers.where((w) => !w.isDeployed).length;
    final activeExpeditions = gameState.expeditions
        .where((expedition) => !expedition.resolved)
        .length;
    final readyExpeditions = gameState.expeditions
        .where((expedition) => expedition.resolved)
        .length;

    return Container(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(
            context,
            idleCount,
            theme,
            activeExpeditions,
            readyExpeditions,
          ),

          const SizedBox(height: AppSpacing.md),

          // Station list (High-Fidelity Steampunk UI)
          const Expanded(child: LoopChambersTab()),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    int idleCount,
    NeonTheme theme,
    int activeExpeditions,
    int readyExpeditions,
  ) {
    final colors = theme.colors;
    final typography = theme.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 620;

          return Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.primary.withValues(alpha: 0.28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (compact) ...[
                  _buildTitleBlock(theme),
                  const SizedBox(height: AppSpacing.sm),
                  _buildExpeditionAction(
                    context,
                    theme,
                    activeExpeditions,
                    readyExpeditions,
                    expanded: true,
                  ),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildTitleBlock(theme)),
                      const SizedBox(width: AppSpacing.sm),
                      _buildExpeditionAction(
                        context,
                        theme,
                        activeExpeditions,
                        readyExpeditions,
                      ),
                    ],
                  ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _buildStatusChip(
                      icon: AppHugeIcons.person,
                      label: '$idleCount IDLE',
                      color: colors.primary,
                      typography: typography,
                    ),
                    _buildStatusChip(
                      icon: AppHugeIcons.rocket_launch,
                      label: '$activeExpeditions ACTIVE',
                      color: colors.secondary,
                      typography: typography,
                    ),
                    if (readyExpeditions > 0)
                      _buildStatusChip(
                        icon: AppHugeIcons.check_circle,
                        label: '$readyExpeditions READY',
                        color: colors.success,
                        typography: typography,
                      ),
                    _buildStatusChip(
                      icon: AppHugeIcons.shield,
                      label: 'SYS.LC1',
                      color: colors.accent,
                      typography: typography,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleBlock(NeonTheme theme) {
    final colors = theme.colors;
    final typography = theme.typography;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.primary.withValues(alpha: 0.24)),
            color: colors.primary.withValues(alpha: 0.08),
          ),
          child: AppIcon(
            AppHugeIcons.grid_view,
            color: colors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LOOP',
                style: typography.bodyMedium.copyWith(
                  fontSize: 11,
                  color: colors.primary.withValues(alpha: 0.75),
                  letterSpacing: 2.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'CHAMBER',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.titleLarge.copyWith(
                  height: 1.0,
                  fontSize: 24,
                  color: colors.primary,
                  letterSpacing: 1.8,
                  shadows: [
                    Shadow(
                      color: colors.primary.withValues(alpha: 0.55),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpeditionAction(
    BuildContext context,
    NeonTheme theme,
    int activeExpeditions,
    int readyExpeditions, {
    bool expanded = false,
  }) {
    final colors = theme.colors;
    final typography = theme.typography;

    final Widget button = SizedBox(
      width: expanded ? double.infinity : null,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          side: BorderSide(
            color: readyExpeditions > 0
                ? colors.success
                : colors.secondary.withValues(alpha: 0.72),
          ),
          backgroundColor: colors.secondary.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ExpeditionsScreen()));
        },
        child: Row(
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            AppIcon(
              AppHugeIcons.rocket_launch,
              color: colors.secondary,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'EXPEDITIONS',
              style: typography.bodyMedium.copyWith(
                fontSize: 11,
                color: colors.secondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '$activeExpeditions ACTIVE',
              style: typography.bodyMedium.copyWith(
                fontSize: 10,
                color: Colors.white70,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            if (readyExpeditions > 0) ...[
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.success.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: colors.success),
                ),
                child: Text(
                  '$readyExpeditions READY',
                  style: typography.bodyMedium.copyWith(
                    fontSize: 9,
                    color: colors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return Semantics(button: true, label: 'Open expeditions', child: button);
  }

  Widget _buildStatusChip({
    required AppIconData icon,
    required String label,
    required Color color,
    required ThemeTypography typography,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon, color: color, size: 12),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: typography.bodyMedium.copyWith(
              fontSize: 10,
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
