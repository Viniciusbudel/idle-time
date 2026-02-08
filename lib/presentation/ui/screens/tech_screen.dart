import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/domain/entities/tech_upgrade.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/state/tech_provider.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/presentation/ui/atoms/steampunk_button.dart';
import 'package:time_factory/presentation/ui/atoms/steampunk_card.dart';
import 'package:time_factory/presentation/ui/widgets/era_advance_button.dart';
import 'package:time_factory/core/constants/spacing.dart';

/// Full Tech Screen - Steampunk Themed
class TechScreen extends ConsumerWidget {
  const TechScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techs = ref.watch(currentEraTechsProvider);
    // Force Neon Theme
    final theme = const NeonTheme();

    return Container(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(theme),

          const SizedBox(height: AppSpacing.md),

          // Era Advance Button
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: EraAdvanceButton(),
          ),

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
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _TechAugmentCard(tech: tech),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic theme) {
    final colors = theme.colors;
    final typography = theme.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          // Icon
          Icon(Icons.settings, color: colors.accent, size: 20),
          const SizedBox(width: 12),

          // Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TECH', style: typography.titleLarge.copyWith(height: 1.0)),
              Text(
                'AUGMENTATION',
                style: typography.titleLarge.copyWith(height: 1.0),
              ),
            ],
          ),

          const Spacer(),

          // Version
          Text(
            'SYS.pV2',
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

class _TechAugmentCard extends ConsumerWidget {
  final TechUpgrade tech;

  const _TechAugmentCard({required this.tech});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final theme = const NeonTheme();
    final colors = theme.colors;
    final typography = theme.typography;

    final nextCost = tech.nextCost;
    final canAfford =
        nextCost > BigInt.zero && gameState.chronoEnergy >= nextCost;
    final isMaxed = nextCost < BigInt.zero;

    final icon = _getTechIcon(tech.type);

    return SteampunkCard(
      themeOverride: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Icon + Title + Level
          Row(
            children: [
              // Icon Box
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.2),
                  border: Border.all(color: colors.glassBorder),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, color: colors.primary, size: 24),
              ),

              const SizedBox(width: 12),

              // Title + Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tech.name,
                          style: typography.bodyMedium.copyWith(
                            fontSize: 16.0,
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        // Level Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colors.accent.withValues(alpha: 0.5),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isMaxed ? 'MAX' : 'LVL ${tech.level}',
                            style: typography.bodyMedium.copyWith(
                              fontSize: 10.0,
                              color: colors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tech.description,
                      style: typography.bodyMedium.copyWith(
                        fontSize: 11.0,
                        color: colors.textSecondary,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Liquid Tube Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: colors.glassBorder.withValues(alpha: 0.5),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Stack(
                children: [
                  // Liquid Fill
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (tech.level / tech.maxLevel).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colors.primary, colors.accent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Glass Reflection Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Row: Bonus + Upgrade Button
          Row(
            children: [
              // Current Bonus
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT EFFECT:',
                      style: typography.bodyMedium.copyWith(
                        fontSize: 9.0,
                        color: colors.textSecondary,
                      ),
                    ),
                    Text(
                      tech.bonusDescription,
                      style: typography.bodyMedium.copyWith(
                        fontSize: 11.0,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Upgrade Button
              SteampunkButton(
                themeOverride: theme,
                label: isMaxed ? 'MAXED' : 'UPGRADE',
                isDestructive: false,
                onPressed: (canAfford && !isMaxed)
                    ? () => ref
                          .read(techProvider.notifier)
                          .purchaseUpgrade(tech.id)
                    : null,
              ),
            ],
          ),

          if (!isMaxed && !canAfford)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'COST: ${NumberFormatter.formatCE(nextCost)} CE',
                  style: typography.bodyMedium.copyWith(
                    fontSize: 10.0,
                    color: colors.error,
                  ),
                ),
              ),
            )
          else if (!isMaxed && canAfford)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'COST: ${NumberFormatter.formatCE(nextCost)} CE',
                  style: typography.bodyMedium.copyWith(
                    fontSize: 10.0,
                    color: colors.success,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getTechIcon(TechType type) {
    switch (type) {
      case TechType.automation:
        return Icons.precision_manufacturing;
      case TechType.efficiency:
        return Icons.bolt;
      case TechType.timeWarp:
        return Icons.shutter_speed;
      case TechType.costReduction:
        return Icons.price_change;
      case TechType.offline:
        return Icons.bedtime;
      case TechType.clickPower:
        return Icons.touch_app;
      case TechType.eraUnlock:
        return Icons.vpn_key;
    }
  }
}
