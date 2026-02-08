import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/presentation/ui/tabs/loop_chambers_tab.dart';
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

  Widget _buildHeader(int idleCount, dynamic theme, BigInt chronoEnergy) {
    final colors = theme.colors;
    final typography = theme.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          // Icon
          Icon(Icons.grid_view, color: colors.accent, size: 20),
          const SizedBox(width: 12),

          // Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LOOP', style: typography.titleLarge.copyWith(height: 1.0)),
              Text(
                'CHAMBERS',
                style: typography.titleLarge.copyWith(height: 1.0),
              ),
            ],
          ),

          const Spacer(),

          // Idle workers badge
          if (idleCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.2),
                border: Border.all(color: colors.accent.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, color: colors.accent, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '$idleCount IDLE',
                    style: typography.bodyMedium.copyWith(
                      fontSize: 10.0,
                      color: colors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // Version/Status (Replacing CE Indicator which is already in top bar usually, but keeping sticking to plan of matching TechScreen header structure.
          // TechScreen has "SYS.pV2". Chambers had CE. I will keep CE as it's useful here or switch to a status text if CE is global.
          // User said "use the tech layout as a example". Tech layout has a version number.
          // But Chambers screen needs CE visibility? Actually CE is usually in a top status bar in these games.
          // Let's stick to the visual style of TechScreen. TechScreen puts version there.
          // However, the previous Chambers screen had CE. I will perform a safe compromise:
          // I'll keep the CE indicator but style it like the version text or keep it as a badge if it fits the "Tech" aesthetic.
          // Actually, looking at the ASCII Mockup in GDD, CE is in the top Status Bar.
          // So the screen header might not need CE.
          // I will replace CE with a "SYS.ACTIVE" or similar status to match TechScreen's "SYS.pV2" aesthetic,
          // OR I will simply style the CE indicator to look better.
          // The request said "use the tech layout as a example".
          // Tech layout: Icon | Title/Subtitle | Spacer | Version
          // I will do: Icon | LOOP/CHAMBERS | Spacer | Idle Badge | SYS.LC1 (Loop Chambers 1)
          Text(
            'SYS.LC1',
            style: typography.bodyMedium.copyWith(
              fontSize: 10.0,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
