import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/state/tech_provider.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/presentation/ui/widgets/neon_tech_card.dart';

/// Full Tech Screen - Neon Futuristic Themed
class TechScreen extends ConsumerWidget {
  const TechScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techs = ref.watch(currentEraTechsProvider);
    final gameState = ref.watch(gameStateProvider);
    const theme = NeonTheme();

    return Container(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(theme),

          const SizedBox(height: AppSpacing.md),

          // Tech List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                160,
              ),
              itemCount: techs.length,
              itemBuilder: (context, index) {
                final tech = techs[index];
                final nextCost = tech.nextCost;
                final canAfford =
                    nextCost > BigInt.zero &&
                    gameState.chronoEnergy >= nextCost;
                final isMaxed = nextCost < BigInt.zero;

                return NeonTechCard(
                  tech: tech,
                  canAfford: canAfford,
                  isMaxed: isMaxed,
                  onUpgrade: (canAfford && !isMaxed)
                      ? () => ref
                            .read(techProvider.notifier)
                            .purchaseUpgrade(tech.id)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(NeonTheme theme) {
    final colors = theme.colors;
    final typography = theme.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hex Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: colors.primary.withValues(alpha: 0.5)),
            ),
            child: Icon(Icons.memory, color: colors.primary, size: 20),
          ),
          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.white, colors.primary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: Text(
                    'TECH AUGMENTATION',
                    style: typography.titleLarge.copyWith(
                      fontFamily: 'Orbitron',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                Text(
                  'SYSTEM UPGRADES AVAILABLE',
                  style: typography.bodyMedium.copyWith(
                    fontSize: 10.0,
                    color: colors.primary.withValues(alpha: 0.7),
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),

          // Version Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color: colors.secondary.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'SYS.pV2',
              style: typography.bodyMedium.copyWith(
                fontSize: 9.0,
                color: colors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
