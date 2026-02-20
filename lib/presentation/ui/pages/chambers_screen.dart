import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/presentation/ui/pages/loop_chambers_tab.dart';
import 'package:time_factory/core/constants/spacing.dart';

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

    return Container(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(idleCount, theme, gameState.chronoEnergy),

          const SizedBox(height: AppSpacing.md),

          // Station list (High-Fidelity Steampunk UI)
          const Expanded(child: LoopChambersTab()),
        ],
      ),
    );
  }

  Widget _buildHeader(int idleCount, NeonTheme theme, BigInt chronoEnergy) {
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
            child: Icon(Icons.grid_view, color: colors.primary, size: 28),
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
                      color: colors.primary.withOpacity( 0.7),
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
                      color: colors.primary.withOpacity( 0.7),
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
              // Idle workers badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity( 0.1),
                  border: Border.all(
                    color: colors.primary.withOpacity( 0.5),
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withOpacity( 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, color: colors.primary, size: 14),
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
                  color: colors.primary.withOpacity( 0.6),
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
