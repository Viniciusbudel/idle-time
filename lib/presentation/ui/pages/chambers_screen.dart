import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
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
        vertical: 8.0,
      ),
      child: Row(
        children: [
          // Icon Button (Menu/Grid)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              // hover effect simulation could go here
            ),
            child: AppIcon(
              AppHugeIcons.grid_view,
              color: colors.primary,
              size: 28,
            ),
          ),

          const SizedBox(width: 8),

          // Title with Glow
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LOOP',
                style: typography.titleLarge.copyWith(
                  height: 1.0,
                  fontSize: 24,
                  color: colors.primary,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      color: colors.primary.withValues(alpha: 0.7),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              Text(
                'CHAMBERS',
                style: typography.titleLarge.copyWith(
                  height: 1.0,
                  fontSize: 24,
                  color: colors.primary,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      color: colors.primary.withValues(alpha: 0.7),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ExpeditionsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        colors.secondary.withValues(alpha: 0.24),
                        colors.primary.withValues(alpha: 0.12),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: readyExpeditions > 0
                          ? colors.success
                          : colors.secondary.withValues(alpha: 0.8),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: colors.secondary.withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(
                            AppHugeIcons.rocket_launch,
                            color: colors.secondary,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'EXPEDITIONS',
                            style: typography.bodyMedium.copyWith(
                              fontSize: 10,
                              color: colors.secondary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          if (readyExpeditions > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.success.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(color: colors.success),
                              ),
                              child: Text(
                                '$readyExpeditions READY',
                                style: typography.bodyMedium.copyWith(
                                  fontSize: 8,
                                  color: colors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Active runs: $activeExpeditions',
                        style: typography.bodyMedium.copyWith(
                          fontSize: 9,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Idle workers badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon(
                      AppHugeIcons.person,
                      color: colors.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$idleCount IDLE',
                      style: typography.bodyMedium.copyWith(
                        fontSize: 12.0,
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Version/System Tag
              Text(
                'SYS.LC1',
                style: typography.bodyMedium.copyWith(
                  fontSize: 10.0,
                  color: colors.primary.withValues(alpha: 0.6),
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
